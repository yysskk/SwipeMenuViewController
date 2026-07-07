import UIKit

// MARK: - TabViewDelegate

/// A main-actor-isolated protocol that responds to ``TabView`` selection events.
///
/// Both methods are optional; default no-op implementations are provided through a protocol
/// extension. Because the protocol is `@MainActor`-isolated, every method is called on the main actor.
@MainActor public protocol TabViewDelegate: AnyObject {

    /// Called before a tab is selected by a tap.
    /// - Parameters:
    ///   - tabView: The tab view whose tab is about to be selected.
    ///   - index: The index of the tab that will be selected.
    func tabView(_ tabView: TabView, willSelectTabAt index: Int)

    /// Called after a tab is selected by a tap.
    /// - Parameters:
    ///   - tabView: The tab view whose tab was selected.
    ///   - index: The index of the selected tab.
    func tabView(_ tabView: TabView, didSelectTabAt index: Int)
}

extension TabViewDelegate {
    public func tabView(_ tabView: TabView, willSelectTabAt index: Int) {}

    public func tabView(_ tabView: TabView, didSelectTabAt index: Int) {}
}

// MARK: - TabViewDataSource

/// A main-actor-isolated protocol that provides items and titles to a ``TabView``.
///
/// Because the protocol is `@MainActor`-isolated, every method is called on the main actor.
@MainActor public protocol TabViewDataSource: AnyObject {

    /// Returns the number of tab items.
    /// - Parameter tabView: The tab view requesting the count.
    /// - Returns: The total number of items.
    func numberOfItems(in tabView: TabView) -> Int

    /// Returns the title displayed in the tab item at the given index.
    /// - Parameters:
    ///   - tabView: The tab view requesting the title.
    ///   - index: The index of the item.
    /// - Returns: The title for the item, or `nil` for no title.
    func tabView(_ tabView: TabView, titleForItemAt index: Int) -> String?
}

/// The scrollable tab bar displayed at the top of a ``SwipeMenuView``.
///
/// A `TabView` lays out one tab item per page and draws the selection addition
/// (underline or circle) configured by ``SwipeMenuViewOptions/TabView``. It is created and
/// managed by ``SwipeMenuView``; you normally configure it through the options rather than
/// instantiating it directly.
open class TabView: UIScrollView {

    /// The delegate that receives tab selection events.
    open weak var tabViewDelegate: TabViewDelegate?

    /// The data source that provides the tab items and their titles.
    open weak var dataSource: TabViewDataSource?

    var itemViews: [TabItemView] = []

    fileprivate let containerView: UIStackView = UIStackView()

    fileprivate var additionView: UIView = .init()

    fileprivate var currentIndex: Int = 0

    fileprivate(set) var options: SwipeMenuViewOptions.TabView = SwipeMenuViewOptions.TabView()

    private var leftMarginConstraint: NSLayoutConstraint = .init()
    private var widthConstraint: NSLayoutConstraint = .init()

    public init(frame: CGRect, options: SwipeMenuViewOptions.TabView? = nil) {
        super.init(frame: frame)

        if let options {
            self.options = options
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        // Skip the rebuild when the view is being removed (superview is nil).
        guard superview != nil else { return }
        reloadData()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        resetAdditionViewPosition(index: currentIndex)
    }

    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()

        // Respect `isSafeAreaEnabled`: when safe-area layout is turned off, a
        // safe-area change (rotation, a notch coming into play) must not shift
        // the tab bar by the inset. The initial layout already positioned the
        // container without the inset, so leave the constraints untouched.
        guard options.isSafeAreaEnabled else { return }

        leftMarginConstraint.constant = options.margin + safeAreaInsets.left
        if options.style == .segmented {
            widthConstraint.constant = options.margin * -2 - safeAreaInsets.left - safeAreaInsets.right
        }

        layoutIfNeeded()
    }

    fileprivate func focus(on target: UIView, animated: Bool = true) {

        if options.style == .segmented { return }

        let offset: CGFloat
        let contentWidth: CGFloat

        if options.isSafeAreaEnabled {
            offset = target.center.x + options.margin + safeAreaInsets.left - self.frame.width / 2
            contentWidth = containerView.frame.width + options.margin * 2 + safeAreaInsets.left + safeAreaInsets.right
        } else {
            offset = target.center.x + options.margin - self.frame.width / 2
            contentWidth = containerView.frame.width + options.margin * 2
        }

        if offset < 0 || self.frame.width > contentWidth {
            self.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
        } else if contentWidth - self.frame.width < offset {
            self.setContentOffset(CGPoint(x: contentWidth - self.frame.width, y: 0), animated: animated)
        } else {
            self.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
        }
    }

    // MARK: - Setup

    /// Rebuilds all tab items from the data source and refreshes the display.
    /// - Parameters:
    ///   - options: New tab options to apply before reloading. Pass `nil` to keep the current options.
    ///   - defaultIndex: The tab to select after reloading. Pass `nil` to leave the selection unchanged.
    ///   - animated: Whether moving to `defaultIndex` is animated. Defaults to `true`.
    public func reloadData(options: SwipeMenuViewOptions.TabView? = nil,
                           default defaultIndex: Int? = nil,
                           animated: Bool = true) {

        if let options {
            self.options = options
        }

        reset()

        guard let dataSource,
            dataSource.numberOfItems(in: self) > 0 else { return }

        setupScrollView()
        setupContainerView(dataSource: dataSource)
        setupTabItemViews(dataSource: dataSource)
        setupAdditionView()

        if let defaultIndex {
            moveTabItem(index: defaultIndex, animated: animated)
        }
    }

    func reset() {
        currentIndex = 0
        itemViews.forEach { $0.removeFromSuperview() }
        additionView.removeFromSuperview()
        containerView.removeFromSuperview()
        itemViews = []
    }

    func update(_ index: Int) {

        if currentIndex == index { return }

        currentIndex = index
        updateSelectedItem(by: currentIndex)
    }

    fileprivate func setupScrollView() {
        backgroundColor = options.backgroundColor
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = true
        isDirectionalLockEnabled = true
        alwaysBounceHorizontal = false
        scrollsToTop = false
        bouncesZoom = false
        translatesAutoresizingMaskIntoConstraints = false
    }

    fileprivate func setupContainerView(dataSource: TabViewDataSource) {

        containerView.alignment = .leading

        switch options.style {
        case .flexible:
            containerView.distribution = .fill
        case .segmented:
            containerView.distribution = .fillEqually
        }

        let itemCount = dataSource.numberOfItems(in: self)
        var containerHeight: CGFloat = 0.0

        switch options.addition {
        case .underline:
            containerHeight = frame.height - options.additionView.underline.height - options.additionView.padding.bottom
        case .none, .circle:
            containerHeight = frame.height
        }

        switch options.style {
        case .flexible:
            let containerWidth = options.itemView.width * CGFloat(itemCount)
            if options.isSafeAreaEnabled {
                contentSize = CGSize(width: containerWidth + options.margin * 2 + safeAreaInsets.left + safeAreaInsets.right, height: options.height)
                containerView.frame = CGRect(x: 0, y: options.margin + safeAreaInsets.left, width: containerWidth, height: containerHeight)
            } else {
                contentSize = CGSize(width: containerWidth + options.margin * 2, height: options.height)
                containerView.frame = CGRect(x: 0, y: options.margin, width: containerWidth, height: containerHeight)
            }
        case .segmented:
            if options.isSafeAreaEnabled {
                contentSize = CGSize(width: frame.width, height: options.height)
                containerView .frame = CGRect(x: 0, y: options.margin + safeAreaInsets.left, width: frame.width - options.margin * 2 - safeAreaInsets.left - safeAreaInsets.right, height: containerHeight)
            } else {
                contentSize = CGSize(width: frame.width, height: options.height)
                containerView .frame = CGRect(x: 0, y: options.margin, width: frame.width - options.margin * 2, height: containerHeight)
            }
        }

        containerView.backgroundColor = .clear
        addSubview(containerView)
    }

    fileprivate func setupTabItemViews(dataSource: TabViewDataSource) {

        itemViews = []

        let itemCount = dataSource.numberOfItems(in: self)

        var xPosition: CGFloat = 0

        for index in 0..<itemCount {
            let tabItemView = TabItemView(frame: CGRect(x: xPosition, y: 0, width: options.itemView.width, height: containerView.frame.size.height))
            tabItemView.translatesAutoresizingMaskIntoConstraints = false
            tabItemView.clipsToBounds = options.clipsToBounds
            if let title = dataSource.tabView(self, titleForItemAt: index) {
                tabItemView.titleLabel.text = title
                tabItemView.titleLabel.numberOfLines = options.itemView.numberOfLines
                tabItemView.font = options.itemView.font
                tabItemView.selectedFont = options.itemView.selectedFont
                tabItemView.textColor = options.itemView.textColor
                tabItemView.selectedTextColor = options.itemView.selectedTextColor
            }

            switch options.style {
            case .flexible:
                if options.needsAdjustItemViewWidth {
                    var adjustCellSize = tabItemView.frame.size
                    adjustCellSize.width = tabItemView.titleLabel.sizeThatFits(containerView.frame.size).width + options.itemView.margin * 2
                    tabItemView.frame.size = adjustCellSize

                    containerView.addArrangedSubview(tabItemView)

                    NSLayoutConstraint.activate([
                        tabItemView.widthAnchor.constraint(equalToConstant: adjustCellSize.width)
                        ])
                } else {
                    containerView.addArrangedSubview(tabItemView)

                    NSLayoutConstraint.activate([
                        tabItemView.widthAnchor.constraint(equalToConstant: options.itemView.width)
                        ])
                }
            case .segmented:
                let adjustCellSize: CGSize
                if options.isSafeAreaEnabled {
                    adjustCellSize = CGSize(width: (frame.width - options.margin * 2 - safeAreaInsets.left - safeAreaInsets.right) / CGFloat(itemCount), height: tabItemView.frame.size.height)
                } else {
                    adjustCellSize = CGSize(width: (frame.width - options.margin * 2) / CGFloat(itemCount), height: tabItemView.frame.size.height)
                }
                tabItemView.frame.size = adjustCellSize

                containerView.addArrangedSubview(tabItemView)
            }

            // Apply selection after the width calc above so each item is measured
            // with `font`. Setting `isSelected` swaps in `selectedFont`, which must
            // not influence layout.
            tabItemView.isSelected = index == currentIndex

            itemViews.append(tabItemView)

            NSLayoutConstraint.activate([
                tabItemView.topAnchor.constraint(equalTo: containerView.topAnchor),
                tabItemView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                ])

            xPosition += tabItemView.frame.size.width
        }

        layout(containerView: containerView, containerWidth: xPosition)
        addTabItemGestures()
        animateAdditionView(index: currentIndex, animated: false)
    }

    private func layout(containerView: UIView, containerWidth: CGFloat) {

        containerView.frame.size.width = containerWidth
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint: NSLayoutConstraint
        switch options.addition {
        case .underline:
            heightConstraint = containerView.heightAnchor.constraint(equalToConstant: options.height - options.additionView.underline.height - options.additionView.padding.bottom)
        case .circle, .none:
            heightConstraint = containerView.heightAnchor.constraint(equalToConstant: options.height)
        }

        switch options.style {
        case .flexible:
            if options.isSafeAreaEnabled {
                leftMarginConstraint = containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: options.margin + safeAreaInsets.left)

                NSLayoutConstraint.activate([
                    containerView.topAnchor.constraint(equalTo: self.topAnchor),
                    leftMarginConstraint,
                    containerView.widthAnchor.constraint(equalToConstant: containerWidth),
                    heightConstraint
                    ])
                contentSize.width = containerWidth + options.margin * 2 + safeAreaInsets.left - safeAreaInsets.right
            } else {
                leftMarginConstraint = containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: options.margin)
                NSLayoutConstraint.activate([
                    containerView.topAnchor.constraint(equalTo: self.topAnchor),
                    leftMarginConstraint,
                    containerView.widthAnchor.constraint(equalToConstant: containerWidth),
                    heightConstraint
                    ])
                contentSize.width = containerWidth + options.margin * 2
            }
        case .segmented:
            if options.isSafeAreaEnabled {
                leftMarginConstraint = containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: options.margin + safeAreaInsets.left)
                widthConstraint = containerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: options.margin * -2 - safeAreaInsets.left - safeAreaInsets.right)
                NSLayoutConstraint.activate([
                    containerView.topAnchor.constraint(equalTo: self.topAnchor),
                    leftMarginConstraint,
                    widthConstraint,
                    heightConstraint
                    ])
            } else {
                leftMarginConstraint = containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: options.margin)
                widthConstraint = containerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: options.margin * -2)
                NSLayoutConstraint.activate([
                    containerView.topAnchor.constraint(equalTo: self.topAnchor),
                    leftMarginConstraint,
                    widthConstraint,
                    heightConstraint
                    ])
            }

            contentSize = .zero
        }
    }

    private func updateSelectedItem(by newIndex: Int) {
        for (i, itemView) in itemViews.enumerated() {
            itemView.isSelected = i == newIndex
        }
    }
}

// MARK: - AdditionView

extension TabView {

    /// The direction in which the selection addition moves as the content scrolls.
    public nonisolated enum Direction: Sendable {
        /// Moving toward a higher page index (scrolling forward).
        case forward
        /// Moving toward a lower page index (scrolling in reverse).
        case reverse
    }

    fileprivate func setupAdditionView() {
        if itemViews.isEmpty { return }

        switch options.addition {
        case .underline:
            let itemView = itemViews[currentIndex]
            additionView = UIView(frame: CGRect(x: itemView.frame.origin.x + options.additionView.padding.left, y: itemView.frame.height - options.additionView.padding.vertical, width: itemView.frame.width - options.additionView.padding.horizontal, height: options.additionView.underline.height))
            additionView.layer.cornerRadius = options.additionView.underline.cornerRadius
            additionView.backgroundColor = options.additionView.backgroundColor
            containerView.addSubview(additionView)
        case .circle:
            let itemView = itemViews[currentIndex]
            let height = itemView.bounds.height - options.additionView.padding.vertical
            additionView = UIView(frame: CGRect(x: itemView.frame.origin.x + options.additionView.padding.left, y: 0, width: itemView.frame.width - options.additionView.padding.horizontal, height: height))
            additionView.layer.position.y = itemView.layer.position.y
            additionView.layer.cornerRadius = options.additionView.circle.cornerRadius ?? additionView.frame.height / 2
            additionView.backgroundColor = options.additionView.backgroundColor
            
            if let m = options.additionView.circle.maskedCorners {
                additionView.layer.maskedCorners = m
            }

            containerView.addSubview(additionView)
            containerView.sendSubviewToBack(additionView)
        case .none:
            additionView.backgroundColor = .clear
        }

        jump(to: currentIndex)
    }

    private func updateAdditionViewPosition(index: Int) {
        guard let target = currentItem else { return }

        additionView.frame.origin.x = target.frame.origin.x + options.additionView.padding.left

        if options.needsAdjustItemViewWidth {
            let cellWidth = itemViews[index].frame.width
            additionView.frame.size.width = cellWidth - options.additionView.padding.horizontal
        }

        focus(on: target)
    }

    fileprivate func resetAdditionViewPosition(index: Int) {
        guard options.style == .segmented,
            let dataSource,
            dataSource.numberOfItems(in: self) > 0 else { return }

        // Each `.segmented` tab item spans the full (unadjusted) cell width, so
        // that width is the indicator's per-tab stride. The indicator itself is
        // inset by the horizontal padding. Using the padding-adjusted width as the
        // stride would drift the indicator left by `index * padding.horizontal`.
        let cellWidth: CGFloat
        if options.isSafeAreaEnabled && safeAreaInsets != .zero {
            cellWidth = (frame.width - options.margin * 2 - safeAreaInsets.left - safeAreaInsets.right) / CGFloat(dataSource.numberOfItems(in: self))
        } else {
            cellWidth = (frame.width - options.margin * 2) / CGFloat(dataSource.numberOfItems(in: self))
        }

        additionView.frame.origin.x = cellWidth * CGFloat(index) + options.additionView.padding.left
        additionView.frame.size.width = cellWidth - options.additionView.padding.horizontal
    }

    fileprivate func animateAdditionView(index: Int, animated: Bool, completion: ((Bool) -> Swift.Void)? = nil) {

        update(index)

        if animated {
            UIView.animate(withDuration: options.additionView.animationDuration, animations: {
                self.updateAdditionViewPosition(index: index)
            }, completion: completion)
        } else {
            updateAdditionViewPosition(index: index)
        }
    }

    func moveAdditionView(index: Int, ratio: CGFloat, direction: Direction) {

        update(index)

        guard let currentItem else { return }

        if options.additionView.isAnimationOnSwipeEnable {
            switch direction {
            case .forward:
                if let nextItem {
                    additionView.frame.origin.x = currentItem.frame.origin.x + (nextItem.frame.origin.x - currentItem.frame.origin.x) * ratio + options.additionView.padding.left
                    additionView.frame.size.width = currentItem.frame.size.width + (nextItem.frame.size.width - currentItem.frame.size.width) * ratio - options.additionView.padding.horizontal
                    if options.needsConvertTextColorRatio {
                        nextItem.titleLabel.textColor = options.itemView.textColor.convert(to: options.itemView.selectedTextColor, multiplier: ratio)
                        currentItem.titleLabel.textColor = options.itemView.selectedTextColor.convert(to: options.itemView.textColor, multiplier: ratio)
                    }
                }
            case .reverse:
                if let previousItem {
                    additionView.frame.origin.x = previousItem.frame.origin.x + (currentItem.frame.origin.x - previousItem.frame.origin.x) * ratio + options.additionView.padding.left
                    additionView.frame.size.width = previousItem.frame.size.width + (currentItem.frame.size.width - previousItem.frame.size.width) * ratio - options.additionView.padding.horizontal
                    if options.needsConvertTextColorRatio {
                        previousItem.titleLabel.textColor = options.itemView.selectedTextColor.convert(to: options.itemView.textColor, multiplier: ratio)
                        currentItem.titleLabel.textColor = options.itemView.textColor.convert(to: options.itemView.selectedTextColor, multiplier: ratio)
                    }
                }
            }
        } else {
            moveTabItem(index: index, animated: true)
        }

        if options.itemView.selectedTextColor.convert(to: options.itemView.textColor, multiplier: ratio) == nil {
            updateSelectedItem(by: currentIndex)
        }

        focus(on: additionView, animated: false)
    }
}

extension TabView {
    var currentItem: TabItemView? {
        return currentIndex < itemViews.count ? itemViews[currentIndex] : nil
    }

    var nextItem: TabItemView? {
        guard currentIndex < itemViews.count - 1 else { return nil }
        return itemViews[currentIndex + 1]
    }

    var previousItem: TabItemView? {
        guard currentIndex > 0 else { return nil }
        return itemViews[currentIndex - 1]
    }

    func jump(to index: Int) {
        update(index)

        guard let currentItem else { return }

        if options.addition == .underline {
            additionView.frame.origin.x = currentItem.frame.origin.x + options.additionView.padding.left
            additionView.frame.size.width = currentItem.frame.size.width - options.additionView.padding.horizontal
        }

        focus(on: currentItem, animated: false)
    }
}

// MARK: - GestureRecognizer

extension TabView {

    fileprivate var tapGestureRecognizer: UITapGestureRecognizer {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapItemView(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.cancelsTouchesInView = false
        return gestureRecognizer
    }

    fileprivate func addTabItemGestures() {
        itemViews.forEach {
            $0.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    @objc func tapItemView(_ recognizer: UITapGestureRecognizer) {
        guard let itemView = recognizer.view as? TabItemView,
            let index: Int = itemViews.firstIndex(of: itemView),
            currentIndex != index else { return }
        tabViewDelegate?.tabView(self, willSelectTabAt: index)
        moveTabItem(index: index, animated: true)
        update(index)
        tabViewDelegate?.tabView(self, didSelectTabAt: index)
    }

    private func moveTabItem(index: Int, animated: Bool) {

        switch options.addition {
        case .underline, .circle:
            animateAdditionView(index: index, animated: animated, completion: nil)
        case .none:
            update(index)
        }
    }
}


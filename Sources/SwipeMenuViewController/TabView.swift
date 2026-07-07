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
/// A `TabView` lays out one tab item per page and draws the selection indicator
/// (underline or circle) configured by ``SwipeMenuViewOptions/TabView``. It is created and
/// managed by ``SwipeMenuView``; you normally configure it through the options rather than
/// instantiating it directly.
open class TabView: UIScrollView {

    /// The delegate that receives tab selection events.
    open weak var tabViewDelegate: TabViewDelegate?

    /// The data source that provides the tab items and their titles.
    open weak var dataSource: TabViewDataSource?

    var itemViews: [TabItemView] = []

    private let containerView = UIStackView()

    private var indicatorView = UIView()

    private var currentIndex: Int = 0

    private(set) var options: SwipeMenuViewOptions.TabView = SwipeMenuViewOptions.TabView()

    private var leftMarginConstraint: NSLayoutConstraint = .init()
    private var widthConstraint: NSLayoutConstraint = .init()

    /// The safe-area insets the layout honors: the view's real insets when
    /// safe-area layout is enabled through the options, `.zero` otherwise.
    private var layoutSafeAreaInsets: UIEdgeInsets {
        return options.isSafeAreaEnabled ? safeAreaInsets : .zero
    }

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
        resetIndicatorViewPosition(index: currentIndex)
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
            widthConstraint.constant = -(options.margin * 2 + safeAreaInsets.left + safeAreaInsets.right)
        }

        layoutIfNeeded()
    }

    private func focus(on target: UIView, animated: Bool = true) {

        if options.style == .segmented { return }

        let inset = layoutSafeAreaInsets
        let offset = target.center.x + options.margin + inset.left - self.frame.width / 2
        let contentWidth = containerView.frame.width + options.margin * 2 + inset.horizontal

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
        setupIndicatorView()

        if let defaultIndex {
            moveTabItem(index: defaultIndex, animated: animated)
        }
    }

    func reset() {
        currentIndex = 0
        itemViews.forEach { $0.removeFromSuperview() }
        indicatorView.removeFromSuperview()
        containerView.removeFromSuperview()
        itemViews = []
    }

    func update(_ index: Int) {

        if currentIndex == index { return }

        currentIndex = index
        updateSelectedItem(by: currentIndex)
    }

    private func setupScrollView() {
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

    private func setupContainerView(dataSource: TabViewDataSource) {

        containerView.alignment = .leading

        switch options.style {
        case .flexible:
            containerView.distribution = .fill
        case .segmented:
            containerView.distribution = .fillEqually
        }

        let itemCount = dataSource.numberOfItems(in: self)
        var containerHeight: CGFloat = 0.0

        switch options.indicator {
        case .underline:
            containerHeight = frame.height - options.indicatorView.underline.height - options.indicatorView.padding.bottom
        case .none, .circle:
            containerHeight = frame.height
        }

        // The container frame is provisional: layout(containerView:containerWidth:)
        // replaces it with constraints. Its size still matters before that pass,
        // because the item views measure themselves against it.
        let inset = layoutSafeAreaInsets

        switch options.style {
        case .flexible:
            let containerWidth = options.itemView.width * CGFloat(itemCount)
            contentSize = CGSize(width: containerWidth + options.margin * 2 + inset.horizontal, height: options.height)
            containerView.frame = CGRect(x: 0, y: options.margin, width: containerWidth, height: containerHeight)
        case .segmented:
            contentSize = CGSize(width: frame.width, height: options.height)
            containerView.frame = CGRect(x: 0, y: options.margin, width: frame.width - options.margin * 2 - inset.horizontal, height: containerHeight)
        }

        containerView.backgroundColor = .clear
        addSubview(containerView)
    }

    private func setupTabItemViews(dataSource: TabViewDataSource) {

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
                if options.adjustsItemViewWidth {
                    tabItemView.frame.size.width = tabItemView.titleLabel.sizeThatFits(containerView.frame.size).width + options.itemView.margin * 2
                }

                containerView.addArrangedSubview(tabItemView)

                NSLayoutConstraint.activate([
                    tabItemView.widthAnchor.constraint(equalToConstant: tabItemView.frame.width)
                    ])
            case .segmented:
                let inset = layoutSafeAreaInsets
                tabItemView.frame.size.width = (frame.width - options.margin * 2 - inset.horizontal) / CGFloat(itemCount)

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
        animateIndicatorView(index: currentIndex, animated: false)
    }

    private func layout(containerView: UIView, containerWidth: CGFloat) {

        containerView.frame.size.width = containerWidth
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let heightConstraint: NSLayoutConstraint
        switch options.indicator {
        case .underline:
            let height = options.height - options.indicatorView.underline.height - options.indicatorView.padding.bottom
            heightConstraint = containerView.heightAnchor.constraint(equalToConstant: height)
        case .circle, .none:
            heightConstraint = containerView.heightAnchor.constraint(equalToConstant: options.height)
        }

        let inset = layoutSafeAreaInsets
        leftMarginConstraint = containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: options.margin + inset.left)

        switch options.style {
        case .flexible:
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: self.topAnchor),
                leftMarginConstraint,
                containerView.widthAnchor.constraint(equalToConstant: containerWidth),
                heightConstraint
                ])
            contentSize.width = containerWidth + options.margin * 2 + inset.horizontal
        case .segmented:
            widthConstraint = containerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -(options.margin * 2 + inset.horizontal))
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: self.topAnchor),
                leftMarginConstraint,
                widthConstraint,
                heightConstraint
                ])

            contentSize = .zero
        }
    }

    private func updateSelectedItem(by newIndex: Int) {
        for (index, itemView) in itemViews.enumerated() {
            itemView.isSelected = index == newIndex
        }
    }
}

// MARK: - IndicatorView

extension TabView {

    /// The direction in which the selection indicator moves as the content scrolls.
    public nonisolated enum Direction: Sendable {
        /// Moving toward a higher page index (scrolling forward).
        case forward
        /// Moving toward a lower page index (scrolling in reverse).
        case reverse
    }

    private func setupIndicatorView() {
        if itemViews.isEmpty { return }

        switch options.indicator {
        case .underline:
            let itemView = itemViews[currentIndex]
            let padding = options.indicatorView.padding
            indicatorView = UIView(frame: CGRect(x: itemView.frame.origin.x + padding.left,
                                                 y: itemView.frame.height - padding.vertical,
                                                 width: itemView.frame.width - padding.horizontal,
                                                 height: options.indicatorView.underline.height))
            indicatorView.layer.cornerRadius = options.indicatorView.underline.cornerRadius
            indicatorView.backgroundColor = options.indicatorView.backgroundColor
            containerView.addSubview(indicatorView)
        case .circle:
            let itemView = itemViews[currentIndex]
            let padding = options.indicatorView.padding
            indicatorView = UIView(frame: CGRect(x: itemView.frame.origin.x + padding.left,
                                                 y: 0,
                                                 width: itemView.frame.width - padding.horizontal,
                                                 height: itemView.bounds.height - padding.vertical))
            indicatorView.layer.position.y = itemView.layer.position.y
            indicatorView.layer.cornerRadius = options.indicatorView.circle.cornerRadius ?? indicatorView.frame.height / 2
            indicatorView.backgroundColor = options.indicatorView.backgroundColor

            if let maskedCorners = options.indicatorView.circle.maskedCorners {
                indicatorView.layer.maskedCorners = maskedCorners
            }

            containerView.addSubview(indicatorView)
            containerView.sendSubviewToBack(indicatorView)
        case .none:
            indicatorView.backgroundColor = .clear
        }

        jump(to: currentIndex)
    }

    private func updateIndicatorViewPosition(index: Int) {
        guard let target = currentItem else { return }

        indicatorView.frame.origin.x = target.frame.origin.x + options.indicatorView.padding.left

        if options.adjustsItemViewWidth {
            let cellWidth = itemViews[index].frame.width
            indicatorView.frame.size.width = cellWidth - options.indicatorView.padding.horizontal
        }

        focus(on: target)
    }

    private func resetIndicatorViewPosition(index: Int) {
        guard options.style == .segmented,
            let dataSource,
            dataSource.numberOfItems(in: self) > 0 else { return }

        // Each `.segmented` tab item spans the full (unadjusted) cell width, so
        // that width is the indicator's per-tab stride. The indicator itself is
        // inset by the horizontal padding. Using the padding-adjusted width as the
        // stride would drift the indicator left by `index * padding.horizontal`.
        let inset = layoutSafeAreaInsets
        let cellWidth = (frame.width - options.margin * 2 - inset.horizontal) / CGFloat(dataSource.numberOfItems(in: self))

        indicatorView.frame.origin.x = cellWidth * CGFloat(index) + options.indicatorView.padding.left
        indicatorView.frame.size.width = cellWidth - options.indicatorView.padding.horizontal
    }

    private func animateIndicatorView(index: Int, animated: Bool, completion: ((Bool) -> Void)? = nil) {

        update(index)

        if animated {
            UIView.animate(withDuration: options.indicatorView.animationDuration, animations: {
                self.updateIndicatorViewPosition(index: index)
            }, completion: completion)
        } else {
            updateIndicatorViewPosition(index: index)
        }
    }

    func moveIndicatorView(index: Int, ratio: CGFloat, direction: Direction) {

        update(index)

        guard let currentItem else { return }

        if options.indicatorView.isAnimationOnSwipeEnabled {
            let padding = options.indicatorView.padding
            switch direction {
            case .forward:
                if let nextItem {
                    indicatorView.frame.origin.x = currentItem.frame.origin.x
                        + (nextItem.frame.origin.x - currentItem.frame.origin.x) * ratio
                        + padding.left
                    indicatorView.frame.size.width = currentItem.frame.size.width
                        + (nextItem.frame.size.width - currentItem.frame.size.width) * ratio
                        - padding.horizontal
                    if options.interpolatesTextColorOnSwipe {
                        nextItem.titleLabel.textColor = options.itemView.textColor.convert(to: options.itemView.selectedTextColor, multiplier: ratio)
                        currentItem.titleLabel.textColor = options.itemView.selectedTextColor.convert(to: options.itemView.textColor, multiplier: ratio)
                    }
                }
            case .reverse:
                if let previousItem {
                    indicatorView.frame.origin.x = previousItem.frame.origin.x
                        + (currentItem.frame.origin.x - previousItem.frame.origin.x) * ratio
                        + padding.left
                    indicatorView.frame.size.width = previousItem.frame.size.width
                        + (currentItem.frame.size.width - previousItem.frame.size.width) * ratio
                        - padding.horizontal
                    if options.interpolatesTextColorOnSwipe {
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

        focus(on: indicatorView, animated: false)
    }
}

extension TabView {
    var currentItem: TabItemView? {
        return itemViews.indices.contains(currentIndex) ? itemViews[currentIndex] : nil
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

        if options.indicator == .underline {
            indicatorView.frame.origin.x = currentItem.frame.origin.x + options.indicatorView.padding.left
            indicatorView.frame.size.width = currentItem.frame.size.width - options.indicatorView.padding.horizontal
        }

        focus(on: currentItem, animated: false)
    }
}

// MARK: - GestureRecognizer

extension TabView {

    private func makeTapGestureRecognizer() -> UITapGestureRecognizer {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapItemView(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.cancelsTouchesInView = false
        return gestureRecognizer
    }

    private func addTabItemGestures() {
        itemViews.forEach {
            $0.addGestureRecognizer(makeTapGestureRecognizer())
        }
    }

    @objc private func tapItemView(_ recognizer: UITapGestureRecognizer) {
        guard let itemView = recognizer.view as? TabItemView,
            let index: Int = itemViews.firstIndex(of: itemView),
            currentIndex != index else { return }
        tabViewDelegate?.tabView(self, willSelectTabAt: index)
        moveTabItem(index: index, animated: true)
        update(index)
        tabViewDelegate?.tabView(self, didSelectTabAt: index)
    }

    private func moveTabItem(index: Int, animated: Bool) {

        switch options.indicator {
        case .underline, .circle:
            animateIndicatorView(index: index, animated: animated, completion: nil)
        case .none:
            update(index)
        }
    }
}

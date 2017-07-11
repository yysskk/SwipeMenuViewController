
import UIKit

public protocol TabViewDataSource {

    func numberOfItems(in tabView: TabView) -> Int

    func tabView(_ tabView: TabView, titleForItemAt index: Int) -> String?
}

open class TabView: UIScrollView {

    open var dataSource: TabViewDataSource!

    var itemViews: [TabItemView] = []

    fileprivate let containerView: UIView = UIView()

    var currentItemView: TabItemView = TabItemView()

    var underlineView: UIView!

    var cacheAdjustCellSizes: [CGSize] = []

    var itemCount: Int {
        return itemViews.count
    }

    fileprivate var currentIndex: Int = 0

    fileprivate var options: SwipeMenuViewOptions.TabView = SwipeMenuViewOptions.TabView()

    public init(frame: CGRect, options: SwipeMenuViewOptions.TabView? = nil) {
        super.init(frame: frame)

        if let options = options {
            self.options = options
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func didMoveToSuperview() {
        setup()
    }

    deinit { }

    // MARK: - Setup

    fileprivate func setup() {
        setupScrollView()
        setupContainerView()
        setupTabItemViews()

        switch options.style {
        case .underline:
            setupUnderlineView()
        case .none:
            break
        }
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

    fileprivate func setupContainerView() {
        let itemCount = dataSource.numberOfItems(in: self)
        let containerWidth = options.itemView.width * CGFloat(itemCount)
        contentSize = CGSize(width: containerWidth, height: options.height)
        containerView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: frame.height - options.underlineView.height)
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
    }

    fileprivate func setupTabItemViews() {

        itemViews = []
        cacheAdjustCellSizes = []

        let itemCount = dataSource.numberOfItems(in: self)

        var xPosition: CGFloat = 0

        for index in 0..<itemCount {
            let tabItemView = TabItemView(frame: CGRect(x: xPosition, y: 0, width: options.itemView.width, height: frame.height - options.underlineView.height))
            tabItemView.translatesAutoresizingMaskIntoConstraints = false
            tabItemView.backgroundColor = options.backgroundColor
            if let title = dataSource.tabView(self, titleForItemAt: index) {
                tabItemView.titleLabel.text = title
            }

            tabItemView.isSelected = index == 0

            if options.isAdjustItemWidth {
                var adjustCellSize = tabItemView.frame.size
                adjustCellSize.width = tabItemView.titleLabel.sizeThatFits(containerView.frame.size).width + options.itemView.margin * 2
                tabItemView.frame.size = adjustCellSize
                cacheAdjustCellSizes.append(adjustCellSize)

                containerView.addSubview(tabItemView)
                itemViews.append(tabItemView)

                NSLayoutConstraint.activate([
                    tabItemView.widthAnchor.constraint(equalToConstant: adjustCellSize.width)
                ])
            } else {
                containerView.addSubview(tabItemView)
                itemViews.append(tabItemView)

                NSLayoutConstraint.activate([
                    tabItemView.widthAnchor.constraint(equalToConstant: options.itemView.width)
                ])
            }

            NSLayoutConstraint.activate([
                tabItemView.topAnchor.constraint(equalTo: containerView.topAnchor),
                tabItemView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: xPosition),
                tabItemView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])

            xPosition += tabItemView.frame.size.width
        }

        layout(containerView: containerView, containerWidth: xPosition)
    }

    private func layout(containerView: UIView, containerWidth: CGFloat) {

        containerView.frame.size.width = containerWidth
        self.contentSize.width = containerWidth
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.widthAnchor.constraint(equalToConstant: containerWidth),
            containerView.heightAnchor.constraint(equalToConstant: options.height - options.underlineView.height)
        ])
    }

    /// focus target
    /// - parameter target: target view
    /// - parameter animated: it is false if not animate
    fileprivate func focus(on target: UIView, animated: Bool = true) {
        let offset = target.center.x - self.frame.width / 2
        if offset < 0 || self.frame.width > containerView.frame.width {
            self.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
        } else if containerView.frame.width - self.frame.width < offset {
            self.setContentOffset(CGPoint(x: containerView.frame.width - self.frame.width, y: 0), animated: animated)
        } else {
            self.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
        }
    }

    /// update index
    /// - parameter index: newIndex
    public func update(_ index: Int) {
        currentIndex = index
        updateSelectedItem(by: currentIndex)
    }

    /// update selected item by new index
    /// - parameter index: newIndex
    private func updateSelectedItem(by newIndex: Int) {
        for (i, itemView) in itemViews.enumerated() {
            itemView.isSelected = i == newIndex
        }
    }
}

// MARK: - UnderlineView

extension TabView {

    public enum Direction {
        case forward
        case reverse
    }

    fileprivate func setupUnderlineView() {
        if itemViews.isEmpty { return }

        let itemView = itemViews[currentIndex]
        underlineView = UIView(frame: CGRect(x: itemView.frame.origin.x, y: itemView.frame.height, width: itemView.frame.width, height: options.underlineView.height))
        underlineView.backgroundColor = options.underlineView.backgroundColor
        addSubview(underlineView)

        jump(to: currentIndex)
    }

    public func animateUnderlineView(index: Int, completion: ((Bool) -> Swift.Void)? = nil) {

        update(index)

        UIView.animate(withDuration: 0.3, animations: { _ in
            let target = self.currentItem
            self.underlineView.frame.origin.x = target.frame.origin.x

            if self.options.isAdjustItemWidth {
                self.underlineView.frame.size.width = self.cacheAdjustCellSizes[index].width
            }

            self.focus(on: target)
        }, completion: completion)
    }

    public func moveUnderlineView(index: Int, ratio: CGFloat, direction: Direction) {

        update(index)

        switch direction {
        case .forward:
            underlineView.frame.origin.x = currentItem.frame.origin.x + (nextItem.frame.origin.x - currentItem.frame.origin.x) * ratio
            underlineView.frame.size.width = currentItem.frame.size.width + (nextItem.frame.size.width - currentItem.frame.size.width) * ratio
        case .reverse:
            underlineView.frame.origin.x = previousItem.frame.origin.x + (currentItem.frame.origin.x - previousItem.frame.origin.x) * ratio
            underlineView.frame.size.width = previousItem.frame.size.width + (currentItem.frame.size.width - previousItem.frame.size.width) * ratio
        }
    }
}

extension TabView {
    var currentItem: UIView {
        return itemViews[currentIndex]
    }

    var nextItem: UIView {
        if currentIndex < itemCount - 1 {
            return itemViews[currentIndex + 1]
        }
        return itemViews[currentIndex]
    }

    var previousItem: UIView {
        if currentIndex > 0 {
            return itemViews[currentIndex - 1]
        }
        return itemViews[currentIndex]
    }

    func jump(to index: Int) {
        update(index)

        underlineView.frame.origin.x = currentItem.frame.origin.x
        underlineView.frame.size.width = currentItem.frame.size.width

        focus(on: currentItem, animated: false)
    }
}

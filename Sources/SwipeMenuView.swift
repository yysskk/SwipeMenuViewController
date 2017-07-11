
import UIKit

// MARK: - SwipeMenuViewOptions
public struct SwipeMenuViewOptions {

    public enum SwipeMenuViewStyle {
        case flexible
// TODO: case segmented
// TODO: case infinity
    }

    public struct TabView {

        public enum TabStyle {
            case underline
            case none
        }

        public struct ItemView {
            public var width: CGFloat = 100.0
            public var margin: CGFloat = 5.0
            public var textColor: UIColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
            public var selectedTextColor: UIColor = .white
        }

        public struct UndelineView {
            public var height: CGFloat = 2.0
            public var margin: CGFloat = 0.0
            public var backgroundColor: UIColor = UIColor(red: 111/255, green: 185/255, blue: 0, alpha: 1.0)
            public var animationDuration: CGFloat = 0.3
        }

        // self
        public var height: CGFloat = 44.0
        public var backgroundColor: UIColor = .black
        public var style: TabStyle = .underline
        public var isAdjustItemWidth: Bool = true

        // item
        public var itemView = ItemView()

        // underline
        public var underlineView = UndelineView()
    }

    public struct ContentView {

        // self
        public var backgroundColor: UIColor = .clear
    }

    // self
    public var style: SwipeMenuViewStyle = .flexible

    // TabView
    public var tabView = TabView()

    // ContentView
    public var contentView = ContentView()
    
    public init() { }
}

// MARK: - SwipeMenuViewDelegate

public protocol SwipeMenuViewDelegate {

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, from fromIndex: Int, to toIndex: Int)

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, style: SwipeMenuViewOptions.SwipeMenuViewStyle) -> SwipeMenuViewOptions.SwipeMenuViewStyle
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, options: SwipeMenuViewOptions.TabView) -> SwipeMenuViewOptions.TabView
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, options: SwipeMenuViewOptions.TabView.ItemView) -> SwipeMenuViewOptions.TabView.ItemView
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, options: SwipeMenuViewOptions.ContentView) -> SwipeMenuViewOptions.ContentView
}

extension SwipeMenuViewDelegate {
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, from fromIndex: Int, to toIndex: Int) { }
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, isScrolling: Bool) {}
}

extension SwipeMenuViewDelegate {

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, style: SwipeMenuViewOptions.SwipeMenuViewStyle) -> SwipeMenuViewOptions.SwipeMenuViewStyle {
        return style
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, options: SwipeMenuViewOptions.TabView) -> SwipeMenuViewOptions.TabView {
        return options
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, options: SwipeMenuViewOptions.TabView.ItemView) -> SwipeMenuViewOptions.TabView.ItemView {
        return options
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, options: SwipeMenuViewOptions.ContentView) -> SwipeMenuViewOptions.ContentView {
        return options
    }
}

// MARK: - SwipeMenuViewDataSource

public protocol SwipeMenuViewDataSource {

    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController
}

// MARK: - SwipeMenuView

open class SwipeMenuView: UIView {

    open var delegate: SwipeMenuViewDelegate?

    open var dataSource: SwipeMenuViewDataSource?

    open fileprivate(set) var tabView: TabView? {
        didSet {
            guard let tabView = tabView else { return }
            tabView.dataSource = self
            addSubview(tabView)
            layout(tabView: tabView)
        }
    }

    open fileprivate(set) var contentView: ContentView? {
        didSet {
            guard let contentView = contentView else { return }
            contentView.delegate = self
            contentView.dataSource = self
            addSubview(contentView)
            layout(contentView: contentView)
        }
    }

    fileprivate var currentIndex: Int = 0

    fileprivate var pageCount: Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }

    fileprivate var isJump: Bool = false
    fileprivate var isPortrait: Bool = true

    open var options = SwipeMenuViewOptions()

    public init(frame: CGRect, options: SwipeMenuViewOptions? = nil) {
        super.init(frame: frame)

        if let options = options {
            self.options = options
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { }

    open override func layoutSubviews() {
        super.layoutSubviews()

        reload()
    }

    public func reload(options: SwipeMenuViewOptions? = nil) {

        if let options = options {
            self.options = options
        }

        reset()
        setup()

        jump(to: currentIndex)
    }

    // MARK: - Setup
    private func setup() {

        if let delegate = delegate {
            options.style = delegate.swipeMenuView(self, style: options.style)
            options.tabView = delegate.swipeMenuView(self, options: options.tabView)
            options.tabView.itemView = delegate.swipeMenuView(self, options: options.tabView.itemView)
            options.contentView = delegate.swipeMenuView(self, options: options.contentView)
        }

        tabView = TabView(frame: CGRect(x: 0, y: 0, width: frame.width, height: options.tabView.height), options: options.tabView)
        addTapGestureHandler()

        contentView = ContentView(frame: CGRect(x: 0, y: options.tabView.height, width: frame.width, height: frame.height - options.tabView.height))
    }

    private func layout(tabView: TabView) {

        tabView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: self.topAnchor),
            tabView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: options.tabView.height)
        ])
    }

    private func layout(contentView: ContentView) {

        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: options.tabView.height),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    private func reset() {
        if let tabView = tabView, let contentView = contentView {
            tabView.removeFromSuperview()
            contentView.removeFromSuperview()
        }

        tabView = nil
        contentView = nil
    }

    public func jump(to index: Int) {

        if let tabView = tabView, let contentView = contentView {
            tabView.jump(to: index)
            contentView.jump(to: index)
        }
    }

    /// update currentIndex
    /// - parameter from    : fromIndex
    /// - parameter to      : toIndex
    fileprivate func update(from fromIndex: Int, to toIndex: Int) {
        delegate?.swipeMenuView(self, from: fromIndex, to: toIndex)
        tabView?.update(toIndex)
        contentView?.update(toIndex)
        currentIndex = toIndex
    }
}

// MARK: - TabViewDataSource

extension SwipeMenuView: TabViewDataSource {

    public func numberOfItems(in menuView: TabView) -> Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }

    public func tabView(_ tabView: TabView, titleForItemAt index: Int) -> String? {
        return dataSource?.swipeMenuView(self, titleForPageAt: index)
    }
}

// MARK: - GestureRecognizer

extension SwipeMenuView {

    fileprivate var tapGestureRecognizer: UITapGestureRecognizer {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapItemView))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.cancelsTouchesInView = false
        return gestureRecognizer
    }

    fileprivate func addTapGestureHandler() {
        tabView?.itemViews.forEach {
            $0.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    func addTabItemGestures() {
        tabView?.itemViews.forEach {
            $0.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    func tapItemView(_ recognizer: UITapGestureRecognizer) {

        guard let itemView = recognizer.view as? TabItemView, let tabView = tabView, let index: Int = tabView.itemViews.index(of: itemView), let contentView = contentView else { return }
        if currentIndex == index { return }

        isJump = true

        moveTabItem(tabView: tabView, index: index)
        contentView.jump(to: index)

        update(from: currentIndex, to: index)
    }

    private func moveTabItem(tabView: TabView, index: Int) {

        switch options.tabView.style {
        case .underline:
            tabView.animateUnderlineView(index: index, completion: { _ in self.isJump = false })
        case .none:
            break
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SwipeMenuView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if isPortrait != (frame.height > frame.width) {
            isPortrait = !isPortrait
            return
        }

        if isJump { return }

        // update currentIndex
        if scrollView.contentOffset.x + 1.0 > frame.width * CGFloat(currentIndex + 1) {
            update(from: currentIndex, to: currentIndex + 1)
        } else if scrollView.contentOffset.x - 1.0 < frame.width * CGFloat(currentIndex - 1) {
            update(from: currentIndex, to: currentIndex - 1)
        }


        switch options.tabView.style {
        case .underline:
            moveUnderlineView(scrollView: scrollView)
        case .none:
            break
        }
    }


    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {

        scrollView.decelerationRate = 0
        if scrollView.contentOffset.x > frame.width * (CGFloat(currentIndex) + 0.5) {
            scrollView.setContentOffset(CGPoint(x: frame.width * CGFloat(currentIndex + 1), y: 0), animated: true)
        } else if scrollView.contentOffset.x < frame.width * (CGFloat(currentIndex) - 0.5) {
            scrollView.setContentOffset(CGPoint(x: frame.width * CGFloat(currentIndex - 1), y: 0), animated: true)
        } else {
            scrollView.setContentOffset(CGPoint(x: frame.width * CGFloat(currentIndex), y: 0), animated: true)
        }
    }

    /// update underbar position
    private func moveUnderlineView(scrollView: UIScrollView) {

        if let tabView = tabView, let contentView = contentView {

            let ratio = scrollView.contentOffset.x.truncatingRemainder(dividingBy: contentView.frame.width) / contentView.frame.width

            switch scrollView.contentOffset.x {
            case let offset where offset > frame.width * CGFloat(currentIndex):
                tabView.moveUnderlineView(index: currentIndex, ratio: ratio, direction: .forward)
            case let offset where offset < frame.width * CGFloat(currentIndex):
                tabView.moveUnderlineView(index: currentIndex, ratio: ratio, direction: .reverse)
            default:
                break
            }
        }
    }
}

// MARK: - ContentViewDataSource

extension SwipeMenuView: ContentViewDataSource {

    public func numberOfPages(in contentView: ContentView) -> Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }

    public func contentView(_ contentView: ContentView, viewForPageAt index: Int) -> UIView? {
        return dataSource?.swipeMenuView(self, viewControllerForPageAt: index).view
    }
}


import UIKit

// MARK: - SwipeMenuViewOptions
public struct SwipeMenuViewOptions {


    public struct TabView {

        public enum Style {
            case flexible
            case segmented
            // TODO: case infinity
        }

        public enum Addition {
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
        public var style: Style = .flexible
        public var addition: Addition = .underline
        public var isAdjustItemViewWidth: Bool = true

        // item
        public var itemView = ItemView()

        // underline
        public var underlineView = UndelineView()
    }

    public struct ContentView {

        // self
        public var backgroundColor: UIColor = .clear
        public var isScrollEnabled: Bool = true
    }

    // TabView
    public var tabView = TabView()

    // ContentView
    public var contentView = ContentView()
    
    public init() { }
}

// MARK: - SwipeMenuViewDelegate

public protocol SwipeMenuViewDelegate: class {

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexfrom fromIndex: Int, to toIndex: Int)
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexfrom fromIndex: Int, to toIndex: Int)
}

extension SwipeMenuViewDelegate {

    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexfrom fromIndex: Int, to toIndex: Int) { }
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexfrom fromIndex: Int, to toIndex: Int) { }
}

// MARK: - SwipeMenuViewDataSource

public protocol SwipeMenuViewDataSource: class {

    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController
}

// MARK: - SwipeMenuView

open class SwipeMenuView: UIView {

    open weak var delegate: SwipeMenuViewDelegate?

    open weak var dataSource: SwipeMenuViewDataSource?

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

    fileprivate var isJumping: Bool = false
    fileprivate var isOrientationChange: Bool = false
    fileprivate var isPortrait: Bool = true

    open var options = SwipeMenuViewOptions()

    public init(frame: CGRect, options: SwipeMenuViewOptions? = nil) {
        super.init(frame: frame)

        if let options = options {
            self.options = options
        }

        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()

        setup()
    }

    public func reload(options: SwipeMenuViewOptions? = nil) {

        if let options = options {
            self.options = options
        }

        reset()
        setup()

        jump(to: currentIndex)

        isOrientationChange = false
    }

    // MARK: - Setup
    private func setup() {

        tabView = TabView(frame: CGRect(x: 0, y: 0, width: frame.width, height: options.tabView.height), options: options.tabView)
        addTabItemGestures()

        contentView = ContentView(frame: CGRect(x: 0, y: options.tabView.height, width: frame.width, height: frame.height - options.tabView.height), options: options.contentView)
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

        if !isOrientationChange {
            currentIndex = 0
        }

        if let tabView = tabView, let contentView = contentView {
            tabView.removeFromSuperview()
            contentView.removeFromSuperview()
            tabView.reset()
            contentView.reset()
        }
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
        delegate?.swipeMenuView(self, willChangeIndexfrom: fromIndex, to: toIndex)
        tabView?.update(toIndex)
        contentView?.update(toIndex)
        currentIndex = toIndex
        delegate?.swipeMenuView(self, didChangeIndexfrom: fromIndex, to: toIndex)
    }

    func onOrientationChange(_ notification: Notification) {

        let deviceOrientation: UIDeviceOrientation!  = UIDevice.current.orientation
        isPortrait = !UIDeviceOrientationIsLandscape(deviceOrientation)
        isOrientationChange = true

        reload()
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
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapItemView(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.cancelsTouchesInView = false
        return gestureRecognizer
    }

    fileprivate func addTabItemGestures() {
        tabView?.itemViews.forEach {
            $0.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    func tapItemView(_ recognizer: UITapGestureRecognizer) {

        guard let itemView = recognizer.view as? TabItemView, let tabView = tabView, let index: Int = tabView.itemViews.index(of: itemView), let contentView = contentView else { return }
        if currentIndex == index { return }

        isJumping = true

        moveTabItem(tabView: tabView, index: index)
        contentView.jump(to: index)

        update(from: currentIndex, to: index)
    }

    private func moveTabItem(tabView: TabView, index: Int) {

        switch options.tabView.addition {
        case .underline:
            tabView.animateUnderlineView(index: index, completion: { _ in self.isJumping = false })
        case .none:
            tabView.update(index)
            isJumping = false
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SwipeMenuView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if isJumping || isOrientationChange { return }

        // update currentIndex
        if scrollView.contentOffset.x + 1.0 > frame.width * CGFloat(currentIndex + 1) {
            update(from: currentIndex, to: currentIndex + 1)
        } else if scrollView.contentOffset.x - 1.0 < frame.width * CGFloat(currentIndex - 1) {
            update(from: currentIndex, to: currentIndex - 1)
        }


        switch options.tabView.addition {
        case .underline:
            moveUnderlineView(scrollView: scrollView)
        case .none:
            tabView?.update(currentIndex)
        }
    }


    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

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


import UIKit

public struct SwipeMenuViewOptions {

    public struct TabView {

        public enum TabStyle {
            case underline
            case none
        }

        public struct ItemView {
            public var width: CGFloat = 100.0
            public var margin: CGFloat = 5.0
        }

        public struct UndelineView {
            public var height: CGFloat = 2.0
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

    // TabView
    public var tabView = TabView()

    public init() { }
}

public protocol SwipeMenuViewDelegate: NSObjectProtocol, UIScrollViewDelegate {

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, from fromIndex: Int, to toIndex: Int)
}


public protocol SwipeMenuViewDataSource {

    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController
}

open class SwipeMenuView: UIView {

    open var delegate: SwipeMenuViewDelegate?

    open var dataSource: SwipeMenuViewDataSource?

    open fileprivate(set) var tabView: TabView? {
        didSet {
            guard let tabView = tabView else { return }
            tabView.dataSource = self
            tabView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(tabView)
            layout(tabView: tabView)
        }
    }

    open fileprivate(set) var pageView: UIView? {
        didSet {
            guard let pageView = pageView else { return }
            pageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(pageView)
            layout(pageView: pageView)
        }
    }

    open fileprivate(set) var pageViewController: UIPageViewController? {
        didSet  {
            guard let pageViewController = pageViewController, let pageView = pageView else { return }
            pageViewController.dataSource = self
            pageViewController.delegate = self
            pageView.addSubview(pageViewController.view)
        }
    }

    fileprivate var currentIndex: Int = 0

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

    open override func didMoveToSuperview() {
        setup()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if let tabView = tabView {
            tabView.animateUnderlineView(index: currentIndex)
        }
    }

    public func reload() {
        reset()
        setup()
    }

    // MARK: - Setup
    private func setup() {
        guard let dataSource = dataSource else { return }

        tabView = TabView(frame: CGRect(x: 0, y: 0, width: frame.width, height: options.tabView.height), options: options.tabView)
        addTapGestureHandler()

        pageView = UIView(frame: CGRect(x: 0, y: options.tabView.height, width: frame.width, height: frame.height - options.tabView.height))
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController?.setViewControllers([dataSource.swipeMenuView(self, viewControllerForPageAt: 0)], direction: .forward, animated: false, completion: nil)
    }

    private func layout(tabView: TabView) {

        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: self.topAnchor),
            tabView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: options.tabView.height)
        ])
    }

    private func layout(pageView: UIView) {

        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: self.topAnchor, constant: options.tabView.height),
            pageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    private func reset() {
        tabView?.removeFromSuperview()
        pageView?.removeFromSuperview()
    }
}

extension SwipeMenuView: TabViewDataSource, TabViewDelegate {

    public func numberOfPages(in menuView: TabView) -> Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }

    public func tabView(_ tabView: TabView, viewForTitleinTabItem page: Int) -> String? {
        return dataSource?.swipeMenuView(self, titleForPageAt: page)
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

        guard let dataSource = dataSource, let itemView = recognizer.view as? TabItemView, let tabView = tabView, let index: Int = tabView.itemViews.index(of: itemView) else { return }

        if  currentIndex == index { return }

        moveTabItem(tabView: tabView, index: index)

        pageViewController?.setViewControllers([dataSource.swipeMenuView(self, viewControllerForPageAt: index)],
                                               direction: currentIndex > index ? .reverse : .forward,
                                               animated: true,
                                               completion: nil)

        delegate?.swipeMenuView(self, from: currentIndex, to: index)

        currentIndex = index
    }

    func moveTabItem(tabView: TabView, index: Int) {
        for (i, itemView) in tabView.itemViews.enumerated() {
            itemView.isSelected = i == index
        }

        switch options.tabView.style {
        case .underline:
            tabView.animateUnderlineView(index: index)
        case .none:
            break
        }
    }
}

// MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension SwipeMenuView: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    private enum Direction {
        case next
        case previous
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        guard let dataSource = dataSource else { return }

        if !finished {
            return
        }

        if let currentVC = pageViewController.viewControllers?.first {
            for index in 0..<dataSource.numberOfPages(in: self) {
                if dataSource.swipeMenuView(self, viewControllerForPageAt: index) == currentVC {
                    delegate?.swipeMenuView(self, from: currentIndex, to: index)
                    currentIndex = index
                    break
                }
            }
        }

        if let tabView = tabView {
            moveTabItem(tabView: tabView, index: currentIndex)
        }
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        return transiotion(from: viewController, direction: .previous)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        return transiotion(from: viewController, direction: .next)
    }

    private func transiotion(from viewController: UIViewController, direction: Direction) -> UIViewController? {

        guard let dataSource = dataSource else { return nil }

        var index: Int = 0

        for i in 0..<dataSource.numberOfPages(in: self) {
            if dataSource.swipeMenuView(self, viewControllerForPageAt: i) == viewController {
                switch direction {
                case .next:
                    index = i + 1
                case .previous:
                    index = i - 1
                }
                break
            }
        }

        if index >= 0 && index < dataSource.numberOfPages(in: self) {
            return dataSource.swipeMenuView(self, viewControllerForPageAt: index)
        }

        return nil
    }
}

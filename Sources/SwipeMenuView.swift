
import UIKit

public struct SwipeMenuViewOptions {
    public static var menuViewHeight: CGFloat = 44.0
    public static var menuViewItemWidth: CGFloat = 100.0
    public static var menuViewItemAutoWidthEnabled: Bool = false
    public static var underLineViewColor: UIColor = UIColor.darkGray
    public static var underLineViewHeight: CGFloat = 1.0
    public static var isUnderLineViewHidden: Bool = false
    public static var animationDuration: CGFloat = 0.4
}

public protocol SwipeMenuViewDelegate: NSObjectProtocol, UIScrollViewDelegate {

}


@objc public protocol SwipeMenuViewDataSource {
    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController

    @objc optional func configureView(page: UIView, forPageAt index: Int)
}

open class SwipeMenuView: UIView {

    open weak var delegate: SwipeMenuViewDelegate!

    open weak var dataSource: SwipeMenuViewDataSource!

    open var menuOptions = SwipeMenuViewOptions()
    open fileprivate(set) var tabView: TabView? {
        didSet {
            guard let tabView = tabView else { return }
            tabView.dataSource = self
            addSubview(tabView)
        }
    }

    open fileprivate(set) var pageView: UIView? {
        didSet {
            guard let pageView = pageView else { return }
            addSubview(pageView)
        }
    }
    open fileprivate(set) var pageViewController: PageViewController? {
        didSet  {
            guard let pageViewController = pageViewController else { return }
            pageViewController.dataSource = self
            pageView?.addSubview(pageViewController.view)
        }
    }
    var currentPage: Int = 0



    // MARK: - Lifecycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit { }


    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

    }

    open override func didMoveToSuperview() {
        setup()
    }

    // MARK: - Setup
    private func setup() {
        tabView = TabView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 44))
        tabView?.contentSize = CGSize(width: 500, height: 44)
        addTapGestureHandler()

        pageView = UIView(frame: CGRect(x: 0, y: 44, width: frame.width, height: frame.height - 44))
        pageViewController = PageViewController()
    }

}

extension SwipeMenuView: TabViewDataSource, TabViewDelegate {

    public func numberOfPages(in menuView: TabView) -> Int {
        return dataSource.numberOfPages(in: self)
    }

    public func tabView(_ tabView: TabView, viewForTitleinTabItem page: Int) -> String? {
        return dataSource.swipeMenuView(self, titleForPageAt: page)
    }

//    public func menuView(_ menuView: MenuView, itemForPageAt page: Int) -> UIView { }

}

// MARK: - GestureRecognizer

extension SwipeMenuView {

    fileprivate var tapGestureRecognizer: UITapGestureRecognizer {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
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

    internal func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        guard let itemView = recognizer.view as? TabItemView,
        let tabView = tabView,
        let index: Int = tabView.itemViews.index(of: itemView) else { return }

        moveTabItem(tabView: tabView, index: index)
    }

    func moveTabItem(tabView: TabView, index: Int) {
        pageViewController?.setViewControllers([dataSource.swipeMenuView(self, viewControllerForPageAt: index)],
                                               direction: currentPage > index ? .reverse : .forward,
                                               animated: true,
                                               completion: nil)

        currentPage = index

        for (i, itemView) in tabView.itemViews.enumerated() {
            itemView.isSelected = i == index
        }
        tabView.animateUnderlineView(index: index)
    }
}

extension SwipeMenuView: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentPage > 0 {
            currentPage -= 1
        }
        if let tabView = tabView {
            moveTabItem(tabView: tabView, index: currentPage)
        }
        return dataSource.swipeMenuView(self, viewControllerForPageAt: currentPage)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentPage < dataSource.numberOfPages(in: self) - 1 {
            currentPage += 1
        }
        if let tabView = tabView {
            moveTabItem(tabView: tabView, index: currentPage)
        }
        return dataSource.swipeMenuView(self, viewControllerForPageAt: currentPage)
    }
}

import UIKit

/// A container view controller that manages a ``SwipeMenuView`` and drives it from its child view controllers.
///
/// `SwipeMenuViewController` creates and hosts a ``SwipeMenuView`` in ``viewDidLoad()`` and
/// acts as both its delegate and its data source. By default each page is backed by one of the
/// controller's `children`: the page count is `children.count`, each page title is the child's
/// `title`, and each page shows the corresponding child's view.
///
/// To use it, subclass `SwipeMenuViewController` and add child view controllers with
/// `addChild(_:)` before the view loads. For fully custom paging, override the data source
/// methods (``numberOfPages(in:)``, ``swipeMenuView(_:titleForPageAt:)``,
/// ``swipeMenuView(_:viewControllerForPageAt:)``) instead of relying on `children`.
open class SwipeMenuViewController: UIViewController, SwipeMenuViewDelegate, SwipeMenuViewDataSource {

    /// The swipe menu view managed by this controller. Created in ``viewDidLoad()``.
    open var swipeMenuView: SwipeMenuView!

    open override func viewDidLoad() {
        super.viewDidLoad()

        swipeMenuView = SwipeMenuView(frame: view.frame)
        swipeMenuView.delegate = self
        swipeMenuView.dataSource = self
        view.addSubview(swipeMenuView)
        setUpSwipeMenuViewConstraints()
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // potentially nil.
        // https://forums.developer.apple.com/thread/94426
        swipeMenuView?.willChangeOrientation()
    }

    private func setUpSwipeMenuViewConstraints() {
        swipeMenuView.translatesAutoresizingMaskIntoConstraints = false
        // The top anchor is chosen once from the initial options. Toggling
        // `options.tabView.isSafeAreaEnabled` at runtime does not re-pin the
        // view, so configure the safe area behavior before the view loads.
        let topAnchor =
            swipeMenuView.options.tabView.isSafeAreaEnabled
            ? view.safeAreaLayoutGuide.topAnchor
            : view.topAnchor
        NSLayoutConstraint.activate([
            swipeMenuView.topAnchor.constraint(equalTo: topAnchor),
            swipeMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swipeMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            swipeMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - SwipeMenuViewDelegate

    /// Called before the swipe menu view sets up its views. The default implementation does nothing; override to react.
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) {}

    /// Called after the swipe menu view has set up its views. The default implementation does nothing; override to react.
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) {}

    /// Called before the front page changes. The default implementation does nothing; override to react.
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {}

    /// Called after the front page has changed. The default implementation does nothing; override to react.
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {}

    // MARK: - SwipeMenuViewDataSource

    /// Returns the number of pages. The default implementation returns `children.count`; override to provide a custom count.
    open func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return children.count
    }

    /// Returns the tab title for the page at `index`.
    ///
    /// The default implementation returns the corresponding child's `title`, or an empty string
    /// when the child has none or `index` is out of range. Override to provide custom titles.
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        guard children.indices.contains(index) else { return "" }
        return children[index].title ?? ""
    }

    /// Returns the view controller for the page at `index`.
    ///
    /// The default implementation returns the child view controller at `index`. If `index` is out
    /// of range it asserts in debug builds and returns an empty placeholder view controller rather
    /// than crashing. Override to provide pages that are not backed by `children`.
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        guard children.indices.contains(index) else {
            assertionFailure(
                """
                SwipeMenuViewController: requested a page at \(index) but only \(children.count) \
                child view controllers exist. Override the data source to provide the missing pages.
                """)
            // Return a detached placeholder rather than crashing. It is
            // intentionally not added via `addChild(_:)`: the default
            // `numberOfPages(in:)` counts `children`, so adding children on this
            // recovery path could feed back into that count.
            return UIViewController()
        }
        let vc = children[index]
        vc.didMove(toParent: self)
        return vc
    }
}

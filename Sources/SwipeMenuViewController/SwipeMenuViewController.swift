import UIKit

open class SwipeMenuViewController: UIViewController, SwipeMenuViewDelegate, SwipeMenuViewDataSource {

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
        let topAnchor = swipeMenuView.options.tabView.isSafeAreaEnabled
            ? view.safeAreaLayoutGuide.topAnchor
            : view.topAnchor
        NSLayoutConstraint.activate([
            swipeMenuView.topAnchor.constraint(equalTo: topAnchor),
            swipeMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swipeMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            swipeMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - SwipeMenuViewDelegate
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) { }
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) { }
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) { }
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) { }

    // MARK: - SwipeMenuViewDataSource

    open func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return children.count
    }

    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        guard children.indices.contains(index) else { return "" }
        return children[index].title ?? ""
    }

    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        guard children.indices.contains(index) else {
            assertionFailure("SwipeMenuViewController: requested a page at \(index) but only \(children.count) child view controllers exist. Override the data source to provide the missing pages.")
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

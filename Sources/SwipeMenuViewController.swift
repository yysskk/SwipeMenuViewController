import UIKit

open class SwipeMenuViewController: UIViewController, SwipeMenuViewDelegate, SwipeMenuViewDataSource {

    open var swipeMenuView: SwipeMenuView!

    open override func viewDidLoad() {
        super.viewDidLoad()

        swipeMenuView = SwipeMenuView(frame: view.frame)
        swipeMenuView.delegate = self
        swipeMenuView.dataSource = self
        view.addSubview(swipeMenuView)
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        swipeMenuView.willChangeOrientation()
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addSwipeMenuViewConstraints()
    }

    private func addSwipeMenuViewConstraints() {

        swipeMenuView.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 11.0, *), view.hasSafeAreaInsets, swipeMenuView.options.tabView.isSafeAreaEnabled {
            NSLayoutConstraint.activate([
                swipeMenuView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                swipeMenuView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                swipeMenuView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                swipeMenuView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                swipeMenuView.topAnchor.constraint(equalTo: self.view.topAnchor),
                swipeMenuView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                swipeMenuView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                swipeMenuView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }

    // MARK: - SwipeMenuViewDelegate
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) { }
    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) { }

    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) { }

    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) { }

    // MARK: - SwipeMenuViewDataSource

    open func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return 0
    }

    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return ""
    }

    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        return UIViewController()
    }
}

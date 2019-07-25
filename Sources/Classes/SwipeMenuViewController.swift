import UIKit

open class SwipeMenuViewController: UIViewController, SwipeMenuViewDelegate, SwipeMenuViewDataSource {

    open var swipeMenuView: SwipeMenuView!
    
    private lazy var isLayouted: Bool = {
        self.addSwipeMenuViewConstraints()
        return true
    }()

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

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = isLayouted
    }

    private func addSwipeMenuViewConstraints() {

        swipeMenuView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *), view.hasSafeAreaInsets, swipeMenuView.options.tabView.isSafeAreaEnabled {
            NSLayoutConstraint.activate([
                swipeMenuView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                swipeMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                swipeMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                swipeMenuView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else {
            if #available(iOS 9.0, *){
                NSLayoutConstraint.activate([
                    swipeMenuView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                    swipeMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    swipeMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    swipeMenuView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
                    ])
            } else {
                let views = ["swipeMenuView": swipeMenuView as Any, "topLayoutGuide": topLayoutGuide, "bottomLayoutGuide": bottomLayoutGuide] as [String : Any]
                let hConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[swipeMenuView]|", options: [], metrics: nil, views: views)
                view.addConstraints(hConstraint)
                let vConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide][swipeMenuView][bottomLayoutGuide]", options: [], metrics: nil, views: views)
                view.addConstraints(vConstraint)
            }
        }
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
        return children[index].title ?? ""
    }

    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = children[index]
        vc.didMove(toParent: self)
        return vc
    }
}

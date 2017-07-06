
import UIKit

open class SwipeMenuViewController: UIViewController, SwipeMenuViewDelegate, SwipeMenuViewDataSource {

    open var swipeMenuView: SwipeMenuView!

    open override func viewDidLoad() {
        super.viewDidLoad()

        swipeMenuView = SwipeMenuView(frame: view.frame, options: setOptions())
        swipeMenuView.delegate = self
        swipeMenuView.dataSource = self
        view.addSubview(swipeMenuView)
        swipeMenuView.translatesAutoresizingMaskIntoConstraints = false
        addSwipeMenuViewConstraints()
    }

    open func setOptions() -> SwipeMenuViewOptions {
        let options = SwipeMenuViewOptions()
        return options
    }

    private func addSwipeMenuViewConstraints() {
        view.addConstraints([
            NSLayoutConstraint(
                item: swipeMenuView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0.0),

            NSLayoutConstraint(
                item: swipeMenuView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerY,
                multiplier: 1,
                constant: 0.0),

            NSLayoutConstraint(
                item: swipeMenuView,
                attribute: .width,
                relatedBy: .equal,
                toItem: view,
                attribute: .width,
                multiplier: 1,
                constant: 0.0),

            NSLayoutConstraint(
                item: swipeMenuView,
                attribute: .height,
                relatedBy: .equal,
                toItem: view,
                attribute: .height,
                multiplier: 1,
                constant: 0.0)
            ])
    }

    // MARK: - SwipeMenuViewDelegate

    open func swipeMenuView(_ swipeMenuView: SwipeMenuView, from fromIndex: Int, to toIndex: Int) { }

    // MARK - SwipeMenuViewDataSource

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

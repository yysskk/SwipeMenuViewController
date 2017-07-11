
import UIKit
import SwipeMenuViewController

class ViewController: SwipeMenuViewController {

    let datas: [String] = ["Bulbasaur","Caterpie", "Golem", "Jynx", "Marshtomp", "Salamence", "Riolu", "Araquanid"]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
    }

    override func setOptions() -> SwipeMenuViewOptions {
        var options = SwipeMenuViewOptions()
        options.tabView.isAdjustItemWidth = false
        return options
    }

    // MARK: - SwipeMenuViewDelegate

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, from fromIndex: Int, to toIndex: Int) {
        print("change from section\(fromIndex + 1)  to section\(toIndex + 1)")
    }


    // MARK - SwipeMenuViewDataSource

    open override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return datas.count
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return datas[index]
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = ContentViewController()
        vc.content = datas[index]
        return vc
    }
}

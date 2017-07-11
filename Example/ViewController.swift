
import UIKit
import SwipeMenuViewController

class ViewController: SwipeMenuViewController {

    let datas: [String] = ["Bulbasaur","Caterpie", "Golem", "Jynx", "Marshtomp", "Salamence", "Riolu", "Araquanid"]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
    }

    // MARK: - SwipeMenuViewDelegate

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, from fromIndex: Int, to toIndex: Int) {
        print("change from section\(fromIndex + 1)  to section\(toIndex + 1)")
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, style: SwipeMenuViewOptions.SwipeMenuViewStyle) -> SwipeMenuViewOptions.SwipeMenuViewStyle {
        return style
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, options: SwipeMenuViewOptions.TabView) -> SwipeMenuViewOptions.TabView {
        var options = options
        options.isAdjustItemWidth = false
        return options
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, options: SwipeMenuViewOptions.TabView.ItemView) -> SwipeMenuViewOptions.TabView.ItemView {
        return options
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, options: SwipeMenuViewOptions.ContentView) -> SwipeMenuViewOptions.ContentView {
        return options
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

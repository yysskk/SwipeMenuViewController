
import UIKit
import SwipeMenuViewController

struct MenuContent {
    let title: String
    let vc: ContentViewController
}

class ViewController: SwipeMenuViewController {

    let data: [MenuContent] = [MenuContent(title: "Bulbasaur", vc: ContentViewController()),
                               MenuContent(title: "Caterpie", vc: ContentViewController()),
                               MenuContent(title: "Golem", vc: ContentViewController()),
                               MenuContent(title: "Jynx", vc: ContentViewController()),
                               MenuContent(title: "Marshtomp", vc: ContentViewController()),
                               MenuContent(title: "Salamence", vc: ContentViewController()),
                               MenuContent(title: "Riolu", vc: ContentViewController()),
                               MenuContent(title: "Araquanid", vc: ContentViewController())]

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
        return data.count
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return data[index].title
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = data[index].vc
        vc.content = data[index].title
        return vc
    }
}

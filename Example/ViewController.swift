
import UIKit
import SwipeMenuViewController

struct MenuContent {
    let title: String
    let vc: ContentViewController
}

class ViewController: SwipeMenuViewController {

    let data: [MenuContent] = [MenuContent(title: "Section1", vc: ContentViewController()),
                               MenuContent(title: "Section2", vc: ContentViewController()),
                               MenuContent(title: "Section3", vc: ContentViewController()),
                               MenuContent(title: "Section4", vc: ContentViewController()),
                               MenuContent(title: "Section5", vc: ContentViewController())]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
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

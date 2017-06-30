
import UIKit
import SwipeMenuViewController

struct MenuContent {
    let title: String
    let vc: UIViewController
}

class ViewController: SwipeMenuViewController {

    let data: [MenuContent] = [MenuContent(title: "アニメ", vc: UIViewController()),
                               MenuContent(title: "映画", vc: UIViewController()),
                               MenuContent(title: "ドラマ", vc: UIViewController()),
                               MenuContent(title: "スポーツ", vc: UIViewController()),
                               MenuContent(title: "音楽", vc: UIViewController()),
                               ]

    override func viewDidLoad() {
        super.viewDidLoad()
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
        if index == 0 {
            vc.view.backgroundColor = .yellow
        } else if index == 1 {
            vc.view.backgroundColor = .blue
        } else if index == 2 {
            vc.view.backgroundColor = .black
        } else if index == 3 {
            vc.view.backgroundColor = .gray
        }
        return vc
    }
}


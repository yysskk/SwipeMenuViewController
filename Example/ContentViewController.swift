
import UIKit

class ContentViewController: UIViewController {

    var contentLabel: UILabel! {
        didSet {
            contentLabel.textColor = .black
            contentLabel.textAlignment = .center
            contentLabel.font = UIFont.boldSystemFont(ofSize: 25)
            contentLabel.text = content
            view.addSubview(contentLabel)
        }
    }

    var content: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        contentLabel = UILabel(frame: CGRect(x: 0, y: view.center.y - 50, width: view.frame.width, height: 50))
    }
}

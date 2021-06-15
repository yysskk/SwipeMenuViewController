import UIKit
import SwipeMenuViewController

final class ViewController: SwipeMenuViewController {

    private var datas: [String] = ["Bulbasaur","Caterpie", "Golem", "Jynx", "Marshtomp", "Salamence", "Riolu", "Araquanid"]

    var options = SwipeMenuViewOptions()
    var dataCount: Int = 5

    @IBOutlet private weak var settingButton: UIButton!

    override func viewDidLoad() {

        datas.forEach { data in
            let vc = ContentViewController()
            vc.title = data
            vc.content = data
            self.addChild(vc)
        }

        super.viewDidLoad()

        view.bringSubviewToFront(settingButton)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popupSegue" {
            let vc = segue.destination as! PopupViewController
            vc.options = options
            vc.dataCount = dataCount
            vc.reloadClosure = { self.reload() }
        }
    }

    private func reload() {
        swipeMenuView.reloadData(options: options)
    }

    // MARK: - SwipeMenuViewDelegate

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) {
        super.swipeMenuView(swipeMenuView, viewWillSetupAt: currentIndex)
        print("will setup SwipeMenuView")
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) {
        super.swipeMenuView(swipeMenuView, viewDidSetupAt: currentIndex)
        print("did setup SwipeMenuView")
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, willChangeIndexFrom: fromIndex, to: toIndex)
        print("will change from section\(fromIndex + 1)  to section\(toIndex + 1)")
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, didChangeIndexFrom: fromIndex, to: toIndex)
        print("did change from section\(fromIndex + 1)  to section\(toIndex + 1)")
    }


    // MARK - SwipeMenuViewDataSource

    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return dataCount
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return children[index].title ?? ""
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, itemViweForPageAt index: Int) -> TabItemViewProtocol? {
        let tabItemView = TabItemView()
        tabItemView.backgroundColor = .red
        return tabItemView
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = children[index]
        vc.didMove(toParent: self)
        return vc
    }
}

final class TabItemView: UIView, TabItemViewProtocol {

    private(set) var titleLabel: UILabel = UILabel()
    private var notificationBadgeView: UIView = UIView()
    let notificationBadgeViewSize: CGSize = CGSize(width: 6, height: 6)

    public var textColor: UIColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
    public var selectedTextColor: UIColor = .white
    public var notificationBadgeColor: UIColor = .red

    public var isSelected: Bool = false {
        didSet {
            if isSelected {
                titleLabel.textColor = selectedTextColor
            } else {
                titleLabel.textColor = textColor
            }
        }
    }
    public var notificationBadgeViewFrame: CGRect = .zero {
        didSet {
            notificationBadgeView.frame = notificationBadgeViewFrame
        }
    }
    public var hasNotification: Bool = false {
        didSet {
            if hasNotification {
                notificationBadgeView.backgroundColor = notificationBadgeColor
                notificationBadgeView.isHidden = false
            } else {
                notificationBadgeView.isHidden = true
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupLabel()
        setupNotificationBadgeView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
    }

    private func setupLabel() {
        titleLabel = UILabel(frame: bounds)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
        titleLabel.backgroundColor = UIColor.clear
        addSubview(titleLabel)
        layoutLabel()
    }
    
    private func setupNotificationBadgeView() {
        notificationBadgeView = UIView()
        notificationBadgeView.isHidden = true
        notificationBadgeView.layer.cornerRadius = notificationBadgeViewSize.height / 2
        notificationBadgeView.clipsToBounds = true
        addSubview(notificationBadgeView)
    }
    
    private func layoutLabel() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

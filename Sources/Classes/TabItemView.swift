import UIKit

final class TabItemView: UIView {

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

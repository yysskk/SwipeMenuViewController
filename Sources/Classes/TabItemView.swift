import UIKit

final class TabItemView: UIView {

    private(set) var titleLabel: UILabel = UILabel()
    private(set) var backgroundImageView: UIImageView = UIImageView()

    public var textColor: UIColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
    public var selectedTextColor: UIColor = .white
    public var labelBackgroundColor: UIColor = .clear
    public var selectedLabelBackgroundColor: UIColor = .clear
    public var backgroundImage: UIImage?
    public var selectedbackgroundImage: UIImage?
    
    public var isRoundBackground: Bool = false {
        didSet {
            titleLabel.clipsToBounds = isRoundBackground
            backgroundImageView.clipsToBounds = isRoundBackground
            if isRoundBackground {
                titleLabel.layer.cornerRadius = titleLabel.bounds.height * 0.5
                backgroundImageView.layer.cornerRadius = titleLabel.bounds.height * 0.5
            } else {
                titleLabel.layer.cornerRadius = 0
                backgroundImageView.layer.cornerRadius = 0
            }
        }
    }

    public var isSelected: Bool = false {
        didSet {
            if isSelected {
                titleLabel.textColor = selectedTextColor
                titleLabel.backgroundColor = selectedLabelBackgroundColor
                backgroundImageView.image = selectedbackgroundImage
            } else {
                titleLabel.textColor = textColor
                titleLabel.backgroundColor = labelBackgroundColor
                backgroundImageView.image = backgroundImage
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupLabel()
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

    private func layoutLabel() {

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
                titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
                titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                ])
        } else {
            let views = ["label": titleLabel]
            let hConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: [], metrics: nil, views: views)
            addConstraints(hConstraint)
            let vConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: views)
            addConstraints(vConstraint)
        }
    }
    
    private func setupImageView() {

        addSubview(backgroundImageView)
        layoutImageView()
    }
    
    private func layoutImageView() {
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
                backgroundImageView.widthAnchor.constraint(equalTo: self.widthAnchor),
                backgroundImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                ])
        } else {
            let views = ["backgroundImageView": backgroundImageView]
            let hConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", options: [], metrics: nil, views: views)
            addConstraints(hConstraint)
            let vConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", options: [], metrics: nil, views: views)
            addConstraints(vConstraint)
        }
    }
}

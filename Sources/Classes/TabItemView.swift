import UIKit

final class TabItemView: UIView {
    
    private(set) var titleLabel: UILabel = UILabel()
    private(set) var dotView: UIView = {
        let dot = UIView()
        dot.backgroundColor = UIColor.red
        dot.frame = CGRect(x: 0, y: 0, width: 8, height: 8)
        dot.layer.cornerRadius = 4
        dot.layer.masksToBounds = true
        dot.isHidden = true
        return dot
    }()
    private var dotTrailingConstraint: NSLayoutConstraint!
    
    var dotHidden = true {
        didSet {
            dotView.isHidden = dotHidden
        }
    }
    
    public var textColor: UIColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
    public var selectedTextColor: UIColor = .white

    public var isSelected: Bool = false {
        didSet {
            if isSelected {
                titleLabel.textColor = selectedTextColor
            } else {
                titleLabel.textColor = textColor
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupLabel()
        setupDotView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        updateXConstraintForDot()
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
    
    private func setupDotView() {
        addSubview(dotView)
        layoutDot()
    }
    
    private func layoutLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
    }
    
    private func layoutDot() {
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotTrailingConstraint = dotView.trailingAnchor.constraint(equalTo: trailingAnchor)

        NSLayoutConstraint.activate([
            dotTrailingConstraint,
            dotView.topAnchor.constraint(equalTo: topAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 8.0),
            dotView.heightAnchor.constraint(equalToConstant: 8.0)
            ])
    }
    
    private func updateXConstraintForDot() {
        let w = titleLabel.sizeThatFits(self.frame.size).width
        let c = ((self.frame.width - titleLabel.sizeThatFits(self.frame.size).width) / 2 - 8)
        let constant = max(c, 0)
        print("constant \(constant) c \(c)")
        dotTrailingConstraint.constant = -constant
    }
}


import UIKit

class TabItemView: UIView {

    open var titleLabel: UILabel = UILabel()

    open var isSelected: Bool = false {
        didSet {
            if isSelected {
                titleLabel.textColor = .white
            } else {
                titleLabel.textColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupLabel()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit { }

    override open func layoutSubviews() {
        super.layoutSubviews()
    }

    private func setupLabel() {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
        titleLabel.backgroundColor = UIColor.clear
        addSubview(titleLabel)
        layoutLabel()
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

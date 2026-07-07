import UIKit

/// A single tab item that displays a centered title and reflects its selected state.
final class TabItemView: UIView {

    /// The label that displays the tab's title.
    private(set) var titleLabel: UILabel = UILabel()

    /// The title color used when the item is not selected.
    public var textColor: UIColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)

    /// The title color used when the item is selected.
    public var selectedTextColor: UIColor = .white

    /// The title font used when the item is not selected.
    public var font: UIFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            if !isSelected { titleLabel.font = font }
        }
    }

    /// The title font used when the item is selected.
    public var selectedFont: UIFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            if isSelected { titleLabel.font = selectedFont }
        }
    }

    /// Whether the item is currently selected. Setting this updates the title color and font.
    public var isSelected: Bool = false {
        didSet {
            if isSelected {
                titleLabel.textColor = selectedTextColor
                titleLabel.font = selectedFont
            } else {
                titleLabel.textColor = textColor
                titleLabel.font = font
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

    override public func layoutSubviews() {
        super.layoutSubviews()
    }

    private func setupLabel() {
        titleLabel = UILabel(frame: bounds)
        titleLabel.textAlignment = .center
        titleLabel.font = font
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

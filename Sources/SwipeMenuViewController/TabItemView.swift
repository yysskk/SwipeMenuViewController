import UIKit

/// A single tab item that displays a centered title and reflects its selected state.
final class TabItemView: UIView {

    /// The label that displays the tab's title.
    let titleLabel = UILabel()

    /// The title color used when the item is not selected.
    var textColor: UIColor = UIColor(red: 140 / 255, green: 140 / 255, blue: 140 / 255, alpha: 1.0)

    /// The title color used when the item is selected.
    var selectedTextColor: UIColor = .white

    /// The title font used when the item is not selected.
    var font: UIFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            if !isSelected { titleLabel.font = font }
        }
    }

    /// The title font used when the item is selected.
    var selectedFont: UIFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            if isSelected { titleLabel.font = selectedFont }
        }
    }

    /// Whether the item is currently selected. Setting this updates the title color and font.
    var isSelected: Bool = false {
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

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel() {
        titleLabel.textAlignment = .center
        titleLabel.font = font
        titleLabel.textColor = textColor
        titleLabel.backgroundColor = .clear
        addSubview(titleLabel)
        layoutLabel()
    }

    private func layoutLabel() {

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

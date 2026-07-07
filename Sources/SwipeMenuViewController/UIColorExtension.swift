import UIKit

extension UIColor {

    func convert(to color: UIColor, multiplier: CGFloat) -> UIColor? {
        let ratio = min(max(multiplier, 0), 1)

        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0

        guard getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha),
            color.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        else {
            return nil
        }

        return UIColor(
            red: fromRed + (toRed - fromRed) * ratio,
            green: fromGreen + (toGreen - fromGreen) * ratio,
            blue: fromBlue + (toBlue - fromBlue) * ratio,
            alpha: fromAlpha + (toAlpha - fromAlpha) * ratio
        )
    }
}

import UIKit

extension UIColor {

    func convert(to color: UIColor, multiplier _multiplier: CGFloat) -> UIColor? {
        let multiplier = min(max(_multiplier, 0), 1)

        var components = cgColor.components ?? []
        var toComponents = color.cgColor.components ?? []

        if cgColor.colorSpace!.model == CGColorSpaceModel.monochrome {
            components = [ components[0], components[0], components[0], components[1]]
        }
        
        if color.cgColor.colorSpace!.model == CGColorSpaceModel.monochrome {
            toComponents = [ toComponents[0], toComponents[0], toComponents[0], toComponents[1]]
        }
        
        if components.isEmpty || components.count < 3 || toComponents.isEmpty || toComponents.count < 3 {
            return nil
        }

        var results: [CGFloat] = []

        for index in 0...3 {
            let result = (toComponents[index] - components[index]) * abs(multiplier) + components[index]
            results.append(result)
        }

        return UIColor(red: results[0], green: results[1], blue: results[2], alpha: results[3])
    }
}

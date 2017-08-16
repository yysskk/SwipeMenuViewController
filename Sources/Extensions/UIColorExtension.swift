//
//  UIColorExtension.swift
//  SwipeMenuViewController
//
//  Created by 森下 侑亮 on 2017/08/15.
//  Copyright © 2017年 yysskk. All rights reserved.
//

import UIKit

extension UIColor {

    func convert(to color: UIColor, multiplier _multiplier: CGFloat) -> UIColor? {
        let multiplier = min(max(_multiplier, 0), 1)

        let components = cgColor.components ?? []
        let toComponents = color.cgColor.components ?? []

        if components.isEmpty || components.count < 3 || toComponents.isEmpty || toComponents.count < 3 {
            return nil
        }

        let results = (0...3).map { (toComponents[$0] - components[$0]) * abs(multiplier) + components[$0] }
        return UIColor(red: results[0], green: results[1], blue: results[2], alpha: results[3])
    }
}

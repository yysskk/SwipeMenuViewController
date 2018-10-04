//
//  UIEdgeInsetsExtension.swift
//  SwipeMenuViewController
//
//  Created by Yusuke Morishia on 2018/06/17.
//  Copyright © 2018年 yysskk. All rights reserved.
//

import UIKit

extension UIEdgeInsets {

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    var horizontal: CGFloat {
        return left + right
    }

    var vertical: CGFloat {
        return top + bottom
    }
}

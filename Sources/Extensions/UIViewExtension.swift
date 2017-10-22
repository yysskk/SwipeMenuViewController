//
//  UIViewExtension.swift
//  SwipeMenuViewController
//
//  Created by 森下 侑亮 on 2017/10/22.
//  Copyright © 2017年 yysskk. All rights reserved.
//

import UIKit

extension UIView {

    var hasSafeAreaInsets: Bool {
        guard #available (iOS 11, *) else { return false }
        return safeAreaInsets != .zero
    }
}

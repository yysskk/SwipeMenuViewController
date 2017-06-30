//
//  PageViewController.swift
//  SwipeMenuViewController
//
//  Created by 森下 侑亮 on 2017/06/30.
//  Copyright © 2017年 yysskk. All rights reserved.
//

import UIKit

open class PageViewController: UIPageViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

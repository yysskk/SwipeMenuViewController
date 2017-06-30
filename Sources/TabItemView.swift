//
//  TabItemView.swift
//  SwipeMenuViewController
//
//  Created by 森下 侑亮 on 2017/06/22.
//  Copyright © 2017年 yysskk. All rights reserved.
//

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

    // MARK: - Lifecycle
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
    }
}

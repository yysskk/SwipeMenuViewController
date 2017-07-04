
import UIKit

public protocol TabViewDelegate {
}

public protocol TabViewDataSource {

    func numberOfPages(in tabView: TabView) -> Int

    func tabView(_ tabView: TabView, viewForTitleinTabItem page: Int) -> String?

}

open class TabView: UIScrollView {

    open var dataSource: TabViewDataSource!

    var itemViews: [TabItemView] = []

    fileprivate let contentView: UIStackView = UIStackView()

    var currentItemView: TabItemView = TabItemView()

    var underlineView: UIView!

    open var isUnderlineViewHidden: Bool = false {
        didSet {
            underlineView.isHidden = isUnderlineViewHidden
        }
    }

    var itemCount: Int {
        return itemViews.count
    }

    fileprivate var currentIndex: Int = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func didMoveToSuperview() {
        setup()
    }

    deinit { }

    // MARK: - Setup

    fileprivate func setup() {
        setupScrollView()
        setupContentView()
        setupTabItemViews()
        setupUnderlineView()
    }

    fileprivate func setupScrollView() {
        backgroundColor = .black
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = true
        isDirectionalLockEnabled = true
        alwaysBounceHorizontal = false
        scrollsToTop = false
        translatesAutoresizingMaskIntoConstraints = false
    }

    fileprivate func setupContentView() {
        let itemCount = dataSource.numberOfPages(in: self)
        contentSize = CGSize(width: 100 * itemCount, height: 44)
        contentView.frame = CGRect(x: 0, y: 0, width: CGFloat(100 * itemCount), height: frame.height - 2)
        contentView.axis = .horizontal
        contentView.backgroundColor = .clear
        contentView.distribution = .fillEqually
        addSubview(contentView)
    }

    fileprivate func setupTabItemViews() {
        let itemCount = dataSource.numberOfPages(in: self)
        for index in 0..<itemCount {
            let tabItemView = TabItemView(frame: CGRect(x: 0, y: 0, width: 100, height: frame.height - 2))
            tabItemView.translatesAutoresizingMaskIntoConstraints = false
            tabItemView.backgroundColor = .black
            if let title = dataSource.tabView(self, viewForTitleinTabItem: index) {
                tabItemView.titleLabel.text = title
            }
            tabItemView.isSelected = index == 0
            contentView.addArrangedSubview(tabItemView)

            itemViews.append(tabItemView)
        }
    }

    fileprivate func setupUnderlineView() {
        let itemView = itemViews[0]
        underlineView = UIView(frame: CGRect(x: itemView.frame.minX, y: itemView.frame.height, width: itemView.frame.width, height: 2))
        underlineView.backgroundColor = UIColor(red: 111/255, green: 185/255, blue: 0, alpha: 1.0)
        addSubview(underlineView)
    }


    fileprivate func layoutTabItemViews() {
        NSLayoutConstraint.deactivate(contentView.constraints)

        for (index, tabItemView) in itemViews.enumerated() {
            if index == 0 {
                // H:|[tabItemView]
                tabItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            } else  {
                if index == itemViews.count - 1 {
                    // H:[tabItemView]|
                    tabItemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
                }
                // H:[previousTabItemView][tabItemView]
                let previousTabItemView = itemViews[index - 1]
                previousTabItemView.trailingAnchor.constraint(equalTo: tabItemView.leadingAnchor, constant: 0).isActive = true
            }

            // V:|[tabItemView]|
            NSLayoutConstraint.activate([
                tabItemView.topAnchor.constraint(equalTo: contentView.topAnchor),
                tabItemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                ])
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    fileprivate func focus(on target: TabItemView) {
        let offset = target.center.x - self.frame.width / 2
        if offset < 0 {
            self.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if contentView.frame.width - self.frame.width < offset {
            self.setContentOffset(CGPoint(x: contentView.frame.width - self.frame.width, y: 0), animated: true)
        }else {
            self.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }

    func animateUnderlineView(index: Int) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] _ in
            if let target = self?.itemViews[index] {
                self?.underlineView.frame.origin.x = target.frame.minX
                self?.focus(on: target)
            }
        }, completion: { _ in

        })
    }
}

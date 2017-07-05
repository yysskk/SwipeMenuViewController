
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

    var itemCount: Int {
        return itemViews.count
    }

    fileprivate var currentIndex: Int = 0

    fileprivate var options: SwipeMenuViewOptions.TabView = SwipeMenuViewOptions.TabView()

    public init(frame: CGRect, options: SwipeMenuViewOptions.TabView? = nil) {
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

        switch options.style {
        case .underline:
            setupUnderlineView()
        case .none:
            break
        }
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
        let contentWidth = options.itemView.width * CGFloat(itemCount)
        contentSize = CGSize(width: contentWidth, height: options.height)
        contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: frame.height - options.underlineView.height)
        contentView.axis = .horizontal
        contentView.backgroundColor = .clear
        contentView.distribution = .fillEqually
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        layout(contentView: contentView, contentWidth: contentWidth)
    }

    fileprivate func setupTabItemViews() {
        let itemCount = dataSource.numberOfPages(in: self)
        for index in 0..<itemCount {
            let tabItemView = TabItemView(frame: CGRect(x: 0, y: 0, width: options.itemView.width, height: frame.height - options.underlineView.height))
            tabItemView.translatesAutoresizingMaskIntoConstraints = false
            tabItemView.backgroundColor = options.backgroundColor
            if let title = dataSource.tabView(self, viewForTitleinTabItem: index) {
                tabItemView.titleLabel.text = title
            }
            tabItemView.isSelected = index == 0
            contentView.addArrangedSubview(tabItemView)

            itemViews.append(tabItemView)
        }
    }

    private func layout(contentView: UIStackView, contentWidth: CGFloat) {
        self.addConstraints([
            NSLayoutConstraint(
                item: contentView,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: 0.0),

            NSLayoutConstraint(
                item: contentView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: options.underlineView.height),

            NSLayoutConstraint(
                item: contentView,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .width,
                multiplier: 1,
                constant: contentWidth),

            NSLayoutConstraint(
                item: contentView,
                attribute: .height,
                relatedBy: .equal,
                toItem:  nil,
                attribute: .height,
                multiplier: 1,
                constant: options.height - options.underlineView.height)
            ])
    }

    fileprivate func focus(on target: TabItemView) {
        let offset = target.center.x - self.frame.width / 2
        if offset < 0 || self.frame.width > contentView.frame.width {
            self.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if contentView.frame.width - self.frame.width < offset {
            self.setContentOffset(CGPoint(x: contentView.frame.width - self.frame.width, y: 0), animated: true)
        }else {
            self.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }
}

// MARK: - UnderlineView

extension TabView {

    fileprivate func setupUnderlineView() {
        if itemViews.isEmpty { return }

        let itemView = itemViews[0]
        underlineView = UIView(frame: CGRect(x: itemView.frame.minX, y: itemView.frame.height, width: itemView.frame.width, height: options.underlineView.height))
        underlineView.backgroundColor = options.underlineView.backgroundColor
        addSubview(underlineView)
    }

    public func animateUnderlineView(index: Int) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] _ in
            if let target = self?.itemViews[index] {
                self?.underlineView.frame.origin.x = target.frame.minX
                self?.focus(on: target)
            }
        })
    }
}

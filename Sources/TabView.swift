
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

    fileprivate let contentView: UIView = UIView()

    var currentItemView: TabItemView = TabItemView()

    var underlineView: UIView!

    var cacheAdjustCellSizes: [CGSize] = []

    var itemCount: Int {
        return itemViews.count
    }

    fileprivate var currentIndex: Int = 0

    fileprivate var options: SwipeMenuViewOptions.TabView = SwipeMenuViewOptions.TabView()

    public init(frame: CGRect, options: SwipeMenuViewOptions.TabView? = nil) {
        super.init(frame: frame)

        if let options = options {
            self.options = options
        }
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
        backgroundColor = options.backgroundColor
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = true
        isDirectionalLockEnabled = true
        alwaysBounceHorizontal = false
        scrollsToTop = false
        bouncesZoom = false
        translatesAutoresizingMaskIntoConstraints = false
    }

    fileprivate func setupContentView() {
        let itemCount = dataSource.numberOfPages(in: self)
        let contentWidth = options.itemView.width * CGFloat(itemCount)
        contentSize = CGSize(width: contentWidth, height: options.height)
        contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: frame.height - options.underlineView.height)
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
    }

    fileprivate func setupTabItemViews() {
        let itemCount = dataSource.numberOfPages(in: self)

        var xPosition: CGFloat = 0

        for index in 0..<itemCount {
            let tabItemView = TabItemView(frame: CGRect(x: xPosition, y: 0, width: options.itemView.width, height: frame.height - options.underlineView.height))
            tabItemView.translatesAutoresizingMaskIntoConstraints = false
            tabItemView.backgroundColor = options.backgroundColor
            if let title = dataSource.tabView(self, viewForTitleinTabItem: index) {
                tabItemView.titleLabel.text = title
            }

            tabItemView.isSelected = index == 0

            if options.isAdjustItemWidth {
                var adjustCellSize = tabItemView.frame.size
                adjustCellSize.width = tabItemView.titleLabel.sizeThatFits(contentView.frame.size).width + options.itemView.margin * 2
                tabItemView.frame.size = adjustCellSize
                cacheAdjustCellSizes.append(adjustCellSize)

                contentView.addSubview(tabItemView)
                itemViews.append(tabItemView)

                NSLayoutConstraint.activate([
                    tabItemView.widthAnchor.constraint(equalToConstant: adjustCellSize.width)
                ])
            } else {
                contentView.addSubview(tabItemView)
                itemViews.append(tabItemView)

                NSLayoutConstraint.activate([
                    tabItemView.widthAnchor.constraint(equalToConstant: options.itemView.width)
                ])
            }

            NSLayoutConstraint.activate([
                tabItemView.topAnchor.constraint(equalTo: contentView.topAnchor),
                tabItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xPosition),
                tabItemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])

            xPosition += tabItemView.frame.size.width
        }

        layout(contentView: contentView, contentWidth: xPosition)
    }

    private func layout(contentView: UIView, contentWidth: CGFloat) {

        self.contentSize.width = contentWidth
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.widthAnchor.constraint(equalToConstant: contentWidth),
            contentView.heightAnchor.constraint(equalToConstant: options.height - options.underlineView.height)
        ])

        self.layoutIfNeeded()
        self.layoutSubviews()

        print(contentSize.width)
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
        UIView.animate(withDuration: 0.3, animations: { _ in
            let target = self.itemViews[index]
            self.underlineView.frame.origin.x = target.frame.origin.x

            if self.options.isAdjustItemWidth {
                self.underlineView.frame.size.width = self.cacheAdjustCellSizes[index].width
            }

            self.focus(on: target)
        })
    }
}

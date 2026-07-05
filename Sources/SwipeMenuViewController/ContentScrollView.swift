import UIKit

public protocol ContentScrollViewDataSource {

    func numberOfPages(in contentScrollView: ContentScrollView) -> Int

    func contentScrollView(_ contentScrollView: ContentScrollView, viewForPageAt index: Int) -> UIView?
}

open class ContentScrollView: UIScrollView {

    open var dataSource: ContentScrollViewDataSource?

    fileprivate var pageViews: [UIView] = []

    fileprivate var currentIndex: Int = 0

    fileprivate var options: SwipeMenuViewOptions.ContentScrollView = SwipeMenuViewOptions.ContentScrollView()

    public init(frame: CGRect, default defaultIndex: Int, options: SwipeMenuViewOptions.ContentScrollView? = nil) {
        super.init(frame: frame)

        currentIndex = defaultIndex

        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }

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

    override open func layoutSubviews() {
        super.layoutSubviews()

        self.contentSize = CGSize(width: frame.width * CGFloat(pageViews.count), height: frame.height)
    }

    public func reset() {
        pageViews = []
        currentIndex = 0
    }

    public func reload() {
        self.didMoveToSuperview()
    }

    public func update(_ newIndex: Int) {
        currentIndex = newIndex
    }

    // MARK: - Setup

    fileprivate func setup() {

        guard let dataSource = dataSource else { return }
        if dataSource.numberOfPages(in: self) <= 0 { return }

        setupScrollView()
        setupPages()
    }

    fileprivate func setupScrollView() {
        backgroundColor = options.backgroundColor
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = options.isScrollEnabled
        isPagingEnabled = true
        isDirectionalLockEnabled = false
        alwaysBounceHorizontal = false
        scrollsToTop = false
        bounces = false
        bouncesZoom = false
        setContentOffset(.zero, animated: false)
    }

    private func setupPages() {
        pageViews = []

        guard let dataSource = dataSource, dataSource.numberOfPages(in: self) > 0 else { return }

        self.contentSize = CGSize(width: frame.width * CGFloat(dataSource.numberOfPages(in: self)), height: frame.height)

        for i in 0...currentIndex {
            guard let pageView = dataSource.contentScrollView(self, viewForPageAt: i) else { return }
            pageViews.append(pageView)
            addSubview(pageView)

            let leadingAnchor = i > 0 ? pageViews[i - 1].trailingAnchor : self.leadingAnchor
            pageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pageView.topAnchor.constraint(equalTo: self.topAnchor),
                pageView.widthAnchor.constraint(equalTo: self.widthAnchor),
                pageView.heightAnchor.constraint(equalTo: self.heightAnchor),
                pageView.leadingAnchor.constraint(equalTo: leadingAnchor)
            ])
        }

        guard currentIndex < dataSource.numberOfPages(in: self) else { return }
        for i in (currentIndex + 1)..<dataSource.numberOfPages(in: self) {
            guard let pageView = dataSource.contentScrollView(self, viewForPageAt: i) else { return }
            pageViews.append(pageView)
            addSubview(pageView)

            pageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pageView.topAnchor.constraint(equalTo: self.topAnchor),
                pageView.widthAnchor.constraint(equalTo: self.widthAnchor),
                pageView.heightAnchor.constraint(equalTo: self.heightAnchor),
                pageView.leadingAnchor.constraint(equalTo: pageViews[i - 1].trailingAnchor)
            ])
        }
    }
}

extension ContentScrollView {

    var currentPage: UIView? {

        if currentIndex < pageViews.count && currentIndex >= 0 {
            return pageViews[currentIndex]
        }

        return nil
    }

    var nextPage: UIView? {

        if currentIndex < pageViews.count - 1 {
            return pageViews[currentIndex + 1]
        }

        return nil
    }

    var previousPage: UIView? {

        if currentIndex > 0 {
            return pageViews[currentIndex - 1]
        }

        return nil
    }

    public func jump(to index: Int, animated: Bool) {
        update(index)
        self.setContentOffset(CGPoint(x: self.frame.width * CGFloat(currentIndex), y: 0), animated: animated)
    }
}

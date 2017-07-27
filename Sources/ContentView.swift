import UIKit

public protocol ContentScrollViewDataSource {

    func numberOfPages(in contentScrollView: ContentScrollView) -> Int

    func contentScrollView(_ contentScrollView: ContentScrollView, viewForPageAt index: Int) -> UIView?
}

open class ContentScrollView: UIScrollView {

    open var dataSource: ContentScrollViewDataSource?

    fileprivate var pageViews: [UIView] = []

    fileprivate let containerView: UIView = UIView()

    fileprivate var currentIndex: Int = 0

    fileprivate var options: SwipeMenuViewOptions.ContentScrollView = SwipeMenuViewOptions.ContentScrollView()

    public init(frame: CGRect, options: SwipeMenuViewOptions.ContentScrollView? = nil) {
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

        guard let dataSource = dataSource else { return }
        if dataSource.numberOfPages(in: self) <= 0 { return }

        setupScrollView()
        setupContainerView()
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

    private func setupContainerView() {
        let itemCount = dataSource?.numberOfPages(in: self) ?? 0
        let containerWidth = frame.width * CGFloat(itemCount)
        contentSize = CGSize(width: containerWidth, height: frame.height)
        containerView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: frame.height)
        containerView.backgroundColor = .clear
        addSubview(containerView)

        self.contentSize.width = containerWidth

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.widthAnchor.constraint(equalToConstant: containerWidth),
            containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }

    private func setupPages() {

        guard let dataSource = dataSource else { return }

        var xPosition: CGFloat = 0

        for index in 0..<dataSource.numberOfPages(in: self) {
            guard let pageView = dataSource.contentScrollView(self, viewForPageAt: index) else { return }
            pageView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(pageView)
            pageViews.append(pageView)

            pageView.translatesAutoresizingMaskIntoConstraints = false
            if index == 0 {
                NSLayoutConstraint.activate([
                    pageViews[index].topAnchor.constraint(equalTo: containerView.topAnchor),
                    pageViews[index].widthAnchor.constraint(equalTo: self.widthAnchor),
                    pageViews[index].heightAnchor.constraint(equalTo: containerView.heightAnchor),
                    pageViews[index].leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    pageViews[pageViews.count-1].trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
                    ])
            } else {
                NSLayoutConstraint.activate([
                    pageView.topAnchor.constraint(equalTo: containerView.topAnchor),
                    pageView.widthAnchor.constraint(equalTo: self.widthAnchor),
                    pageView.heightAnchor.constraint(equalTo: containerView.heightAnchor),
                    pageView.leadingAnchor.constraint(equalTo: pageViews[index - 1].trailingAnchor),
                    pageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                    ])
            }

            xPosition += pageView.frame.size.width
        }
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

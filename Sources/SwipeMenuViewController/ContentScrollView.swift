import UIKit

/// A main-actor-isolated protocol that provides page views to a ``ContentScrollView``.
///
/// Because the protocol is `@MainActor`-isolated, every method is called on the main actor.
@MainActor public protocol ContentScrollViewDataSource: AnyObject {

    /// Returns the number of pages.
    /// - Parameter contentScrollView: The content scroll view requesting the count.
    /// - Returns: The total number of pages.
    func numberOfPages(in contentScrollView: ContentScrollView) -> Int

    /// Returns the view displayed for the given page.
    /// - Parameters:
    ///   - contentScrollView: The content scroll view requesting the page view.
    ///   - index: The index of the page.
    /// - Returns: The view for the page at `index`, or `nil` if none is available.
    func contentScrollView(_ contentScrollView: ContentScrollView, viewForPageAt index: Int) -> UIView?
}

/// The horizontally paging scroll view that hosts the page views of a ``SwipeMenuView``.
///
/// A `ContentScrollView` lays out one page per item supplied by its data source and pages
/// between them. It is created and managed by ``SwipeMenuView``; you normally do not
/// instantiate it directly.
open class ContentScrollView: UIScrollView {

    /// The data source that provides the page views.
    open weak var dataSource: ContentScrollViewDataSource?

    fileprivate var pageViews: [UIView] = []

    fileprivate var currentIndex: Int = 0

    fileprivate var options: SwipeMenuViewOptions.ContentScrollView = SwipeMenuViewOptions.ContentScrollView()

    /// Creates a content scroll view with the given frame, initial page, and options.
    /// - Parameters:
    ///   - frame: The frame rectangle for the view.
    ///   - defaultIndex: The index of the page shown initially.
    ///   - options: The appearance and behavior options. Pass `nil` to use the defaults.
    public init(frame: CGRect, default defaultIndex: Int, options: SwipeMenuViewOptions.ContentScrollView? = nil) {
        super.init(frame: frame)

        currentIndex = defaultIndex

        self.contentInsetAdjustmentBehavior = .never

        if let options = options {
            self.options = options
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        // Skip the rebuild when the view is being removed (superview is nil).
        guard superview != nil else { return }
        setup()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        self.contentSize = CGSize(width: frame.width * CGFloat(pageViews.count), height: frame.height)
    }

    /// Removes all page views and resets the current index to zero.
    public func reset() {
        pageViews = []
        currentIndex = 0
    }

    /// Rebuilds the page views from the data source.
    public func reload() {
        self.didMoveToSuperview()
    }

    /// Updates the tracked current page index without changing the scroll offset.
    /// - Parameter newIndex: The new current page index.
    public func update(_ newIndex: Int) {
        currentIndex = newIndex
    }

    // MARK: - Setup

    fileprivate func setup() {

        guard let dataSource else { return }
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

        guard let dataSource else { return }
        let pageCount = dataSource.numberOfPages(in: self)
        guard pageCount > 0 else { return }

        contentSize = CGSize(width: frame.width * CGFloat(pageCount), height: frame.height)

        // Build every page in order and pin each one after the previous, so an
        // out-of-range `currentIndex` can never make us ask the data source for a
        // page that does not exist.
        for index in 0..<pageCount {
            guard let pageView = dataSource.contentScrollView(self, viewForPageAt: index) else { return }
            pageViews.append(pageView)
            addSubview(pageView)

            let leadingAnchor = index > 0 ? pageViews[index - 1].trailingAnchor : self.leadingAnchor
            pageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pageView.topAnchor.constraint(equalTo: self.topAnchor),
                pageView.widthAnchor.constraint(equalTo: self.widthAnchor),
                pageView.heightAnchor.constraint(equalTo: self.heightAnchor),
                pageView.leadingAnchor.constraint(equalTo: leadingAnchor)
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

    /// Scrolls directly to the page at the given index.
    /// - Parameters:
    ///   - index: The index of the page to display.
    ///   - animated: Whether the scroll is animated.
    public func jump(to index: Int, animated: Bool) {
        update(index)
        self.setContentOffset(CGPoint(x: self.frame.width * CGFloat(currentIndex), y: 0), animated: animated)
    }
}

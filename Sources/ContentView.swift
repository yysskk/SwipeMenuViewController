
import UIKit

public protocol ContentViewDataSource {

    func numberOfPages(in contentView: ContentView) -> Int

    func contentView(_ contentView: ContentView, viewForPageAt index: Int) -> UIView?
}

protocol Pagable {

    var currentPage: UIView { get }
    var nextPage: UIView? { get }
    var previousPage: UIView? { get }

    func jump(to index: Int)
}

open class ContentView: UIScrollView {

    open var dataSource: ContentViewDataSource?

    var pageViews: [UIView] = []
    fileprivate let containerView: UIView = UIView()

    var pageCount: Int {
        return pageViews.count
    }

    fileprivate var currentIndex: Int = 0

    fileprivate var options: SwipeMenuViewOptions.ContentView = SwipeMenuViewOptions.ContentView()

    public init(frame: CGRect, options: SwipeMenuViewOptions.ContentView? = nil) {
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
        bounces = options.bounces
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
            guard let pageView = dataSource.contentView(self, viewForPageAt: index) else { return }
            pageView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(pageView)
            pageViews.append(pageView)

            pageView.translatesAutoresizingMaskIntoConstraints = false
            if index > 0 {
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

        NSLayoutConstraint.activate([
            pageViews[0].topAnchor.constraint(equalTo: containerView.topAnchor),
            pageViews[0].widthAnchor.constraint(equalTo: self.widthAnchor),
            pageViews[0].heightAnchor.constraint(equalTo: containerView.heightAnchor),
            pageViews[0].leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageViews[pageCount-1].trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }

    public func layout() {

        var xPosition: CGFloat = 0

        for pageView in pageViews {

            pageView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                pageView.topAnchor.constraint(equalTo: self.topAnchor),
                pageView.widthAnchor.constraint(equalToConstant: self.frame.size.width),
                pageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: xPosition),
                pageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])

            xPosition += pageView.frame.size.width
        }

        NSLayoutConstraint.activate([
            pageViews[pageCount-1].trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        contentSize.width = xPosition

        self.layoutIfNeeded()
        self.layoutSubviews()
    }

    public func reset() {
        pageViews = []
        currentIndex = 0
    }

    public func reload() {

        self.didMoveToSuperview()
    }

    /// update currentIndex
    /// parameter index : newIndex
    public func update(_ newIndex: Int) {
        currentIndex = newIndex
    }

    public func animate(to index: Int) {
        update(index)
        self.setContentOffset(CGPoint(x: self.frame.width * CGFloat(currentIndex), y: 0), animated: true)
    }
}

extension ContentView: Pagable {

    var currentPage: UIView {
        if currentIndex < pageCount && currentIndex >= 0 {
            return pageViews[currentIndex]
        } else {
            return UIView()
        }
    }

    var nextPage: UIView? {

        if currentIndex < pageCount - 1 {
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

    public func jump(to index: Int) {

        update(index)
        self.setContentOffset(CGPoint(x: self.frame.width * CGFloat(currentIndex), y: 0), animated: false)
    }
}

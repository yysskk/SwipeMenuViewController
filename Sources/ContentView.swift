
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

        setupScrollView()
        setupPages()
    }

    fileprivate func setupScrollView() {
        backgroundColor = options.backgroundColor
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = true
        isDirectionalLockEnabled = true
        alwaysBounceHorizontal = false
        scrollsToTop = false
        bounces = false
        bouncesZoom = false
    }

    private func setupPages() {

        guard let dataSource = dataSource else { return }

        var xPosition: CGFloat = 0

        for index in 0..<dataSource.numberOfPages(in: self) {
            guard let pageView = dataSource.contentView(self, viewForPageAt: index) else { return }
            pageView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(pageView)
                pageViews.append(pageView)


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

        self.layoutIfNeeded()
        self.layoutSubviews()
    }
}

extension ContentView: Pagable {

    var currentPage: UIView {
        return dataSource?.contentView(self, viewForPageAt: currentIndex) ?? UIView()
    }

    var nextPage: UIView? {

        if currentIndex < pageCount - 1 {
            return dataSource?.contentView(self, viewForPageAt: currentIndex)
        }

        return nil
    }

    var previousPage: UIView? {

        if currentIndex > 0 {
            return dataSource?.contentView(self, viewForPageAt: currentIndex - 1)
        }

        return nil
    }

    func jump(to index: Int) {

        currentIndex = index

        self.setContentOffset(CGPoint(x: self.frame.width * CGFloat(currentIndex), y: 0), animated: true)
    }
}

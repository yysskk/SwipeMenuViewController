import UIKit

// MARK: - SwipeMenuViewOptions
public nonisolated struct SwipeMenuViewOptions: Sendable {

    public nonisolated struct TabView: Sendable {

        public nonisolated enum Style: Sendable {
            case flexible
            case segmented
            // TODO: case infinity
        }

        public nonisolated enum Addition: Sendable {
            case underline
            case circle
            case none
        }

        public nonisolated struct ItemView: Sendable {
            /// ItemView width. Defaults to `100.0`.
            public var width: CGFloat = 100.0

            /// ItemView side margin. Defaults to `5.0`.
            public var margin: CGFloat = 5.0

            /// ItemView font. Defaults to `14 pt as bold SystemFont`.
            public var font: UIFont = UIFont.boldSystemFont(ofSize: 14)

            /// ItemView clipsToBounds. Defaults to `true`.
            public var clipsToBounds: Bool = true

            /// ItemView textColor. Defaults to `.lightGray`.
            public var textColor: UIColor = UIColor(red: 170 / 255, green: 170 / 255, blue: 170 / 255, alpha: 1.0)

            /// ItemView selected textColor. Defaults to `.black`.
            public var selectedTextColor: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }

        public nonisolated struct AdditionView: Sendable {

            public nonisolated struct Underline: Sendable {
                /// Underline height if addition style select `.underline`. Defaults to `2.0`.
                public var height: CGFloat = 2.0
            }

            public nonisolated struct Circle: Sendable {
                /// Circle cornerRadius if addition style select `.circle`. Defaults to `nil`.
                /// `AdditionView.height / 2` in the case of nil.
                public var cornerRadius: CGFloat? = nil
                
                /// Circle maskedCorners if addition style select `.circle`. Defaults to `nil`.
                /// It helps to make specific corners rounded.
                public var maskedCorners: CACornerMask? = nil
            }

            /// AdditionView paddings. Defaults to `.zero`.
            public var padding: UIEdgeInsets = .zero
            
            /// AdditionView backgroundColor. Defaults to `.black`.
            public var backgroundColor: UIColor = .black
            
            /// AdditionView animating duration. Defaults to `0.3`.
            public var animationDuration: Double = 0.3
            
            /// AdditionView swipe animation disable feature. Defaults to 'true'
            public var isAnimationOnSwipeEnable: Bool = true

            /// Underline style options.
            public var underline = Underline()
            
            /// Circle style options.
            public var circle = Circle()
        }

        /// TabView height. Defaults to `44.0`.
        public var height: CGFloat = 44.0

        /// TabView side margin. Defaults to `0.0`.
        public var margin: CGFloat = 0.0

        /// TabView background color. Defaults to `.clear`.
        public var backgroundColor: UIColor = .clear

        /// TabView clipsToBounds. Defaults to `true`.
        public var clipsToBounds: Bool = true

        /// TabView style. Defaults to `.flexible`. Style type has [`.flexible` , `.segmented`].
        public var style: Style = .flexible

        /// TabView addition. Defaults to `.underline`. Addition type has [`.underline`, `.circle`, `.none`].
        public var addition: Addition = .underline

        /// TabView adjust width or not. Defaults to `true`.
        public var needsAdjustItemViewWidth: Bool = true

        /// Convert the text color of ItemView to selected text color by scroll rate of ContentScrollView. Defaults to `true`.
        public var needsConvertTextColorRatio: Bool = true

        /// TabView enable safeAreaLayout. Defaults to `true`.
        public var isSafeAreaEnabled: Bool = true

        /// ItemView options
        public var itemView = ItemView()

        /// AdditionView options
        public var additionView = AdditionView()

        public init() { }
    }

    public nonisolated struct ContentScrollView: Sendable {

        /// ContentScrollView backgroundColor. Defaults to `.clear`.
        public var backgroundColor: UIColor = .clear

        /// ContentScrollView clipsToBounds. Defaults to `true`.
        public var clipsToBounds: Bool = true

        /// ContentScrollView scroll enabled. Defaults to `true`.
        public var isScrollEnabled: Bool = true

        /// ContentScrollView enable safeAreaLayout. Defaults to `true`.
        public var isSafeAreaEnabled: Bool = true
    }

    /// TabView and ContentScrollView Enable safeAreaLayout. Defaults to `true`.
    public var isSafeAreaEnabled: Bool = true {
        didSet {
            tabView.isSafeAreaEnabled = isSafeAreaEnabled
            contentScrollView.isSafeAreaEnabled = isSafeAreaEnabled
        }
    }

    /// TabView options
    public var tabView = TabView()

    /// ContentScrollView options
    public var contentScrollView = ContentScrollView()

    public init() { }
}

// MARK: - SwipeMenuViewDelegate

/// A main-actor-isolated protocol that responds to ``SwipeMenuView`` lifecycle and paging events.
///
/// All methods are optional; default no-op implementations are provided through a
/// protocol extension, so a conforming type only implements the callbacks it cares about.
/// Because the protocol is `@MainActor`-isolated, every method is called on the main actor.
@MainActor public protocol SwipeMenuViewDelegate: AnyObject {

    /// Called before the swipe menu view sets up its tab and content views.
    /// - Parameters:
    ///   - swipeMenuView: The swipe menu view that is about to be set up.
    ///   - currentIndex: The index that will be shown once setup finishes.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int)

    /// Called after the swipe menu view has finished setting up its tab and content views.
    /// - Parameters:
    ///   - swipeMenuView: The swipe menu view that finished setting up.
    ///   - currentIndex: The index that is now shown.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int)

    /// Called before the front page changes.
    /// - Parameters:
    ///   - swipeMenuView: The swipe menu view whose page is about to change.
    ///   - fromIndex: The index of the page currently in front.
    ///   - toIndex: The index of the page that will move to the front.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int)

    /// Called after the front page has changed.
    /// - Parameters:
    ///   - swipeMenuView: The swipe menu view whose page changed.
    ///   - fromIndex: The index of the page that was previously in front.
    ///   - toIndex: The index of the page now in front.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int)
}

extension SwipeMenuViewDelegate {
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) { }
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) { }
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) { }
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) { }
}

// MARK: - SwipeMenuViewDataSource

/// A main-actor-isolated protocol that provides pages and titles to a ``SwipeMenuView``.
///
/// A ``SwipeMenuView`` displays nothing until it is given a data source. Because the protocol
/// is `@MainActor`-isolated, every method is called on the main actor.
@MainActor public protocol SwipeMenuViewDataSource: AnyObject {

    /// Returns the number of pages in the swipe menu view.
    /// - Parameter swipeMenuView: The swipe menu view requesting the count.
    /// - Returns: The total number of pages.
    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int

    /// Returns the title displayed in the tab for the given page.
    /// - Parameters:
    ///   - swipeMenuView: The swipe menu view requesting the title.
    ///   - index: The index of the page.
    /// - Returns: The title for the tab at `index`.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String

    /// Returns the view controller whose view is displayed for the given page.
    /// - Parameters:
    ///   - swipeMenuView: The swipe menu view requesting the view controller.
    ///   - index: The index of the page.
    /// - Returns: The view controller for the page at `index`.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController
}

// MARK: - SwipeMenuView

/// A view that presents a scrollable tab bar above a horizontally paging content area.
///
/// Assign a ``dataSource`` to provide the pages and their titles, and optionally a
/// ``delegate`` to observe setup and paging events. The view builds its tab bar
/// (``tabView``) and paging area (``contentScrollView``) from the data source the first
/// time it is added to a superview, so it must be hosted inside a view hierarchy to
/// display anything. Appearance is configured through ``options``. Call
/// ``reloadData(options:default:isOrientationChange:)`` to rebuild the pages after the
/// data source changes.
open class SwipeMenuView: UIView {

    /// The delegate that receives ``SwipeMenuView`` setup and paging events.
    open weak var delegate: SwipeMenuViewDelegate?

    /// The data source that provides the pages and titles for the ``SwipeMenuView``.
    ///
    /// The view displays nothing until this is set.
    open weak var dataSource: SwipeMenuViewDataSource?

    /// The tab bar displayed above the content, or `nil` before the view is set up.
    open fileprivate(set) var tabView: TabView? {
        didSet {
            guard let tabView = tabView else { return }
            tabView.dataSource = self
            tabView.tabViewDelegate = self
            addSubview(tabView)
            layout(tabView: tabView)
        }
    }

    /// The horizontally paging scroll view that hosts the page views, or `nil` before the view is set up.
    open fileprivate(set) var contentScrollView: ContentScrollView? {
        didSet {
            guard let contentScrollView = contentScrollView else { return }
            contentScrollView.delegate = self
            contentScrollView.dataSource = self
            addSubview(contentScrollView)
            layout(contentScrollView: contentScrollView)
        }
    }

    /// The options that control the appearance and behavior of the tab bar and content area.
    public var options: SwipeMenuViewOptions

    fileprivate var isLayoutingSubviews: Bool = false

    fileprivate var pageCount: Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }

    fileprivate var isJumping: Bool = false
    fileprivate var isPortrait: Bool = true

    /// The index of the front page in `SwipeMenuView` (read only).
    open private(set) var currentIndex: Int = 0
    private var jumpingToIndex: Int?

    /// Creates a swipe menu view with the given frame and options.
    /// - Parameters:
    ///   - frame: The frame rectangle for the view.
    ///   - options: The appearance and behavior options. Pass `nil` to use the defaults.
    public init(frame: CGRect, options: SwipeMenuViewOptions? = nil) {

        if let options = options {
            self.options = options
        } else {
            self.options = .init()
        }

        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {

        self.options = .init()

        super.init(coder: aDecoder)
    }

    open override func layoutSubviews() {

        isLayoutingSubviews = true
        super.layoutSubviews()
        if !isJumping {
            reloadData(isOrientationChange: true)
        }
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()

        setup()
    }

    /// Rebuilds the tab bar and pages from the data source and refreshes the display.
    /// - Parameters:
    ///   - options: New options to apply before reloading. Pass `nil` to keep the current ``options``.
    ///   - defaultIndex: The page to show after reloading. Pass `nil` to keep the current ``currentIndex``.
    ///   - isOrientationChange: Pass `true` when reloading in response to an orientation change so the
    ///     view relayouts without resetting its state. Defaults to `false`.
    public func reloadData(options: SwipeMenuViewOptions? = nil, default defaultIndex: Int? = nil, isOrientationChange: Bool = false) {

        if let options = options {
            self.options = options
        }

        isLayoutingSubviews = isOrientationChange

        if !isLayoutingSubviews {
            reset()
            setup(default: defaultIndex ?? currentIndex)
        }

        jump(to: defaultIndex ?? currentIndex, animated: false)

        isLayoutingSubviews = false
    }

    /// Moves directly to the given page.
    ///
    /// After the call, ``currentIndex`` equals `index` and the delegate receives exactly one
    /// ``SwipeMenuViewDelegate/swipeMenuView(_:willChangeIndexFrom:to:)`` and one
    /// ``SwipeMenuViewDelegate/swipeMenuView(_:didChangeIndexFrom:to:)`` when the page actually
    /// changes. An `index` with no corresponding page is ignored.
    /// - Parameters:
    ///   - index: The index of the page to display.
    ///   - animated: Whether the content transition is animated.
    public func jump(to index: Int, animated: Bool) {
        guard let tabView = tabView, let contentScrollView = contentScrollView else { return }
        // Ignore indices that have no corresponding page rather than scrolling
        // into empty space (or trapping on a negative index).
        guard (0..<pageCount).contains(index) else { return }

        let fromIndex = currentIndex

        // The tab bar is repositioned immediately; only the content scroll honors `animated`.
        tabView.jump(to: index)

        guard fromIndex != index else {
            // Already on the target page; just keep the content offset aligned.
            contentScrollView.jump(to: index, animated: animated)
            return
        }

        delegate?.swipeMenuView(self, willChangeIndexFrom: fromIndex, to: index)

        // While the programmatic scroll runs, `isJumping` suppresses the
        // scroll-driven, one-page-at-a-time index updates in `scrollViewDidScroll(_:)`.
        isJumping = true
        jumpingToIndex = index
        contentScrollView.jump(to: index, animated: animated)

        if !animated {
            // A non-animated offset change fires no
            // `scrollViewDidEndScrollingAnimation(_:)`, so finalize synchronously.
            currentIndex = index
            jumpingToIndex = nil
            isJumping = false
            delegate?.swipeMenuView(self, didChangeIndexFrom: fromIndex, to: index)
        }
    }

    /// Notifies the view that an orientation change is about to occur so it can relayout.
    ///
    /// Call this from `viewWillTransition(to:with:)` before the size change takes effect.
    public func willChangeOrientation() {
        isLayoutingSubviews = true
        setNeedsLayout()
    }

    fileprivate func update(from fromIndex: Int, to toIndex: Int) {

        if !isLayoutingSubviews {
            delegate?.swipeMenuView(self, willChangeIndexFrom: fromIndex, to: toIndex)
        }

        tabView?.update(toIndex)
        contentScrollView?.update(toIndex)
        if !isJumping {
            // delay setting currentIndex until end scroll when jumping
            currentIndex = toIndex
        }

        if !isJumping && !isLayoutingSubviews {
            delegate?.swipeMenuView(self, didChangeIndexFrom: fromIndex, to: toIndex)
        }
    }

    // MARK: - Setup
    private func setup(default defaultIndex: Int = 0) {

        delegate?.swipeMenuView(self, viewWillSetupAt: defaultIndex)

        backgroundColor = .clear

        tabView = TabView(frame: CGRect(x: 0, y: 0, width: frame.width, height: options.tabView.height), options: options.tabView)
        tabView?.clipsToBounds = options.tabView.clipsToBounds

        contentScrollView = ContentScrollView(frame: CGRect(x: 0, y: options.tabView.height, width: frame.width, height: frame.height - options.tabView.height), default: defaultIndex, options: options.contentScrollView)
        contentScrollView?.clipsToBounds = options.contentScrollView.clipsToBounds

        tabView?.update(defaultIndex)
        contentScrollView?.update(defaultIndex)
        currentIndex = defaultIndex

        delegate?.swipeMenuView(self, viewDidSetupAt: defaultIndex)
    }

    private func layout(tabView: TabView) {

        tabView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: self.topAnchor),
            tabView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: options.tabView.height)
            ])
    }

    private func layout(contentScrollView: ContentScrollView) {

        contentScrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: options.tabView.height),
            contentScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
    }

    private func reset() {

        if !isLayoutingSubviews {
            currentIndex = 0
        }

        if let tabView = tabView, let contentScrollView = contentScrollView {
            tabView.removeFromSuperview()
            contentScrollView.removeFromSuperview()
            tabView.reset()
            contentScrollView.reset()
        }
    }
}

// MARK: - TabViewDelegate, TabViewDataSource

extension SwipeMenuView: TabViewDelegate, TabViewDataSource {

    public func tabView(_ tabView: TabView, didSelectTabAt index: Int) {

        guard let contentScrollView = contentScrollView,
            currentIndex != index else { return }

        isJumping = true
        jumpingToIndex = index

        contentScrollView.jump(to: index, animated: true)

        update(from: currentIndex, to: index)
    }

    public func numberOfItems(in menuView: TabView) -> Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }

    public func tabView(_ tabView: TabView, titleForItemAt index: Int) -> String? {
        return dataSource?.swipeMenuView(self, titleForPageAt: index)
    }
}

// MARK: - UIScrollViewDelegate

extension SwipeMenuView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if isJumping || isLayoutingSubviews { return }

        // update currentIndex
        if scrollView.contentOffset.x >= frame.width * CGFloat(currentIndex + 1) {
            update(from: currentIndex, to: currentIndex + 1)
        } else if scrollView.contentOffset.x <= frame.width * CGFloat(currentIndex - 1) {
            update(from: currentIndex, to: currentIndex - 1)
        }

        updateTabViewAddition(by: scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {

        if isJumping || isLayoutingSubviews {
            if let toIndex = jumpingToIndex {
                delegate?.swipeMenuView(self, didChangeIndexFrom: currentIndex, to: toIndex)
                currentIndex = toIndex
                jumpingToIndex = nil
            }
            isJumping = false
            isLayoutingSubviews = false
            return
        }

        updateTabViewAddition(by: scrollView)
    }

    /// update addition in tab view
    private func updateTabViewAddition(by scrollView: UIScrollView) {
        moveAdditionView(scrollView: scrollView)
    }

    /// update underbar position
    private func moveAdditionView(scrollView: UIScrollView) {

        if let tabView = tabView, let contentScrollView = contentScrollView {

            let ratio = scrollView.contentOffset.x.truncatingRemainder(dividingBy: contentScrollView.frame.width) / contentScrollView.frame.width

            switch scrollView.contentOffset.x {
            case let offset where offset >= frame.width * CGFloat(currentIndex):
                tabView.moveAdditionView(index: currentIndex, ratio: ratio, direction: .forward)
            case let offset where offset < frame.width * CGFloat(currentIndex):
                tabView.moveAdditionView(index: currentIndex, ratio: ratio, direction: .reverse)
            default:
                break
            }
        }
    }
}

// MARK: - ContentScrollViewDataSource

extension SwipeMenuView: ContentScrollViewDataSource {

    public func numberOfPages(in contentScrollView: ContentScrollView) -> Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }

    public func contentScrollView(_ contentScrollView: ContentScrollView, viewForPageAt index: Int) -> UIView? {
        return dataSource?.swipeMenuView(self, viewControllerForPageAt: index).view
    }
}

import UIKit

// MARK: - SwipeMenuViewOptions
public nonisolated struct SwipeMenuViewOptions: Sendable {

    public nonisolated struct TabView: Sendable {

        public nonisolated enum Style: Sendable {
            case flexible
            case segmented
        }

        public nonisolated enum Indicator: Sendable {
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

            /// ItemView font used while the item is selected. Defaults to `14 pt as bold SystemFont`,
            /// matching `font` so the title font does not change on selection unless you set this.
            ///
            /// This changes the selected title's appearance only; in the `.flexible` style each item's
            /// width is still measured with `font`, so a larger `selectedFont` may be truncated.
            public var selectedFont: UIFont = UIFont.boldSystemFont(ofSize: 14)

            /// ItemView clipsToBounds. Defaults to `true`.
            public var clipsToBounds: Bool = true

            /// ItemView textColor. Defaults to `.lightGray`.
            public var textColor: UIColor = UIColor(red: 170 / 255, green: 170 / 255, blue: 170 / 255, alpha: 1.0)

            /// ItemView selected textColor. Defaults to `.black`.
            public var selectedTextColor: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

            /// The maximum number of lines used to render the title. Use `0` to allow as many lines
            /// as the title needs. Titles that do not fit are truncated. Defaults to `1`.
            ///
            /// This is most useful with the `.segmented` style, where each item has a fixed width and
            /// a long title would otherwise be truncated onto a single line.
            public var numberOfLines: Int = 1
        }

        public nonisolated struct IndicatorView: Sendable {

            public nonisolated struct Underline: Sendable {
                /// The underline thickness when the indicator is `.underline`. Defaults to `2.0`.
                public var height: CGFloat = 2.0

                /// The corner radius of the underline when the indicator is `.underline`.
                /// Defaults to `0` (square corners). Set it to half of `height` for a pill shape.
                public var cornerRadius: CGFloat = 0
            }

            public nonisolated struct Circle: Sendable {
                /// The corner radius of the highlight when the indicator is `.circle`.
                /// Defaults to `nil`, which uses half the highlight's height (a capsule).
                public var cornerRadius: CGFloat?

                /// The corners rounded by `cornerRadius` when the indicator is `.circle`.
                /// Defaults to `nil`, which rounds all four corners.
                public var maskedCorners: CACornerMask?
            }

            /// The padding around the indicator view. Defaults to `.zero`.
            public var padding: UIEdgeInsets = .zero

            /// The indicator view's background color. Defaults to `.black`.
            public var backgroundColor: UIColor = .black

            /// The duration of the indicator's move animation, in seconds. Defaults to `0.3`.
            public var animationDuration: Double = 0.3

            /// Whether the indicator view continuously tracks the finger while the content is
            /// swiped. When `false`, it animates to the destination tab once the page changes
            /// instead. Defaults to `true`.
            public var isAnimationOnSwipeEnabled: Bool = true

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

        /// The selection indicator drawn on the selected tab: `.underline`, `.circle`,
        /// or `.none`. Defaults to `.underline`.
        public var indicator: Indicator = .underline

        /// Whether each `.flexible` item is sized to fit its title (plus ``ItemView/margin``
        /// on both sides) instead of using the fixed ``ItemView/width``. Defaults to `true`.
        public var adjustsItemViewWidth: Bool = true

        /// Whether tab titles crossfade between ``ItemView/textColor`` and
        /// ``ItemView/selectedTextColor`` in proportion to the swipe progress. When `false`,
        /// titles switch color only when the selection changes. Defaults to `true`.
        public var interpolatesTextColorOnSwipe: Bool = true

        /// TabView enable safeAreaLayout. Defaults to `true`.
        public var isSafeAreaEnabled: Bool = true

        /// ItemView options
        public var itemView = ItemView()

        /// IndicatorView options
        public var indicatorView = IndicatorView()

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

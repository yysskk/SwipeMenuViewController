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

        public nonisolated struct AdditionView: Sendable {

            public nonisolated struct Underline: Sendable {
                /// Underline height if addition style select `.underline`. Defaults to `2.0`.
                public var height: CGFloat = 2.0

                /// Corner radius of the underline if addition style select `.underline`.
                /// Defaults to `0` (square corners). Set it to half of `height` for a pill shape.
                public var cornerRadius: CGFloat = 0
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

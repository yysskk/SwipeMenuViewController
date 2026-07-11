import SwiftUI

// MARK: - SwipeMenuOptions

/// The appearance and behavior options for the SwiftUI ``SwipeMenu`` view.
///
/// `SwipeMenuOptions` mirrors ``SwipeMenuViewOptions`` with SwiftUI-native types:
/// colors are `Color`, fonts are `Font`, and insets are `EdgeInsets`. Options that
/// SwiftUI already owns at the container level — safe-area layout and clipping —
/// have no counterpart here; apply `ignoresSafeArea(_:edges:)` or `clipped()`
/// around a ``SwipeMenu`` instead.
@available(iOS 18.0, *)
public nonisolated struct SwipeMenuOptions: Sendable {

    public nonisolated struct TabView: Sendable {

        public nonisolated enum Style: Sendable {
            /// Tabs size themselves to their content and scroll horizontally.
            case flexible
            /// Tabs share the available width equally.
            case segmented
        }

        public nonisolated enum Indicator: Sendable {
            case underline
            case circle
            case none
        }

        public nonisolated struct ItemView: Sendable {
            /// ItemView width used when ``TabView/adjustsItemViewWidth`` is `false`.
            /// Defaults to `100.0`.
            public var width: CGFloat = 100.0

            /// The horizontal margin added on both sides of a self-sizing item's title.
            /// Defaults to `5.0`.
            public var margin: CGFloat = 5.0

            /// ItemView font. Defaults to a bold 14 pt system font.
            public var font: Font = .system(size: 14, weight: .bold)

            /// ItemView font used while the item is selected. Defaults to a bold 14 pt
            /// system font, matching ``font`` so the title font does not change on
            /// selection unless you set this.
            ///
            /// This changes the selected title's appearance only; in the `.flexible`
            /// style each item's width is still measured with ``font``, so a larger
            /// `selectedFont` may be truncated.
            public var selectedFont: Font = .system(size: 14, weight: .bold)

            /// ItemView text color. Defaults to a light gray.
            public var textColor: Color = Color(red: 170 / 255, green: 170 / 255, blue: 170 / 255)

            /// ItemView selected text color. Defaults to `.black`.
            public var selectedTextColor: Color = .black

            /// The maximum number of lines used to render the title. Use `0` to allow as
            /// many lines as the title needs. Titles that do not fit are truncated.
            /// Defaults to `1`.
            ///
            /// This is most useful with the `.segmented` style, where each item has a
            /// fixed width and a long title would otherwise be truncated onto a single line.
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
            }

            /// The padding around the indicator view. Defaults to zero insets.
            public var padding: EdgeInsets = EdgeInsets()

            /// The indicator view's background color. Defaults to `.black`.
            public var backgroundColor: Color = .black

            /// The duration of the indicator's move animation, in seconds. Defaults to `0.3`.
            public var animationDuration: Double = 0.3

            /// Whether the indicator view continuously tracks the finger while the content
            /// is swiped. When `false`, it animates to the destination tab once the page
            /// changes instead. Defaults to `true`.
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
        public var backgroundColor: Color = .clear

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

        /// ItemView options
        public var itemView = ItemView()

        /// IndicatorView options
        public var indicatorView = IndicatorView()

        public init() {}
    }

    public nonisolated struct ContentScrollView: Sendable {

        /// ContentScrollView backgroundColor. Defaults to `.clear`.
        public var backgroundColor: Color = .clear

        /// ContentScrollView scroll enabled. Defaults to `true`.
        public var isScrollEnabled: Bool = true
    }

    /// TabView options
    public var tabView = TabView()

    /// ContentScrollView options
    public var contentScrollView = ContentScrollView()

    public init() {}
}

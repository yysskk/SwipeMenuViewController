import UIKit
import SwipeMenuViewController

/// The user-adjustable configuration behind the example's swipe menu.
///
/// `SwipeMenuSettings` is a plain value type that captures every option the demo
/// lets you change and knows how to turn itself into a ``SwipeMenuViewOptions``
/// through ``makeOptions()``. Concentrating this logic in one small, `UIKit`-only
/// type — rather than spreading it across a view controller's actions — is what
/// lets the example ship with unit tests.
struct SwipeMenuSettings: Equatable {

    /// The tab bar layout style.
    enum Style: CaseIterable {
        /// Tabs size themselves to their content and scroll horizontally.
        case flexible
        /// Tabs share the available width equally.
        case segmented
    }

    /// The decoration that marks the selected tab.
    enum TabDecoration: CaseIterable {
        /// A bar drawn under the selected tab.
        case underline
        /// A filled pill drawn behind the selected tab.
        case circle
        /// No decoration.
        case none
    }

    /// The smallest number of pages the menu can show.
    static let minimumPageCount = 1
    /// The largest number of pages the `.flexible` style can show.
    static let flexiblePageLimit = 8
    /// The largest number of pages the `.segmented` style can show.
    ///
    /// Segmented tabs divide the width evenly, so the demo caps them at a count
    /// that stays comfortably readable.
    static let segmentedPageLimit = 4

    /// The number of pages shown in the menu.
    ///
    /// Expected to stay within `minimumPageCount...maximumPageCount`; ``setStyle(_:)``
    /// re-clamps it whenever the style changes.
    var pageCount = 5

    /// The tab bar layout style.
    private(set) var style = Style.flexible

    /// The decoration that marks the selected tab.
    var tabDecoration = TabDecoration.underline

    /// Whether `.flexible` tabs widen to fill the available width.
    var adjustsItemWidthToFit = true

    /// The fixed width of each tab when ``adjustsItemWidthToFit`` is `false`.
    var itemWidth: CGFloat = 100

    /// The side margin around the tab bar.
    var tabMargin: CGFloat = 0

    /// Whether the content area can be swiped between pages.
    var isContentScrollEnabled = true

    /// The largest page count allowed for the current ``style``.
    var maximumPageCount: Int {
        switch style {
        case .flexible: Self.flexiblePageLimit
        case .segmented: Self.segmentedPageLimit
        }
    }

    /// Updates the layout ``style`` and clamps ``pageCount`` to the new limit.
    ///
    /// Switching to `.segmented` can lower the page count, because a segmented bar
    /// shows fewer tabs than a flexible one.
    /// - Parameter newStyle: The style to adopt.
    mutating func setStyle(_ newStyle: Style) {
        style = newStyle
        pageCount = min(max(pageCount, Self.minimumPageCount), maximumPageCount)
    }

    /// Builds the ``SwipeMenuViewOptions`` described by these settings.
    ///
    /// Colors are resolved from semantic `UIColor`s so the menu adapts to light
    /// and dark appearances.
    /// - Returns: Options ready to hand to `SwipeMenuView.reloadData(options:)`.
    func makeOptions() -> SwipeMenuViewOptions {
        var options = SwipeMenuViewOptions()

        options.tabView.margin = tabMargin
        options.tabView.adjustsItemViewWidth = adjustsItemWidthToFit
        options.tabView.itemView.width = itemWidth
        options.tabView.itemView.textColor = .secondaryLabel
        options.tabView.indicatorView.backgroundColor = .label

        switch style {
        case .flexible: options.tabView.style = .flexible
        case .segmented: options.tabView.style = .segmented
        }

        switch tabDecoration {
        case .underline:
            options.tabView.indicator = .underline
            options.tabView.itemView.selectedTextColor = .label
        case .circle:
            options.tabView.indicator = .circle
            // The pill is filled with `.label`, so the title inverts to stay legible.
            options.tabView.itemView.selectedTextColor = .systemBackground
        case .none:
            options.tabView.indicator = .none
            options.tabView.itemView.selectedTextColor = .label
        }

        options.contentScrollView.isScrollEnabled = isContentScrollEnabled

        return options
    }
}

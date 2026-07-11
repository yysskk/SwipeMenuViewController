import SwiftUI
import SwipeMenuViewController

extension SwipeMenuSettings {

    /// Builds the ``SwipeMenuOptions`` for the SwiftUI ``SwipeMenu`` described by
    /// these settings — the SwiftUI counterpart of ``makeOptions()``.
    ///
    /// Colors are resolved from semantic `UIColor`s so the menu adapts to light
    /// and dark appearances.
    /// - Returns: Options ready to hand to a ``SwipeMenu``.
    func makeSwiftUIOptions() -> SwipeMenuOptions {
        var options = SwipeMenuOptions()

        options.tabView.margin = tabMargin
        options.tabView.adjustsItemViewWidth = adjustsItemWidthToFit
        options.tabView.itemView.width = itemWidth
        options.tabView.itemView.textColor = Color(.secondaryLabel)
        options.tabView.indicatorView.backgroundColor = Color(.label)

        switch style {
        case .flexible: options.tabView.style = .flexible
        case .segmented: options.tabView.style = .segmented
        }

        switch tabDecoration {
        case .underline:
            options.tabView.indicator = .underline
            options.tabView.itemView.selectedTextColor = Color(.label)
        case .circle:
            options.tabView.indicator = .circle
            // The pill is filled with `.label`, so the title inverts to stay legible.
            options.tabView.itemView.selectedTextColor = Color(.systemBackground)
        case .none:
            options.tabView.indicator = .none
            options.tabView.itemView.selectedTextColor = Color(.label)
        }

        options.contentScrollView.isScrollEnabled = isContentScrollEnabled

        return options
    }
}

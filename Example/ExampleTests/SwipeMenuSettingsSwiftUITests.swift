import SwiftUI
import SwipeMenuViewController
import Testing
import UIKit

@testable import Example

@Suite("SwipeMenuSettings+SwiftUI")
struct SwipeMenuSettingsSwiftUITests {

    @Test("Default settings map to the expected SwiftUI options")
    func defaultsMapToOptions() {
        let options = SwipeMenuSettings().makeSwiftUIOptions()

        #expect(options.tabView.style == .flexible)
        #expect(options.tabView.indicator == .underline)
        #expect(options.tabView.margin == 0)
        #expect(options.tabView.adjustsItemViewWidth)
        #expect(options.tabView.itemView.width == 100)
        #expect(options.tabView.itemView.textColor == Color(.secondaryLabel))
        #expect(options.tabView.indicatorView.backgroundColor == Color(.label))
        #expect(options.contentScrollView.isScrollEnabled)
    }

    @Test("The style is forwarded to the SwiftUI options")
    func styleIsForwarded() {
        var settings = SwipeMenuSettings()
        settings.setStyle(.segmented)

        #expect(settings.makeSwiftUIOptions().tabView.style == .segmented)
    }

    @Test("Each decoration maps to its indicator and a legible selected color")
    func decorationMapsToIndicatorAndColor() {
        var settings = SwipeMenuSettings()

        settings.tabDecoration = .underline
        var options = settings.makeSwiftUIOptions()
        #expect(options.tabView.indicator == .underline)
        #expect(options.tabView.itemView.selectedTextColor == Color(.label))

        settings.tabDecoration = .circle
        options = settings.makeSwiftUIOptions()
        #expect(options.tabView.indicator == .circle)
        #expect(options.tabView.itemView.selectedTextColor == Color(.systemBackground))

        settings.tabDecoration = .none
        options = settings.makeSwiftUIOptions()
        #expect(options.tabView.indicator == .none)
        #expect(options.tabView.itemView.selectedTextColor == Color(.label))
    }

    @Test("Continuous and boolean settings are forwarded to the SwiftUI options")
    func numericAndBooleanSettingsAreForwarded() {
        var settings = SwipeMenuSettings()
        settings.tabMargin = 12
        settings.itemWidth = 220
        settings.adjustsItemWidthToFit = false
        settings.isContentScrollEnabled = false

        let options = settings.makeSwiftUIOptions()

        #expect(options.tabView.margin == 12)
        #expect(options.tabView.itemView.width == 220)
        #expect(!options.tabView.adjustsItemViewWidth)
        #expect(!options.contentScrollView.isScrollEnabled)
    }
}

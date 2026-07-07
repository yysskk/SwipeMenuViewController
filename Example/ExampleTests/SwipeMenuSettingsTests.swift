import Testing
import UIKit
import SwipeMenuViewController
@testable import Example

@Suite("SwipeMenuSettings")
struct SwipeMenuSettingsTests {

    @Test("Default settings map to the expected options")
    func defaultsMapToOptions() {
        let options = SwipeMenuSettings().makeOptions()

        #expect(options.tabView.style == .flexible)
        #expect(options.tabView.addition == .underline)
        #expect(options.tabView.margin == 0)
        #expect(options.tabView.adjustsItemViewWidth)
        #expect(options.tabView.itemView.width == 100)
        #expect(options.contentScrollView.isScrollEnabled)
    }

    @Test("The page-count limit depends on the style")
    func maximumPageCountDependsOnStyle() {
        var settings = SwipeMenuSettings()

        settings.setStyle(.flexible)
        #expect(settings.maximumPageCount == SwipeMenuSettings.flexiblePageLimit)

        settings.setStyle(.segmented)
        #expect(settings.maximumPageCount == SwipeMenuSettings.segmentedPageLimit)
    }

    @Test("Switching to the segmented style clamps an over-limit page count")
    func segmentedStyleClampsPageCount() {
        var settings = SwipeMenuSettings()
        settings.pageCount = 8

        settings.setStyle(.segmented)

        #expect(settings.pageCount == SwipeMenuSettings.segmentedPageLimit)
    }

    @Test("Switching style leaves an in-range page count untouched")
    func inRangePageCountIsPreserved() {
        var settings = SwipeMenuSettings()
        settings.pageCount = 3

        settings.setStyle(.segmented)
        #expect(settings.pageCount == 3)

        settings.setStyle(.flexible)
        #expect(settings.pageCount == 3)
    }

    @Test("The style is forwarded to the options")
    func styleIsForwarded() {
        var settings = SwipeMenuSettings()
        settings.setStyle(.segmented)

        #expect(settings.makeOptions().tabView.style == .segmented)
    }

    @Test("Each decoration maps to its addition and a legible selected color")
    func decorationMapsToAdditionAndColor() {
        var settings = SwipeMenuSettings()

        settings.tabDecoration = .underline
        var options = settings.makeOptions()
        #expect(options.tabView.addition == .underline)
        #expect(options.tabView.itemView.selectedTextColor == UIColor.label)

        settings.tabDecoration = .circle
        options = settings.makeOptions()
        #expect(options.tabView.addition == .circle)
        #expect(options.tabView.itemView.selectedTextColor == UIColor.systemBackground)

        settings.tabDecoration = .none
        options = settings.makeOptions()
        #expect(options.tabView.addition == .none)
        #expect(options.tabView.itemView.selectedTextColor == UIColor.label)
    }

    @Test("Continuous and boolean settings are forwarded to the options")
    func numericAndBooleanSettingsAreForwarded() {
        var settings = SwipeMenuSettings()
        settings.tabMargin = 12
        settings.itemWidth = 220
        settings.adjustsItemWidthToFit = false
        settings.isContentScrollEnabled = false

        let options = settings.makeOptions()

        #expect(options.tabView.margin == 12)
        #expect(options.tabView.itemView.width == 220)
        #expect(!options.tabView.adjustsItemViewWidth)
        #expect(!options.contentScrollView.isScrollEnabled)
    }

    @Test("Resetting produces a value equal to a fresh instance")
    func defaultsAreEquatable() {
        #expect(SwipeMenuSettings() == SwipeMenuSettings())
    }
}

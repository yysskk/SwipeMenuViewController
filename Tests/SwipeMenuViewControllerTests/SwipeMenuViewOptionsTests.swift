import Testing
import UIKit
@testable import SwipeMenuViewController

/// Constructs a `SwipeMenuViewOptions` from a `nonisolated` context. That this
/// compiles proves the type is usable outside the main actor (i.e. it really is
/// `Sendable` and not main-actor isolated).
private nonisolated func makeOptionsFromNonisolatedContext() -> SwipeMenuViewOptions {
    return SwipeMenuViewOptions()
}

@Suite("SwipeMenuViewOptions")
struct SwipeMenuViewOptionsTests {

    @Test("TabView documented defaults")
    func tabViewDefaults() {
        let options = SwipeMenuViewOptions()

        #expect(options.tabView.height == 44.0)
        #expect(options.tabView.margin == 0.0)
        #expect(options.tabView.style == .flexible)
        #expect(options.tabView.indicator == .underline)
        #expect(options.tabView.adjustsItemViewWidth == true)
        #expect(options.tabView.interpolatesTextColorOnSwipe == true)
        #expect(options.tabView.isSafeAreaEnabled == true)
    }

    @Test("ItemView documented defaults")
    func itemViewDefaults() {
        let options = SwipeMenuViewOptions()

        #expect(options.tabView.itemView.width == 100.0)
        #expect(options.tabView.itemView.margin == 5.0)
        #expect(options.tabView.itemView.font == UIFont.boldSystemFont(ofSize: 14))
        // Defaults to the same font as `font`, so selection does not change the title font by default.
        #expect(options.tabView.itemView.selectedFont == UIFont.boldSystemFont(ofSize: 14))
        #expect(options.tabView.itemView.clipsToBounds == true)
        #expect(options.tabView.itemView.numberOfLines == 1)
    }

    @Test("IndicatorView documented defaults")
    func indicatorViewDefaults() {
        let options = SwipeMenuViewOptions()

        #expect(options.tabView.indicatorView.underline.height == 2.0)
        #expect(options.tabView.indicatorView.underline.cornerRadius == 0)
        #expect(options.tabView.indicatorView.animationDuration == 0.3)
        #expect(options.tabView.indicatorView.isAnimationOnSwipeEnabled == true)
        #expect(options.tabView.indicatorView.padding == .zero)
    }

    @Test("ContentScrollView documented defaults")
    func contentScrollViewDefaults() {
        let options = SwipeMenuViewOptions()

        #expect(options.contentScrollView.clipsToBounds == true)
        #expect(options.contentScrollView.isScrollEnabled == true)
        #expect(options.contentScrollView.isSafeAreaEnabled == true)
    }

    @Test("Top-level isSafeAreaEnabled default is true")
    func isSafeAreaEnabledDefault() {
        let options = SwipeMenuViewOptions()
        #expect(options.isSafeAreaEnabled == true)
    }

    @Test("Setting isSafeAreaEnabled propagates to nested options")
    func isSafeAreaEnabledPropagates() {
        var options = SwipeMenuViewOptions()

        options.isSafeAreaEnabled = false
        #expect(options.tabView.isSafeAreaEnabled == false)
        #expect(options.contentScrollView.isSafeAreaEnabled == false)

        options.isSafeAreaEnabled = true
        #expect(options.tabView.isSafeAreaEnabled == true)
        #expect(options.contentScrollView.isSafeAreaEnabled == true)
    }

    @Test("Options are Sendable")
    func optionsAreSendable() {
        // Compile-time proof that the value can be treated as `any Sendable`.
        let sendable: any Sendable = SwipeMenuViewOptions()
        #expect(sendable is SwipeMenuViewOptions)

        // Compile-time proof that a nonisolated context can construct the
        // options (the call itself still runs on the main actor here).
        let fromNonisolated = makeOptionsFromNonisolatedContext()
        #expect(fromNonisolated.tabView.height == 44.0)
    }
}

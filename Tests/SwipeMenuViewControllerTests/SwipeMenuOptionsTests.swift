import SwiftUI
import Testing

@testable import SwipeMenuViewController

/// Constructs a `SwipeMenuOptions` from a `nonisolated` context. That this
/// compiles proves the type is usable outside the main actor (i.e. it really is
/// `Sendable` and not main-actor isolated).
@available(iOS 18.0, *)
private nonisolated func makeOptionsFromNonisolatedContext() -> SwipeMenuOptions {
    return SwipeMenuOptions()
}

@Suite("SwipeMenuOptions")
struct SwipeMenuOptionsTests {

    @available(iOS 18.0, *)
    @Test("TabView documented defaults")
    func tabViewDefaults() {
        let options = SwipeMenuOptions()

        #expect(options.tabView.height == 44.0)
        #expect(options.tabView.margin == 0.0)
        #expect(options.tabView.backgroundColor == .clear)
        #expect(options.tabView.style == .flexible)
        #expect(options.tabView.indicator == .underline)
        #expect(options.tabView.adjustsItemViewWidth == true)
        #expect(options.tabView.interpolatesTextColorOnSwipe == true)
    }

    @available(iOS 18.0, *)
    @Test("ItemView documented defaults")
    func itemViewDefaults() {
        let options = SwipeMenuOptions()

        #expect(options.tabView.itemView.width == 100.0)
        #expect(options.tabView.itemView.margin == 5.0)
        #expect(options.tabView.itemView.font == .system(size: 14, weight: .bold))
        // Defaults to the same font as `font`, so selection does not change the title font by default.
        #expect(options.tabView.itemView.selectedFont == .system(size: 14, weight: .bold))
        #expect(options.tabView.itemView.textColor == Color(red: 170 / 255, green: 170 / 255, blue: 170 / 255))
        #expect(options.tabView.itemView.selectedTextColor == .black)
        #expect(options.tabView.itemView.numberOfLines == 1)
    }

    @available(iOS 18.0, *)
    @Test("IndicatorView documented defaults")
    func indicatorViewDefaults() {
        let options = SwipeMenuOptions()

        #expect(options.tabView.indicatorView.underline.height == 2.0)
        #expect(options.tabView.indicatorView.underline.cornerRadius == 0)
        #expect(options.tabView.indicatorView.circle.cornerRadius == nil)
        #expect(options.tabView.indicatorView.padding == EdgeInsets())
        #expect(options.tabView.indicatorView.backgroundColor == .black)
        #expect(options.tabView.indicatorView.animationDuration == 0.3)
        #expect(options.tabView.indicatorView.isAnimationOnSwipeEnabled == true)
    }

    @available(iOS 18.0, *)
    @Test("ContentScrollView documented defaults")
    func contentScrollViewDefaults() {
        let options = SwipeMenuOptions()

        #expect(options.contentScrollView.backgroundColor == .clear)
        #expect(options.contentScrollView.isScrollEnabled == true)
    }

    @available(iOS 18.0, *)
    @Test("Options are Sendable")
    func optionsAreSendable() {
        // Compile-time proof that the value can be treated as `any Sendable`.
        let sendable: any Sendable = SwipeMenuOptions()
        #expect(sendable is SwipeMenuOptions)

        // Compile-time proof that a nonisolated context can construct the
        // options (the call itself still runs on the main actor here).
        let fromNonisolated = makeOptionsFromNonisolatedContext()
        #expect(fromNonisolated.tabView.height == 44.0)
    }
}

import Testing
import UIKit
@testable import SwipeMenuViewController

/// Constructs a `SwipeMenuViewOptions` off the main actor to prove the type is
/// usable from a `nonisolated` context (i.e. it really is `Sendable`).
private nonisolated func makeOptionsOffMainActor() -> SwipeMenuViewOptions {
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
        #expect(options.tabView.addition == .underline)
        #expect(options.tabView.needsAdjustItemViewWidth == true)
        #expect(options.tabView.needsConvertTextColorRatio == true)
        #expect(options.tabView.isSafeAreaEnabled == true)
    }

    @Test("ItemView documented defaults")
    func itemViewDefaults() {
        let options = SwipeMenuViewOptions()

        #expect(options.tabView.itemView.width == 100.0)
        #expect(options.tabView.itemView.margin == 5.0)
        #expect(options.tabView.itemView.font == UIFont.boldSystemFont(ofSize: 14))
        #expect(options.tabView.itemView.clipsToBounds == true)
    }

    @Test("AdditionView documented defaults")
    func additionViewDefaults() {
        let options = SwipeMenuViewOptions()

        #expect(options.tabView.additionView.underline.height == 2.0)
        #expect(options.tabView.additionView.animationDuration == 0.3)
        #expect(options.tabView.additionView.isAnimationOnSwipeEnable == true)
        #expect(options.tabView.additionView.padding == .zero)
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

        // And that it can be constructed off the main actor.
        let offMain = makeOptionsOffMainActor()
        #expect(offMain.tabView.height == 44.0)
    }
}

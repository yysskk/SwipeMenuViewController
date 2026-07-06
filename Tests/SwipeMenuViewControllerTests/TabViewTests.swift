import Testing
import UIKit
@testable import SwipeMenuViewController

@MainActor
@Suite("TabView", .serialized)
struct TabViewTests {

    private func makeTabView(titles: [String], options: SwipeMenuViewOptions.TabView) -> (TabView, StubTabViewDataSource) {
        var opts = options
        // Keep tests deterministic regardless of the host window's safe area.
        opts.isSafeAreaEnabled = false
        let tabView = TabView(frame: CGRect(x: 0, y: 0, width: 375, height: opts.height), options: opts)
        let dataSource = StubTabViewDataSource(titles: titles)
        tabView.dataSource = dataSource
        return (tabView, dataSource)
    }

    @Test("reloadData builds one item per title with the correct labels")
    func reloadDataBuildsItems() {
        let titles = ["One", "Two", "Three"]
        // `TabView.dataSource` is weak; keep a strong reference for the test.
        let (tabView, dataSource) = makeTabView(titles: titles, options: SwipeMenuViewOptions.TabView())

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        #expect(tabView.itemViews.count == titles.count)
        for (index, title) in titles.enumerated() {
            #expect(tabView.itemViews[index].titleLabel.text == title)
        }
    }

    @Test("The first item is selected after reload")
    func firstItemSelected() {
        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: SwipeMenuViewOptions.TabView())

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        #expect(tabView.itemViews.first?.isSelected == true)
        #expect(tabView.itemViews.dropFirst().allSatisfy { $0.isSelected == false })
    }

    @Test("Flexible style with fixed width uses options.itemView.width")
    func flexibleFixedWidth() {
        var options = SwipeMenuViewOptions.TabView()
        options.style = .flexible
        options.needsAdjustItemViewWidth = false
        options.itemView.width = 100

        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: options)

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        #expect(tabView.itemViews.count == 3)
        for itemView in tabView.itemViews {
            #expect(abs(itemView.frame.width - 100) < 0.5)
        }
    }

    @Test("Segmented style divides the width roughly equally across items")
    func segmentedEqualWidths() {
        var options = SwipeMenuViewOptions.TabView()
        options.style = .segmented
        options.margin = 0

        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C", "D"], options: options)

        let window = hostTabView(tabView, width: 400)
        defer { withExtendedLifetime((window, dataSource)) {} }

        #expect(tabView.itemViews.count == 4)

        let widths = tabView.itemViews.map { $0.frame.width }
        let expected = tabView.frame.width / 4

        // Each item is roughly an equal share of the tab width...
        for width in widths {
            #expect(abs(width - expected) < 1.0)
        }
        // ...and together they span the full tab width.
        let total = widths.reduce(0, +)
        #expect(abs(total - tabView.frame.width) < 1.0)
    }

    /// Counts the plain (non-`TabItemView`) `UIView` subviews inside the tab's
    /// container stack view. The underline/circle addition view is added there
    /// as a plain `UIView`; the item views are `TabItemView`s. `additionView`
    /// itself is `fileprivate`, so we detect it through the view hierarchy.
    private func additionViewCount(in tabView: TabView) -> Int {
        guard let container = tabView.subviews.first(where: { $0 is UIStackView }) else {
            return 0
        }
        return container.subviews.filter { type(of: $0) == UIView.self }.count
    }

    @Test("Underline addition produces an addition view in the hierarchy")
    func underlineAdditionExists() {
        var options = SwipeMenuViewOptions.TabView()
        options.addition = .underline

        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: options)

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        // The underline addition view is added to the container view hierarchy.
        #expect(additionViewCount(in: tabView) == 1)
    }

    @Test("No addition leaves the addition view out of the hierarchy")
    func noAdditionHasNoAdditionView() {
        var options = SwipeMenuViewOptions.TabView()
        options.addition = .none

        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: options)

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        // With `.none`, the addition view is never added to the container.
        #expect(additionViewCount(in: tabView) == 0)
    }
}

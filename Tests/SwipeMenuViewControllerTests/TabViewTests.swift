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

    // MARK: - Item title lines

    @Test("By default each title label is limited to a single line")
    func titleLabelsAreSingleLineByDefault() {
        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: SwipeMenuViewOptions.TabView())

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        #expect(tabView.itemViews.allSatisfy { $0.titleLabel.numberOfLines == 1 })
    }

    @Test("itemView.numberOfLines is applied to every title label")
    func numberOfLinesIsApplied() {
        var options = SwipeMenuViewOptions.TabView()
        options.style = .segmented
        // `0` means the label uses as many lines as the title needs.
        options.itemView.numberOfLines = 0

        let (tabView, dataSource) = makeTabView(titles: ["Long title one", "Long title two"], options: options)

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        #expect(tabView.itemViews.allSatisfy { $0.titleLabel.numberOfLines == 0 })
    }

    @Test("Flexible style with fixed width uses options.itemView.width")
    func flexibleFixedWidth() {
        var options = SwipeMenuViewOptions.TabView()
        options.style = .flexible
        options.adjustsItemViewWidth = false
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

    @Test("Flexible content width includes both horizontal safe-area insets")
    func flexibleContentWidthIncludesSafeAreaInsets() {
        var options = SwipeMenuViewOptions.TabView()
        options.style = .flexible
        options.margin = 0
        options.isSafeAreaEnabled = true
        options.adjustsItemViewWidth = false
        options.itemView.width = 100

        let dataSource = StubTabViewDataSource(titles: ["A", "B", "C"])
        let tabView = TabView(frame: CGRect(x: 0, y: 0, width: 400, height: options.height), options: options)
        tabView.dataSource = dataSource

        // Host inside a view controller so its safe area can be driven via
        // additionalSafeAreaInsets (a UIViewController-only property).
        let viewController = UIViewController()
        viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 667))
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        defer { withExtendedLifetime((window, dataSource)) {} }

        tabView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(tabView)
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            tabView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: options.height)
        ])
        viewController.view.layoutIfNeeded()
        // Build the items against the stable frame with the safe area in place.
        tabView.reloadData()
        viewController.view.layoutIfNeeded()

        // Precondition: the safe area really reached the tab view.
        #expect(tabView.safeAreaInsets.left == 20)
        #expect(tabView.safeAreaInsets.right == 20)

        // The container is laid out at leading inset + margin, so the scrollable
        // width must cover the items plus the margin and inset on *both* sides;
        // otherwise the last item cannot be scrolled fully into view.
        let itemsWidth: CGFloat = 100 * 3
        let expectedWidth = itemsWidth + tabView.safeAreaInsets.left + tabView.safeAreaInsets.right
        #expect(abs(tabView.contentSize.width - expectedWidth) < 1.0)
    }

    @Test("With safe area enabled, segmented items shrink by the horizontal insets")
    func safeAreaEnabledShrinksSegmentedItems() {
        var options = SwipeMenuViewOptions.TabView()
        options.style = .segmented
        options.margin = 0
        options.isSafeAreaEnabled = true

        let dataSource = StubTabViewDataSource(titles: ["A", "B", "C", "D"])
        let tabView = TabView(frame: CGRect(x: 0, y: 0, width: 400, height: options.height), options: options)
        tabView.dataSource = dataSource

        // Host inside a view controller so its safe area can be driven via
        // additionalSafeAreaInsets (a UIViewController-only property).
        let viewController = UIViewController()
        viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 667))
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        defer { withExtendedLifetime((window, dataSource)) {} }

        tabView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(tabView)
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            tabView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: options.height)
        ])
        viewController.view.layoutIfNeeded()
        // Build the items against the stable frame with the safe area in place.
        tabView.reloadData()
        viewController.view.layoutIfNeeded()

        // Precondition: the safe area really reached the tab view.
        #expect(tabView.safeAreaInsets.left == 20)
        #expect(tabView.safeAreaInsets.right == 20)

        // The items share the width that remains after both insets.
        let total = tabView.itemViews.reduce(0) { $0 + $1.frame.width }
        let expected = tabView.frame.width - tabView.safeAreaInsets.left - tabView.safeAreaInsets.right
        #expect(abs(total - expected) < 1.0)
    }

    @Test("With safe area disabled, a safe-area change does not shrink segmented items")
    func safeAreaDisabledIgnoresInsetChanges() {
        var options = SwipeMenuViewOptions.TabView()
        options.style = .segmented
        options.margin = 0
        options.isSafeAreaEnabled = false

        let dataSource = StubTabViewDataSource(titles: ["A", "B", "C", "D"])
        let tabView = TabView(frame: CGRect(x: 0, y: 0, width: 400, height: options.height), options: options)
        tabView.dataSource = dataSource

        // Host inside a view controller so its safe area can be driven via
        // additionalSafeAreaInsets (a UIViewController-only property).
        let viewController = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 667))
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        defer { withExtendedLifetime((window, dataSource)) {} }

        tabView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(tabView)
        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            tabView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: options.height)
        ])
        viewController.view.layoutIfNeeded()
        // Build the items against the stable frame with no safe area yet.
        tabView.reloadData()
        viewController.view.layoutIfNeeded()

        // Now introduce a safe area. This fires safeAreaInsetsDidChange() on the
        // tab view; with safe area disabled it must not resize the items.
        viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()

        // Precondition: the safe area really reached the tab view, so the
        // assertion below is meaningful rather than a silent no-op.
        #expect(tabView.safeAreaInsets.left == 20)

        let total = tabView.itemViews.reduce(0) { $0 + $1.frame.width }
        // Items still span the full tab width, not width - (left + right).
        #expect(abs(total - tabView.frame.width) < 1.0)
    }

    /// Counts the plain (non-`TabItemView`) `UIView` subviews inside the tab's
    /// container stack view. The underline/circle addition view is added there
    /// as a plain `UIView`; the item views are `TabItemView`s. `additionView`
    /// itself is `private`, so we detect it through the view hierarchy.
    private func additionViewCount(in tabView: TabView) -> Int {
        guard let container = tabView.subviews.first(where: { $0 is UIStackView }) else {
            return 0
        }
        return container.subviews.filter { type(of: $0) == UIView.self }.count
    }

    /// Returns the plain (non-`TabItemView`) `UIView` acting as the selection
    /// indicator inside the container stack view, or `nil` if there is none.
    /// `additionView` is `private`, so it is located through the hierarchy.
    private func additionView(in tabView: TabView) -> UIView? {
        guard let container = tabView.subviews.first(where: { $0 is UIStackView }) else {
            return nil
        }
        return container.subviews.first { type(of: $0) == UIView.self }
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

    @Test("Circle addition produces an addition view in the hierarchy")
    func circleAdditionExists() {
        var options = SwipeMenuViewOptions.TabView()
        options.addition = .circle

        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: options)

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        // The circle addition view is added to the container view hierarchy.
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

    // MARK: - Item fonts

    @Test("The selected item uses selectedFont and the rest use font")
    func selectedFontIsAppliedToSelectedItemOnly() {
        var options = SwipeMenuViewOptions.TabView()
        options.itemView.font = .systemFont(ofSize: 14)
        options.itemView.selectedFont = .boldSystemFont(ofSize: 20)

        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: options)

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        // The first item is selected after reload, so it uses the selected font...
        #expect(tabView.itemViews[0].titleLabel.font == options.itemView.selectedFont)
        // ...and every other item uses the base font.
        #expect(tabView.itemViews.dropFirst().allSatisfy { $0.titleLabel.font == options.itemView.font })
    }

    @Test("Selecting another tab moves the selected font onto it")
    func selectedFontFollowsSelection() {
        var options = SwipeMenuViewOptions.TabView()
        options.itemView.font = .systemFont(ofSize: 14)
        options.itemView.selectedFont = .boldSystemFont(ofSize: 20)

        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: options)

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        tabView.jump(to: 1)

        #expect(tabView.itemViews[1].titleLabel.font == options.itemView.selectedFont)
        #expect(tabView.itemViews[0].titleLabel.font == options.itemView.font)
        #expect(tabView.itemViews[2].titleLabel.font == options.itemView.font)
    }

    @Test("selectedFont does not affect flexible item widths")
    func selectedFontDoesNotAffectWidth() {
        var base = SwipeMenuViewOptions.TabView()
        base.style = .flexible
        base.itemView.font = .systemFont(ofSize: 14)
        base.itemView.selectedFont = .systemFont(ofSize: 14)

        var large = base
        // A much larger selected font must not widen the selected item, because
        // widths are measured with `font`.
        large.itemView.selectedFont = .boldSystemFont(ofSize: 40)

        let (baseTab, baseDS) = makeTabView(titles: ["Selected", "B", "C"], options: base)
        let baseWindow = hostTabView(baseTab)
        defer { withExtendedLifetime((baseWindow, baseDS)) {} }

        let (largeTab, largeDS) = makeTabView(titles: ["Selected", "B", "C"], options: large)
        let largeWindow = hostTabView(largeTab)
        defer { withExtendedLifetime((largeWindow, largeDS)) {} }

        // Item 0 is selected in both tab views; its width must be identical.
        #expect(abs(baseTab.itemViews[0].frame.width - largeTab.itemViews[0].frame.width) < 0.5)
    }

    // MARK: - Underline corner radius

    @Test("The underline indicator has square corners by default")
    func underlineCornerRadiusDefaultsToSquare() throws {
        var options = SwipeMenuViewOptions.TabView()
        options.addition = .underline

        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: options)

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        let indicator = try #require(additionView(in: tabView))
        #expect(indicator.layer.cornerRadius == 0)
    }

    @Test("underline.cornerRadius is applied to the indicator layer")
    func underlineCornerRadiusIsApplied() throws {
        var options = SwipeMenuViewOptions.TabView()
        options.addition = .underline
        options.additionView.underline.height = 4
        // Half the height rounds the underline into a pill.
        options.additionView.underline.cornerRadius = 2

        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: options)

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        let indicator = try #require(additionView(in: tabView))
        #expect(indicator.layer.cornerRadius == 2)
    }

    // MARK: - Segmented indicator offset (issue #25)

    @Test("Segmented indicator sits inside every tab, inset by the padding")
    func segmentedIndicatorAlignsWithEachTab() throws {
        var options = SwipeMenuViewOptions.TabView()
        options.style = .segmented
        options.addition = .underline
        options.margin = 0
        // Non-zero horizontal padding makes both the offset sign (first tab) and
        // the per-tab stride (later tabs) observable.
        options.additionView.padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let titles = ["A", "B", "C"]
        let (tabView, dataSource) = makeTabView(titles: titles, options: options)

        let window = hostTabView(tabView, width: 375)
        defer { withExtendedLifetime((window, dataSource)) {} }

        let indicator = try #require(additionView(in: tabView))
        let padding = options.additionView.padding

        // The indicator should align with the selected tab's frame, inset by the
        // padding — the same way the flexible style aligns it. Before the fix the
        // segmented path placed the first tab at `-padding.left` and used the
        // padding-adjusted width as the per-tab stride, so later tabs drifted left
        // by `index * padding.horizontal` (issue #25).
        for index in titles.indices {
            tabView.jump(to: index)
            tabView.setNeedsLayout()
            tabView.layoutIfNeeded()

            let item = tabView.itemViews[index]
            #expect(abs(indicator.frame.origin.x - (item.frame.origin.x + padding.left)) < 0.5)
            #expect(abs(indicator.frame.width - (item.frame.width - padding.horizontal)) < 0.5)
        }
    }

    // MARK: - BUG 4: boundary items

    @Test("nextItem/previousItem are nil at the boundaries")
    func boundaryNeighborsAreNil() {
        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: SwipeMenuViewOptions.TabView())

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        tabView.jump(to: 2)
        #expect(tabView.nextItem == nil)

        tabView.jump(to: 0)
        #expect(tabView.previousItem == nil)
    }

    @Test("Swiping past the last tab does not fade the current item's label")
    func forwardSwipeAtLastItemLeavesLabelSelected() {
        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: SwipeMenuViewOptions.TabView())

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        // Select the last item. `isSelected` sets its label to the selected
        // text color, so record that as the expected, stable color.
        tabView.jump(to: 2)
        let lastItem = tabView.itemViews[2]
        #expect(lastItem.isSelected == true)
        let expectedColor = lastItem.selectedTextColor

        // A forward swipe at the last item has no next neighbor. Pre-fix,
        // `nextItem` returned the current item and its label was overwritten
        // with an interpolated (mid-fade) color, causing a flicker. Post-fix the
        // branch is skipped, so the label keeps the selected color.
        tabView.moveAdditionView(index: 2, ratio: 0.3, direction: .forward)

        let actual = lastItem.titleLabel.textColor ?? .clear
        #expect(colorsEqual(actual, expectedColor))
    }

    @Test("A forward swipe fades the current and next labels by the ratio")
    func forwardSwipeInterpolatesNeighborColors() {
        var options = SwipeMenuViewOptions.TabView()
        options.interpolatesTextColorOnSwipe = true
        // Use pure black/white endpoints so the midpoint is an unambiguous gray.
        options.itemView.textColor = .black
        options.itemView.selectedTextColor = .white

        let (tabView, dataSource) = makeTabView(titles: ["A", "B", "C"], options: options)

        let window = hostTabView(tabView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        tabView.jump(to: 0)
        // Halfway through a forward swipe from item 0 to item 1.
        tabView.moveAdditionView(index: 0, ratio: 0.5, direction: .forward)

        let midGray = UIColor(white: 0.5, alpha: 1)
        let current = tabView.itemViews[0].titleLabel.textColor ?? .clear
        let next = tabView.itemViews[1].titleLabel.textColor ?? .clear

        // The current label fades selected -> text and the next fades text ->
        // selected; at ratio 0.5 both meet in the middle.
        #expect(colorsEqual(current, midGray))
        #expect(colorsEqual(next, midGray))
    }

    /// Compares two colors by their RGBA components with a small tolerance.
    private func colorsEqual(_ lhs: UIColor, _ rhs: UIColor, tolerance: CGFloat = 0.01) -> Bool {
        var lr: CGFloat = 0, lg: CGFloat = 0, lb: CGFloat = 0, la: CGFloat = 0
        var rr: CGFloat = 0, rg: CGFloat = 0, rb: CGFloat = 0, ra: CGFloat = 0
        lhs.getRed(&lr, green: &lg, blue: &lb, alpha: &la)
        rhs.getRed(&rr, green: &rg, blue: &rb, alpha: &ra)
        return abs(lr - rr) < tolerance && abs(lg - rg) < tolerance
            && abs(lb - rb) < tolerance && abs(la - ra) < tolerance
    }
}

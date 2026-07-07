import Testing
import UIKit

@testable import SwipeMenuViewController

@MainActor
@Suite("SwipeMenuView", .serialized)
struct SwipeMenuViewTests {

    // `SwipeMenuView.dataSource`/`delegate` are `weak`, so every test keeps a
    // strong local reference alive across its assertions.

    @Test("Hosting sets up tabView and contentScrollView with matching counts")
    func setupOnHosting() throws {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource)) {} }

        let tabView = try #require(view.tabView)
        let contentScrollView = try #require(view.contentScrollView)

        #expect(tabView.itemViews.count == 3)
        // `pageViews` is private; verify the page count via the content
        // width (one page-width per page) instead.
        #expect(abs(contentScrollView.contentSize.width - contentScrollView.frame.width * 3) < 0.5)
    }

    @Test("Titles from the dataSource appear on tab item labels")
    func dataSourcePlumbing() throws {
        let view = SwipeMenuView(frame: .zero)
        let titles = ["First", "Second", "Third"]
        let dataSource = StubMenuDataSource(titles: titles)
        view.dataSource = dataSource

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource)) {} }

        let tabView = try #require(view.tabView)
        #expect(tabView.itemViews.count == titles.count)
        for (index, title) in titles.enumerated() {
            #expect(tabView.itemViews[index].titleLabel.text == title)
        }
    }

    @Test("jump(to:animated:false) moves the content offset to the target page")
    func jumpUpdatesContentOffset() throws {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource)) {} }

        let contentScrollView = try #require(view.contentScrollView)
        let pageWidth = contentScrollView.frame.width
        #expect(pageWidth > 0)

        view.jump(to: 2, animated: false)

        #expect(abs(contentScrollView.contentOffset.x - pageWidth * 2) < 0.5)
    }

    @Test("jump(to:animated:false) updates currentIndex to the target page")
    func jumpUpdatesCurrentIndex() {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C", "D"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource)) {} }

        // Jump across more than one page. The content offset and currentIndex
        // must both land on the target.
        view.jump(to: 3, animated: false)
        #expect(view.currentIndex == 3)

        view.jump(to: 1, animated: false)
        #expect(view.currentIndex == 1)
    }

    @Test("jump(to:) emits one willChange/didChange pair to the target")
    func jumpEmitsSingleDelegatePair() {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C", "D"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        // Attach the delegate after hosting so only the jump's events are recorded.
        let delegate = RecordingMenuDelegate()
        view.delegate = delegate
        defer { withExtendedLifetime((window, dataSource, delegate)) {} }

        view.jump(to: 2, animated: false)

        #expect(delegate.events == [.willChange(from: 0, to: 2), .didChange(from: 0, to: 2)])
    }

    @Test("A re-entrant jump keeps willChange/didChange calls paired")
    func reentrantJumpKeepsDelegatePaired() {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C", "D"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        let delegate = RecordingMenuDelegate()
        view.delegate = delegate
        defer { withExtendedLifetime((window, dataSource, delegate)) {} }

        // Start an animated jump (its end-of-animation callback does not fire in
        // this synchronous test, so the jump stays "in flight"), then issue a
        // second jump before the first completes.
        view.jump(to: 2, animated: true)
        view.jump(to: 0, animated: false)

        // Each jump contributes exactly one paired willChange/didChange, and the
        // view lands on the most recent target.
        #expect(view.currentIndex == 0)
        #expect(
            delegate.events == [
                .willChange(from: 0, to: 2),
                .didChange(from: 0, to: 2),
                .willChange(from: 2, to: 0),
                .didChange(from: 2, to: 0),
            ])
    }

    @Test("Selecting a tab during an in-flight jump keeps delegate calls paired")
    func tabSelectionDuringJumpKeepsDelegatePaired() throws {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C", "D"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        let delegate = RecordingMenuDelegate()
        view.delegate = delegate
        defer { withExtendedLifetime((window, dataSource, delegate)) {} }

        let tabView = try #require(view.tabView)

        // Start an animated jump (in flight in this synchronous test), then tap a
        // different tab before it completes. `finalizePendingJump()` runs
        // synchronously at the start of the tab selection, so the first jump is
        // paired deterministically regardless of the tap animation's timing.
        view.jump(to: 2, animated: true)
        view.tabView(tabView, didSelectTabAt: 3)

        #expect(delegate.events.prefix(2) == [.willChange(from: 0, to: 2), .didChange(from: 0, to: 2)])
    }

    @Test("jump(to:) ignores an out-of-range index")
    func jumpIgnoresOutOfRangeIndex() throws {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource)) {} }

        let contentScrollView = try #require(view.contentScrollView)

        view.jump(to: 99, animated: false)
        #expect(view.currentIndex == 0)
        #expect(abs(contentScrollView.contentOffset.x) < 0.5)

        view.jump(to: -1, animated: false)
        #expect(view.currentIndex == 0)
        #expect(abs(contentScrollView.contentOffset.x) < 0.5)
    }

    @Test("Delegate receives willSetup before didSetup")
    func delegateSetupOrdering() throws {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: ["A", "B"])
        view.dataSource = dataSource
        let delegate = RecordingMenuDelegate()
        view.delegate = delegate

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource, delegate)) {} }

        let will = try #require(delegate.events.firstIndex(of: .willSetup(0)))
        let did = try #require(delegate.events.firstIndex(of: .didSetup(0)))
        #expect(will < did)
    }

    @Test("reloadData(options:) applies a new tab height")
    func reloadDataAppliesNewOptions() throws {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource)) {} }

        var newOptions = SwipeMenuViewOptions()
        newOptions.tabView.height = 60

        view.reloadData(options: newOptions)

        #expect(view.options.tabView.height == 60)
        let tabView = try #require(view.tabView)
        #expect(tabView.options.height == 60)
    }

    @Test("Zero pages hosts without crashing and produces no items")
    func zeroPages() {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: [])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource)) {} }

        // setup() always constructs the subviews, but with no data the tab has
        // no item views and the content scroll view has no pages (zero width,
        // no current page).
        #expect(view.tabView?.itemViews.count == 0)
        #expect(view.contentScrollView?.currentPage == nil)
        if let contentScrollView = view.contentScrollView {
            #expect(contentScrollView.contentSize.width == 0)
        }
    }

    @Test("reloadData(default:) shows the requested page")
    func reloadDataWithDefaultIndex() throws {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C", "D"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource)) {} }

        view.reloadData(default: 2)

        #expect(view.currentIndex == 2)
        let contentScrollView = try #require(view.contentScrollView)
        #expect(abs(contentScrollView.contentOffset.x - contentScrollView.frame.width * 2) < 0.5)
    }

    @Test("An orientation relayout preserves the current index")
    func orientationPreservesCurrentIndex() {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C", "D"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource)) {} }

        view.jump(to: 2, animated: false)
        #expect(view.currentIndex == 2)

        // Simulate an orientation change: willChangeOrientation() marks the next
        // layout pass as a relayout that must not reset paging state.
        view.willChangeOrientation()
        view.setNeedsLayout()
        view.layoutIfNeeded()

        #expect(view.currentIndex == 2)
    }

    @Test("Removing and re-adding the view does not duplicate its subviews")
    func reAddDoesNotDuplicateSubviews() {
        let view = SwipeMenuView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C"])
        view.dataSource = dataSource

        let window1 = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window1.addSubview(view)
        view.layoutIfNeeded()

        view.removeFromSuperview()

        let window2 = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window2.addSubview(view)
        view.layoutIfNeeded()
        defer { withExtendedLifetime((window1, window2, dataSource)) {} }

        // Exactly one tab view and one content view, not one per attach.
        #expect(view.subviews.compactMap { $0 as? TabView }.count == 1)
        #expect(view.subviews.compactMap { $0 as? ContentScrollView }.count == 1)
        #expect(view.tabView?.itemViews.count == 3)
    }

    @Test("Initial setup builds each page exactly once")
    func setupBuildsEachPageOnce() {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = CountingMenuDataSource(titles: ["A", "B", "C"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource)) {} }

        // Hosting plus the initial layout passes must ask the data source for
        // every page exactly once; the layout-driven relayout path must not
        // rebuild the pages a second time (issue #79).
        #expect(dataSource.requestedPageIndices == [0, 1, 2])
    }

    @Test("An explicit reloadData() builds each page exactly once more")
    func reloadDataBuildsEachPageOnceMore() {
        let view = SwipeMenuView(frame: .zero)
        let dataSource = CountingMenuDataSource(titles: ["A", "B", "C"])
        view.dataSource = dataSource

        let window = hostInWindow(view)
        defer { withExtendedLifetime((window, dataSource)) {} }

        view.reloadData()

        #expect(dataSource.requestedPageIndices == [0, 1, 2, 0, 1, 2])
    }

    @Test("Removal does not emit setup callbacks")
    func removalDoesNotEmitSetupCallbacks() {
        let view = SwipeMenuView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C"])
        view.dataSource = dataSource

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.addSubview(view)
        view.layoutIfNeeded()

        // Attach the delegate after the initial setup so only removal is observed.
        let delegate = RecordingMenuDelegate()
        view.delegate = delegate
        defer { withExtendedLifetime((window, dataSource, delegate)) {} }

        view.removeFromSuperview()

        // Removal must not run setup again.
        #expect(delegate.events.isEmpty)
    }
}

import Testing
import UIKit
@testable import SwipeMenuViewController

@MainActor
@Suite("Retain cycle", .serialized)
struct RetainCycleTests {

    @Test("ContentScrollView.dataSource is a weak reference")
    func contentScrollViewDataSourceIsWeak() {
        let contentScrollView = ContentScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 600), default: 0)

        autoreleasepool {
            let dataSource = StubContentDataSource(pageCount: 3)
            contentScrollView.dataSource = dataSource
            #expect(contentScrollView.dataSource != nil)
        }

        // Pre-fix: `dataSource` was a strong `var`, so it stayed non-nil after
        // the only other reference was released. Post-fix the weak reference is
        // cleared once the stub deallocates.
        #expect(contentScrollView.dataSource == nil)
    }

    @Test("SwipeMenuView deallocates after teardown")
    func swipeMenuViewDeallocates() {
        weak var weakView: SwipeMenuView?
        let dataSource = StubMenuDataSource(titles: ["A", "B", "C"])
        autoreleasepool {
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
            let view = SwipeMenuView(frame: container.bounds)
            view.dataSource = dataSource
            container.addSubview(view)      // triggers setup -> contentScrollView.dataSource = self
            view.layoutIfNeeded()
            weakView = view
            view.removeFromSuperview()
        }
        withExtendedLifetime(dataSource) {}
        // Pre-fix: SwipeMenuView -> contentScrollView (subview) -> dataSource ->
        // SwipeMenuView formed a retain cycle, so the view never deallocated.
        #expect(weakView == nil)
    }
}

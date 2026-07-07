import Testing
import UIKit

@testable import SwipeMenuViewController

@MainActor
@Suite("SwipeMenuViewController", .serialized)
struct SwipeMenuViewControllerTests {

    /// A controller that adds a fixed number of child view controllers before
    /// its view loads, so the default data source has pages to vend.
    private final class HostingController: SwipeMenuViewController {
        let pageTitles: [String]

        init(pageTitles: [String]) {
            self.pageTitles = pageTitles
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            for title in pageTitles {
                let child = UIViewController()
                child.title = title
                addChild(child)
                child.didMove(toParent: self)
            }
            super.viewDidLoad()
        }
    }

    // MARK: - BUG 2: duplicate constraints

    @Test("Constraints are not re-added on repeated layout passes")
    func constraintsAreStableAcrossLayoutPasses() {
        let vc = HostingController(pageTitles: ["A", "B", "C"])

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.rootViewController = vc
        defer { withExtendedLifetime(window) {} }

        // Force the first layout so viewDidLoad + constraint setup run.
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()

        let initialCount = vc.view.constraints.count

        // Pre-fix: viewDidLayoutSubviews re-activated 4 constraints per pass, so
        // this count grew by 4 on every layout. Post-fix it must be stable.
        for _ in 0..<3 {
            vc.view.setNeedsLayout()
            vc.view.layoutIfNeeded()
        }

        #expect(vc.view.constraints.count == initialCount)
    }

    @Test("The top anchor is tied to the safe-area guide when enabled")
    func topAnchorTiesToSafeAreaGuide() {
        let vc = HostingController(pageTitles: ["A", "B", "C"])
        // Safe area is enabled by default; assert the wiring explicitly.
        #expect(vc.swipeMenuView == nil)

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.rootViewController = vc
        defer { withExtendedLifetime(window) {} }

        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()

        #expect(vc.swipeMenuView.options.tabView.isSafeAreaEnabled == true)

        // Find the constraint that pins swipeMenuView.topAnchor and confirm its
        // other end is the view's safe-area layout guide (not the view itself).
        let topConstraint = vc.view.constraints.first { constraint in
            (constraint.firstItem === vc.swipeMenuView && constraint.firstAttribute == .top)
                || (constraint.secondItem === vc.swipeMenuView && constraint.secondAttribute == .top)
        }

        #expect(topConstraint != nil)

        if let topConstraint {
            let otherItem: AnyObject? =
                (topConstraint.firstItem === vc.swipeMenuView)
                ? topConstraint.secondItem
                : topConstraint.firstItem
            #expect(otherItem === vc.view.safeAreaLayoutGuide)
            #expect(otherItem !== vc.view)
        }
    }

    // MARK: - BUG 3: unguarded children[index]

    /// A subclass whose `numberOfPages` reports more pages than there are child
    /// view controllers, so the default data source can be asked for an
    /// out-of-range index.
    private final class OverreportingController: SwipeMenuViewController {
        override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
            return children.count + 5
        }
    }

    @Test("titleForPageAt returns empty string for an out-of-range index")
    func titleGuardForOutOfRangeIndex() {
        let vc = OverreportingController()
        // No children added, so any index is out of range.
        #expect(vc.children.isEmpty)

        let dummy = SwipeMenuView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))

        // Pre-fix: children[10] traps on an empty array. Post-fix the guard
        // returns "".
        #expect(vc.swipeMenuView(dummy, titleForPageAt: 10) == "")

        // NOTE: `viewControllerForPageAt` with an out-of-range index is
        // deliberately NOT exercised here. Its guard calls `assertionFailure`,
        // which traps in debug test builds and would abort the whole suite. The
        // guard's return value is only meaningful in release builds, so we only
        // verify the happy path for that method below.
    }

    @Test("The default data source vends one page and title per child")
    func defaultDataSourceHappyPath() {
        let vc = HostingController(pageTitles: ["One", "Two", "Three"])

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.rootViewController = vc
        defer { withExtendedLifetime(window) {} }

        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()

        let dummy = SwipeMenuView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))

        #expect(vc.numberOfPages(in: dummy) == 3)
        #expect(vc.swipeMenuView(dummy, titleForPageAt: 0) == "One")
        #expect(vc.swipeMenuView(dummy, titleForPageAt: 1) == "Two")
        #expect(vc.swipeMenuView(dummy, titleForPageAt: 2) == "Three")

        // In-range viewControllerForPageAt returns the corresponding child.
        let firstChild = vc.children[0]
        #expect(vc.swipeMenuView(dummy, viewControllerForPageAt: 0) === firstChild)
    }
}

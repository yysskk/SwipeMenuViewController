import Testing
import UIKit
@testable import SwipeMenuViewController

// MARK: - SwipeMenuView stubs

/// A configurable `SwipeMenuViewDataSource` for tests.
///
/// `numberOfPages` mirrors `titles.count`, `titleForPageAt` returns the
/// corresponding title, and `viewControllerForPageAt` vends a fresh
/// `UIViewController` whose `title` matches the page's title.
final class StubMenuDataSource: SwipeMenuViewDataSource {

    var titles: [String]

    init(titles: [String]) {
        self.titles = titles
    }

    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return titles.count
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return titles[index]
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = UIViewController()
        vc.title = titles[index]
        return vc
    }
}

/// A `SwipeMenuViewDelegate` that records an ordered log of the lifecycle and
/// paging callbacks it receives.
final class RecordingMenuDelegate: SwipeMenuViewDelegate {

    enum Event: Equatable {
        case willSetup(Int)
        case didSetup(Int)
        case willChange(from: Int, to: Int)
        case didChange(from: Int, to: Int)
    }

    private(set) var events: [Event] = []

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) {
        events.append(.willSetup(currentIndex))
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) {
        events.append(.didSetup(currentIndex))
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        events.append(.willChange(from: fromIndex, to: toIndex))
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        events.append(.didChange(from: fromIndex, to: toIndex))
    }
}

// MARK: - TabView stub

/// A configurable `TabViewDataSource` for tests.
final class StubTabViewDataSource: TabViewDataSource {

    var titles: [String]

    init(titles: [String]) {
        self.titles = titles
    }

    func numberOfItems(in tabView: TabView) -> Int {
        return titles.count
    }

    func tabView(_ tabView: TabView, titleForItemAt index: Int) -> String? {
        return titles[index]
    }
}

// MARK: - ContentScrollView stub

/// A configurable `ContentScrollViewDataSource` for tests. Each vended page is
/// tagged with `baseTag + index` so pages can be identified in assertions.
final class StubContentDataSource: ContentScrollViewDataSource {

    var pageCount: Int
    let baseTag: Int

    init(pageCount: Int, baseTag: Int = 100) {
        self.pageCount = pageCount
        self.baseTag = baseTag
    }

    func numberOfPages(in contentScrollView: ContentScrollView) -> Int {
        return pageCount
    }

    func contentScrollView(_ contentScrollView: ContentScrollView, viewForPageAt index: Int) -> UIView? {
        let view = UIView()
        view.tag = baseTag + index
        return view
    }
}

// MARK: - Hosting helper

/// Hosts `view` in a real window so that `didMoveToSuperview()` fires and layout
/// runs. The returned window must be kept alive by the caller for the duration
/// of the test.
///
/// The window is not made key/visible: these tests only need the view attached
/// to a window and laid out at a known size, and keeping the window offscreen
/// avoids sharing global key-window state across tests.
@MainActor
func hostInWindow(_ view: UIView, size: CGSize = CGSize(width: 375, height: 667)) -> UIWindow {
    let window = UIWindow(frame: CGRect(origin: .zero, size: size))
    view.frame = CGRect(origin: .zero, size: size)
    window.addSubview(view)
    view.setNeedsLayout()
    view.layoutIfNeeded()
    return window
}

/// Hosts a bare `TabView` at a fixed size using explicit constraints (mirroring
/// how `SwipeMenuView` lays out its tab view) so the tab view's frame does not
/// collapse when it sets `translatesAutoresizingMaskIntoConstraints = false`.
///
/// After laying out, `reloadData()` is called explicitly so the item views are
/// built against the final, stable frame. The returned window must be kept
/// alive by the caller.
@MainActor
func hostTabView(_ tabView: TabView, width: CGFloat = 375) -> UIWindow {
    let containerSize = CGSize(width: width, height: 667)
    let window = UIWindow(frame: CGRect(origin: .zero, size: containerSize))
    let container = UIView(frame: CGRect(origin: .zero, size: containerSize))
    window.addSubview(container)

    let height = tabView.options.height
    tabView.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(tabView)
    NSLayoutConstraint.activate([
        tabView.topAnchor.constraint(equalTo: container.topAnchor),
        tabView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
        tabView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        tabView.heightAnchor.constraint(equalToConstant: height)
    ])

    container.setNeedsLayout()
    container.layoutIfNeeded()

    // Rebuild items against the final frame (didMoveToSuperview may have run a
    // reload while the frame was still collapsing).
    tabView.reloadData()
    container.layoutIfNeeded()

    return window
}

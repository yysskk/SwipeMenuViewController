import Testing
import UIKit
@testable import SwipeMenuViewController

@MainActor
@Suite("ContentScrollView", .serialized)
struct ContentScrollViewTests {

    @Test("Setup sizes the content width to one page per item")
    func setupSizesContent() {
        let contentScrollView = ContentScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 600), default: 0)
        let dataSource = StubContentDataSource(pageCount: 4)
        contentScrollView.dataSource = dataSource

        let window = hostInWindow(contentScrollView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        #expect(abs(contentScrollView.contentSize.width - contentScrollView.frame.width * 4) < 0.5)

        // Neighboring pages exist around the default (index 0): there is a next
        // page but no previous page.
        #expect(contentScrollView.currentPage != nil)
        #expect(contentScrollView.previousPage == nil)
        #expect(contentScrollView.nextPage != nil)
    }

    @Test("jump(to:animated:false) moves the content offset to the page")
    func jumpUpdatesOffset() {
        let contentScrollView = ContentScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 600), default: 0)
        let dataSource = StubContentDataSource(pageCount: 4)
        contentScrollView.dataSource = dataSource

        let window = hostInWindow(contentScrollView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        let pageWidth = contentScrollView.frame.width
        #expect(pageWidth > 0)

        contentScrollView.jump(to: 3, animated: false)
        #expect(abs(contentScrollView.contentOffset.x - pageWidth * 3) < 0.5)

        contentScrollView.jump(to: 1, animated: false)
        #expect(abs(contentScrollView.contentOffset.x - pageWidth * 1) < 0.5)
    }

    @Test("An out-of-range default index never asks for a nonexistent page")
    func outOfRangeDefaultIndexDoesNotOverRead() {
        // A default index past the last page must not make setup request pages
        // that do not exist; it should still build exactly the real pages.
        let contentScrollView = ContentScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 600), default: 10)
        let dataSource = CountingContentDataSource(pageCount: 3)
        contentScrollView.dataSource = dataSource

        let window = hostInWindow(contentScrollView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        #expect(dataSource.requestedIndices.allSatisfy { (0..<3).contains($0) })
        #expect(Set(dataSource.requestedIndices) == Set(0..<3))
        #expect(abs(contentScrollView.contentSize.width - contentScrollView.frame.width * 3) < 0.5)
    }

    @Test("reload() rebuilds the pages from the data source when hosted")
    func reloadRebuildsPages() {
        let contentScrollView = ContentScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 600), default: 0)
        let dataSource = CountingContentDataSource(pageCount: 3)
        contentScrollView.dataSource = dataSource

        let window = hostInWindow(contentScrollView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        #expect(dataSource.requestedIndices == [0, 1, 2])

        contentScrollView.reload()

        #expect(dataSource.requestedIndices == [0, 1, 2, 0, 1, 2])
    }

    @Test("reload() replaces the page views instead of stacking them")
    func reloadReplacesPageViews() {
        let baseTag = 700
        let contentScrollView = ContentScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 600), default: 0)
        let dataSource = StubContentDataSource(pageCount: 3, baseTag: baseTag)
        contentScrollView.dataSource = dataSource

        let window = hostInWindow(contentScrollView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        // Page views are identified by their tag (baseTag + index).
        func hostedPageViewCount() -> Int {
            contentScrollView.subviews.count { $0.tag >= baseTag }
        }

        #expect(hostedPageViewCount() == 3)

        contentScrollView.reload()

        // The previous pages must be gone; only the freshly built set remains.
        #expect(hostedPageViewCount() == 3)
    }

    @Test("reload() without a superview does nothing")
    func reloadWithoutSuperviewDoesNothing() {
        let contentScrollView = ContentScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 600), default: 0)
        let dataSource = CountingContentDataSource(pageCount: 3)
        contentScrollView.dataSource = dataSource
        defer { withExtendedLifetime(dataSource) {} }

        contentScrollView.reload()

        #expect(dataSource.requestedIndices.isEmpty)
    }

    @Test("A non-zero default index sets the matching current page")
    func nonZeroDefaultIndex() throws {
        let baseTag = 500
        let contentScrollView = ContentScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 600), default: 2)
        let dataSource = StubContentDataSource(pageCount: 4, baseTag: baseTag)
        contentScrollView.dataSource = dataSource

        let window = hostInWindow(contentScrollView)
        defer { withExtendedLifetime((window, dataSource)) {} }

        // The content spans all four pages regardless of the default index.
        #expect(abs(contentScrollView.contentSize.width - contentScrollView.frame.width * 4) < 0.5)

        // The current page corresponds to the default index, and it has both a
        // previous and a next neighbor (index 2 of 0..<4).
        let currentPage = try #require(contentScrollView.currentPage)
        #expect(currentPage.tag == baseTag + 2)

        let previousPage = try #require(contentScrollView.previousPage)
        #expect(previousPage.tag == baseTag + 1)

        let nextPage = try #require(contentScrollView.nextPage)
        #expect(nextPage.tag == baseTag + 3)
    }
}

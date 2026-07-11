import SwiftUI
import Testing

@testable import SwipeMenuViewController

@Suite("SwipeMenuGeometry")
struct SwipeMenuGeometryTests {

    /// Frames matching a flexible bar with three differently sized tabs laid out
    /// end to end: widths 80, 120, and 60.
    private let itemFrames: [Int: CGRect] = [
        0: CGRect(x: 0, y: 0, width: 80, height: 40),
        1: CGRect(x: 80, y: 0, width: 120, height: 40),
        2: CGRect(x: 200, y: 0, width: 60, height: 40),
    ]

    // MARK: - clampedPosition

    @Test("Positions inside the page range pass through unchanged")
    func inRangePositionsPassThrough() {
        #expect(SwipeMenuGeometry.clampedPosition(0, pageCount: 3) == 0)
        #expect(SwipeMenuGeometry.clampedPosition(0.75, pageCount: 3) == 0.75)
        #expect(SwipeMenuGeometry.clampedPosition(2, pageCount: 3) == 2)
    }

    @Test("Positions outside the page range clamp to the outermost pages")
    func outOfRangePositionsClamp() {
        #expect(SwipeMenuGeometry.clampedPosition(-0.5, pageCount: 3) == 0)
        #expect(SwipeMenuGeometry.clampedPosition(7, pageCount: 3) == 2)
    }

    @Test("An empty menu clamps every position to zero")
    func emptyMenuClampsToZero() {
        #expect(SwipeMenuGeometry.clampedPosition(1.5, pageCount: 0) == 0)
    }

    // MARK: - landedPage

    @Test("The landed page is the page nearest to the settled position")
    func landedPageIsNearest() {
        #expect(SwipeMenuGeometry.landedPage(position: 0, pageCount: 3) == 0)
        #expect(SwipeMenuGeometry.landedPage(position: 1.4, pageCount: 3) == 1)
        #expect(SwipeMenuGeometry.landedPage(position: 1.5, pageCount: 3) == 2)
    }

    @Test("Overscrolled positions land on the outermost pages")
    func overscrollLandsOnOutermostPages() {
        #expect(SwipeMenuGeometry.landedPage(position: -0.4, pageCount: 3) == 0)
        #expect(SwipeMenuGeometry.landedPage(position: 2.7, pageCount: 3) == 2)
    }

    @Test("An empty menu has no landed page")
    func emptyMenuHasNoLandedPage() {
        #expect(SwipeMenuGeometry.landedPage(position: 0, pageCount: 0) == nil)
    }

    // MARK: - selectionAmount

    @Test("A tab the swipe rests on is fully selected")
    func restingTabIsFullySelected() {
        #expect(SwipeMenuGeometry.selectionAmount(at: 1, position: 1) == 1)
    }

    @Test("Selection fades linearly between the two adjacent tabs")
    func selectionFadesLinearly() {
        #expect(SwipeMenuGeometry.selectionAmount(at: 1, position: 1.25) == 0.75)
        #expect(SwipeMenuGeometry.selectionAmount(at: 2, position: 1.25) == 0.25)
    }

    @Test("Tabs a full page or more away are fully deselected")
    func distantTabsAreDeselected() {
        #expect(SwipeMenuGeometry.selectionAmount(at: 0, position: 1) == 0)
        #expect(SwipeMenuGeometry.selectionAmount(at: 0, position: 2.5) == 0)
    }

    // MARK: - indicatorFrame

    @Test("At rest the indicator matches the selected tab")
    func indicatorMatchesTabAtRest() {
        let frame = SwipeMenuGeometry.indicatorFrame(
            itemFrames: itemFrames, itemCount: 3, position: 1, padding: EdgeInsets())

        #expect(frame?.minX == 80)
        #expect(frame?.width == 120)
    }

    @Test("Halfway through a swipe the indicator interpolates position and width")
    func indicatorInterpolatesMidSwipe() {
        let frame = SwipeMenuGeometry.indicatorFrame(
            itemFrames: itemFrames, itemCount: 3, position: 0.5, padding: EdgeInsets())

        #expect(frame?.minX == 40)
        #expect(frame?.width == 100)
    }

    @Test("Padding insets the indicator inside its tab")
    func paddingInsetsIndicator() {
        let padding = EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 6)
        let frame = SwipeMenuGeometry.indicatorFrame(
            itemFrames: itemFrames, itemCount: 3, position: 0, padding: padding)

        #expect(frame?.minX == 4)
        #expect(frame?.width == 70)
    }

    @Test("Positions beyond the ends pin the indicator to the outermost tabs")
    func indicatorClampsToOutermostTabs() {
        let below = SwipeMenuGeometry.indicatorFrame(
            itemFrames: itemFrames, itemCount: 3, position: -1, padding: EdgeInsets())
        #expect(below?.minX == 0)
        #expect(below?.width == 80)

        let beyond = SwipeMenuGeometry.indicatorFrame(
            itemFrames: itemFrames, itemCount: 3, position: 5, padding: EdgeInsets())
        #expect(beyond?.minX == 200)
        #expect(beyond?.width == 60)
    }

    @Test("The indicator hides until every needed tab frame is measured")
    func indicatorHidesWithoutMeasuredFrames() {
        let partialFrames: [Int: CGRect] = [0: CGRect(x: 0, y: 0, width: 80, height: 40)]

        let frame = SwipeMenuGeometry.indicatorFrame(
            itemFrames: partialFrames, itemCount: 3, position: 0.5, padding: EdgeInsets())
        #expect(frame == nil)

        let empty = SwipeMenuGeometry.indicatorFrame(
            itemFrames: [:], itemCount: 0, position: 0, padding: EdgeInsets())
        #expect(empty == nil)
    }

    @Test("Padding wider than the tab collapses the indicator instead of inverting it")
    func oversizedPaddingCollapsesIndicator() {
        let padding = EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50)
        let frame = SwipeMenuGeometry.indicatorFrame(
            itemFrames: itemFrames, itemCount: 3, position: 2, padding: padding)

        #expect(frame?.width == 0)
    }

    // MARK: - focusOffset

    @Test("The focus offset centers the point in the visible bar")
    func focusOffsetCenters() {
        let offset = SwipeMenuGeometry.focusOffset(
            centeringOn: 300, containerWidth: 200, contentWidth: 1000)
        #expect(offset == 200)
    }

    @Test("The focus offset clamps at the leading edge")
    func focusOffsetClampsAtLeadingEdge() {
        let offset = SwipeMenuGeometry.focusOffset(
            centeringOn: 50, containerWidth: 200, contentWidth: 1000)
        #expect(offset == 0)
    }

    @Test("The focus offset clamps at the trailing edge")
    func focusOffsetClampsAtTrailingEdge() {
        let offset = SwipeMenuGeometry.focusOffset(
            centeringOn: 950, containerWidth: 200, contentWidth: 1000)
        #expect(offset == 800)
    }

    @Test("Content narrower than the bar never scrolls")
    func narrowContentNeverScrolls() {
        let offset = SwipeMenuGeometry.focusOffset(
            centeringOn: 100, containerWidth: 200, contentWidth: 150)
        #expect(offset == 0)
    }
}

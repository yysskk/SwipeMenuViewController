import SwiftUI

/// The pure geometry behind ``SwipeMenu`` and `SwipeTabBar`.
///
/// Everything the SwiftUI menu draws or scrolls is derived from one continuous
/// value: the content's swipe position, in pages (`1.5` is halfway between the
/// second and third page). The functions here turn that value — together with
/// the measured tab frames — into the landed page, each title's selection
/// amount, the interpolated indicator frame, and the tab bar offset that keeps
/// the indicator in view. They are `nonisolated` and free of view state, so
/// they can be exercised directly in unit tests.
nonisolated enum SwipeMenuGeometry {

    /// Clamps a continuous page position to the valid range `0...(pageCount - 1)`.
    ///
    /// The content scroll reports offsets slightly past the first and last page
    /// while bouncing; clamping keeps the indicator and the title colors pinned
    /// to the outermost tabs, matching the UIKit ``TabView``.
    /// - Parameters:
    ///   - position: The raw page position (content offset divided by page width).
    ///   - pageCount: The number of pages.
    /// - Returns: The clamped position, or `0` when there are no pages.
    static func clampedPosition(_ position: CGFloat, pageCount: Int) -> CGFloat {
        guard pageCount > 0 else { return 0 }
        return min(max(position, 0), CGFloat(pageCount - 1))
    }

    /// The page a scroll has landed on: the page nearest to `position`, clamped
    /// to the valid range.
    /// - Parameters:
    ///   - position: The continuous page position when the scroll settled.
    ///   - pageCount: The number of pages.
    /// - Returns: The landed page index, or `nil` when there are no pages.
    static func landedPage(position: CGFloat, pageCount: Int) -> Int? {
        guard pageCount > 0 else { return nil }
        return min(max(Int(position.rounded()), 0), pageCount - 1)
    }

    /// How selected the tab at `index` is for a continuous page position: `1`
    /// when the swipe rests on the tab, `0` from a full page away, and linear in
    /// between. `SwipeTabBar` feeds this to `Color.mix(with:by:)` to crossfade
    /// the title colors while swiping.
    /// - Parameters:
    ///   - index: The tab index.
    ///   - position: The continuous page position.
    /// - Returns: The selection amount in `0...1`.
    static func selectionAmount(at index: Int, position: CGFloat) -> CGFloat {
        return max(0, 1 - abs(position - CGFloat(index)))
    }

    /// The horizontal frame of the selection indicator for a continuous page
    /// position, interpolated between the tab the swipe is leaving and the tab
    /// it is entering — the counterpart of the UIKit `TabView.moveIndicatorView`.
    ///
    /// Only `minX` and `width` are meaningful; the caller decides the vertical
    /// placement (underline versus circle).
    /// - Parameters:
    ///   - itemFrames: The measured frame of each tab, keyed by index, in the
    ///     tab container's coordinate space.
    ///   - itemCount: The number of tabs.
    ///   - position: The continuous page position; clamped to the valid range.
    ///   - padding: The indicator padding; `leading`/`trailing` inset the frame.
    /// - Returns: The interpolated frame, or `nil` while a needed tab frame has
    ///   not been measured yet.
    static func indicatorFrame(
        itemFrames: [Int: CGRect],
        itemCount: Int,
        position: CGFloat,
        padding: EdgeInsets
    ) -> CGRect? {
        guard itemCount > 0 else { return nil }

        let clamped = clampedPosition(position, pageCount: itemCount)
        let lowerIndex = min(Int(clamped), itemCount - 1)
        let upperIndex = min(lowerIndex + 1, itemCount - 1)
        let fraction = clamped - CGFloat(lowerIndex)

        guard let lower = itemFrames[lowerIndex], let upper = itemFrames[upperIndex] else { return nil }

        let minX = lower.minX + (upper.minX - lower.minX) * fraction + padding.leading
        let width = lower.width + (upper.width - lower.width) * fraction - padding.leading - padding.trailing
        return CGRect(x: minX, y: 0, width: max(width, 0), height: 0)
    }

    /// The scroll offset that keeps `centerX` in the middle of the visible tab
    /// bar, clamped so the bar never scrolls past its edges — the counterpart of
    /// the UIKit `TabView.focus(on:)`.
    /// - Parameters:
    ///   - centerX: The point to center, in the scroll content's coordinate space.
    ///   - containerWidth: The visible width of the tab bar.
    ///   - contentWidth: The full width of the scrollable tab content.
    /// - Returns: The clamped target offset.
    static func focusOffset(
        centeringOn centerX: CGFloat,
        containerWidth: CGFloat,
        contentWidth: CGFloat
    ) -> CGFloat {
        let maxOffset = max(contentWidth - containerWidth, 0)
        return min(max(centerX - containerWidth / 2, 0), maxOffset)
    }
}

import SwiftUI

/// The scrollable tab bar displayed at the top of a ``SwipeMenu`` — the SwiftUI
/// counterpart of the UIKit ``TabView``.
///
/// The bar lays out one tab item per title, draws the selection indicator
/// configured by ``SwipeMenuOptions/TabView-swift.struct``, and — in the
/// `.flexible` style — scrolls itself to keep the indicator in view while the
/// content is swiped. It holds no paging state of its own: the parent passes in
/// the committed `selection` and the continuous `progress`, and reacts to tab
/// taps through `onSelect`. All interpolation is delegated to
/// ``SwipeMenuGeometry`` so it can be unit tested.
@available(iOS 18.0, *)
struct SwipeTabBar: View {

    /// The container/content widths of the bar's scroll view, measured so the
    /// focus offset can be clamped to the scrollable range.
    nonisolated struct ScrollMetrics: Equatable, Sendable {
        var containerWidth: CGFloat = 0
        var contentWidth: CGFloat = 0
    }

    /// The name of the coordinate space the tab items are measured in: the tab
    /// container that also hosts the selection indicator.
    nonisolated static let coordinateSpaceName = "SwipeMenu.TabBar"

    /// The index of the selected tab.
    let selection: Int

    /// The tab titles; one item is laid out per title.
    let titles: [String]

    /// The appearance and behavior options for the bar.
    let options: SwipeMenuOptions.TabView

    /// The continuous page position of the content scroll, in pages.
    let progress: CGFloat

    /// Called when a tab is tapped, with the tapped index.
    let onSelect: (Int) -> Void

    /// The frame of each tab item in the tab container's coordinate space.
    @State private var itemFrames: [Int: CGRect] = [:]

    @State private var barPosition = ScrollPosition()
    @State private var barMetrics = ScrollMetrics()

    var body: some View {
        Group {
            switch options.style {
            case .flexible:
                flexibleBar
            case .segmented:
                container
                    .padding(.horizontal, options.margin)
            }
        }
        .frame(height: options.height)
        .background(options.backgroundColor)
    }

    private var flexibleBar: some View {
        ScrollView(.horizontal) {
            container
                .padding(.horizontal, options.margin)
        }
        .scrollIndicators(.hidden)
        .scrollPosition($barPosition)
        .onScrollGeometryChange(for: ScrollMetrics.self) { geometry in
            ScrollMetrics(
                containerWidth: geometry.containerSize.width,
                contentWidth: geometry.contentSize.width)
        } action: { _, newValue in
            barMetrics = newValue
        }
        .onChange(of: focusTargetX) { _, newValue in
            guard let newValue else { return }
            if options.indicatorView.isAnimationOnSwipeEnabled {
                // The swipe (or the tap-driven paging animation) moves the target a
                // little each frame, so following it unanimated tracks the finger.
                barPosition.scrollTo(x: newValue)
            } else {
                withAnimation(.easeInOut(duration: options.indicatorView.animationDuration)) {
                    barPosition.scrollTo(x: newValue)
                }
            }
        }
    }

    private var container: some View {
        ZStack(alignment: .topLeading) {
            if options.indicator == .circle {
                indicator
            }
            HStack(spacing: 0) {
                ForEach(titles.indices, id: \.self) { index in
                    itemView(at: index)
                }
            }
            .frame(height: itemsHeight)
            if options.indicator == .underline {
                indicator
            }
        }
        .frame(height: options.height, alignment: .topLeading)
        .coordinateSpace(.named(Self.coordinateSpaceName))
    }

    // MARK: - Items

    /// The height of the tab item area. The underline (and its bottom padding) is
    /// laid out below the items, matching the UIKit ``TabView``.
    private var itemsHeight: CGFloat {
        switch options.indicator {
        case .underline:
            return max(options.height - options.indicatorView.underline.height - options.indicatorView.padding.bottom, 0)
        case .circle, .none:
            return options.height
        }
    }

    @ViewBuilder
    private func itemView(at index: Int) -> some View {
        let label = itemLabel(at: index)
        Group {
            switch options.style {
            case .flexible:
                if options.adjustsItemViewWidth {
                    label.padding(.horizontal, options.itemView.margin)
                } else {
                    label.frame(width: options.itemView.width)
                }
            case .segmented:
                label.frame(maxWidth: .infinity)
            }
        }
        .frame(maxHeight: .infinity)
        .contentShape(.rect)
        .onTapGesture { onSelect(index) }
        .accessibilityAddTraits(index == selection ? [.isButton, .isSelected] : .isButton)
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .named(Self.coordinateSpaceName))
        } action: { newValue in
            itemFrames[index] = newValue
        }
    }

    @ViewBuilder
    private func itemLabel(at index: Int) -> some View {
        let item = options.itemView
        let lineLimit = item.numberOfLines == 0 ? nil : item.numberOfLines
        // The hidden text sizes the item with the base font so, as in the UIKit
        // `TabView`, swapping in `selectedFont` never changes the layout.
        Text(titles[index])
            .font(item.font)
            .lineLimit(lineLimit)
            .multilineTextAlignment(.center)
            .hidden()
            .overlay {
                Text(titles[index])
                    .font(index == selection ? item.selectedFont : item.font)
                    .foregroundStyle(titleColor(at: index))
                    .lineLimit(lineLimit)
                    .multilineTextAlignment(.center)
            }
    }

    private func titleColor(at index: Int) -> Color {
        let item = options.itemView
        guard options.interpolatesTextColorOnSwipe, options.indicatorView.isAnimationOnSwipeEnabled else {
            return index == selection ? item.selectedTextColor : item.textColor
        }
        let amount = SwipeMenuGeometry.selectionAmount(at: index, position: progress)
        return item.textColor.mix(with: item.selectedTextColor, by: Double(amount))
    }

    // MARK: - Indicator

    @ViewBuilder
    private var indicator: some View {
        let frame = indicatorFrame ?? .zero
        let indicatorView = options.indicatorView
        switch options.indicator {
        case .underline:
            RoundedRectangle(cornerRadius: indicatorView.underline.cornerRadius)
                .fill(indicatorView.backgroundColor)
                .frame(width: frame.width, height: indicatorView.underline.height)
                .offset(x: frame.minX, y: itemsHeight)
                .animation(indicatorAnimation, value: selection)
        case .circle:
            let height = max(itemsHeight - indicatorView.padding.top - indicatorView.padding.bottom, 0)
            RoundedRectangle(cornerRadius: indicatorView.circle.cornerRadius ?? height / 2)
                .fill(indicatorView.backgroundColor)
                .frame(width: frame.width, height: height)
                .offset(x: frame.minX, y: (itemsHeight - height) / 2)
                .animation(indicatorAnimation, value: selection)
        case .none:
            EmptyView()
        }
    }

    /// Animates selection-driven indicator moves when swipe tracking is off. With
    /// tracking on, the indicator follows `progress`, which the scroll itself
    /// animates frame by frame.
    private var indicatorAnimation: Animation? {
        options.indicatorView.isAnimationOnSwipeEnabled
            ? nil
            : .easeInOut(duration: options.indicatorView.animationDuration)
    }

    /// The indicator's horizontal frame, or `nil` while the tabs it interpolates
    /// between have not been measured yet. With swipe tracking off, the frame
    /// follows the committed selection instead of the continuous progress.
    private var indicatorFrame: CGRect? {
        let position = options.indicatorView.isAnimationOnSwipeEnabled ? progress : CGFloat(selection)
        return SwipeMenuGeometry.indicatorFrame(
            itemFrames: itemFrames,
            itemCount: titles.count,
            position: position,
            padding: options.indicatorView.padding)
    }

    // MARK: - Focus

    /// The scroll offset that centers the indicator in the visible tab bar,
    /// clamped to the scrollable range — the counterpart of the UIKit
    /// `TabView.focus(on:)`. `nil` while the bar or the items are not laid out
    /// yet, or when the `.segmented` style makes the bar unscrollable.
    private var focusTargetX: CGFloat? {
        guard options.style == .flexible, barMetrics.containerWidth > 0 else { return nil }
        guard let frame = indicatorFrame, frame.width > 0 else { return nil }

        return SwipeMenuGeometry.focusOffset(
            centeringOn: frame.midX + options.margin,
            containerWidth: barMetrics.containerWidth,
            contentWidth: barMetrics.contentWidth)
    }
}

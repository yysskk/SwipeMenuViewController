import SwiftUI

/// A SwiftUI view that presents a scrollable tab bar above a horizontally paging
/// content area — the SwiftUI counterpart of ``SwipeMenuView``.
///
/// The selected page is driven by a `Binding<Int>`, so moving to a page
/// programmatically (the equivalent of ``SwipeMenuView/jump(to:animated:)``) is a
/// matter of setting the binding. Tabs and pages come from `titles` and the `page`
/// view builder, appearance is configured through ``SwipeMenuOptions``, and the
/// optional `onWillChangeIndex`/`onDidChangeIndex` closures mirror the
/// ``SwipeMenuViewDelegate`` paging callbacks:
///
/// ```swift
/// @State private var selection = 0
///
/// var body: some View {
///     SwipeMenu(selection: $selection, titles: ["One", "Two", "Three"]) { index in
///         Text("Page \(index)")
///             .frame(maxWidth: .infinity, maxHeight: .infinity)
///     }
/// }
/// ```
///
/// Like the UIKit view, the tab bar's selection indicator and title colors track
/// the swipe continuously (see ``SwipeMenuOptions/TabView-swift.struct/indicatorView-swift.property``
/// and ``SwipeMenuOptions/TabView-swift.struct/interpolatesTextColorOnSwipe``), and
/// the `.flexible` tab bar auto-scrolls to keep the selection in view. Because
/// SwiftUI is declarative there is no `reloadData()`: changing `titles` or
/// `options` updates the menu in place.
@available(iOS 18.0, *)
public struct SwipeMenu<Page: View>: View {

    @Binding private var selection: Int

    private let titles: [String]
    private let options: SwipeMenuOptions
    private let onWillChangeIndex: ((_ fromIndex: Int, _ toIndex: Int) -> Void)?
    private let onDidChangeIndex: ((_ fromIndex: Int, _ toIndex: Int) -> Void)?
    private let page: (Int) -> Page

    /// The continuous page position driven by the content scroll offset, in pages
    /// (`1.5` = halfway between the second and third page). The tab bar
    /// interpolates the indicator and the title colors from this value.
    @State private var progress: CGFloat

    @State private var contentPosition: ScrollPosition

    /// The index a tap- or binding-driven move started from, kept until the scroll
    /// settles so `onDidChangeIndex` fires when the page actually finishes moving.
    @State private var pendingFromIndex: Int?

    /// Creates a swipe menu with the given pages.
    /// - Parameters:
    ///   - selection: A binding to the index of the front page.
    ///   - titles: The tab titles; one page is created per title.
    ///   - options: The appearance and behavior options.
    ///   - onWillChangeIndex: Called before the front page changes, with the current
    ///     and destination indices.
    ///   - onDidChangeIndex: Called after the front page has changed, with the
    ///     previous and current indices.
    ///   - page: A view builder that returns the content for the page at an index.
    public init(
        selection: Binding<Int>,
        titles: [String],
        options: SwipeMenuOptions = .init(),
        onWillChangeIndex: ((_ fromIndex: Int, _ toIndex: Int) -> Void)? = nil,
        onDidChangeIndex: ((_ fromIndex: Int, _ toIndex: Int) -> Void)? = nil,
        @ViewBuilder page: @escaping (Int) -> Page
    ) {
        self._selection = selection
        self.titles = titles
        self.options = options
        self.onWillChangeIndex = onWillChangeIndex
        self.onDidChangeIndex = onDidChangeIndex
        self.page = page
        self._progress = State(initialValue: CGFloat(selection.wrappedValue))
        self._contentPosition = State(initialValue: ScrollPosition(id: selection.wrappedValue))
    }

    public var body: some View {
        VStack(spacing: 0) {
            SwipeTabBar(
                selection: selection,
                titles: titles,
                options: options.tabView,
                progress: progress,
                onSelect: { index in
                    guard titles.indices.contains(index), index != selection else { return }
                    selection = index
                }
            )
            pager
        }
        .onChange(of: selection) { oldValue, newValue in
            guard oldValue != newValue else { return }
            // A selection committed by a swipe settling is already at the target
            // offset; only tap- or binding-driven changes need a scroll.
            guard SwipeMenuGeometry.landedPage(position: progress, pageCount: titles.count) != newValue else { return }
            if let pending = pendingFromIndex {
                // Finalize an interrupted move first so its `will` is paired with
                // a `did` before this move begins.
                pendingFromIndex = nil
                onDidChangeIndex?(pending, oldValue)
            }
            onWillChangeIndex?(oldValue, newValue)
            pendingFromIndex = oldValue
            withAnimation(.easeInOut(duration: options.tabView.indicatorView.animationDuration)) {
                contentPosition.scrollTo(id: newValue)
            }
        }
    }

    // MARK: - Content

    private var pager: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(titles.indices, id: \.self) { index in
                    page(index)
                        .containerRelativeFrame([.horizontal, .vertical])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition($contentPosition)
        .scrollIndicators(.hidden)
        .scrollDisabled(!options.contentScrollView.isScrollEnabled)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            guard geometry.containerSize.width > 0 else { return 0 }
            return geometry.contentOffset.x / geometry.containerSize.width
        } action: { _, newValue in
            progress = SwipeMenuGeometry.clampedPosition(newValue, pageCount: titles.count)
        }
        .onScrollPhaseChange { _, newPhase in
            guard newPhase == .idle else { return }
            commitScrollEnd()
        }
        .background(options.contentScrollView.backgroundColor)
    }

    /// Commits the page the content scroll settled on, firing the paging callbacks
    /// exactly once per move — whether the move came from a swipe, a tab tap, or a
    /// change to the selection binding.
    private func commitScrollEnd() {
        guard let landed = SwipeMenuGeometry.landedPage(position: progress, pageCount: titles.count) else { return }

        if let from = pendingFromIndex {
            pendingFromIndex = nil
            onDidChangeIndex?(from, selection)
            // A drag can interrupt the programmatic scroll and land elsewhere.
            guard landed != selection else { return }
        } else if landed == selection {
            return
        }

        onWillChangeIndex?(selection, landed)
        let from = selection
        selection = landed
        onDidChangeIndex?(from, landed)
    }
}

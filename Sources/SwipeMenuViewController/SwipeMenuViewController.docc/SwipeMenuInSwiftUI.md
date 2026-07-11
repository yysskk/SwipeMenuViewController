# SwipeMenu in SwiftUI

Drive the same swipe-based paging UI from SwiftUI with a selection binding.

@Metadata {
    @PageKind(article)
}

## Overview

``SwipeMenu`` is the SwiftUI counterpart of ``SwipeMenuView``, available on iOS 18 and later. It
presents the same UI — a tab bar above a horizontally paging content area — with a SwiftUI-native
API: the selected page is a `Binding<Int>`, pages come from a view builder, and the appearance is
configured with ``SwipeMenuOptions``.

The signature behaviors of the UIKit view carry over. The selection indicator interpolates its
position and width between the adjacent tabs while you swipe, the tab titles crossfade between
their normal and selected colors in proportion to the swipe progress, and the `.flexible` tab bar
scrolls itself to keep the selection in view.

## Displaying pages

Provide one title per page and a view builder that returns the page for an index. There is no data
source or `reloadData()`: changing `titles` or `options` re-renders the menu in place.

```swift
import SwiftUI
import SwipeMenuViewController

struct ContentView: View {

    @State private var selection = 0

    private let titles = ["Sports", "News", "Weather"]

    var body: some View {
        SwipeMenu(selection: $selection, titles: titles) { index in
            Text(titles[index])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
```

Setting the binding is the equivalent of ``SwipeMenuView/jump(to:animated:)`` — the content
animates to the new page and the tab bar follows:

```swift
Button("Show News") { selection = 1 }
```

## Customizing appearance

``SwipeMenuOptions`` mirrors ``SwipeMenuViewOptions`` with SwiftUI-native types: colors are
`Color`, fonts are `Font`, and insets are `EdgeInsets`. Build one, set the properties you care
about, and pass it to ``SwipeMenu/init(selection:titles:options:onWillChangeIndex:onDidChangeIndex:page:)``.

```swift
var options = SwipeMenuOptions()
options.tabView.style = .segmented
options.tabView.indicator = .circle
options.tabView.itemView.textColor = Color(.secondaryLabel)
options.tabView.itemView.selectedTextColor = Color(.systemBackground)
options.tabView.indicatorView.backgroundColor = Color(.label)

SwipeMenu(selection: $selection, titles: titles, options: options) { index in
    PageView(title: titles[index])
}
```

The option groups match the UIKit ones described in <doc:CustomizingAppearance>: `tabView` for the
bar, `tabView.itemView` for each tab, `tabView.indicatorView` for the selection indicator, and
`contentScrollView` for the paging content.

## Observing page changes

The `onWillChangeIndex` and `onDidChangeIndex` closures mirror the
``SwipeMenuViewDelegate/swipeMenuView(_:willChangeIndexFrom:to:)`` and
``SwipeMenuViewDelegate/swipeMenuView(_:didChangeIndexFrom:to:)`` callbacks. They fire exactly once
per move, whether the move came from a swipe, a tab tap, or a change to the selection binding:

```swift
SwipeMenu(
    selection: $selection,
    titles: titles,
    onWillChangeIndex: { fromIndex, toIndex in
        print("will move from \(fromIndex) to \(toIndex)")
    },
    onDidChangeIndex: { fromIndex, toIndex in
        print("did move from \(fromIndex) to \(toIndex)")
    }
) { index in
    PageView(title: titles[index])
}
```

There are no counterparts to the `viewWillSetupAt`/`viewDidSetupAt` callbacks; use `onAppear` if
you need to react to the menu appearing.

## Differences from the UIKit view

`SwipeMenu` leans on SwiftUI where SwiftUI already owns the behavior, so a few
``SwipeMenuViewOptions`` knobs intentionally have no counterpart on ``SwipeMenuOptions``:

- `isSafeAreaEnabled` and `clipsToBounds` are layout concerns of the container. Apply
  `ignoresSafeArea(_:edges:)` or `clipped()` around the `SwipeMenu` instead.
- The circle indicator exposes `cornerRadius` only; there is no `maskedCorners`.
- Programmatic moves are always animated, and the paging callbacks fire when the scroll settles
  rather than at the page boundary.
- Pages are built lazily as they scroll into view, not all at once.

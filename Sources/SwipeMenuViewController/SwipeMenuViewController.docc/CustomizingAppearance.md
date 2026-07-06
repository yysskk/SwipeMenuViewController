# Customizing Appearance

Tune the tab bar and content area with a `SwipeMenuViewOptions` value.

@Metadata {
    @PageKind(article)
}

## Overview

``SwipeMenuView`` reads its appearance from a ``SwipeMenuViewOptions`` value. Build one, set the
properties you care about, and pass it either to ``SwipeMenuView/init(frame:options:)`` or to
``SwipeMenuView/reloadData(options:default:isOrientationChange:)``. All properties have sensible
defaults, so you only override what you need.

```swift
var options = SwipeMenuViewOptions()
options.tabView.style = .segmented
options.tabView.addition = .underline
swipeMenuView.reloadData(options: options)
```

The options are grouped into ``SwipeMenuViewOptions/TabView`` (the tab bar) and
``SwipeMenuViewOptions/ContentScrollView`` (the paging content). The ``SwipeMenuViewOptions``
top-level `isSafeAreaEnabled` toggles the safe-area behavior of both at once.

## Tab bar

``SwipeMenuViewOptions/TabView`` controls the tab bar as a whole:

- `height`: the bar's height. Defaults to `44.0`.
- `margin`: the side margin. Defaults to `0.0`.
- `backgroundColor`: the bar's background color. Defaults to `.clear`.
- `clipsToBounds`: whether the bar clips its contents. Defaults to `true`.
- `style`: `.flexible` (items sized to their content) or `.segmented` (items share the width equally). Defaults to `.flexible`.
- `addition`: the selection indicator — `.underline`, `.circle`, or `.none`. Defaults to `.underline`.
- `needsAdjustItemViewWidth`: whether flexible item widths are adjusted to fit their titles. Defaults to `true`.
- `needsConvertTextColorRatio`: whether the item text color interpolates toward the selected color as you swipe. Defaults to `true`.
- `isSafeAreaEnabled`: whether the bar respects the safe area. Defaults to `true`.

```swift
var options = SwipeMenuViewOptions()
options.tabView.height = 52
options.tabView.margin = 8
options.tabView.backgroundColor = .systemBackground
options.tabView.style = .flexible
options.tabView.addition = .underline
options.tabView.needsAdjustItemViewWidth = true
options.tabView.needsConvertTextColorRatio = true
options.tabView.isSafeAreaEnabled = true
```

## Tab items

The `itemView` group configures each individual tab:

- `width`: the item width, used when `needsAdjustItemViewWidth` is `false`. Defaults to `100.0`.
- `margin`: the horizontal padding added around the title. Defaults to `5.0`.
- `font`: the title font. Defaults to a 14 pt bold system font.
- `clipsToBounds`: whether the item clips its contents. Defaults to `true`.
- `textColor`: the title color when unselected. Defaults to a gray.
- `selectedTextColor`: the title color when selected. Defaults to black.

```swift
options.tabView.itemView.width = 120
options.tabView.itemView.margin = 8
options.tabView.itemView.font = .boldSystemFont(ofSize: 15)
options.tabView.itemView.textColor = .secondaryLabel
options.tabView.itemView.selectedTextColor = .label
```

## Selection indicator

The `additionView` group configures the selection indicator drawn behind or beneath the items:

- `padding`: insets applied to the indicator. Defaults to `.zero`.
- `backgroundColor`: the indicator color. Defaults to `.black`.
- `animationDuration`: the duration used when animating the indicator to a tapped tab. Defaults to `0.3`.
- `isAnimationOnSwipeEnable`: whether the indicator follows your finger continuously while swiping. When `false`, it jumps to the destination tab instead. Defaults to `true`.

```swift
options.tabView.addition = .underline
options.tabView.additionView.padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
options.tabView.additionView.backgroundColor = .systemBlue
options.tabView.additionView.animationDuration = 0.25
options.tabView.additionView.isAnimationOnSwipeEnable = true
```

### Underline

When `addition` is `.underline`, the `underline` group sets the underline thickness. There is no
top-level height on the addition view — the thickness lives on the underline options:

- `height`: the underline thickness. Defaults to `2.0`.

```swift
options.tabView.addition = .underline
options.tabView.additionView.underline.height = 3
```

### Circle

When `addition` is `.circle`, the `circle` group shapes the highlight drawn behind the selected item:

- `cornerRadius`: the corner radius. When `nil` (the default), it is half the indicator's height, producing a pill.
- `maskedCorners`: which corners are rounded. Defaults to `nil` (all corners).

```swift
options.tabView.addition = .circle
options.tabView.additionView.backgroundColor = .systemBlue
options.tabView.additionView.circle.cornerRadius = 8
options.tabView.additionView.circle.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
```

## Content area

``SwipeMenuViewOptions/ContentScrollView`` controls the paging content beneath the tab bar:

- `backgroundColor`: the content background color. Defaults to `.clear`.
- `clipsToBounds`: whether the content clips to its bounds. Defaults to `true`.
- `isScrollEnabled`: whether the user can swipe between pages. Set to `false` to allow paging only by tapping tabs. Defaults to `true`.
- `isSafeAreaEnabled`: whether the content respects the safe area. Defaults to `true`.

```swift
options.contentScrollView.backgroundColor = .systemBackground
options.contentScrollView.clipsToBounds = true
options.contentScrollView.isScrollEnabled = true
options.contentScrollView.isSafeAreaEnabled = true
```

For a walkthrough of the initial setup, see <doc:GettingStarted>.

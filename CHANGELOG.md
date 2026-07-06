# Changelog

## 5.0.0 (Unreleased)

### Breaking
- Distribution is Swift Package Manager only. CocoaPods and Carthage support has been removed (the podspec and the framework Xcode project were deleted).
- The minimum deployment target was raised from iOS 11 to iOS 16.
- Requires the Swift 6.2 toolchain (Xcode 26+); the package now builds in Swift 6 language mode with main-actor default isolation.
- The public delegate and data source protocols are now `@MainActor`-isolated and use `AnyObject` instead of `class`.
- `SwipeMenuViewOptions` and its nested types are now `Sendable`.
- Removed the deprecated `SwipeMenuViewOptions.TabView.AdditionView.margin` property; use `padding` instead.
- `ContentScrollViewDataSource` now requires `AnyObject` and `ContentScrollView.dataSource` is now a `weak` reference (fixes a retain cycle that leaked `SwipeMenuView`).

### Added
- DocC documentation catalog with Getting Started and Customizing Appearance articles, plus documentation comments across the public API.
- A unit test suite (Swift Testing) that runs on the iOS simulator in CI.

### Changed
- Sources were reorganized into the standard Swift package layout (`Sources/SwipeMenuViewController`).
- The example app was rebuilt as a standalone Xcode project (`Example/Example.xcodeproj`) that consumes the library as a local package dependency.
- CI now builds the Swift package and the example app and runs the tests on the latest Xcode.

### Fixed
- Fixed a crash and broken tab text-color interpolation when tab colors are defined in a non-RGB color space (for example `.white`/`.black`).
- Fixed duplicate Auto Layout constraints being added on every layout pass in `SwipeMenuViewController`.
- Fixed a potential crash in the default data source when `numberOfPages(in:)` returns more pages than there are child view controllers.
- Fixed tab underline/text-color artifacts when swiping past the first or last tab.
- Fixed `SwipeMenuView.jump(to:animated:)` leaving `currentIndex` and the delegate change callbacks out of sync with the content when jumping across more than one page, and made it ignore out-of-range indices (a negative index previously crashed).
- Fixed `ContentScrollView` requesting nonexistent pages from its data source when built with an out-of-range initial index (for example `reloadData(default:)` past the last page).
- Fixed the views rebuilding themselves when removed from their superview (emitting spurious delegate setup callbacks) and duplicating their tab and content subviews when a `SwipeMenuView` was removed and re-added to a view hierarchy.
- Fixed the tab bar applying safe-area insets even when `isSafeAreaEnabled` is `false`, so a safe-area change (rotation, notch) no longer shifts a tab bar that opted out of safe-area layout.

## 4.1.0 - 2020-03-12
- Added `circle` addition style with `cornerRadius` and `maskedCorners` options.
- Added the `isAnimationOnSwipeEnable` option.
- Added Swift Package Manager support.
- Fixed incorrect display when `reloadData()` is executed while swiping a menu.

## 4.0.0 - 2019-10-09
- Swift 5.0 / Xcode 11 support.

## 3.0.0 - 2018-10-04
- Swift 4.2 / Xcode 10 support.

## 2.0.0 - 2017-10-01
- Swift 4.0 / Xcode 9 support.

## 1.x - 2017
- Initial releases (Swift 3, Xcode 8/9).

# SwipeMenuViewController

[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg?style=for-the-badge)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg?style=for-the-badge)](https://swift.org)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=for-the-badge)](https://www.swift.org/documentation/package-manager/)
[![CI](https://img.shields.io/github/actions/workflow/status/yysskk/SwipeMenuViewController/test.yml?branch=main&style=for-the-badge)](https://github.com/yysskk/SwipeMenuViewController/actions/workflows/test.yml)
[![Documentation](https://img.shields.io/badge/documentation-DocC-blueviolet.svg?style=for-the-badge)](https://yysskk.github.io/SwipeMenuViewController/documentation/swipemenuviewcontroller/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Swipe-based paging UI for iOS: a scrollable tab bar sits above a horizontally paging content area, and swiping the content keeps the tab selection in sync. You populate it through data source and delegate protocols modeled on UIKit's own, and tune its appearance with `SwipeMenuViewOptions`.

| Segmented Tab & Underline | Flexible Tab & Underline | Flexible Tab & Circle |
|:---:|:---:|:---:|
| <img src="https://raw.githubusercontent.com/yysskk/Assets/master/SwipeMenuViewController/demo_segmented_underline.gif"> | <img src="https://raw.githubusercontent.com/yysskk/Assets/master/SwipeMenuViewController/demo_flexible_underline.gif"> | <img src="https://raw.githubusercontent.com/yysskk/Assets/master/SwipeMenuViewController/demo_flexible_circle.gif"> |

## Requirements

- iOS 16.0+
- Xcode 26.0+ / Swift 6.2+

> Need an older toolchain or deployment target? Use the [4.x releases](https://github.com/yysskk/SwipeMenuViewController/releases).

## Installation

SwipeMenuViewController is distributed with [Swift Package Manager](https://www.swift.org/documentation/package-manager/). In Xcode, choose **File ▸ Add Package Dependencies…** and enter the repository URL, or add it to a `Package.swift` manifest:

```swift
dependencies: [
    .package(url: "https://github.com/yysskk/SwipeMenuViewController.git", .upToNextMajor(from: "5.0.0"))
]
```

## Quick Start

Subclass `SwipeMenuViewController` and add your pages as child view controllers. Each child becomes a page: its `title` is the tab title and its view is the page content.

```swift
import SwipeMenuViewController

final class MenuViewController: SwipeMenuViewController {

    override func viewDidLoad() {
        pages.forEach { addChild($0) }
        super.viewDidLoad()
    }

    private let pages: [UIViewController] = {
        let first = UIViewController()
        first.title = "First"
        let second = UIViewController()
        second.title = "Second"
        return [first, second]
    }()
}
```

To embed the paging UI in a view hierarchy you already have, add a `SwipeMenuView` directly and drive it through `SwipeMenuViewDataSource` — the [Getting Started](https://yysskk.github.io/SwipeMenuViewController/documentation/swipemenuviewcontroller/gettingstarted) article walks through both approaches.

## Documentation

The full API reference and guides are published with DocC:

**[Read the documentation →](https://yysskk.github.io/SwipeMenuViewController/documentation/swipemenuviewcontroller/)**

- [Getting Started](https://yysskk.github.io/SwipeMenuViewController/documentation/swipemenuviewcontroller/gettingstarted) — set up `SwipeMenuView` or `SwipeMenuViewController`
- [Customizing Appearance](https://yysskk.github.io/SwipeMenuViewController/documentation/swipemenuviewcontroller/customizingappearance) — every `SwipeMenuViewOptions` field

You can also build the documentation locally in Xcode with **Product ▸ Build Documentation**, or explore the [Example app](./Example) in this repository (its Xcode project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) — see the [Example README](./Example/README.md)).

## Contributing

Bug reports and pull requests are welcome. Please open an issue using one of the templates, and make sure the test suite passes (`xcodebuild test -scheme SwipeMenuViewController -destination 'platform=iOS Simulator,name=iPhone 16'`).

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for the release history.

## License

SwipeMenuViewController is available under the MIT license. See the [LICENSE](./LICENSE) file for details.

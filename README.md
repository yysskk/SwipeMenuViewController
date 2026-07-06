# SwipeMenuViewController

[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg?style=for-the-badge)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg?style=for-the-badge)](https://swift.org)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=for-the-badge)](https://www.swift.org/documentation/package-manager/)
[![CI](https://img.shields.io/github/actions/workflow/status/yysskk/SwipeMenuViewController/test.yml?branch=master&style=for-the-badge)](https://github.com/yysskk/SwipeMenuViewController/actions/workflows/test.yml)
[![Documentation](https://img.shields.io/badge/documentation-DocC-blueviolet.svg?style=for-the-badge)](https://yysskk.github.io/SwipeMenuViewController/documentation/swipemenuviewcontroller/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

## Overview
SwipeMenuViewController provides `SwipeMenuView` and `SwipeMenuViewController`, which make it easy to build swipe-based paging UI. A scrollable tab bar sits above a horizontally paging content area, and swiping the content keeps the tab selection in sync. The interface is modeled on UIKit's own data source and delegate patterns, so it should feel familiar.

## Demo
Here are some of the styles you can build with `SwipeMenuView`.

| Segmented Tab & Underline | Flexible Tab & Underline | Flexible Tab & Circle |
|:---:|:---:|:---:|
| <img src="https://raw.githubusercontent.com/yysskk/Assets/master/SwipeMenuViewController/demo_segmented_underline.gif"> | <img src="https://raw.githubusercontent.com/yysskk/Assets/master/SwipeMenuViewController/demo_flexible_underline.gif"> | <img src="https://raw.githubusercontent.com/yysskk/Assets/master/SwipeMenuViewController/demo_flexible_circle.gif"> |

## Requirements
- iOS 16.0+
- Xcode 26.0+ / Swift 6.2+

> Need an older toolchain or deployment target? Use the [4.x releases](https://github.com/yysskk/SwipeMenuViewController/releases).

## Installation
### Swift Package Manager
SwipeMenuViewController is distributed exclusively through [Swift Package Manager](https://www.swift.org/documentation/package-manager/).

In Xcode, choose **File ▸ Add Package Dependencies…** and enter:

```
https://github.com/yysskk/SwipeMenuViewController.git
```

Or add it to a `Package.swift` manifest:

```swift
dependencies: [
    .package(url: "https://github.com/yysskk/SwipeMenuViewController.git", .upToNextMajor(from: "5.0.0"))
]
```

## Usage
The quickest way to get started is to subclass `SwipeMenuViewController` and add your pages as child view controllers:

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

By default each page is backed by one of the controller's `children`: the page count is `children.count`, each tab title is the child's `title`, and each page shows the child's view. Override the `SwipeMenuViewDataSource` methods for fully custom paging.

To place the paging UI inside a view hierarchy you already have, add a `SwipeMenuView` directly, set its `dataSource` (and optional `delegate`), and customize it with `SwipeMenuViewOptions`:

```swift
import SwipeMenuViewController

final class CatalogViewController: UIViewController {

    private let swipeMenuView = SwipeMenuView(frame: .zero)
    private let titles = ["Sports", "News", "Weather"]

    override func viewDidLoad() {
        super.viewDidLoad()

        swipeMenuView.frame = view.bounds
        swipeMenuView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        swipeMenuView.dataSource = self
        view.addSubview(swipeMenuView)

        var options = SwipeMenuViewOptions()
        options.tabView.style = .segmented
        swipeMenuView.reloadData(options: options)
    }
}

extension CatalogViewController: SwipeMenuViewDataSource {

    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int { titles.count }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        titles[index]
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let page = UIViewController()
        page.title = titles[index]
        return page
    }
}
```

The delegate and data source callbacks are main-actor isolated, so implement them from your (main-actor) view controllers as usual. See the [documentation](#documentation) for every `SwipeMenuViewOptions` field.

## Documentation
The full API reference and articles are published online with DocC:

**[Read the documentation →](https://yysskk.github.io/SwipeMenuViewController/documentation/swipemenuviewcontroller/)**

Start with the **Getting Started** and **Customizing Appearance** articles for the full setup walkthrough and every available option. You can also build the documentation locally in Xcode with **Product ▸ Build Documentation**.

## Contributing
Bug reports and pull requests are welcome. Please open an issue using one of the templates, and make sure the test suite passes (`xcodebuild test -scheme SwipeMenuViewController -destination 'platform=iOS Simulator,name=iPhone 16'`).

## Changelog
See [CHANGELOG.md](./CHANGELOG.md) for the release history.

## License
SwipeMenuViewController is available under the MIT license. See the [LICENSE](./LICENSE) file for details.

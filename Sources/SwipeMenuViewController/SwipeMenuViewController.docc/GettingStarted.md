# Getting Started

Add a swipe menu to your app, either as a view or as a container view controller.

@Metadata {
    @PageKind(article)
}

## Overview

There are two ways to use the library. Use ``SwipeMenuView`` directly when you want to embed the
paging UI inside a view controller you already have, or subclass ``SwipeMenuViewController`` when
you want a ready-made container that pages between child view controllers.

Both the data source and the delegate protocols are `@MainActor`-isolated, so their callbacks are
always delivered on the main actor.

## Using SwipeMenuView

Import the module wherever you use the API:

```swift
import SwipeMenuViewController
```

Add a ``SwipeMenuView`` to your view controller, assign its ``SwipeMenuView/dataSource`` and
optional ``SwipeMenuView/delegate``, and call
``SwipeMenuView/reloadData(options:default:isOrientationChange:)`` to build its pages. You can
pass a ``SwipeMenuViewOptions`` value to customize the appearance.

```swift
final class CustomViewController: UIViewController {

    private let swipeMenuView = SwipeMenuView(frame: .zero)
    private let titles = ["Sports", "News", "Weather"]

    override func viewDidLoad() {
        super.viewDidLoad()

        swipeMenuView.frame = view.bounds
        swipeMenuView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        swipeMenuView.dataSource = self
        swipeMenuView.delegate = self
        view.addSubview(swipeMenuView)

        var options = SwipeMenuViewOptions()
        options.tabView.style = .segmented
        swipeMenuView.reloadData(options: options)
    }
}
```

Conform to ``SwipeMenuViewDataSource`` to supply the pages and their titles:

```swift
extension CustomViewController: SwipeMenuViewDataSource {

    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return titles.count
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return titles[index]
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        return ContentViewController()
    }
}
```

Conform to ``SwipeMenuViewDelegate`` to observe setup and paging events. Every method has a
default no-op implementation, so implement only the ones you need:

```swift
extension CustomViewController: SwipeMenuViewDelegate {

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) { }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) { }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) { }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) { }
}
```

## Subclassing SwipeMenuViewController

``SwipeMenuViewController`` is a container that creates and manages a ``SwipeMenuView`` for you and
acts as both its data source and its delegate. By default it uses the controller's `children` as
the pages: the page count is `children.count`, each page's title is the child's `title`, and each
page shows the child's view. Add child view controllers before the view loads, and the container
does the rest:

```swift
final class MenuViewController: SwipeMenuViewController {

    override func viewDidLoad() {
        let sports = ContentViewController()
        sports.title = "Sports"
        let news = ContentViewController()
        news.title = "News"

        addChild(sports)
        addChild(news)

        super.viewDidLoad()
    }
}
```

If your pages are not backed by `children`, override the data source methods instead. The
out-of-range fallbacks are handled for you: ``SwipeMenuViewController/swipeMenuView(_:titleForPageAt:)``
returns an empty string and ``SwipeMenuViewController/swipeMenuView(_:viewControllerForPageAt:)``
returns a placeholder view controller when asked for an index that does not exist.

```swift
final class MenuViewController: SwipeMenuViewController {

    private let pages = ["Sports", "News", "Weather"]

    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return pages.count
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return pages[index]
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        return ContentViewController()
    }
}
```

Once your data source is in place, see <doc:CustomizingAppearance> to tune the tab bar and content area.

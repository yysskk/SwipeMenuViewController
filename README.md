# SwipeMenuViewController
[![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)
[![Cocoapods](https://img.shields.io/badge/Cocoapods-compatible-brightgreen.svg)](https://img.shields.io/badge/Cocoapods-compatible-brightgreen.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)
![pod](https://img.shields.io/badge/pod-v1.0.0-red.svg)

## Overview
This is swipable menu framework including `SwipeMenuView` and `SwipeMenuViewController`. It is designed to resembling simple UIKit interface.

## Demo
Here are some style demos and codes using `SwipeMenuView`.

<img src="https://github.com/yysskk/Assets/blob/master/SwipeMenuViewController/demo_segmented.gif" align="left" width="300">

### Segmented style

```
@IBOutlet weak var swipeMenuView: SwipeMenuView! {
    didSet {
        swipeMenuView.delegate                        = self
        swipeMenuView.dataSource                      = self
        var options: SwipeMenuViewOptions             = .init()
        options.tabView.style                         = .segmented
        options.tabView.underlineView.backgroundColor = UIColor.customUnderlineColor
        options.tabView.itemView.textColor            = UIColor.customTextColor
        options.tabView.itemView.selectedTextColor    = UIColor.customSelectedTextColor
        swipeMenuView.reload(options: options)
    }
}
```
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

<img src="https://github.com/yysskk/Assets/blob/master/SwipeMenuViewController/demo_flexible.gif" align="right" width="300">

### Flexible style

```
@IBOutlet weak var swipeMenuView: SwipeMenuView! {
    didSet {
        swipeMenuView.delegate                          = self
        swipeMenuView.dataSource                        = self
        var options: SwipeMenuViewOptions               = .init()
        options.tabView.style                           = .flexible
        options.tabView.margin                          = 8.0
        options.tabView.underlineView.backgroundColor   = UIColor.customUnderlineColor
        options.tabView.backgroundColor                 = UIColor.customBackgroundColor
        options.tabView.underlineView.height            = 3.0
        options.tabView.itemView.textColor              = UIColor.customTextColor
        options.tabView.itemView.selectedTextColor      = .white
        options.tabView.itemView.margin                 = 10.0
        options.contentScrollView.backgroundColor       = UIColor.customBackgroundColor
        swipeMenuView.reload(options: options)
    }
}
```
<br/>
<br/>
<br/>
<br/>
<br/>

### Infinity style
WIP...

## Installation
#### CocoaPods
SwipeMenuViewController is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your `Podfile` :


```
pod ‘SwipeMenuViewController’
```

#### Carthage

SwipeMenuViewController is also available through [Carthage](https://github.com/carthage/carthage).  Add the following line to your `Cartfile` :


```
github “yysskk/SwipeMenuViewController”
```
## Usage
### SwipeMenuView
**1)** Add the files listed in the installation section to your project

**2)** Import `SwipeMenuViewController ` module to your `CustomViewController` class

```
import SwipeMenuViewController
```

**3)** Add SwipeMenuView to `CustomViewController` , then set dataSource and delegate, options if you need for it

```
class CustomViewController: UIViewController {

    @IBOutlet weak var swipeMenuView: SwipeMenuView!

    override func viewDidLoad() {
        super.viewDidLoad()

        swipeMenuView.dataSource = self
        swipeMenuView.delegate = self

        let options: SwipeMenuViewOptions = .init()

        swipeMenuView.reloadData(options: options)
    }
}
```

**4)** Conform your `CustomViewController` to `SwipeMenuViewControllerDelegate` optional protocol.

```
extension CustomViewController: SwipeMenuViewControllerDelegate {

    // MARK - SwipeMenuViewControllerDelegate
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // Codes
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // Codes
    }
}
```

**5)** Conform your `CustomViewController` to `SwipeMenuViewControllerDataSource` protocol.

```
extension CustomViewController: SwipeMenuViewControllerDataSource {

     //MARK - SwipeMenuViewControllerDataSource
     func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return array.count
      }

     func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return array[index]
     }

     func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = ContentViewController()
        return vc
     }
}
```

### SwipeMenuViewController
**1)** Check SwipeMenuView section 1) ~ 2)

**2)** Use `SwipeMenuViewController` classes

```
class CustomViewController: SwipeMenuViewController {
}
```

**3)** Conform your `CustomViewController` to override `SwipeMenuViewDelegate` methods and `SwipeMenuViewDataSource` methods if you need.

```
extension CustomViewController {

    // MARK: - SwipeMenuViewDelegate
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // Codes
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // Codes
    }


    // MARK - SwipeMenuViewDataSource
    open override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return array.count
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return array[index]
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = ContentViewController()
        return vc
    }
}
```

### Methods
`SwipeMenuView` has the following methods.

```
func setup()
```
This method setup `SwipeMenuView` from the dataSource.
```
func reloadData(options: SwipeMenuViewOptions? = nil, isOrientationChange: Bool = false)
```
This method reloads all `SwipeMenuView` item views from the dataSource and refreshes the display.
```
func jump(to index: Int)
```
This method apply jumping action to the selected page.
```
func willChangeOrientation()
```
This method notice changing orientaion to `SwipeMenuView` before it.

### Protocols
`SwipeMenuView` has the following protocols.
```
func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int
```
Return the number of pages in `SwipeMenuView`.

```
func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String
```
Return strings to be displayed at the specified tag in `SwipeMenuView`.

```
func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController
```
Return a ViewController to be displayed at the specified page in `SwipeMenuView`.

```
func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int)
```
This method is called before swiping the page.

```
func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int)
```
This method is called after swiping the page.

### Properties
`SwipeMenuView` has the following properties.

```
weak var delegate: SwipeMenuViewDelegate!
```
An object that supports the `SwipeMenuViewDelegate` protocol and can provide views to populate the `SwipeMenuView`.

```
weak var dataSource: SwipeMenuDataSource!
```
An object that supports the `SwipeMenuViewDataSource` protocol and can provide views to can respond to `SwipeMenuView` events.

```
public var currentIndex
```
The index of the front page in `SwipeMenuView` (read only).

### Customization
`SwipeMenuView` is customizable by designated options property when calling `reloadData()` method.
Here are many properties of `SwipeMenuViewOptions` which you are able to customize it for your needs.

#### TabView
```
public var height: CGFloat
```
TabView height. Default setting `44.0`.

```
public var margin: CGFloat
```
TabView side margin. Default setting `0.0`.

```
public var backgroundColor: UIColor
```
TabView background color. Default setting `.white`.

```
public var style: Style
```
TabView style. Default setting `.flexible`. Style type has [`.flexible` , `.segmented`].

```
public var addition: Addition
```
TabView addition. Default setting `.underline`. Addition type has [`.underline`, `.none`].

```
public var isAdjustItemViewWidth: Bool
```
TabView adjust width or not. Default setting `true`.

##### ItemView

```
public var width: CGFloat
```
ItemView width. Default setting `100.0`.

```
public var margin: CGFloat
```
ItemView side margin. Default setting `5.0`.

```
public var textColor: UIColor
```
ItemView textColor. Default setting `.lightGray`.

```
public var selectedTextColor: UIColor
```
ItemView selected textColor. Default setting `.black`.

##### UndelineView

```
public var height: CGFloat
```
UndelineView height. Default setting `2.0`.

```
public var margin: CGFloat
```
UndelineView side margin. Default setting `0.0`.

```
public var backgroundColor: UIColor
```
UndelineView backgroundColor. Default setting `.black`.

```
public var animationDuration: CGFloat
```
UnderlineView animating duration. Default setting `0.3`.

#### ContentScrollView

```
public var backgroundColor: UIColor
```
ContentScrollView backgroundColor. Default setting `.clear`.

```
public var isScrollEnabled: Bool
```
ContentScrollView scroll enabled. Default setting `true`.

## Requirements
- Xcode 8.0+
- Swift 3.0+

## Creator
### Yusuke Morishita
- [Github](https://github.com/yysskk)
- [Facebook](https://www.facebook.com/yysskk.mrst)
- [Twitter](https://twitter.com/_yysskk)


## License
`SwipeMenuViewController` is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.

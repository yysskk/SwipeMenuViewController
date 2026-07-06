# ``SwipeMenuViewController``

Build swipe-based paging interfaces with a scrollable tab bar and a familiar, UIKit-like API.

## Overview

SwipeMenuViewController provides ``SwipeMenuView`` and ``SwipeMenuViewController`` for building
swipe-based paging UI. A tab bar sits above a horizontally paging content area, and swiping the
content keeps the tab selection in sync. You populate it through data source and delegate
protocols modeled on UIKit's, and you tune its appearance with ``SwipeMenuViewOptions``.

Use ``SwipeMenuView`` when you want to embed the paging UI inside an existing view hierarchy, or
subclass ``SwipeMenuViewController`` to get a container view controller that drives the paging
from its child view controllers.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:CustomizingAppearance>

### Menu View

- ``SwipeMenuView``
- ``SwipeMenuViewDelegate``
- ``SwipeMenuViewDataSource``
- ``SwipeMenuViewOptions``

### View Controller

- ``SwipeMenuViewController``

### Tabs

- ``TabView``
- ``TabViewDelegate``
- ``TabViewDataSource``

### Content

- ``ContentScrollView``
- ``ContentScrollViewDataSource``

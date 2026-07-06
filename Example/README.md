# Example app

A small iOS app that demonstrates `SwipeMenuViewController` and lets you tweak
`SwipeMenuViewOptions` live. It is written entirely in code — no storyboards —
with a `UIWindowScene` lifecycle and SF Symbols, and the option-building logic in
[`SwipeMenuSettings`](./Example/SwipeMenuSettings.swift) is covered by unit tests
in [`ExampleTests`](./ExampleTests).

The Xcode project is generated from [`project.yml`](./project.yml) with
[XcodeGen](https://github.com/yonaskolb/XcodeGen), so `Example.xcodeproj` is not
checked in. Generate it before opening the app:

```sh
brew install xcodegen        # once, if you don't have it
cd Example
xcodegen generate
open Example.xcodeproj
```

Re-run `xcodegen generate` whenever you change `project.yml`. Adding or removing
source files does not require regenerating — the project references the
`Example/` folder directly.

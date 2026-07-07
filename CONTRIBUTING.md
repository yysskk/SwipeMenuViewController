# Contributing to SwipeMenuViewController

Thank you for considering a contribution! Bug reports, fixes, documentation
improvements, and well-scoped features are all welcome. This document explains
how to get the project running locally and what a pull request needs before it
can be merged.

## Requirements

- Xcode 26.0 or later (Swift 6.2 toolchain)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — only if you work on the example app

## Project layout

| Path | What it is |
|---|---|
| `Package.swift` | Swift package manifest — the library is SPM-only |
| `Sources/SwipeMenuViewController/` | Library sources and the DocC catalog |
| `Tests/SwipeMenuViewControllerTests/` | Unit tests (Swift Testing, run on the iOS simulator) |
| `Example/` | Demo app consuming the library as a local package |

## Building and testing

Open the package directly in Xcode (`File ▸ Open… ▸ Package.swift`) or run the
tests from the command line against any available iPhone simulator:

```sh
xcodebuild test \
  -scheme SwipeMenuViewController \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  CODE_SIGNING_ALLOWED=NO
```

Replace `iPhone 17` with any simulator you have installed
(`xcrun simctl list devices available`).

## Example app

The example app's Xcode project is generated — `Example.xcodeproj` is not
committed, and [`Example/project.yml`](Example/project.yml) is the source of
truth:

```sh
cd Example
xcodegen generate
open Example.xcodeproj
```

Re-run `xcodegen generate` whenever you change `project.yml`. See the
[Example README](Example/README.md) for details.

## Formatting and linting

The codebase is formatted and linted with the Swift toolchain's built-in
[swift-format](https://github.com/swiftlang/swift-format); the configuration
lives in [`.swift-format`](.swift-format). Before pushing:

```sh
swift format --in-place --recursive --parallel Sources Tests Example/Example Example/ExampleTests Package.swift
swift format lint --strict --recursive --parallel Sources Tests Example/Example Example/ExampleTests Package.swift
```

CI fails if the tree is not formatter-clean or any lint rule fires.

## Documentation

The public API is documented with DocC (`Sources/SwipeMenuViewController/SwipeMenuViewController.docc`).
If your change touches the public API, update the documentation comments and,
where relevant, the articles. CI builds the documentation with warnings treated
as errors, so broken symbol links fail the build:

```sh
xcodebuild docbuild \
  -scheme SwipeMenuViewController \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  OTHER_DOCC_FLAGS='--warnings-as-errors'
```

The published documentation at
[yysskk.github.io/SwipeMenuViewController](https://yysskk.github.io/SwipeMenuViewController/documentation/swipemenuviewcontroller/)
is deployed automatically from `main`.

## Changelog

User-facing changes (new options, behavior changes, bug fixes) get an entry in
the **Unreleased** section of [CHANGELOG.md](CHANGELOG.md). Internal refactors
and CI changes do not need one.

## Pull requests

1. Fork and create a topic branch from `main`.
2. Keep the PR focused; unrelated changes belong in separate PRs.
3. Add or update unit tests for what you change — bug fixes need a regression
   test that fails without the fix.
4. Make sure the test suite, the formatter, and the documentation build all
   pass locally.
5. Fill in the pull request template. CI (tests, example build, documentation,
   swift-format) must be green before review.

For anything larger than a bug fix, consider opening an issue first to discuss
the direction.

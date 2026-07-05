// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwipeMenuViewController",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "SwipeMenuViewController", targets: ["SwipeMenuViewController"])
    ],
    targets: [
        .target(name: "SwipeMenuViewController")
    ]
)

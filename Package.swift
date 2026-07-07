// swift-tools-version:6.2
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
        .target(
            name: "SwipeMenuViewController",
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
        .testTarget(
            name: "SwipeMenuViewControllerTests",
            dependencies: ["SwipeMenuViewController"],
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
    ]
)

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StarscreamWebSocketBackend",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "StarscreamWebSocketBackend",
            targets: ["StarscreamWebSocketBackend"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.8"),
        .package(url: "https://github.com/codingiran/WebSocketClient.git", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "StarscreamWebSocketBackend",
            dependencies: [
                "WebSocketCore",
            ]
        ),
        .testTarget(
            name: "StarscreamWebSocketBackendTests",
            dependencies: ["StarscreamWebSocketBackend"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StarscreamWebSocketBackend",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
        .visionOS(.v1),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "StarscreamWebSocketBackend",
            targets: ["StarscreamWebSocketBackend"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.8"),
        .package(url: "https://github.com/codingiran/WebSocketClient.git", from: "0.0.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "StarscreamWebSocketBackend",
            dependencies: [
                "WebSocketClient",
                "Starscream",
            ],
            path: "Sources/StarscreamWebSocketBackend",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "StarscreamWebSocketBackendTests",
            dependencies: ["StarscreamWebSocketBackend"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

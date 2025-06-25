// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TaskManager",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "TaskManagerCLI",
            targets: ["TaskManagerCLI"]
        ),
        .executable(
            name: "TaskManagerMac",
            targets: ["TaskManagerMac"]
        ),
        .library(
            name: "TaskManagerCore",
            targets: ["TaskManagerCore"]
        ),
        .library(
            name: "TaskManagerUI",
            targets: ["TaskManagerUI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0")
    ],
    targets: [
        // Core business logic and data models
        .target(
            name: "TaskManagerCore",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ],
            path: "Sources/Core"
        ),
        
        // UI components and SwiftUI views
        .target(
            name: "TaskManagerUI",
            dependencies: ["TaskManagerCore"],
            path: "Sources/UI"
        ),
        
        // Command line interface
        .executableTarget(
            name: "TaskManagerCLI",
            dependencies: [
                "TaskManagerCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CLI"
        ),
        
        // macOS SwiftUI application
        .executableTarget(
            name: "TaskManagerMac",
            dependencies: ["TaskManagerCore", "TaskManagerUI"],
            path: "Sources/MacOS"
        ),
        
        // Tests
        .testTarget(
            name: "TaskManagerCoreTests",
            dependencies: ["TaskManagerCore"],
            path: "Tests/TaskManagerCoreTests"
        ),
        
        .testTarget(
            name: "TaskManagerUITests",
            dependencies: ["TaskManagerUI", "TaskManagerCore"],
            path: "Tests/TaskManagerUITests"
        )
    ]
)

// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WorktualAIBot",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "WorktualAIBot",
            targets: ["WorktualAIBot"]
        )
    ],
    targets: [
        .target(
            name: "WorktualAIBot",
            path: "Sources/WorktualAIBot"
        ),
        .testTarget(
            name: "WorktualAIBotTests",
            dependencies: ["WorktualAIBot"],
            path: "Tests/WorktualAIBotTests"
        )
    ]
)

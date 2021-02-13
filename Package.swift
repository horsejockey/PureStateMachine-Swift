// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PureStateMachine",
    products: [
        .library(
            name: "PureStateMachine",
            targets: ["PureStateMachine"]),
    ],
    dependencies: [
        .package(
            name: "Actor",
            url: "https://github.com/horsejockey/Actor-iOS",
            from: "4.0.0"
        ),
    ],
    targets: [
        .target(
            name: "PureStateMachine",
            dependencies: ["Actor"]),
        .testTarget(
            name: "PureStateMachineTests",
            dependencies: ["PureStateMachine"]),
    ]
)

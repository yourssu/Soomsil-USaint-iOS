// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Soomsil-USaint-iOS",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Soomsil-USaint-iOS",
            targets: ["Soomsil-USaint-iOS"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Soomsil-USaint-iOS"),
        .testTarget(
            name: "Soomsil-USaint-iOSTests",
            dependencies: ["Soomsil-USaint-iOS"]
        ),
    ]
)

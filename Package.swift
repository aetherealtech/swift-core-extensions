// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreExtensions",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AsyncCollectionExtensions",
            targets: ["AsyncCollectionExtensions"]),
        .library(
            name: "AsyncExtensions",
            targets: ["AsyncExtensions"]),
        .library(
            name: "CodableExtensions",
            targets: ["CodableExtensions"]),
        .library(
            name: "CollectionExtensions",
            targets: ["CollectionExtensions"]),
        .library(
            name: "CombineExtensions",
            targets: ["CombineExtensions"]),
        .library(
            name: "CompareFunctions",
            targets: ["CompareFunctions"]),
        .library(
            name: "CoreExtensions",
            targets: ["CoreExtensions"]),
        .library(
            name: "FileSystemExtensions",
            targets: ["FileSystemExtensions"]),
        .library(
            name: "LazyCollectionExtensions",
            targets: ["LazyCollectionExtensions"]),
        .library(
            name: "NumericExtensions",
            targets: ["NumericExtensions"]),
        .library(
            name: "OptionalExtensions",
            targets: ["OptionalExtensions"]),
    ],
    dependencies: [
        .package(path: "../Synchronization"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AsyncCollectionExtensions",
            dependencies: [
                "AsyncExtensions",
                "CollectionExtensions",
                "CoreExtensions"
            ]),
        .target(
            name: "AsyncExtensions",
            dependencies: []),
        .target(
            name: "CodableExtensions",
            dependencies: []),
        .target(
            name: "CollectionExtensions",
            dependencies: [
                "CompareFunctions",
                "OptionalExtensions"
            ]),
        .target(
            name: "CombineExtensions",
            dependencies: [
                "AsyncCollectionExtensions",
                "AsyncExtensions",
                "CollectionExtensions",
                .product(name: "Synchronization", package: "Synchronization"),
                "OptionalExtensions"
            ]),
        .target(
            name: "CompareFunctions",
            dependencies: []),
        .target(
            name: "CoreExtensions",
            dependencies: [
                "OptionalExtensions"
            ]),
        .target(
            name: "FileSystemExtensions",
            dependencies: []),
        .target(
            name: "LazyCollectionExtensions",
            dependencies: [
                "CollectionExtensions"
            ]),
        .target(
            name: "NumericExtensions",
            dependencies: []),
        .target(
            name: "OptionalExtensions",
            dependencies: []),
        .testTarget(
            name: "AsyncCollectionExtensionsTests",
            dependencies: ["AsyncCollectionExtensions"]),
        .testTarget(
            name: "AsyncExtensionsTests",
            dependencies: ["AsyncExtensions"]),
        .testTarget(
            name: "CollectionExtensionsTests",
            dependencies: ["CollectionExtensions"]),
        .testTarget(
            name: "CoreExtensionsTests",
            dependencies: ["CoreExtensions"]),
        .testTarget(
            name: "LazyCollectionExtensionsTests",
            dependencies: ["LazyCollectionExtensions"]),
    ]
)

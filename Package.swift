// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreExtensions",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "AsyncCollectionExtensions",
            targets: ["AsyncCollectionExtensions"]
        ),
        .library(
            name: "AsyncExtensions",
            targets: ["AsyncExtensions"]
        ),
        .library(
            name: "CodableExtensions",
            targets: ["CodableExtensions"]
        ),
        .library(
            name: "CollectionExtensions",
            targets: ["CollectionExtensions"]
        ),
        .library(
            name: "CombineExtensions",
            targets: ["CombineExtensions"]
        ),
        .library(
            name: "CompareFunctions",
            targets: ["CompareFunctions"]
        ),
        .library(
            name: "CoreExtensions",
            targets: ["CoreExtensions"]
        ),
        .library(
            name: "DateExtensions",
            targets: ["DateExtensions"]
        ),
        .library(
            name: "FileSystemExtensions",
            targets: ["FileSystemExtensions"]
        ),
        .library(
            name: "LazyCollectionExtensions",
            targets: ["LazyCollectionExtensions"]
        ),
        .library(
            name: "NumericExtensions",
            targets: ["NumericExtensions"]
        ),
        .library(
            name: "OptionalExtensions",
            targets: ["OptionalExtensions"]
        ),
        .library(
            name: "ResultExtensions",
            targets: ["ResultExtensions"]
        ),
        .library(
            name: "URLExtensions",
            targets: ["URLExtensions"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/aetherealtech/swift-assertions", branch: "master"),
        .package(url: "https://github.com/aetherealtech/swift-backports", branch: "master"),
        .package(url: "https://github.com/aetherealtech/swift-stubbing", branch: "master"),
        .package(url: "https://github.com/aetherealtech/swift-synchronization", branch: "master"),
    ],
    targets: [
        .target(
            name: "AsyncCollectionExtensions",
            dependencies: [
                "AsyncExtensions",
                "CollectionExtensions",
                "OptionalExtensions",
                "ResultExtensions",
                .product(name: "Synchronization", package: "swift-synchronization"),
            ]
        ),
        .target(
            name: "AsyncExtensions",
            dependencies: [
                "ResultExtensions",
            ]
        ),
        .target(
            name: "CodableExtensions",
            dependencies: []
        ),
        .target(
            name: "CollectionExtensions",
            dependencies: [
                "CompareFunctions",
            ]
        ),
        .target(
            name: "CombineExtensions",
            dependencies: [
                "AsyncCollectionExtensions",
                "AsyncExtensions",
                "CollectionExtensions",
                "DateExtensions",
                .product(name: "Synchronization", package: "swift-synchronization"),
                "OptionalExtensions"
            ]
        ),
        .target(
            name: "CompareFunctions",
            dependencies: []
        ),
        .target(
            name: "CoreExtensions",
            dependencies: [
                "AsyncCollectionExtensions",
                "AsyncExtensions",
                "CodableExtensions",
                "CollectionExtensions",
                "CombineExtensions",
                "CompareFunctions",
                "DateExtensions",
                "FileSystemExtensions",
                "LazyCollectionExtensions",
                "NumericExtensions",
                "OptionalExtensions",
                "ResultExtensions",
                "URLExtensions",
            ]
        ),
        .target(
            name: "DateExtensions",
            dependencies: [
                "CollectionExtensions",
                .product(name: "Backports", package: "swift-backports"),
            ]
        ),
        .target(
            name: "FileSystemExtensions",
            dependencies: []
        ),
        .target(
            name: "LazyCollectionExtensions",
            dependencies: [
                "CollectionExtensions",
                "OptionalExtensions",
                "ResultExtensions",
            ]
        ),
        .target(
            name: "NumericExtensions",
            dependencies: []
        ),
        .target(
            name: "OptionalExtensions",
            dependencies: []
        ),
        .target(
            name: "ResultExtensions",
            dependencies: []
        ),
        .target(
            name: "URLExtensions",
            dependencies: []
        ),
        .testTarget(
            name: "AsyncCollectionExtensionsTests",
            dependencies: ["AsyncCollectionExtensions"]
        ),
        .testTarget(
            name: "AsyncExtensionsTests",
            dependencies: [
                "AsyncExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ]
        ),
        .testTarget(
            name: "CollectionExtensionsTests",
            dependencies: [
                "CollectionExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
                .product(name: "Stubbing", package: "swift-stubbing"),
            ]
        ),
        .testTarget(
            name: "CombineExtensionsTests",
            dependencies: [
                "CombineExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ]
        ),
        .testTarget(
            name: "CompareFunctionsTests",
            dependencies: [
                "CompareFunctions",
                .product(name: "Assertions", package: "swift-assertions"),
            ]
        ),
        .testTarget(
            name: "DateExtensionsTests",
            dependencies: [
                "CollectionExtensions",
                "DateExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ]
        ),
        .testTarget(
            name: "LazyCollectionExtensionsTests",
            dependencies: [
                "LazyCollectionExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
                .product(name: "Stubbing", package: "swift-stubbing"),
            ]
        ),
        .testTarget(
            name: "NumericExtensionsTests",
            dependencies: [
                "NumericExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ]
        ),
        .testTarget(
            name: "OptionalExtensionsTests",
            dependencies: [
                "OptionalExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ]
        ),
        .testTarget(
            name: "ResultExtensionsTests",
            dependencies: [
                "ResultExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ]
        ),
        .testTarget(
            name: "URLExtensionsTests",
            dependencies: [
                "CollectionExtensions",
                "URLExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ],
            resources: [
                .process("dummy.pdf")
            ]
        ),
    ]
)

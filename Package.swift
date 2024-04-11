// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreExtensions",
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
        .package(url: "https://github.com/aetherealtech/swift-synchronization", branch: "master"),
    ],
    targets: [
        .target(
            name: "AsyncCollectionExtensions",
            dependencies: [
                "AsyncExtensions",
                "CollectionExtensions",
                "ResultExtensions",
                .product(name: "Synchronization", package: "swift-synchronization"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "AsyncExtensions",
            dependencies: [
                "ResultExtensions",
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "CodableExtensions",
            dependencies: [],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "CollectionExtensions",
            dependencies: [
                "CompareFunctions",
                "OptionalExtensions"
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
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
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "CompareFunctions",
            dependencies: [],
            swiftSettings: [.concurrencyChecking(.complete)]
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
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "DateExtensions",
            dependencies: [
                "CollectionExtensions",
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "FileSystemExtensions",
            dependencies: [],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "LazyCollectionExtensions",
            dependencies: [
                "CollectionExtensions",
                "ResultExtensions",
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "NumericExtensions",
            dependencies: [],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "OptionalExtensions",
            dependencies: [],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "ResultExtensions",
            dependencies: [],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "URLExtensions",
            dependencies: [],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "AsyncCollectionExtensionsTests",
            dependencies: ["AsyncCollectionExtensions"],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "AsyncExtensionsTests",
            dependencies: [
                "AsyncExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "CollectionExtensionsTests",
            dependencies: [
                "CollectionExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "DateExtensionsTests",
            dependencies: [
                "CollectionExtensions",
                "DateExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
//        .testTarget(
//            name: "LazyCollectionExtensionsTests",
//            dependencies: ["LazyCollectionExtensions"],
//            swiftSettings: [.concurrencyChecking(.complete)]
//        ),
        .testTarget(
            name: "OptionalExtensionsTests",
            dependencies: [
                "OptionalExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "ResultExtensionsTests",
            dependencies: [
                "ResultExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "URLExtensionsTests",
            dependencies: [
                "URLExtensions",
                .product(name: "Assertions", package: "swift-assertions"),
            ],
            resources: [
                .process("dummy.pdf")
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
    ]
)

extension SwiftSetting {
    enum ConcurrencyChecking: String {
        case complete
        case minimal
        case targeted
    }
    
    static func concurrencyChecking(_ setting: ConcurrencyChecking = .minimal) -> Self {
        unsafeFlags([
            "-Xfrontend", "-strict-concurrency=\(setting)",
            "-Xfrontend", "-warn-concurrency",
            "-Xfrontend", "-enable-actor-data-race-checks",
        ])
    }
}

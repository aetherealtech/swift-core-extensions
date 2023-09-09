// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreExtensions",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
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
                "CoreExtensions",
                .product(name: "Synchronization", package: "Synchronization"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "AsyncExtensions",
            dependencies: [],
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
                .product(name: "Synchronization", package: "Synchronization"),
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
                "OptionalExtensions"
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
                "CollectionExtensions"
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
        .testTarget(
            name: "AsyncCollectionExtensionsTests",
            dependencies: ["AsyncCollectionExtensions"],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "AsyncExtensionsTests",
            dependencies: ["AsyncExtensions"],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "CollectionExtensionsTests",
            dependencies: ["CollectionExtensions"],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "CoreExtensionsTests",
            dependencies: ["CoreExtensions"],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "LazyCollectionExtensionsTests",
            dependencies: ["LazyCollectionExtensions"],
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

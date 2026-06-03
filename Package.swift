// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "GroceryAppServer",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        //
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0"),
        //
        .package(url: "https://github.com/Autthawigorn/GroceryAppSharedDTO.git", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "GroceryAppServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                //
                .product(name: "Fluent", package: "fluent"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                //
                .product(name: "GroceryAppSharedDTO", package: "GroceryAppSharedDTO")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "GroceryAppServerTests",
            dependencies: [
                .target(name: "GroceryAppServer"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }

// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CafecitosAPI",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // Vapor Framework
        .package(url: "https://github.com/vapor/vapor.git", from: "4.92.0"),
        // Fluent ORM
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // Driver de PostgreSQL
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.9.0")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver")
            ],
            path: "Sources/App"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor")
            ],
            path: "Tests/AppTests"
        )
    ]
)

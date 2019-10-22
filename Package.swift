// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "CoTBMSrv",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMinor(from: "3.3.0")),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/vapor/fluent-mysql.git", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/weichsel/ZIPFoundation/", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentSQLite", "FluentMySQL", "ZIPFoundation"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ])


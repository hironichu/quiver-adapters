// swift-tools-version: 6.2

import Foundation
import PackageDescription

let useLocalDeps = Context.environment["SWIFTCI_USE_LOCAL_DEPS"] != nil
let packageDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let localQuiverPackagesRoot = Context.environment["QUIVER_PACKAGES_PATH"] ?? ".."

func quiverPackage(_ repository: String) -> Package.Dependency {
    let localURL = URL(fileURLWithPath: localQuiverPackagesRoot, relativeTo: packageDirectory)
        .appendingPathComponent(repository)
        .standardizedFileURL
    let manifestURL = localURL.appendingPathComponent("Package.swift")

    if FileManager.default.fileExists(atPath: manifestURL.path) {
        return .package(path: localURL.path)
    }

    return .package(url: "https://github.com/hironichu/\(repository).git", branch: "main")
}

func nioDependencies() -> [Package.Dependency] {
    if useLocalDeps {
        return [
            .package(path: "../../swift-nio"),
        ]
    } else {
        return [
            .package(url: "https://github.com/apple/swift-nio.git", branch: "pr-3433"),
        ]
    }
}

let package = Package(
    name: "quiver-adapters",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .library(name: "QuiverVapor", targets: ["QuiverVapor"]),
        .library(name: "QuiverHummingbird", targets: ["QuiverHummingbird"]),
    ],
    dependencies: nioDependencies() + [
        quiverPackage("quiver-http3"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.121.4"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.12.0"),
    ],
    targets: [
        .target(
            name: "QuiverVapor",
            dependencies: [
                .product(name: "HTTP3", package: "quiver-http3"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/QuiverVapor"
        ),
        .target(
            name: "QuiverHummingbird",
            dependencies: [
                .product(name: "HTTP3", package: "quiver-http3"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOEmbedded", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/QuiverHummingbird"
        ),
        .testTarget(
            name: "QuiverVaporTests",
            dependencies: [
                "QuiverVapor",
                .product(name: "HTTP3", package: "quiver-http3"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
            ],
            path: "Tests/QuiverVaporTests"
        ),
        .testTarget(
            name: "QuiverHummingbirdTests",
            dependencies: [
                "QuiverHummingbird",
                .product(name: "HTTP3", package: "quiver-http3"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "NIOCore", package: "swift-nio"),
            ],
            path: "Tests/QuiverHummingbirdTests"
        ),
    ]
)

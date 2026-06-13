// swift-tools-version: 6.2

import Foundation
import PackageDescription

let useLocalDeps = Context.environment["SWIFTCI_USE_LOCAL_DEPS"] != nil
let packageDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let localQuiverPackagesRoot = Context.environment["QUIVER_PACKAGES_PATH"]

func quiverPackage(_ repository: String) -> Package.Dependency {
    if let localQuiverPackagesRoot {
        let localURL = URL(fileURLWithPath: localQuiverPackagesRoot, relativeTo: packageDirectory)
            .appendingPathComponent(repository)
            .standardizedFileURL
        let manifestURL = localURL.appendingPathComponent("Package.swift")

        if FileManager.default.fileExists(atPath: manifestURL.path) {
            return .package(path: localURL.path)
        }
    }

    return .package(url: "https://github.com/hironichu/\(repository).git", branch: "experimental/runtime")
}

func nioDependencies() -> [Package.Dependency] {
    if useLocalDeps {
        return [
            .package(url: "https://github.com/apple/swift-nio.git", from: "2.101.0"),
            // .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.37.1"),
        ]
    } else {
        return [
            .package(url: "https://github.com/apple/swift-nio.git", from: "2.101.0"),
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
    traits: [
        .trait(name: "vapor", description: "Provides integration with the Vapor web framework."),
        .trait(name: "hummingbird", description: "Provides integration with the Hummingbird web framework."),
    ],
    dependencies: nioDependencies() + [
        quiverPackage("quiver-http3"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.121.4", ),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.12.0"),
    ],

    targets: [
        .target(
            name: "QuiverVapor",
            dependencies: [
                .product(name: "HTTP3", package: "quiver-http3", condition: .when(traits: ["vapor"])),
                .product(name: "Vapor", package: "vapor", condition: .when(traits: ["vapor"])),
                .product(name: "NIOCore", package: "swift-nio", condition: .when(traits: ["vapor"])),
                .product(name: "NIOHTTP1", package: "swift-nio", condition: .when(traits: ["vapor"])),
                .product(name: "Logging", package: "swift-log", condition: .when(traits: ["vapor"])),
            ],
            path: "Sources/QuiverVapor",
            swiftSettings: [
                .define("VAPOR", .when(traits: ["vapor"])),
            ]
        ),
        .target(
            name: "QuiverHummingbird",
            dependencies: [
                .product(name: "HTTP3", package: "quiver-http3", condition: .when(traits: ["hummingbird"])),
                .product(name: "Hummingbird", package: "hummingbird", condition: .when(traits: ["hummingbird"])),
                .product(name: "HTTPTypes", package: "swift-http-types", condition: .when(traits: ["hummingbird"])),
                .product(name: "NIOCore", package: "swift-nio", condition: .when(traits: ["hummingbird"])),
                .product(name: "NIOEmbedded", package: "swift-nio", condition: .when(traits: ["hummingbird"])),
                .product(name: "Logging", package: "swift-log", condition: .when(traits: ["hummingbird"])),
            ],
            path: "Sources/QuiverHummingbird",
            swiftSettings: [
                .define("HUMMINGBIRD", .when(traits: ["hummingbird"])),
            ]
        ),
        .testTarget(
            name: "QuiverVaporTests",
            dependencies: [
                "QuiverVapor",
                .product(name: "HTTP3", package: "quiver-http3", condition: .when(traits: ["vapor"])),
                .product(name: "Vapor", package: "vapor", condition: .when(traits: ["vapor"])),
                .product(name: "NIOCore", package: "swift-nio", condition: .when(traits: ["vapor"])),
            ],
            path: "Tests/QuiverVaporTests",
            swiftSettings: [
                .define("VAPOR_TESTS", .when(traits: ["vapor"])),
            ]
        ),
        .testTarget(
            name: "QuiverHummingbirdTests",
            dependencies: [
                "QuiverHummingbird",
                .product(name: "HTTP3", package: "quiver-http3", condition: .when(traits: ["hummingbird"])),
                .product(name: "Hummingbird", package: "hummingbird", condition: .when(traits: ["hummingbird"])),
                .product(name: "HTTPTypes", package: "swift-http-types", condition: .when(traits: ["hummingbird"])),
                .product(name: "NIOCore", package: "swift-nio", condition: .when(traits: ["hummingbird"])),
            ],
            path: "Tests/QuiverHummingbirdTests",
            swiftSettings: [
                .define("HUMMINGBIRD_TESTS", .when(traits: ["hummingbird"])),
            ]
        ),
    ]
)

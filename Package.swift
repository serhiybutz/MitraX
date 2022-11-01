// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "MitraX",
    platforms: [
        .iOS(.v12), .macOS(.v10_14),
    ],
    products: [
        .library(
            name: "MitraX",
            targets: ["MitraX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SerhiyButz/XConcurrencyKit.git", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "MitraX",
            dependencies: []),
        .testTarget(
            name: "MitraXTests",
            dependencies: ["MitraX", "XConcurrencyKit"]),
    ]
)

// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "classifier",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "classifier",
            targets: ["classifierABC"]
        )
    ],
    targets: [
        .target(
            name: "classifierABC",
            path: "Sources/classifier",
            sources: ["ClassifierWrapper.cpp"],
            cxxSettings: [
                .headerSearchPath("include"),
            ]
        )
    ]
)

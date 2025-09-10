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
            targets: ["classifier"]
        )
    ],
    targets: [
        .target(
            name: "classifier",
            path: "Sources/classifier",
            sources: ["Classifier.cpp"],
            cxxSettings: [
                .headerSearchPath("include"),
            ]
        )
    ]
)

// swift-tools-version: 5.9
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
        .binaryTarget(
            name: "onnxruntime",
            path: "../onnxruntime.xcframework"
        ),
        .target(
            name: "classifierABC",
            dependencies: [
                .target(name: "onnxruntime")
            ],
            path: "Sources/classifier",
            sources: ["ClassifierWrapper.cpp"],
            cxxSettings: [
                .headerSearchPath("include"),
            //    .unsafeFlags(["-arch", "arm64"], .when(platforms: [.macOS]))
            ]
        )
    ]
)

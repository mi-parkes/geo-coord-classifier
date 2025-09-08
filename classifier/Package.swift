import Foundation
// swift-tools-version: 6.1
import PackageDescription

let baseOnnxruntimePath = "../onnxruntime-release"

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
                .unsafeFlags(
                    ["-I\(baseOnnxruntimePath)/macosx/include"],
                    .when(platforms: [.macOS])
                ),
                .unsafeFlags(
                    ["-I\(baseOnnxruntimePath)/iphoneos/include"],
                    .when(platforms: [.iOS])
                ),
            ]
        )
    ]
)

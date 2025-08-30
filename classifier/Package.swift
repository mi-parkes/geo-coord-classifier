// swift-tools-version: 6.1
import PackageDescription
import Foundation

let onnxruntimePath = ProcessInfo.processInfo.environment["ONNXRUNTIME_HOME"]!
let includePath = onnxruntimePath + "/include"
let libPath = onnxruntimePath + "/lib"

let package = Package(
    name: "classifier",
    products: [
        .library(
            name: "classifier",
            targets: ["classifier"]
        ),
    ],
    targets: [
        .target(
            name: "classifier",
            path: "Sources/classifier",
            sources: ["Classifier.cpp"],
            cxxSettings: [
                .headerSearchPath("include"),
                .unsafeFlags(["-I\(includePath)"])
            ],
            linkerSettings: [
                .unsafeFlags(["-L\(libPath)", "-lonnxruntime", "-rpath", "\(libPath)"])
            ]
        )
    ]
)

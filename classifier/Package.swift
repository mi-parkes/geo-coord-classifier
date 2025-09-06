// swift-tools-version: 6.1
import PackageDescription
import Foundation


// Check for the ONNXRUNTIME_HOME environment variable first.
guard let baseOnnxruntimePath = ProcessInfo.processInfo.environment["ONNXRUNTIME_HOME"] else {
    fatalError("ONNXRUNTIME_HOME environment variable is not set.")
}

let onnxruntimePath: String

#if os(macOS)
onnxruntimePath = "\(baseOnnxruntimePath)/osx"
#elseif os(iOS)
onnxruntimePath = "\(baseOnnxruntimePath)/ios"
#elseif targetEnvironment(simulator)
onnxruntimePath = "\(baseOnnxruntimePath)/simulator"
#else
fatalError("Unsupported platform.")
#endif

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

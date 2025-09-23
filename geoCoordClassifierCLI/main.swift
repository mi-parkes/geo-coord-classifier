//
// main.swift
// geoCoordClassifierCLI
//
import Foundation
import geoCoordClassifierCore

let args = CommandLine.arguments
let verbose = args.contains("--verbose")

func printer(msg: String) {
    print(msg)
}

let fileGeoDataLoader = FileGeoDataLoader()

// --- ONNX Classifier (C++ Wrapper) ---
var onnxClassifier: ClassifierProtocol = CppClassifierWrapper()
let onnxModelURL = MainBundleHelper.getFileUrl(filename: "GeoClassifier", ext: "onnx")
let testDataURL = MainBundleHelper.getFileUrl(filename: "GeoClassifierEvaluationData", ext: "json")

if let testURL = testDataURL, let modelURL = onnxModelURL {
    let tc: TestClassifier = TestClassifier(
        geoClassifier: onnxClassifier,
        geoDataLoader: fileGeoDataLoader,
        printer: printer,
        modelURL: modelURL,
        testURL: testURL,
        verbose: verbose
    )
    if !tc.runTest() {
        printer(msg: "Check your C++ wrapper setup.")
    }
} else {
    printer(msg: "ONNX classifier test skipped: One or more files not found.")
}

// --- Core ML Classifier (Swift) ---
var swiftClassifier: ClassifierProtocol = SwiftClassifier()
let coreMLModelURL = GeoCoordClassifierBundleHelper.getFileUrl(filename: "GeoClassifier", ext: "mlmodelc")

if let testURL = testDataURL, let modelURL = coreMLModelURL {
    let tc: TestClassifier = TestClassifier(
        geoClassifier: swiftClassifier,
        geoDataLoader: fileGeoDataLoader,
        printer: printer,
        modelURL: modelURL,
        testURL: testURL,
        verbose: verbose
    )
    if !tc.runTest() {
        printer(msg: "Check your Swift classifier setup.")
    }
} else {
    printer(msg: "Core ML classifier test skipped: One or more files not found.")
}

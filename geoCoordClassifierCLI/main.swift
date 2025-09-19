//
//  main.swift
//  geoCoordClassifierCLI
//
import Foundation
import geoCoordClassifierCore
//import classifier

let args = CommandLine.arguments
let verbose = args.contains("--verbose")

import Foundation

func printer(msg: String) {
    print(msg)
}

var classifier: ClassifierProtocol

let testURL = getFileUrl(filename: "GeoClassifierEvaluationData", ext: "json")
var modelURL = getFileUrl(filename: "GeoClassifier", ext: "onnx")

classifier = CppClassifierWrapper()

if let testURL = testURL, let modelURL = modelURL {
    let tc: TestClassifier = TestClassifier(
        geoClassifier:classifier,
        printer: printer,
        modelURL: modelURL,
        testURL:testURL,
        verbose: verbose
    )
    if !tc.runTest() {
        printer(msg: "Check your setup")
    }
}

classifier = SwiftClassifier()
modelURL = getCoreFileUrl(filename: "GeoClassifier",ext:"mlmodelc")

if let testURL = testURL, let modelURL = modelURL  {
    let tc: TestClassifier = TestClassifier(
        geoClassifier:classifier,
        printer: printer,
        modelURL: modelURL,
        testURL:testURL,
        verbose: verbose
    )
    if !tc.runTest() {
        printer(msg: "Check your setup")
    }
}


import Foundation

let args = CommandLine.arguments
let verbose = args.contains("--verbose")

import Foundation

func printer(msg: String) {
    print(msg)
}

var classifier: ClassifierProtocol

classifier = CppClassifierWrapper()

let testURL = getFileUrl(filename: "GeoClassifierEvaluationData", ext: "json")
var modelURL = getFileUrl(filename: "GeoClassifier", ext: "onnx")
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
modelURL = getFileUrl(filename: "GeoClassifier",ext:"mlmodelc")

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

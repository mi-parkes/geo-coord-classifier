import Foundation

let args = CommandLine.arguments
let verbose = args.contains("--verbose")

func printer(msg: String) {
    print(msg)
}

let testURL = getFilePath(filename: "test", ext: "json")

if let testURL = testURL {
    let tc: TestClassifier = TestClassifier(
        printer: printer,
        modelPath: "model.onnx",
        testURL:testURL
    )
    if !tc.runTest() {
        printer(msg: "Check your setup")
    }
}

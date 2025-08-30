import Foundation
import SwiftUI

let WelcomeText: String =
    "This App tests Swift/C++ integration and deployment of tiny onnx model created with pytorch:"

struct ContentView: View {
    @State var gmsg: String = WelcomeText

    @State var verbose: Bool = false

    func mprinter(msg: String) {
        gmsg += "\n" + msg
    }

    func runTest() {
        let modelURL = getFilePath(filename: "model", ext: "onnx")
        let testURL = getFilePath(filename: "test", ext: "json")

        if let modelURL = modelURL, let testURL = testURL {
            let tc: TestClassifier = TestClassifier(
                printer: mprinter,
                modelPath: modelURL.path,
                testURL: testURL,
                verbose: verbose
            )

            tc.reset()

            if !tc.runTest() {
                mprinter(msg: "Check your setup")
            }
        } else {
            mprinter(msg: "Failure")
        }
    }

    var body: some View {

        Image(systemName: "globe")
            .imageScale(.large)
            .foregroundStyle(.tint)
            .padding()
        HStack {
            Button("Run test") {
                runTest()
            }
            .frame(maxWidth: .infinity)

            Button(action: {
                self.verbose.toggle()
                gmsg = WelcomeText

            }) {
                Text(self.verbose ? "Verbose OFF" : "Verbose ON")
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            Button("clear") {
                gmsg = WelcomeText
            }
            .frame(maxWidth: .infinity)
        }
        ScrollView {
            VStack {
                Text(gmsg)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

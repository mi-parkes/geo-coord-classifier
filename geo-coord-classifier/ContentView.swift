import SwiftUI
import classifier
import Foundation

let WelcomeText: String = "This App tests Swift/C++ integration and deployment of tiny onnx model created with pytorch:"

struct ContentView: View {
    @State var gmsg: String = WelcomeText
    @State var verbose: Bool = false
    @State private var showBackground = true
    
    var body: some View {
        #if os(macOS)
        // macOS Layout
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Top row of buttons
                HStack {
                    Button("Run test") {
                        runTest()
                    }
                    .frame(maxWidth: .infinity)

                    Button(action: {
                        verbose.toggle()
                        showBackground.toggle()
                        gmsg = WelcomeText
                    }) {
                        Text(verbose ? "Verbose OFF" : "Verbose ON")
                    }
                    .frame(maxWidth: .infinity)

                    Button("Clear") {
                        gmsg = WelcomeText
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)

                // Middle section: background image
                if showBackground {
                    Image("classify-city-gc")
                        .resizable()
                        .scaledToFit()  // ✅ show entire image
                        .frame(maxWidth: geo.size.width)
                        .padding(.vertical)
                }

                // Bottom section: scrollable text
                ScrollView {
                    VStack {
                        Text(gmsg)
                            .padding()
                    }
                }
                .frame(
                    maxHeight: showBackground
                        ? geo.size.height * 0.1 : .infinity
                )
            }
        }
        #else
        // iOS Layout (including Simulator)
        VStack(spacing: 0) {
            // Top row of buttons
            HStack {
                Button("Run test") {
                    runTest()
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    verbose.toggle()
                    showBackground.toggle()
                    gmsg = WelcomeText
                }) {
                    Text(verbose ? "Verbose OFF" : "Verbose ON")
                }
                .frame(maxWidth: .infinity)
                
                Button("Clear") {
                    gmsg = WelcomeText
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
            
            // Middle section: background image
            if showBackground {
                Image("classify-city-gc")
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical)
            }
            
            // Bottom section: scrollable text
            ScrollView {
                Text(gmsg)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        #endif
    }
    
    // MARK: - Helper Functions
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
}

#Preview {
    ContentView()
}

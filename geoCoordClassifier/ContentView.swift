//
//  ContentView.swift
//  geoCoordClassifier
//
import SwiftUI
import Foundation
import geoCoordClassifierCore

let WelcomeText: String = "This App tests Swift/C++ integration and deployment of tiny onnx model created with pytorch:"

struct ContentView: View {
    @State var gmsg: String = WelcomeText
    @State var verbose: Bool
    @State private var showBackground: Bool
    
    init(verbose: Bool = false) {
        _verbose = State(initialValue: verbose)
        _showBackground = State(initialValue: !verbose)
    }
    
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
    
    func mprinter(msg: String) {
        gmsg += "\n" + msg
    }

    func runTest() {
        var classifier: ClassifierProtocol
        let fileGeoDataLoader = FileGeoDataLoader()
        let testURL = MainBundleHelper.getFileUrl(filename: "GeoClassifierEvaluationData", ext: "json")
        var modelURL = MainBundleHelper.getFileUrl(filename: "GeoClassifier", ext: "onnx")

        classifier = CppClassifierWrapper()

        if let testURL = testURL, let modelURL = modelURL {
            let tc: TestClassifier = TestClassifier(
                geoClassifier:classifier,
                geoDataLoader: fileGeoDataLoader,
                printer: mprinter,
                modelURL: modelURL,
                testURL:testURL,
                verbose:verbose
            )
            tc.reset()
            if !tc.runTest() {
                mprinter(msg: "Check your setup")
            }
        }

        classifier = SwiftClassifier()
        modelURL = GeoCoordClassifierBundleHelper.getFileUrl(filename: "GeoClassifier",ext:"mlmodelc")
        if let testURL = testURL, let modelURL = modelURL  {
            let tc: TestClassifier = TestClassifier(
                geoClassifier:classifier,
                geoDataLoader: fileGeoDataLoader,
                printer: mprinter,
                modelURL: modelURL,
                testURL:testURL,
                verbose:verbose
            )
            tc.reset()
            if !tc.runTest() {
                mprinter(msg: "Check your setup")
            }
        }
    }
}

#Preview {
    ContentView()
}

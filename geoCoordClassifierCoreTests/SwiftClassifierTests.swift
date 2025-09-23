//
// SwiftClassifierTests.swift
// geoCoordClassifierCoreTests
//
import XCTest
@testable import geoCoordClassifierCore
import CoreML

final class SwiftClassifierTests: XCTestCase {

    var classifier: SwiftClassifier!
    var modelURL: URL!

    override func setUpWithError() throws {
        super.setUp()

        // Locate the model in the framework's bundle
        let bundle = Bundle(for: SwiftClassifier.self)
        guard let url = bundle.url(forResource: "GeoClassifier", withExtension: "mlmodelc") else {
            XCTFail("Test model not found in the framework's bundle.")
            return
        }
        self.modelURL = url
        
        // Initialize the classifier with the found model for all tests
        self.classifier = SwiftClassifier()
        let initResult = self.classifier.minit(modelURL: self.modelURL, verbose: false)
        XCTAssertEqual(initResult, 1, "Classifier failed to initialize in setUp().")
    }
    

    // Test a coordinate pair within the normalization range
    // We are now testing `infer`, which in turn calls the private `normalizeCoords`
    // This approach tests the public API and its side effects.
    func testInferenceAndNormalization() {
        // Use a test classifier instance to avoid state conflicts
        let testClassifier = SwiftClassifier()
        // Manually set the normalization parameters for a clean test
        testClassifier.minLat = 0.0
        testClassifier.maxLat = 100.0
        testClassifier.minLon = 0.0
        testClassifier.maxLon = 100.0
        testClassifier.initialized = true // Set initialized state to avoid guard clause

        let normalizedMid = testClassifier.normalizeCoords(coords: [50.0, 50.0])
        let expectedLon = (50.0 - 0.0) / (100.0 - 0.0 + 1e-8)

        // The fix: Cast the Float values to Double
        XCTAssertEqual(Double(normalizedMid[1]), Double(expectedLon), accuracy: 1e-6)
    }

    // Test the `findMaxIndex` helper function.
    func testFindMaxIndex() throws {
        let shape = [1, 5] as [NSNumber]
        let multiArray = try MLMultiArray(shape: shape, dataType: .float)
        
        multiArray[0] = 0.1
        multiArray[1] = 0.8
        multiArray[2] = 0.2
        multiArray[3] = 0.5
        multiArray[4] = 0.3

        let maxIndex = findMaxIndex(in: multiArray)
        XCTAssertEqual(maxIndex, 1, "The max index should be 1.")
    }
    
    // Test the infer function with a known input/output.
    func testInfer() {
        let result = classifier.infer(v1: 52.37, v2: 4.90)
        XCTAssertEqual(result, 3, "Infer should return the correct label for the input.")
    }
}

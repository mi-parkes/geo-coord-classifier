//
// TestClassifierTests.swift
// geoCoordClassifierCoreTests
//
import XCTest
@testable import geoCoordClassifierCore

// A mock classifier that always returns the same label.
class MockClassifier: ClassifierProtocol {
    var expectedLabel: Int = 0

    func minit(modelURL: URL, verbose: Bool) -> Int { return 1 }
    func infer(v1: Float, v2: Float) -> Int { return expectedLabel }
    func dispose() {}
    func getLastError() -> String { return "" }
    func getName() -> String { return "Mock" }
}

// A mock GeoDataLoader that returns predictable data for testing.
class MockGeoDataLoader: GeoDataLoader {
    var mockData: GeoData?

    func loadGeoData(from url: URL) -> GeoData? {
        return mockData
    }
}

// A mock CityNameFinder for predictable lookups.
class MockCityNameFinder: CityNameFinder {
    var cityMap: [Int: String] = [:]

    func findCityName(forLabel label: Int, in geoData: GeoData) -> String? {
        return cityMap[label]
    }
}

final class TestClassifierTests: XCTestCase {
    var testClassifier: TestClassifier!
    var mockClassifier: MockClassifier!
    var mockDataLoader: MockGeoDataLoader!
    var mockCityNameFinder: MockCityNameFinder!
    var mockPrinterOutput: [String] = []

    override func setUp() {
        super.setUp()

        mockClassifier = MockClassifier()
        mockDataLoader = MockGeoDataLoader()
        mockCityNameFinder = MockCityNameFinder()

        let mockPrinter: TestClassifier.Printer = { msg in
            self.mockPrinterOutput.append(msg)
        }

        let mockTestURL = URL(fileURLWithPath: "/path/to/test/data.json")
        let mockModelURL = URL(fileURLWithPath: "/path/to/model.onnx")

        testClassifier = TestClassifier(
            geoClassifier: mockClassifier,
            geoDataLoader: mockDataLoader,
            printer: mockPrinter,
            modelURL: mockModelURL,
            testURL: mockTestURL,
            verbose: true
        )
    }

    override func tearDown() {
        mockPrinterOutput.removeAll()
        testClassifier = nil
        mockClassifier = nil
        mockDataLoader = nil
        mockCityNameFinder = nil
        super.tearDown()
    }

    // Test processing a set of coordinates where all inferences are correct.
    func testProcessCoordinatesAllCorrect() {
        mockClassifier.expectedLabel = 1 // Match the label of "Berlin"

        // This geoData must also be provided to the mockCityNameFinder for the lookup
        let geoData: GeoData = [
            "Berlin": CityData(label: 1, coords: [[52.52, 13.40], [52.53, 13.41]])
        ]

        // Setup the mock city name finder to correctly look up the label
        mockCityNameFinder.cityMap = [1: "Berlin"]

        testClassifier.processCoordinates(for: "Berlin", in: geoData)

        XCTAssertEqual(testClassifier.correct, 2)
        XCTAssertEqual(testClassifier.total, 2)
        XCTAssertTrue(mockPrinterOutput.contains(where: { $0.contains("OK") }))
    }

    // Test processing coordinates with a single incorrect inference.
    func testProcessCoordinatesWithOneIncorrect() {
        // Set the mock classifier to return a label that will result in an incorrect match.
        mockClassifier.expectedLabel = 2 // Label for "Paris", which is incorrect for "Berlin"

        let geoData: GeoData = [
            "Berlin": CityData(label: 1, coords: [[52.52, 13.40]]),
            "Paris": CityData(label: 2, coords: [[48.85, 2.35]]) // This is necessary for the lookup
        ]

        // Set up the mock city name finder to correctly look up the labels
        mockCityNameFinder.cityMap = [1: "Berlin", 2: "Paris"]

        // Call the method with a city name.
        testClassifier.processCoordinates(for: "Berlin", in: geoData)

        XCTAssertEqual(testClassifier.correct, 0)
        XCTAssertEqual(testClassifier.total, 1)
        XCTAssertTrue(mockPrinterOutput.contains(where: { $0.contains("!!") }))
    }
    // Test the accuracy calculation logic, now correctly implemented with mocks.
    func testRunTestAccuracyCalculation() {
        mockClassifier.expectedLabel = 1 // Our mock classifier always returns label 1.

        // We define the mock data the data loader will return.
        let mockGeoData: GeoData = [
            "Berlin": CityData(label: 1, coords: [[52.52, 13.40], [52.53, 13.41]]), // These two will be correct
            "Paris": CityData(label: 2, coords: [[48.85, 2.35]]) // This will be incorrect, since the mock returns 1.
        ]

        // Set the mock data for the mock data loader.
        mockDataLoader.mockData = mockGeoData

        // Set the city map for the mock city name finder.
        mockCityNameFinder.cityMap = [1: "Berlin", 2: "Paris"]

        // Run the main test function.
        let result = testClassifier.runTest()

        // Assert that the test ran successfully.
        XCTAssertTrue(result, "runTest() should return true for success.")

        // Assert the counts. We have 2 correct predictions and 1 incorrect. Total is 3.
        XCTAssertEqual(testClassifier.correct, 2)
        XCTAssertEqual(testClassifier.total, 3)

        // Assert the final accuracy string printed to the mock output.
        XCTAssertTrue(mockPrinterOutput.contains(where: { $0.contains("Accuracy (Mock): 66.67%") }))
    }
}

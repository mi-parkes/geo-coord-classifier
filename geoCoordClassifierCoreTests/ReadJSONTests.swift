//
// ReadJSONTests.swift
// geoCoordClassifierCoreTests
//
import XCTest
@testable import geoCoordClassifierCore

final class ReadJSONTests: XCTestCase {
    
    // Test loading valid JSON data from a mock file.
    func testLoadGeoData() {
        // Create a temporary JSON file for testing
        let jsonContent = """
        {
          "New York": { "label": 0, "coords": [[40.71, -74.00]] },
          "London": { "label": 1, "coords": [[51.50, -0.12]] }
        }
        """
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test.json")
        try? jsonContent.write(to: tempURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempURL) } // Clean up

        // Use the new class instance
        let dataLoader = FileGeoDataLoader()
        let geoData = dataLoader.loadGeoData(from: tempURL)
        
        XCTAssertNotNil(geoData)
        XCTAssertEqual(geoData?.count, 2)
        XCTAssertEqual(geoData?["New York"]?.label, 0)
    }

    // Test loading malformed JSON data to ensure the function handles errors gracefully.
    func testLoadGeoDataMalformed() {
        let malformedContent = "{ \"New York\": { \"label\": 0, \"coords\": \"invalid\" }"
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("malformed.json")
        try? malformedContent.write(to: tempURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        // Use the new class instance
        let dataLoader = FileGeoDataLoader()
        let geoData = dataLoader.loadGeoData(from: tempURL)

        XCTAssertNil(geoData, "Malformed JSON should return nil.")
    }

    // Test the `findCityName` function with a valid label.
    func testFindCityName() {
        let geoData: GeoData = [
            "Paris": CityData(label: 2, coords: []),
            "Tokyo": CityData(label: 3, coords: [])
        ]

        // Use the new class instance
        let cityNameFinder = DefaultCityNameFinder()
        let cityName = cityNameFinder.findCityName(forLabel: 3, in: geoData)

        XCTAssertEqual(cityName, "Tokyo", "Should find the correct city name.")
    }

    // Test `findCityName` with a label that does not exist.
    func testFindCityNameNotFound() {
        let geoData: GeoData = [ "Paris": CityData(label: 2, coords: []) ]

        // Use the new class instance
        let cityNameFinder = DefaultCityNameFinder()
        let cityName = cityNameFinder.findCityName(forLabel: 99, in: geoData)

        XCTAssertNil(cityName, "Should return nil if the label is not found.")
    }
}

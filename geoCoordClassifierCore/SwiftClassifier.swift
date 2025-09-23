//
// SwiftClassifier.swift
// geoCoordClassifierCore
//
import Foundation
import CoreML

/// A helper function to find the index of the max value in an MLMultiArray.
internal func findMaxIndex(in array: MLMultiArray) -> Int {
    guard array.count > 0 else { return -1 }

    var maxVal: Float = -Float.greatestFiniteMagnitude
    var maxIndex: Int = -1

    let ptr = UnsafeMutablePointer<Float>(OpaquePointer(array.dataPointer))

    for i in 0..<array.count {
        let value = ptr[i]
        if value > maxVal {
            maxVal = value
            maxIndex = i
        }
    }
    return maxIndex
}

public class SwiftClassifier: ClassifierProtocol {

    // Core ML model instance
    private var geoClassifierModel: GeoClassifier

    // Normalization params
    internal var minLat: Float = 0
    internal var maxLat: Float = 0
    internal var minLon: Float = 0
    internal var maxLon: Float = 0
    internal let epsilon: Float = 1e-8

    // Error state
    private var lastError: String = ""

    // Initialization state
    internal var initialized: Bool = false

    // Default initializer
    public init() {
        self.geoClassifierModel = try! GeoClassifier()
    }

    /// Initializes the classifier and loads normalization metadata.
    public func minit(modelURL: URL, verbose: Bool) -> Int {
        do {
            self.geoClassifierModel = try GeoClassifier(contentsOf: modelURL)

            guard let metadata =
                self.geoClassifierModel.model.modelDescription.metadata[.creatorDefinedKey]
                    as? [String: String]
            else {
                self.lastError = "Model metadata missing."
                self.initialized = false
                return 0
            }

            // Parse min values
            guard let minValsString = metadata["min_vals"] else {
                self.lastError = "Model metadata missing min_vals."
                self.initialized = false
                return 0
            }
            let minVals = minValsString.split(separator: ",").compactMap { Float($0) }
            guard minVals.count == 2 else {
                self.lastError = "Invalid min_vals metadata format."
                self.initialized = false
                return 0
            }
            self.minLat = minVals[0]
            self.minLon = minVals[1]

            // Parse max values
            guard let maxValsString = metadata["max_vals"] else {
                self.lastError = "Model metadata missing max_vals."
                self.initialized = false
                return 0
            }
            let maxVals = maxValsString.split(separator: ",").compactMap { Float($0) }
            guard maxVals.count == 2 else {
                self.lastError = "Invalid max_vals metadata format."
                self.initialized = false
                return 0
            }
            self.maxLat = maxVals[0]
            self.maxLon = maxVals[1]

            if verbose {
                print("Loaded normalization: lat [\(minLat), \(maxLat)], lon [\(minLon), \(maxLon)]")
            }

            self.initialized = true
            return 1
        } catch {
            self.lastError = "Failed to load Core ML model: \(error.localizedDescription)"
            self.initialized = false
            return 0
        }
    }

    /// Normalizes a coordinate pair using loaded metadata values.
    internal func normalizeCoords(coords: [Float]) -> [Float] {
        let normalizedLat = (coords[0] - self.minLat) / (self.maxLat - self.minLat + epsilon)
        let normalizedLon = (coords[1] - self.minLon) / (self.maxLon - self.minLon + epsilon)
        return [normalizedLat, normalizedLon]
    }

    /// Performs inference on a coordinate pair.
    public func infer(v1: Float, v2: Float) -> Int {
        guard initialized else {
            self.lastError = "Classifier not initialized."
            return -1
        }

        // Create input array
        let input = try! MLMultiArray(shape: [1, 2] as [NSNumber], dataType: .float)
        let normalizedCoords = normalizeCoords(coords: [v1, v2])

        input[0] = NSNumber(value: normalizedCoords[0])
        input[1] = NSNumber(value: normalizedCoords[1])

        // Run prediction
        guard
            let prediction = try? self.geoClassifierModel.prediction(
                input: GeoClassifierInput(input: input)
            )
        else {
            self.lastError = "Prediction failed."
            return -1
        }

        let predictedLabel = findMaxIndex(in: prediction.output)
        return predictedLabel
    }

    /// Dispose classifier resources
    public func dispose() {
        self.initialized = false
    }

    /// Get last error
    public func getLastError() -> String {
        return self.lastError
    }

    /// Get classifier name
    public func getName() -> String {
        return "coreml"
    }
}

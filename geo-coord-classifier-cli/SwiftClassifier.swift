import CoreML
// SwiftClassifier.swift
import Foundation

// Constants for normalization, matching the C++ code
private let minLat: Float = 47.4979
private let maxLat: Float = 52.5251
private let minLon: Float = -0.1270
private let maxLon: Float = 19.0514
private let epsilon: Float = 1e-8

/// Normalizes a single geo-coordinate pair using the defined min/max bounds.
/// This function mirrors the C++ `normalize_coords` logic.
/// - Parameter coords: An array of two floats [latitude, longitude].
/// - Returns: A new array with the normalized latitude and longitude.
private func normalizeCoords(coords: [Float]) -> [Float] {
    let normalizedLat = (coords[0] - minLat) / (maxLat - minLat + epsilon)
    let normalizedLon = (coords[1] - minLon) / (maxLon - minLon + epsilon)
    return [normalizedLat, normalizedLon]
}

/// A helper function to find the index of the max value in an MLMultiArray.
/// This is a more robust approach than iterating with subscripts.
private func findMaxIndex(in array: MLMultiArray) -> Int {
    guard array.count > 0 else { return -1 }

    var maxVal: Float = -Float.greatestFiniteMagnitude
    var maxIndex: Int = -1

    // Access the raw data pointer for efficiency and reliability
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

    // Error state
    private var lastError: String = ""

    // Initialization state
    private var initialized: Bool = false

    // The initializer is a special method named 'init'
    // It is responsible for setting up all stored properties.
    public init() {
        // Initialize with default values, or load the model here
        // We'll load the model in the `minit` function as per the protocol
        self.geoClassifierModel = try! GeoClassifier()  // Or a placeholder
    }

    public func minit(modelURL: URL, verbose: Bool) -> Int {
        do {
            self.geoClassifierModel = try GeoClassifier(contentsOf: modelURL)
            self.initialized = true
            // Access metadata
            let metadata =
                self.geoClassifierModel.model.modelDescription.metadata[
                    .creatorDefinedKey
                ] as? [String: String]

            if let metadata = metadata {
                if let minValsString = metadata["min_vals"] {
                    let minVals = minValsString.split(separator: ",").compactMap
                    { Double($0) }
                    //print("min_vals:", minVals)
                }
                if let maxValsString = metadata["max_vals"] {
                    let maxVals = maxValsString.split(separator: ",").compactMap
                    { Double($0) }
                    //print("max_vals:", maxVals)
                }
            }
            return 1
        } catch {
            self.lastError =
                "Failed to load Core ML model: \(error.localizedDescription)"
            self.initialized = false
            return 0
        }
    }

    public func infer(v1: Float, v2: Float) -> Int {
        guard initialized else {
            self.lastError = "Classifier not initialized."
            return -1
        }

        // 1. Create the MLMultiArray with the raw, un-normalized input values.
        // The Core ML model will handle the normalization internally.
        let input = try! MLMultiArray(
            shape: [1, 2] as [NSNumber],
            dataType: .float
        )
        let normalizedCoords = normalizeCoords(coords: [v1, v2])

        input[0] = NSNumber(value: normalizedCoords[0])
        input[1] = NSNumber(value: normalizedCoords[1])

        // 3. Pass the un-normalized input to the model.
        guard
            let prediction = try? self.geoClassifierModel.prediction(
                input: GeoClassifierInput(input: input)
            )
        else {
            self.lastError = "Prediction failed."
            return -1
        }

        let predictedLabel = findMaxIndex(in: prediction.output)
        //print("Sample: Original Coords = [\(v1), \(v2)], Normalized Coords = [\(normalizedCoords[0]), \(normalizedCoords[1])] label=\(predictedLabel)")

        return predictedLabel
    }

    public func dispose() {
        self.initialized = false
        // No de-initialization needed for Core ML models, but you can add cleanup logic here
    }

    public func getLastError() -> String {
        return self.lastError
    }
    public func getName() -> String {
        return "coreml"
    }
}

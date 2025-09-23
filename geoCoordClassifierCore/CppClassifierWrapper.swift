//
// CppClassifierWrapper.swift
// geoCoordClassifierCore
//
import Foundation
//import classifier
@_implementationOnly import classifierABC

public class CppClassifierWrapper: ClassifierProtocol {
    
    private var cppClassifier: Classifier
    
    public init() {
        self.cppClassifier = Classifier()
    }
    
    public func minit(modelURL: URL, verbose: Bool) -> Int {
        return Int(self.cppClassifier.minit(modelURL.path, verbose))
    }
    
    public func infer(v1: Float, v2: Float) -> Int {
        return Int(self.cppClassifier.infer(v1, v2))
    }
    
    public func dispose() {
        self.cppClassifier.deinit()
    }
    
    public func getLastError() -> String {
        return String(self.cppClassifier.getLastError())
    }
    public func getName() -> String {
        return "onnx"
    }
}

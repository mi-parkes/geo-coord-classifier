//
//  geoCoordClassifierApp.swift
//  geoCoordClassifier
//
import SwiftUI

@main
struct geo_coord_classifierApp: App {
    private var verbose: Bool
    init() {
        let args = CommandLine.arguments
        verbose = args.contains("-verbose")
    }
    var body: some Scene {
        WindowGroup {
            ContentView(verbose: verbose)
        }
    }
}

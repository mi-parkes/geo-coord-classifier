import Foundation
//import classifier

public func getFileUrl(filename: String, ext: String) -> URL? {
    if let fileURL = Bundle.main.url(
        forResource: filename,
        withExtension: ext
    ) {
        return fileURL
    } else {
        return nil
    }
}

public func getCoreFileUrl(filename: String, ext: String) -> URL? {
    // A placeholder class or struct within your framework.
    // This could be your main public class or a simple helper.
    class BundleFinder {}

    // 1. Get a reference to the framework's own bundle.
    let frameworkBundle = Bundle(for: BundleFinder.self)

    // 2. Use the framework's bundle to find the resource.
    if let fileURL = frameworkBundle.url(
        forResource: filename,
        withExtension: ext
    ) {
        return fileURL
    } else {
        print("Error: Could not find the file in the framework bundle.")
        return nil
    }
}

public class TestClassifier {
    public typealias Printer = (String) -> Void

    let geoClassifier: ClassifierProtocol
    var printer: Printer
    let modelURL: URL
    let testURL: URL
    let verbose: Bool

    var total: Int = 0
    var correct: Int = 0

    public init(geoClassifier:ClassifierProtocol, printer:  @escaping Printer, modelURL:URL, testURL:URL, verbose: Bool = false) {
        self.geoClassifier = geoClassifier
        self.printer = printer
        self.modelURL = modelURL
        self.testURL = testURL
        self.verbose = verbose
    }

    public func reset() {
        total = 0
        correct = 0
    }

    func processCoordinates(for cityName: String, in geoData: GeoData) {
        if let cityData = geoData[cityName] {
            for coordinatePair in cityData.coords {
                if coordinatePair.count >= 2 {
                    var res: String = "--"
                    let latitude: Float = Float(coordinatePair[0])
                    let longitude: Float = Float(coordinatePair[1])
                    let myInt = geoClassifier.infer(v1:latitude, v2:longitude)
                    total += 1
                    if let foundCity = findCityName(
                        forLabel: Int(myInt),
                        in: geoData
                    ) {
                        if foundCity == cityName {
                            correct += 1
                            res = "OK"
                        } else {
                            res = "!!"
                        }
                    }
                    if verbose {
                        printer(
                            String(
                                format: "  - Latitude: %5.2f, Longitude: %5.2f -> %@",
                                latitude,
                                longitude,
                                res
                            )
                        )
                    }
                } else {
                    printer("  - Invalid coordinate pair found.")
                }
            }
        } else {
            printer("City not found: \(cityName)")
        }
    }
        
    public func runTest() -> Bool {
        if geoClassifier.minit(modelURL:modelURL,verbose:verbose) == 1 {
            if let myGeoData = loadGeoData(testURL) {
                for (cityName, cityData) in myGeoData.sorted(by: {
                    $0.value.label < $1.value.label
                }) {
                    if verbose {
                        printer(
                            String(format: "Label: %02d City: %@", cityData.label, cityName)
                        )
                    }
                    processCoordinates(for: cityName, in: myGeoData)
                }
                let accuracy = Double(correct) / Double(total)
                printer(String(format: "Accuracy (%@): %.2f%% (%d/%d)", geoClassifier.getName(),accuracy * 100.0, correct, total))
            }
        }
        
        return true
    }
}

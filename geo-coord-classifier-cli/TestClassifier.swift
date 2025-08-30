import Foundation
import classifier

var hw: Classifier = Classifier()

func getFilePath(filename: String, ext: String) -> URL? {
    if let fileURL = Bundle.main.url(
        forResource: filename,
        withExtension: ext
    ) {
        return fileURL
    } else {
        return nil
    }
}

class TestClassifier {
    public typealias Printer = (String) -> Void

    var printer: Printer
    let modelPath: String
    let testURL: URL
    let verbose: Bool

    var total: Int = 0
    var correct: Int = 0

    init(printer:  @escaping Printer, modelPath:String, testURL:URL, verbose: Bool = false) {
        self.printer = printer
        self.modelPath = modelPath
        self.testURL = testURL
        self.verbose = verbose
    }

    func reset() {
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
                    let myInt = hw.infer(latitude, longitude)
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
        if hw.minit(modelPath,verbose) == 1 {
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
                printer(String(format: "Accuracy: %.2f%% (%d/%d)", accuracy * 100.0, correct, total))
            }
        }
        
        return true
    }
}

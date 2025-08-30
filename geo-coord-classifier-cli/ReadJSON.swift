import Foundation

struct CityData: Decodable {
    let label: Int
    let coords: [[Double]] // An array of arrays of Doubles
}

typealias GeoData = [String: CityData]

func loadGeoData(_ testURL: URL) -> GeoData? {
    do {
        let data = try Data(contentsOf: testURL)
        let decoder = JSONDecoder()
        let geoData = try decoder.decode(GeoData.self, from: data)
        return geoData
    } catch {
        print("Error decoding geodata: \(error)")
        return nil
    }
}

func findCityName(forLabel targetLabel: Int, in geoData: GeoData) -> String? {
    // Iterate through each key-value pair in the geoData dictionary.
    // 'cityName' is the key and 'cityData' is the value.
    for (cityName, cityData) in geoData {
        // Check if the label of the current city matches the target label.
        if cityData.label == targetLabel {
            // If a match is found, return the city's name immediately.
            return cityName
        }
    }
    
    // If the loop completes without finding a match, return nil.
    return nil
}

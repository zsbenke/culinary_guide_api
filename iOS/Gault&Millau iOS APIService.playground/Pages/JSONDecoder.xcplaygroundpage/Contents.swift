import Foundation

protocol PointOfInterest {
    var name: String { get }
    var city: String { get }
    var address: String { get }
}

class Restaurant: PointOfInterest, Codable {
    let name: String
    let city: String
    let address: String
    
    init(name: String, city: String, address: String) {
        self.name = name
        self.city = city
        self.address = address
    }
    
    static func parseFromJSON(_ jsonString: String) -> Restaurant? {
        do {
            let jsonData = jsonString.data(using: .utf8)
            if let json = jsonData {
                return try JSONDecoder().decode(self, from: json)
            }
        } catch {
            
        }
        return nil
    }
}

var jsonString = """
{ "name": "Teszt étterem", "city": "Pécs", "address": "XYZ utca" }
"""

var restaurant: Restaurant? = Restaurant.parseFromJSON(jsonString)

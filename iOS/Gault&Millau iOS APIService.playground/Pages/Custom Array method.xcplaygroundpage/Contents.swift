import Foundation

var something = [String]()
something.count

protocol Location {
    var name: String { get }
}

struct Restaurant: Location {
    let name: String
}

extension Array where Element == Restaurant {
    func filterByName(_ value: String) -> Array<Restaurant> {
        return self.filter { item in item.name ~= value }
    }
}

var restOne = Restaurant(name: "Teszt 1")
var restTwo = Restaurant(name: "Teszt 1")
var restThree = Restaurant(name: "Teszt 3")

var restaurants = [restOne, restTwo, restThree]
restaurants = restaurants.filterByName("Teszt 1")

restaurants

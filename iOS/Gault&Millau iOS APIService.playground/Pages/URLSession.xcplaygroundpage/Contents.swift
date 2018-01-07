import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let authToken = "Token token=eyJhbGciOiJIUzI1NiJ9.eyJ1bmlxdWVfaGFzaCI6InRlc3QifQ.9RwhNNuROSt_DpadCdGhSICbp0HSceu6Nv1u3sn5q-E"
let sessionConfiguration = URLSessionConfiguration.ephemeral
sessionConfiguration.httpAdditionalHeaders = ["Authorization": authToken]
let session = URLSession(configuration: sessionConfiguration)

struct APIManager {
    static var restaurant: String?
    
    private static func authorize(data: Data?, for response: URLResponse?, error: Error?, _ completionHandler: (_ data: Data?) -> Void) {
        defer { PlaygroundPage.current.finishExecution() }
        if (error != nil) {
            print(error?.localizedDescription)
        } else {
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 401:
                    print("Not authorized") 
                case 200:
                    print("Logged in")
                    completionHandler(data)
                default:
                    print("unknown status code")
                }
            }
        }
    }
    
    static func showRestaurant(_ id: Int, _ completionHandler: @escaping (_ data: Data?) -> Void) {
        let dataTask = session.dataTask(with: URL(string: "http://develop.decoding.io:3000/api/v1/restaurants/\(id)")!) { data, response, error in
            APIManager.authorize(data: data, for: response, error: error){ data in
                completionHandler(data)
            }
        }
        
        dataTask.resume()
    }
}

APIManager.showRestaurant(10177) { data in
    var something = String(data: data!, encoding: .utf8)
}


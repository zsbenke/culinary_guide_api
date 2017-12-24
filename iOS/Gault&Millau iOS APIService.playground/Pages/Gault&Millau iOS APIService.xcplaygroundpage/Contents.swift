import Foundation
import PlaygroundSupport

func assertEqual(_ lhs: String, with rhs: String) -> String {
    if lhs == rhs {
        return "✅ Passed"
    } else {
        return "❌ Failed"
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 # Routers
 
 All object, protocols needed for generating API URL objects.
 */

let authToken = "Token token=eyJhbGciOiJIUzI1NiJ9.eyJ1bmlxdWVfaGFzaCI6InRlc3QifQ.9RwhNNuROSt_DpadCdGhSICbp0HSceu6Nv1u3sn5q-E"
let sessionConfiguration = URLSessionConfiguration.ephemeral
sessionConfiguration.httpAdditionalHeaders = ["Authorization": authToken]
let session = URLSession(configuration: sessionConfiguration)

public enum Environment {
    case production
    case staging
    case development
}

public struct API {
    static var environment: Environment = .development
    private static var domain: String {
        switch environment {
        case .development:
            return "http://develop.decoding.io:3000"
        case .production:
            return "http://api.gaultmillau.eu"
        case .staging: 
            return "http://api.staging.gaultmillau.eu"
        }
    }
    
    static let baseURL = "\(domain)/api/v1"
}

public struct URLQueryToken: CustomStringConvertible {
    enum TokenType: CustomStringConvertible {
        case column, value
        
        public var description: String {
            var tokenTypeDescription: String
            
            switch self {
            case .column: tokenTypeDescription = "column" 
            case .value: tokenTypeDescription = "value"
            }
            return tokenTypeDescription
        }
    }
    
    let column: String
    let value: String
    
    var columnItem: URLQueryItem {
        return URLQueryToken.initURLQueryItem(for: .column, value: column)
    }
    
    var valueItem: URLQueryItem {
        return URLQueryToken.initURLQueryItem(for: .value, value: value)
    }
    
    private static func initURLQueryItem(for tokenType: TokenType, value: String) -> URLQueryItem {
        return URLQueryItem(name: "token[\(tokenType)]", value: value)
    }
    
    public var description: String {
        return ["\(columnItem)", "\(valueItem)"].joined(separator: "&")
    }
}

protocol Router {
    static var baseURLEndpoint: String { get }
    func asURLRequest() -> URLRequest
}

public enum RestaurantRouter: Router, CustomStringConvertible {
    static let baseURLEndpoint: String = "\(API.baseURL)/restaurants"
    
    case index
    case search([URLQueryToken])
    case show(Int)
    
    var method: String {
        switch self {
        case .index, .search, .show:
            return "GET"
        }
    }
    
    public func asURLRequest() -> URLRequest {
        let url: URL = {
            let path: String?
            switch self {
            case .index, .search:
                path = ""
            case .show(let id):
                path = "\(id)"
            }
            
            var tokens: [URLQueryItem] = []
            
            switch self {
            case .search(let assignedTokens):
                assignedTokens
                assignedTokens.forEach { token in 
                    tokens.append(token.columnItem)
                    tokens.append(token.valueItem)
                }
            default:
                tokens = [] 
            }
            
            var url = URL(string: RestaurantRouter.baseURLEndpoint)!
            if let path = path { url.appendPathComponent(path) }
            var urlComponents = URLComponents.init(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = tokens
            return urlComponents!.url!
        }()
        
        var request = URLRequest(url: url)
        
        request.httpMethod = method
        return request
    }
    
    public var description: String {
        return String(describing: self.asURLRequest())
    }
}

/*:
 # Routers
 
 Testing routers with restaurant endpoints.
 */

class RestaurantRouterTests {
    static func testSearchWithParameters() -> String {
        var tokens = [
            URLQueryToken(column: "search", value: "string"),
            URLQueryToken(column: "open_on_monday", value: "true"),
            URLQueryToken(column: "has_parking", value: "true")
        ]
        let urlString = "\(API.baseURL)/restaurants/"
        var assertedURL = URLComponents(string: urlString)
        
        assertedURL?.queryItems = []
        tokens.forEach { token in
            assertedURL?.queryItems?.append(token.columnItem)
            assertedURL?.queryItems?.append(token.valueItem)
        }
        
        let searchURL = "\(RestaurantRouter.search(tokens))"
        if let assertedURL = assertedURL {
            let assertion = "\(assertedURL)" ?? ""
            return assertEqual(searchURL, with: assertion)
        } else {
            return assertEqual("true", with: "false")
        }
    }
    
    static func testIndexWithoutParameters() -> String {
        let indexURL = "\(RestaurantRouter.index)"
        let assertion = "\(API.baseURL)/restaurants/"
        return assertEqual(indexURL, with: assertion)
    }
    
    static func testShow() -> String {
        let showURL = "\(RestaurantRouter.show(1))"
        let assertion = "\(API.baseURL)/restaurants/1"
        return assertEqual(showURL, with: assertion)
    }
}

RestaurantRouterTests.testIndexWithoutParameters()
RestaurantRouterTests.testSearchWithParameters()
RestaurantRouterTests.testShow()

/*:
 # Requests
 
 APIResource protocol defines needed methods to access a read-only resource. RestaurantResource implements the following methods:
 
 - index(completionHandler:)
 - index(search:,completionHandler:)
 - show(_, :completionHandler:)
 
 All of these callbacks returning a Data? object for creating model object.
 */

protocol APIResource {
    associatedtype Router
    static var router: Router { get }
    
    static func index(completionHandler: @escaping (_ data: Data?) -> Void)
    static func index(search tokens: [URLQueryToken], completionHandler: @escaping  (_ data: Data?) -> Void)
    static func show(_ id: Int, completionHandler: @escaping  (_ data: Data?) -> Void)
}

extension APIResource {
    static func authorize(data: Data?, for response: URLResponse?, error: Error?, _ completionHandler: (_ data: Data?) -> Void) {
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
}

class RestaurantResource: APIResource {
    static let router = RestaurantRouter.self 
    
    static func index(completionHandler: @escaping (Data?) -> Void) {
        let dataTask = session.dataTask(with: router.index.asURLRequest()) { data, response, error in
            RestaurantResource.authorize(data: data, for: response, error: error) { data in
                completionHandler(data)
            }
        }
        dataTask.resume()
    }
    
    static func index(search tokens: [URLQueryToken], completionHandler: @escaping (Data?) -> Void) {
        let dataTask = session.dataTask(with: router.search(tokens).asURLRequest()) { data, response, error in
            RestaurantResource.authorize(data: data, for: response, error: error) { data in
                completionHandler(data)
            }
        }
        dataTask.resume()
    }

    static func show(_ id: Int, completionHandler: @escaping (Data?) -> Void) {
        let dataTask = session.dataTask(with: router.show(id).asURLRequest()) { data, response, error in
            RestaurantResource.authorize(data: data, for: response, error: error) { data in
                completionHandler(data)
            }
        }
        dataTask.resume()
    }
}

/*:
 # Models
 
 Defining model objects used for decoding data for resources.
 
 */

protocol PointOfInterest {
    var title: String? { get }
    var address: String? { get }   
    var latitude: String? { get }
    var longitude: String? { get }
}

struct APIResponse: Codable {
    var headers: [String: String]
    var data: [String: String]
}

class Restaurant: PointOfInterest, Decodable {
    var title: String? = nil
    var address: String? = nil
    var latitude: String? = nil
    var longitude: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case header
        case data
    }
    
    enum DataKeys: String, CodingKey {
        case title = "title"
        case address = "full_address"
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
    static func parseFromJSON(_ data: Data) -> Restaurant? {
        do {
            var json = String(data: data, encoding: .utf8)
            return try JSONDecoder().decode(Restaurant.self, from: data)
        } catch {
            return nil
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let dataInfo = try values.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        title = try dataInfo.decode(String.self, forKey: .title)
        address = try dataInfo.decode(String.self, forKey: .address)
        latitude = try dataInfo.decode(String.self, forKey: .latitude)
        longitude = try dataInfo.decode(String.self, forKey: .longitude)
    }
}

RestaurantResource.show(10177) { data in
    if let data = data { Restaurant.parseFromJSON(data) }
}

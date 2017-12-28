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
 # Models
 
 Defining model objects used for decoding data for resources.
 
 */
protocol PointOfInterest {
    var id: Int? { get }
    var title: String? { get }
    var address: String? { get }   
    var latitude: String? { get }
    var longitude: String? { get }
}

struct Restaurant: PointOfInterest, Codable {
    let id: Int?
    let title: String?
    let address: String?
    let latitude: String?
    let longitude: String?
    let rating: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case address = "full_address"
        case latitude
        case longitude
        case rating
    }
}

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
        return URLQueryItem(name: "tokens[][\(tokenType)]", value: value)
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
            print(urlComponents!.url!)
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

class AsyncOperation: Operation {
    enum State: String {
        case Ready, Executing, Finished
        
        fileprivate var keyPath: String {
            return "is\(rawValue)"
        }
    }
    
    var state = State.Ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    override var isReady: Bool {
        return super.isReady && state == .Ready
    }
    
    override var isExecuting: Bool {
        return state == .Executing
    }
    
    override var isFinished: Bool {
        return state == .Finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start() {
        if isCancelled {
            state = .Finished
            return
        }
        main()
        state = .Executing
    }
    
    override func cancel() {
        state = .Finished
    }
}

protocol APIResource {
    associatedtype Router
    associatedtype Record
    
    static var router: Router { get }
    
    static func index(completionHandler: @escaping (_ records: [Record?]) -> Void)
    static func index(search tokens: [URLQueryToken], completionHandler: @escaping  (_ records: [Record?]) -> Void)
    static func show(_ id: Int, completionHandler: @escaping  (_ record: Record?) -> Void)
}

class APIRequestOperation: AsyncOperation {
    let urlRequest: URLRequest
    var data: Data?
    
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        super.init()
    }
    
    override func main() {
        request(urlRequest) { (data) in
            self.data = data
            self.state = .Finished
        }
    }
    
    private func request(_ apiRequest: URLRequest, completionHandler: @escaping (_ data: Data?) -> Void) {
        let dataTask = session.dataTask(with: apiRequest) { data, response, error in
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
        dataTask.resume()
    }
}

extension Restaurant: APIResource {
    internal static let router = RestaurantRouter.self
    
    static func index(completionHandler: @escaping (_ restaurants: [Restaurant?]) -> Void) {
        let operationQueue = OperationQueue()
        let requestOperation = APIRequestOperation(urlRequest: router.index.asURLRequest())
        requestOperation.completionBlock = {
            guard let data = requestOperation.data else { return }
            do {
                let restaurants = try JSONDecoder().decode([Restaurant].self, from: data)
                completionHandler(restaurants)
            } catch {
                return
            }
        }
        operationQueue.addOperation(requestOperation)
    }
    
    static func index(search tokens: [URLQueryToken], completionHandler: @escaping (_ restaurants: [Restaurant?]) -> Void) {
        let operationQueue = OperationQueue()
        let requestOperation = APIRequestOperation(urlRequest: router.search(tokens).asURLRequest())
        requestOperation.completionBlock = {
            guard let data = requestOperation.data else { return }
            do {
                let restaurants = try JSONDecoder().decode([Restaurant].self, from: data)
                completionHandler(restaurants)
            } catch {
                return
            }
        }
        operationQueue.addOperation(requestOperation)
    }

    static func show(_ id: Int, completionHandler: @escaping (_ restaurant: Restaurant?) -> Void) {
        let operationQueue = OperationQueue()
        let requestOperation = APIRequestOperation(urlRequest: router.show(id).asURLRequest())
        requestOperation.completionBlock = {
            guard let data = requestOperation.data else { return }
            do {
                let restaurant = try JSONDecoder().decode(Restaurant.self, from: data)
                completionHandler(restaurant)
            } catch {
                return
            }
            
        }
        operationQueue.addOperation(requestOperation)
    }
}

enum TestRouter: Router {
    static var baseURLEndpoint: String = "\(API.baseURL)/api/test"

    func asURLRequest() -> URLRequest {
        let url = URL(string: TestRouter.baseURLEndpoint)
        return URLRequest(url: url!)
    }
}
/*
struct TestResource: APIResource {
    static let router = TestRouter.self
    
    enum TestJSON {
        static let index = ""
        static let show = "{ \"title\": \"Test Resource\", \"address\": \"Somewhere City\" }"
    }
    
    static func index(completionHandler: @escaping (Data?) -> Void) {
        let data = TestJSON.index.data(using: .utf8)
        completionHandler(data)
    }

    static func index(search tokens: [URLQueryToken], completionHandler: @escaping (Data?) -> Void) {
        let data = TestJSON.index.data(using: .utf8)
        completionHandler(data)
    }

    static func show(_ id: Int, completionHandler: @escaping (Data?) -> Void) {
        let data = TestJSON.show.data(using: .utf8)
        completionHandler(data)
    }
}

struct TestModel: Codable {
    var title: String
    var address: String
    
    static func parseFromJSON(_ data: Data) -> TestModel? {
        do {
            var json = String(data: data, encoding: .utf8)
            return try JSONDecoder().decode(self, from: data)
        } catch {
            return nil
        }
    }
}

TestResource.show(1) { (data) in
    var testModel = TestModel.parseFromJSON(data!)
}
 */

Restaurant.index() { (restaurants) in
    let titles = restaurants.map { $0?.title }
}

let cityToken = URLQueryToken(column: "city", value: "Debrecen")
let openOnSundayToken = URLQueryToken(column: "open_on_sunday", value: "true")
Restaurant.index(search: [cityToken, openOnSundayToken]) { restaurants in
    let addresses = restaurants.map { $0?.address }
    addresses.count
}
    
Restaurant.show(10177) { restaurant in
    let title = restaurant?.title
}

var thing = ""

DispatchQueue.global().async {
    sleep(3)
    
    DispatchQueue.main.async {
        thing = "csá"
        print(thing)
    }
}

var another = "xxx"

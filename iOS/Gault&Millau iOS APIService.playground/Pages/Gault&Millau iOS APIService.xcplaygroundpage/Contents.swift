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


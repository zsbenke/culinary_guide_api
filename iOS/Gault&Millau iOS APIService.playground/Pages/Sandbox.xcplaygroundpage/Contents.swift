import Foundation

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

let queryToken = URLQueryToken(column: "title", value: "test")

var url = URLComponents(string: "http://test.com/")
url?.queryItems = [queryToken.columnItem, queryToken.columnItem]

if let url = url {
    "\(url)"
}

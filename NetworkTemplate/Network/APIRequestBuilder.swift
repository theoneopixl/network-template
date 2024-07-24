//
//  NetworkConstant.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

/// Represents the standard HTTP methods used in API requests.
public enum HTTPMethod: String {
    /// GET method for retrieving resources.
    case GET
    /// POST method for creating new resources.
    case POST
    /// PUT method for updating an existing resource.
    case PUT
    /// PATCH method for partially updating an existing resource.
    case PATCH
    /// DELETE method for removing a resource.
    case DELETE
}

/// Protocol defining the structure of an API request builder.
public protocol APIRequestBuilder {
    /// The path of the API endpoint.
    var path: String { get }
    
    /// The HTTP method to be used for the request.
    var httpMethod: HTTPMethod { get }
    
    /// The query parameters to be included in the URL.
    var parameters: [URLQueryItem]? { get }
    
    /// Indicates whether an authentication token is required for this request.
    var isTokenNeeded: Bool { get }
    
    /// Additional HTTP headers to be included in the request.
    var headers: [(key: String, value: String)]? { get }
    
    /// The body of the request, if needed.
    var body: Data? { get }
    
    /// The URL request constructed from the builder's properties.
    var urlRequest: URLRequest? { get }
}

extension APIRequestBuilder {
    /// Provides default HTTP headers, including content type and authorization token if needed.
    ///
    /// - Returns: An array of tuples representing the HTTP headers.
    var headers: [(key: String, value: String)]? {
        var header = [(String, String)]()
        header.append(("Content-Type", "application/json"))
        if isTokenNeeded {
            header.append(("Authorization", "Bearer \(TokenManager.shared.token)"))
        }
        return header
    }
    
    /// Constructs a URL request from the builder's properties.
    ///
    /// This method combines the base URL, path, parameters, headers, and body to create a complete URL request.
    ///
    /// - Returns: A constructed `URLRequest`, or `nil` if the construction fails.
    var urlRequest: URLRequest? {
        let urlString = NetworkConstant.baseURL + path
        
        var components = URLComponents(string: urlString)
        if let parameters {
            components?.queryItems = parameters
        }
        
        guard let url = components?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let headers {
            headers.forEach {
                request.addValue($0.value, forHTTPHeaderField: $0.key)
            }
        }
        
        if let body {
            request.httpBody = body
        }
        
        return request
    }
}

//
//  NetworkConstant.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

public enum NetworkError: Error, LocalizedError {
    case notFound
    case unauthorized
    case badRequest
    case parsingError
    case conflict
    case fieldIsIncorrectlyFilled
    case internalError
    case refreshTokenFailed
    case noInternet
    case timeout
    case unknown

    public var errorDescription: String {
        switch self {
        case .notFound:                 return "Resource not found"
        case .unauthorized:             return "Unauthorized access"
        case .badRequest:               return "Bad request"
        case .parsingError:             return "Failed to parse the response"
        case .conflict:                 return "Conflict in the request"
        case .fieldIsIncorrectlyFilled: return "One or more fields are incorrectly filled"
        case .internalError:            return "Internal server error"
        case .refreshTokenFailed:       return "Failed to refresh the token"
        case .noInternet:               return "No internet connection"
        case .timeout:                  return "Request timed out"
        case .unknown:                  return "Unknown error"
        }
    }
}

func mapResponse(response: (data: Data, response: URLResponse, method: String?)) throws -> Data {
    
    guard let httpResponse = response.response as? HTTPURLResponse else {
        return response.data
    }
    
    #if DEBUG
    if let url = httpResponse.url {
        print("🛜 \(response.method ?? "") | \(httpResponse.statusCode) -> \(url)")
    }
    #endif
    
    switch httpResponse.statusCode {
    case 200..<300: return response.data
    case 400: throw NetworkError.badRequest
    case 401: throw NetworkError.unauthorized
    case 404: throw NetworkError.notFound
    case 409: throw NetworkError.conflict
    case 422: throw NetworkError.fieldIsIncorrectlyFilled
    case 500: throw NetworkError.internalError
    case 503: throw NetworkError.internalError
    default:  throw NetworkError.unknown
    }
    
}

//
//  UtilsAPIRequester.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

enum UtilsAPIRequester: APIRequestBuilder {
    case refreshToken(token: String)
}

extension UtilsAPIRequester {
    var path: String {
        switch self {
        case .refreshToken(let token):
            return NetworkConstant.Path.Utils.refreshToken(token: token)
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .refreshToken(_):
            return .GET
        }
    }
    
    var parameters: [URLQueryItem]? { return nil }
    
    var isTokenNeeded: Bool { return false }
    
    var body: Data? { return nil }
}

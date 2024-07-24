//
//  Error+Extensions.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

extension Error {
    
    func toNetworkError() -> NetworkError {
        if let networkError = self as? NetworkError {
            return networkError
        } else if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:   return .noInternet
            case .timedOut:                 return .timeout
            default:                        return .unknown
            }
        } else { return .unknown }
    }
    
}

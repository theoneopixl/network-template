//
//  NetworkConstant.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

/// A struct containing network-related constants.
struct NetworkConstant {
    
    /// The base URL for the network requests.
    static let baseURL: String = "http://127.0.0.1:8080"
    
    /// A nested struct containing paths for various network requests.
    struct Path {
        struct Utils {
            static func refreshToken(token: String) -> String {
                return "/refresh-token/\(token)"
            }
        }
        
        struct Person {
            static let persons: String = "/persons"
            static func managePerson(personID: Int) -> String {
                return "/persons/\(personID)"
            }
            static func grantAdmin(personID: Int) -> String {
                return "/persons/\(personID)/grantAdmin"
            }
        }
    }
}

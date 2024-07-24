//
//  TokenResponse.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

struct TokenResponse: Codable {
    var token: String?
    var refreshToken: String?
}

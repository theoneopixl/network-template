//
//  JSONEncoder+Extensions.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

extension JSONEncoder {
    
    static func encode<T: Encodable>(body: T) -> Data? {
        return try? JSONEncoder().encode(body)
    }
    
}

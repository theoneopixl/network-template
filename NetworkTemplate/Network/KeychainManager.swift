//
//  NetworkConstant.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation
import Security
import LocalAuthentication

enum KeychainServiceManager: String {
    case refreshToken = "refreshToken"
}

final class KeychainManager {
    static let shared = KeychainManager()
}

extension KeychainManager {
    func retrieveItemFromKeychain(keychainService: KeychainServiceManager) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainService.rawValue,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary
                
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        if let result = result as? NSDictionary {
            if let itemData = result[kSecValueData] as? Data {
                let item = String(data: itemData, encoding: .utf8)!
                return item
            }
        }
        
        return nil
    }
    
    func setItemToKeychain(newValue: String, keychainService: KeychainServiceManager) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainService.rawValue,
            kSecValueData: newValue.data(using: .utf8)!,
        ] as CFDictionary
        
        var status = SecItemAdd(query, nil)
                
        if status == errSecDuplicateItem {
            // Item already exist, thus update it.
            let updateQuery = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount as String: keychainService.rawValue
            ] as CFDictionary
            
            let attributesToUpdate = [kSecValueData: newValue.data(using: .utf8)!] as CFDictionary
            status = SecItemUpdate(updateQuery, attributesToUpdate)
        }
    }
}

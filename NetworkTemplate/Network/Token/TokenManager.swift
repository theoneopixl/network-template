//
//  NetworkConstant.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

final class TokenManager: ObservableObject {
    static let shared = TokenManager()
    
    @Published var token: String = ""
}

extension TokenManager {
    
    @MainActor
    func refreshToken() async throws {
        if let refreshToken = KeychainManager.shared.retrieveItemFromKeychain(keychainService: .refreshToken) {
            do {
                let tokenResponse = try await NetworkService.shared.sendRequest(
                    apiBuilder: UtilsAPIRequester.refreshToken(token: refreshToken),
                    responseModel: TokenResponse.self
                )
                
                if let refreshToken = tokenResponse.refreshToken, let token = tokenResponse.token {
                    self.token = token
                    KeychainManager.shared.setItemToKeychain(newValue: refreshToken, keychainService: .refreshToken)
                }
            } catch {
                try await refreshTokenFailed()
            }
        }
    }
    
}

extension TokenManager {
    
    private func refreshTokenFailed() async  throws {
        await resetTokens()
        throw NetworkError.refreshTokenFailed
    }
    
    func resetTokens() async {
        self.token = ""
        KeychainManager.shared.setItemToKeychain(newValue: "", keychainService: .refreshToken)
    }
    
}

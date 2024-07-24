//
//  NetworkConstant.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

public protocol NetworkServiceProtocol {
    func sendRequest<T: Decodable>(apiBuilder: APIRequestBuilder, responseModel: T.Type, withRefreshToken: Bool) async throws -> T
    func sendRequest(apiBuilder: APIRequestBuilder, withRefreshToken: Bool) async throws
}

public class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    private var retryCount = 0
    private let maxRetries = 2
}

// MARK: - With Response
extension NetworkService {
    
    public func sendRequest<T: Decodable>(apiBuilder: APIRequestBuilder, responseModel: T.Type, withRefreshToken: Bool = false) async throws -> T {
        do {
            return try await self.sendRequest(apiBuilder: apiBuilder, responseModel: responseModel, withRefreshToken: withRefreshToken, retryCount: 0)
        } catch {
            self.retryCount = 0
            throw error
        }
    }
    
    private func sendRequest<T: Decodable>(apiBuilder: APIRequestBuilder, responseModel: T.Type, withRefreshToken: Bool, retryCount: Int) async throws -> T {
        do {
            guard let urlRequest = apiBuilder.urlRequest else { throw NetworkError.badRequest }
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            let dataToDecode = try mapResponse(response: (data, response, urlRequest.httpMethod))
            
           self.retryCount = 0
            
            return try decodeResponse(dataToDecode: dataToDecode, responseModel: responseModel)
        } catch let error as NetworkError {
            if withRefreshToken && error == .unauthorized {
                if self.retryCount < maxRetries {
                    self.retryCount += 1
                    try await TokenManager.shared.refreshToken()
                    
                    return try await self.sendRequest(apiBuilder: apiBuilder, responseModel: responseModel, withRefreshToken: true, retryCount: self.retryCount)
                } else {
                    self.retryCount = 0
                    throw NetworkError.refreshTokenFailed
                }
            } else { throw error }
        }
    }
    
    private func decodeResponse<T: Decodable>(dataToDecode: Data, responseModel: T.Type) throws -> T {
        do {
            let results = try JSONDecoder().decode(responseModel, from: dataToDecode)
            return results
        } catch {
            throw NetworkError.parsingError
        }
    }
    
}

// MARK: - Without Response
extension NetworkService {
    
    public func sendRequest(apiBuilder: APIRequestBuilder, withRefreshToken: Bool = false) async throws {
        do {
            return try await self.sendRequest(apiBuilder: apiBuilder, withRefreshToken: withRefreshToken, retryCount: 0)
        } catch {
            self.retryCount = 0
            throw error
        }
    }
    
    private func sendRequest(apiBuilder: APIRequestBuilder, withRefreshToken: Bool, retryCount: Int) async throws {
        do {
            guard let urlRequest = apiBuilder.urlRequest else { throw NetworkError.badRequest }
            self.retryCount = 0
        } catch let error as NetworkError {
            if withRefreshToken && error == .unauthorized {
                if self.retryCount < maxRetries {
                    self.retryCount += 1
                    try await TokenManager.shared.refreshToken()
                    
                    return try await self.sendRequest(apiBuilder: apiBuilder, withRefreshToken: true, retryCount: self.retryCount)
                } else {
                    self.retryCount = 0
                    throw NetworkError.refreshTokenFailed
                }
            } else { throw error }
        }
    }
    
}

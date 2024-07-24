//
//  NetworkConstant.swift
//  NetworkTemplate
//
//  Created by Theo Sementa on 23/07/2024.
//

import Foundation

/// A protocol defining the necessary methods for a network service.
public protocol NetworkServiceProtocol {
    /// Sends a request and decodes the response.
    /// - Parameters:
    ///   - apiBuilder: An object that builds the API request.
    ///   - responseModel: The type of the response model to decode.
    ///   - withRefreshToken: A boolean indicating if a refresh token should be used in case of unauthorized error.
    /// - Returns: A decoded response of type `T`.
    /// - Throws: An error if the request or decoding fails.
    func sendRequest<T: Decodable>(apiBuilder: APIRequestBuilder, responseModel: T.Type, withRefreshToken: Bool) async throws -> T
    
    /// Sends a request without expecting a response.
    /// - Parameters:
    ///   - apiBuilder: An object that builds the API request.
    ///   - withRefreshToken: A boolean indicating if a refresh token should be used in case of unauthorized error.
    /// - Throws: An error if the request fails.
    func sendRequest(apiBuilder: APIRequestBuilder, withRefreshToken: Bool) async throws
}

/// A class that provides network services and handles requests.
public class NetworkService: NetworkServiceProtocol {
    /// A shared instance of `NetworkService`.
    static let shared = NetworkService()
    
    private var retryCount = 0
    private let maxRetries = 2
    
    // MARK: - With Response
    
    /// Sends a request and decodes the response.
    /// - Parameters:
    ///   - apiBuilder: An object that builds the API request.
    ///   - responseModel: The type of the response model to decode.
    ///   - withRefreshToken: A boolean indicating if a refresh token should be used in case of unauthorized error. Default is `false`.
    /// - Returns: A decoded response of type `T`.
    /// - Throws: An error if the request or decoding fails.
    public func sendRequest<T: Decodable>(apiBuilder: APIRequestBuilder, responseModel: T.Type, withRefreshToken: Bool = false) async throws -> T {
        do {
            return try await self.sendRequest(apiBuilder: apiBuilder, responseModel: responseModel, withRefreshToken: withRefreshToken, retryCount: 0)
        } catch {
            self.retryCount = 0
            throw error
        }
    }
    
    /// Private method to send a request and decode the response.
    /// - Parameters:
    ///   - apiBuilder: An object that builds the API request.
    ///   - responseModel: The type of the response model to decode.
    ///   - withRefreshToken: A boolean indicating if a refresh token should be used in case of unauthorized error.
    ///   - retryCount: The current retry count.
    /// - Returns: A decoded response of type `T`.
    /// - Throws: An error if the request or decoding fails.
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
            } else {
                throw error
            }
        }
    }
    
    /// Decodes the response data to the specified model.
    /// - Parameters:
    ///   - dataToDecode: The data to decode.
    ///   - responseModel: The type of the response model to decode.
    /// - Returns: A decoded response of type `T`.
    /// - Throws: An error if decoding fails.
    private func decodeResponse<T: Decodable>(dataToDecode: Data, responseModel: T.Type) throws -> T {
        do {
            let results = try JSONDecoder().decode(responseModel, from: dataToDecode)
            return results
        } catch {
            throw NetworkError.parsingError
        }
    }
    
    // MARK: - Without Response
    
    /// Sends a request without expecting a response.
    /// - Parameters:
    ///   - apiBuilder: An object that builds the API request.
    ///   - withRefreshToken: A boolean indicating if a refresh token should be used in case of unauthorized error. Default is `false`.
    /// - Throws: An error if the request fails.
    public func sendRequest(apiBuilder: APIRequestBuilder, withRefreshToken: Bool = false) async throws {
        do {
            return try await self.sendRequest(apiBuilder: apiBuilder, withRefreshToken: withRefreshToken, retryCount: 0)
        } catch {
            self.retryCount = 0
            throw error
        }
    }
    
    /// Private method to send a request without expecting a response.
    /// - Parameters:
    ///   - apiBuilder: An object that builds the API request.
    ///   - withRefreshToken: A boolean indicating if a refresh token should be used in case of unauthorized error.
    ///   - retryCount: The current retry count.
    /// - Throws: An error if the request fails.
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
            } else {
                throw error
            }
        }
    }
}

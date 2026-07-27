//
//  NetworkService.swift
//  TMDBMovieApp
//
//  Protocol-based network layer using URLSession + async/await.
//  Generic, reusable, and testable via protocol abstraction.
//

import Foundation

// MARK: - Protocol

/// Protocol for network service abstraction.
/// Enables dependency injection and easy mocking in unit tests.
protocol NetworkServiceProtocol: Sendable {
    /// Fetches and decodes a `Decodable` response from the given endpoint.
    /// - Parameter endpoint: The TMDB endpoint to request.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: `TMDBError` for any failure case.
    func request<T: Decodable & Sendable>(_ endpoint: TMDBEndpoint) async throws -> T
}

// MARK: - Implementation

/// Concrete implementation of `NetworkServiceProtocol` using `URLSession`.
final class NetworkService: NetworkServiceProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder

    /// Initializes the network service.
    /// - Parameter session: URLSession instance (defaults to `.shared`, injectable for testing).
    init(session: URLSession = .shared) {
        self.session = session

        // Configure decoder for TMDB's snake_case JSON keys
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func request<T: Decodable & Sendable>(_ endpoint: TMDBEndpoint) async throws -> T {
        // 1. Build URLRequest
        let urlRequest: URLRequest
        do {
            urlRequest = try endpoint.asURLRequest()
        } catch {
            throw TMDBError.invalidURL
        }

        #if DEBUG
        print("🌐 [NetworkService] \(urlRequest.httpMethod ?? "GET") \(urlRequest.url?.absoluteString ?? "nil")")
        #endif

        // 2. Execute request
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            throw TMDBError.from(urlError)
        } catch {
            throw TMDBError.unknown(error.localizedDescription)
        }

        // 3. Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TMDBError.unknown("Invalid response type")
        }

        #if DEBUG
        print("📡 [NetworkService] Status: \(httpResponse.statusCode) | Bytes: \(data.count)")
        #endif

        switch httpResponse.statusCode {
        case 200...299:
            break // Success range
        case 401:
            throw TMDBError.unauthorized
        case 429:
            throw TMDBError.rateLimitExceeded
        case 500...599:
            throw TMDBError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw TMDBError.serverError(statusCode: httpResponse.statusCode)
        }

        // 4. Guard against empty data
        guard !data.isEmpty else {
            throw TMDBError.noData
        }

        // 5. Decode response
        do {
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
        } catch let decodingError as DecodingError {
            let detail = Self.describeDecodingError(decodingError)
            #if DEBUG
            print("❌ [NetworkService] Decoding error: \(detail)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 [NetworkService] Raw response: \(responseString.prefix(500))")
            }
            #endif
            throw TMDBError.decodingError(detail)
        }
    }

    // MARK: - Helpers

    /// Provides a human-readable description of a `DecodingError` for debugging.
    private static func describeDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            return "Type mismatch for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .valueNotFound(let type, let context):
            return "Value not found for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .keyNotFound(let key, let context):
            return "Key '\(key.stringValue)' not found at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        case .dataCorrupted(let context):
            return "Data corrupted at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
        @unknown default:
            return "Unknown decoding error"
        }
    }
}

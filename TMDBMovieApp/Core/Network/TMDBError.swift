//
//  TMDBError.swift
//  TMDBMovieApp
//
//  Custom error enum for all TMDB API and networking errors.
//

import Foundation

/// Unified error type for TMDB API operations.
/// Conforms to `LocalizedError` to provide user-facing descriptions.
enum TMDBError: Error, LocalizedError, Equatable {
    case invalidURL
    case noData
    case decodingError(String)
    case serverError(statusCode: Int)
    case noInternet
    case timeout
    case unauthorized
    case rateLimitExceeded
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid. Please try again."
        case .noData:
            return "No data received from the server."
        case .decodingError(let detail):
            return "Failed to process server response: \(detail)"
        case .serverError(let statusCode):
            return "Server error occurred (HTTP \(statusCode)). Please try again later."
        case .noInternet:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return "The request timed out. Please try again."
        case .unauthorized:
            return "Invalid API key. Please check your configuration."
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment and try again."
        case .unknown(let message):
            return "An unexpected error occurred: \(message)"
        }
    }

    /// User-friendly short title for UI display
    var title: String {
        switch self {
        case .noInternet:
            return "No Connection"
        case .timeout:
            return "Timeout"
        case .serverError:
            return "Server Error"
        case .unauthorized:
            return "Unauthorized"
        case .rateLimitExceeded:
            return "Rate Limited"
        default:
            return "Error"
        }
    }

    /// Whether this error is retryable
    var isRetryable: Bool {
        switch self {
        case .noInternet, .timeout, .serverError, .rateLimitExceeded:
            return true
        case .invalidURL, .noData, .decodingError, .unauthorized, .unknown:
            return false
        }
    }

    /// Maps URLError to TMDBError for consistent error handling
    static func from(_ urlError: URLError) -> TMDBError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return .noInternet
        case .timedOut:
            return .timeout
        default:
            return .unknown(urlError.localizedDescription)
        }
    }
}

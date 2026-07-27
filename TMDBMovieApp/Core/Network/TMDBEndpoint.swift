//
//  TMDBEndpoint.swift
//  TMDBMovieApp
//
//  Endpoint builder for constructing TMDB API requests cleanly.
//

import Foundation

/// Configuration for TMDB API credentials and base URL.
enum TMDBConfig {
    /// TMDB API Key
    static let apiKey = "318bd7b164451c099356cf7428b206b5"

    /// TMDB API base URL
    static let baseURL = "https://api.themoviedb.org/3"

    /// TMDB image base URL for poster/backdrop
    static let imageBaseURL = "https://image.tmdb.org/t/p"

    /// Default language for API responses
    static let defaultLanguage = "en-US"
}

// MARK: - Image Size Helpers

/// Poster image sizes available from TMDB
enum TMDBPosterSize: String {
    case small = "w185"
    case medium = "w342"
    case large = "w500"
    case original = "original"

    var url: String {
        "\(TMDBConfig.imageBaseURL)/\(rawValue)"
    }
}

/// Backdrop image sizes available from TMDB
enum TMDBBackdropSize: String {
    case small = "w300"
    case medium = "w780"
    case large = "w1280"
    case original = "original"

    var url: String {
        "\(TMDBConfig.imageBaseURL)/\(rawValue)"
    }
}

// MARK: - Endpoint Definition

/// Type-safe endpoint builder for all TMDB API routes.
/// Each case represents a specific API endpoint with its required parameters.
enum TMDBEndpoint {
    /// GET /genre/movie/list
    case genres

    /// GET /discover/movie?with_genres=\(genreId)&page=\(page)
    case discoverMovies(genreId: Int, page: Int)

    /// GET /movie/\(movieId)
    case movieDetail(movieId: Int)

    /// GET /movie/\(movieId)/reviews?page=\(page)
    case movieReviews(movieId: Int, page: Int)

    /// GET /movie/\(movieId)/videos
    case movieVideos(movieId: Int)

    /// GET /search/movie?query=\(query)&page=\(page)
    case searchMovies(query: String, page: Int)
}

// MARK: - URL Construction

extension TMDBEndpoint {

    /// The path component of the URL (without base URL)
    var path: String {
        switch self {
        case .genres:
            return "/genre/movie/list"
        case .discoverMovies:
            return "/discover/movie"
        case .movieDetail(let movieId):
            return "/movie/\(movieId)"
        case .movieReviews(let movieId, _):
            return "/movie/\(movieId)/reviews"
        case .movieVideos(let movieId):
            return "/movie/\(movieId)/videos"
        case .searchMovies:
            return "/search/movie"
        }
    }

    /// Query parameters specific to this endpoint (excluding api_key and language)
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        switch self {
        case .genres:
            break
        case .discoverMovies(let genreId, let page):
            items.append(URLQueryItem(name: "with_genres", value: "\(genreId)"))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "sort_by", value: "popularity.desc"))
        case .movieDetail:
            break
        case .movieReviews(_, let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        case .movieVideos:
            break
        case .searchMovies(let query, let page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        }

        return items
    }

    /// HTTP method for this endpoint (all TMDB read endpoints are GET)
    var httpMethod: String {
        return "GET"
    }

    /// Constructs the full `URLRequest` for this endpoint.
    /// - Throws: `TMDBError.invalidURL` if URL construction fails.
    /// - Returns: A configured `URLRequest` ready to be executed.
    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(string: TMDBConfig.baseURL + path) else {
            throw TMDBError.invalidURL
        }

        // Common query parameters applied to all endpoints
        var allQueryItems: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: TMDBConfig.apiKey),
            URLQueryItem(name: "language", value: TMDBConfig.defaultLanguage),
        ]

        // Append endpoint-specific query items
        allQueryItems.append(contentsOf: queryItems)
        components.queryItems = allQueryItems

        guard let url = components.url else {
            throw TMDBError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        return request
    }
}

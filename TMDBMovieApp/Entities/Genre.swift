//
//  Genre.swift
//  TMDBMovieApp
//
//  Entity models for TMDB Genre API responses.
//

import Foundation

// MARK: - Genre Response

/// Root response for GET /genre/movie/list
struct GenreResponse: Decodable, Sendable {
    let genres: [Genre]
}

// MARK: - Genre

/// Represents a single movie genre from TMDB.
struct Genre: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
}

// MARK: - Mock Data (for Previews & Testing)

#if DEBUG
extension Genre {
    static let mockAction = Genre(id: 28, name: "Action")
    static let mockComedy = Genre(id: 35, name: "Comedy")
    static let mockDrama = Genre(id: 18, name: "Drama")
    static let mockHorror = Genre(id: 27, name: "Horror")
    static let mockSciFi = Genre(id: 878, name: "Science Fiction")

    static let mockList: [Genre] = [
        .mockAction, .mockComedy, .mockDrama, .mockHorror, .mockSciFi,
    ]
}

extension GenreResponse {
    static let mock = GenreResponse(genres: Genre.mockList)
}
#endif

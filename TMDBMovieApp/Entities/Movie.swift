//
//  Movie.swift
//  TMDBMovieApp
//
//  Entity models for TMDB Movie API responses, including pagination metadata.
//

import Foundation

// MARK: - Movie Response (Paginated)

/// Paginated response wrapper for movie lists.
/// Used by discover, search, and similar list endpoints.
nonisolated struct MovieResponse: Decodable, Sendable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int

    /// Whether there are more pages to load
    var hasNextPage: Bool {
        page < totalPages
    }

    /// The next page number, if available
    var nextPage: Int? {
        hasNextPage ? page + 1 : nil
    }
}

// MARK: - Movie

/// Represents a single movie from TMDB.
/// Used in both list (discover) and detail contexts.
nonisolated struct Movie: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let genreIds: [Int]?       // Present in list responses
    let genres: [Genre]?        // Present in detail responses
    let runtime: Int?           // Only in detail response
    let status: String?         // Only in detail response
    let tagline: String?        // Only in detail response
    let budget: Int?            // Only in detail response
    let revenue: Int?           // Only in detail response
    let adult: Bool?

    // MARK: - Computed Properties

    /// Full URL for the poster image
    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "\(TMDBPosterSize.medium.url)\(posterPath)")
    }

    /// Full URL for the backdrop image
    var backdropURL: URL? {
        guard let backdropPath else { return nil }
        return URL(string: "\(TMDBBackdropSize.large.url)\(backdropPath)")
    }

    /// Formatted release year (e.g., "2024")
    var releaseYear: String {
        guard let releaseDate, releaseDate.count >= 4 else { return "N/A" }
        return String(releaseDate.prefix(4))
    }

    /// Formatted vote average to one decimal (e.g., "7.8")
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }

    /// Runtime formatted as "2h 15m"
    var formattedRuntime: String? {
        guard let runtime, runtime > 0 else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    /// Genre names from detail response
    var genreNames: [String] {
        genres?.map(\.name) ?? []
    }
}

// MARK: - Mock Data (for Previews & Testing)

#if DEBUG
extension Movie {
    static let mock = Movie(
        id: 550,
        title: "Fight Club",
        originalTitle: "Fight Club",
        overview: "A ticking-Loss narrator recounts his experiences in an underground fight club. An insomniac office worker and a devil-may-care soap maker form an underground fight club that evolves into much more.",
        posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        backdropPath: "/hZkgoQYus5dXo3H8T7Uef6DNknx.jpg",
        releaseDate: "1999-10-15",
        voteAverage: 8.4,
        voteCount: 26_000,
        popularity: 61.4,
        genreIds: [18, 53, 35],
        genres: [Genre.mockDrama, Genre.mockAction],
        runtime: 139,
        status: "Released",
        tagline: "Mischief. Mayhem. Soap.",
        budget: 63_000_000,
        revenue: 101_209_702,
        adult: false
    )

    static let mockList: [Movie] = [
        .mock,
        Movie(
            id: 680,
            title: "Pulp Fiction",
            originalTitle: "Pulp Fiction",
            overview: "The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption.",
            posterPath: "/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg",
            backdropPath: nil,
            releaseDate: "1994-09-10",
            voteAverage: 8.5,
            voteCount: 24_000,
            popularity: 55.2,
            genreIds: [53, 80],
            genres: nil,
            runtime: 154,
            status: "Released",
            tagline: "Just because you are a character doesn't mean you have character.",
            budget: 8_000_000,
            revenue: 213_928_762,
            adult: false
        ),
    ]
}

extension MovieResponse {
    static let mock = MovieResponse(
        page: 1,
        results: Movie.mockList,
        totalPages: 5,
        totalResults: 100
    )
}
#endif

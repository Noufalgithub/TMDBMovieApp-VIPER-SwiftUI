//
//  Review.swift
//  TMDBMovieApp
//
//  Entity models for TMDB Movie Review API responses.
//

import Foundation

// MARK: - Review Response (Paginated)

/// Paginated response for movie reviews.
nonisolated struct ReviewResponse: Decodable, Sendable {
    let id: Int
    let page: Int
    let results: [Review]
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

// MARK: - Review

/// Represents a single user review from TMDB.
nonisolated struct Review: Decodable, Identifiable, Hashable, Sendable {
    let id: String
    let author: String
    let authorDetails: AuthorDetails?
    let content: String
    let createdAt: String?
    let updatedAt: String?
    let url: String?

    // MARK: - Computed Properties

    /// Author's avatar full URL (handles both TMDB-hosted and Gravatar URLs)
    var avatarURL: URL? {
        guard let avatarPath = authorDetails?.avatarPath else { return nil }

        // TMDB sometimes returns full URLs with leading slash (e.g., "/https://...")
        if avatarPath.contains("https://") || avatarPath.contains("http://") {
            let cleaned = avatarPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            return URL(string: cleaned)
        }

        return URL(string: "\(TMDBPosterSize.small.url)\(avatarPath)")
    }

    /// Formatted rating display (e.g., "8.0/10" or nil)
    var formattedRating: String? {
        guard let rating = authorDetails?.rating else { return nil }
        return String(format: "%.1f/10", rating)
    }

    /// Truncated content for preview display
    func contentPreview(maxLength: Int = 200) -> String {
        if content.count <= maxLength { return content }
        let index = content.index(content.startIndex, offsetBy: maxLength)
        return String(content[..<index]) + "..."
    }
}

// MARK: - Author Details

/// Details of a review author from TMDB.
nonisolated struct AuthorDetails: Decodable, Hashable, Sendable {
    let name: String?
    let username: String?
    let avatarPath: String?
    let rating: Double?

    /// Display name — prefers `name`, falls back to `username`
    var displayName: String {
        if let name, !name.isEmpty { return name }
        if let username, !username.isEmpty { return username }
        return "Anonymous"
    }
}

// MARK: - Mock Data (for Previews & Testing)

#if DEBUG
extension Review {
    static let mock = Review(
        id: "review_001",
        author: "MovieBuff42",
        authorDetails: AuthorDetails(
            name: "MovieBuff42",
            username: "moviebuff42",
            avatarPath: "/abc123.jpg",
            rating: 8.5
        ),
        content: "An absolute masterpiece of modern cinema. The direction is superb, the performances are career-defining, and the storyline keeps you engaged from start to finish. Highly recommended for anyone who appreciates quality filmmaking.",
        createdAt: "2024-01-15T10:30:00.000Z",
        updatedAt: "2024-01-15T10:30:00.000Z",
        url: "https://www.themoviedb.org/review/review_001"
    )

    static let mockList: [Review] = [
        .mock,
        Review(
            id: "review_002",
            author: "CinemaLover",
            authorDetails: AuthorDetails(
                name: "Cinema Lover",
                username: "cinemalover",
                avatarPath: nil,
                rating: 7.0
            ),
            content: "A solid film with great visuals and a compelling narrative. While it may not reinvent the genre, it delivers a thoroughly entertaining experience. The supporting cast brings unexpected depth to the story.",
            createdAt: "2024-02-20T14:45:00.000Z",
            updatedAt: nil,
            url: nil
        ),
    ]
}

extension ReviewResponse {
    static let mock = ReviewResponse(
        id: 550,
        page: 1,
        results: Review.mockList,
        totalPages: 3,
        totalResults: 45
    )
}
#endif

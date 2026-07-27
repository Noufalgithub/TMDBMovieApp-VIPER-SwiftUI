//
//  Video.swift
//  TMDBMovieApp
//
//  Entity models for TMDB Movie Video API responses (trailers, teasers, etc.)
//

import Foundation

// MARK: - Video Response

/// Response for GET /movie/{id}/videos
nonisolated struct VideoResponse: Decodable, Sendable {
    let id: Int
    let results: [Video]

    /// Returns the first official YouTube trailer, falling back to any YouTube video.
    var officialTrailer: Video? {
        // Priority: Official Trailer > Official Teaser > Any YouTube video
        results.first(where: { $0.isOfficialTrailer })
            ?? results.first(where: { $0.site == "YouTube" && $0.type == "Teaser" && $0.official == true })
            ?? results.first(where: { $0.isYouTube })
    }

    /// All YouTube videos sorted by official status
    var youTubeVideos: [Video] {
        results
            .filter { $0.isYouTube }
            .sorted { ($0.official ?? false) && !($1.official ?? false) }
    }
}

// MARK: - Video

/// Represents a video (trailer, teaser, featurette) for a movie.
nonisolated struct Video: Decodable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let key: String         // YouTube video ID or Vimeo ID
    let site: String        // "YouTube" or "Vimeo"
    let size: Int?          // Video quality: 360, 480, 720, 1080
    let type: String        // "Trailer", "Teaser", "Featurette", "Behind the Scenes", "Clip"
    let official: Bool?
    let publishedAt: String?
    let iso6391: String?    // Language code (mapped from iso_639_1)
    let iso31661: String?   // Country code (mapped from iso_3166_1)

    // MARK: - Computed Properties

    /// Whether this is a YouTube video
    var isYouTube: Bool {
        site == "YouTube"
    }

    /// Whether this is an official trailer
    var isOfficialTrailer: Bool {
        isYouTube && type == "Trailer" && (official ?? false)
    }

    /// YouTube thumbnail URL
    var thumbnailURL: URL? {
        guard isYouTube else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(key)/hqdefault.jpg")
    }

    /// YouTube watch URL (for opening in browser/app)
    var youTubeURL: URL? {
        guard isYouTube else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }

    /// YouTube embed URL (for in-app WebView playback)
    var youTubeEmbedURL: URL? {
        guard isYouTube else { return nil }
        return URL(string: "https://www.youtube.com/embed/\(key)?autoplay=1&playsinline=1")
    }
}

// MARK: - CodingKeys

extension Video {
    enum CodingKeys: String, CodingKey {
        case id, name, key, site, size, type, official
        case publishedAt
        case iso6391 = "iso6391"
        case iso31661 = "iso31661"
    }
}

// MARK: - Mock Data (for Previews & Testing)

#if DEBUG
extension Video {
    static let mockTrailer = Video(
        id: "video_001",
        name: "Official Trailer",
        key: "dQw4w9WgXcQ",
        site: "YouTube",
        size: 1080,
        type: "Trailer",
        official: true,
        publishedAt: "2024-01-10T12:00:00.000Z",
        iso6391: "en",
        iso31661: "US"
    )

    static let mockTeaser = Video(
        id: "video_002",
        name: "Official Teaser",
        key: "abc123def456",
        site: "YouTube",
        size: 1080,
        type: "Teaser",
        official: true,
        publishedAt: "2023-12-01T08:00:00.000Z",
        iso6391: "en",
        iso31661: "US"
    )

    static let mockList: [Video] = [.mockTrailer, .mockTeaser]
}

extension VideoResponse {
    static let mock = VideoResponse(id: 550, results: Video.mockList)
}
#endif

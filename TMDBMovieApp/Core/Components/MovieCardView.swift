//
//  MovieCardView.swift
//  TMDBMovieApp
//
//  Reusable movie poster card for grid/list display.
//

import SwiftUI

/// Displays a movie poster card with title, year, and rating badge.
/// Used in movie grid layouts across modules.
struct MovieCardView: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Poster Image
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .empty:
                    posterPlaceholder
                        .overlay { ProgressView() }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    posterPlaceholder
                        .overlay {
                            Image(systemName: "film")
                                .font(.largeTitle)
                                .foregroundStyle(.tertiary)
                        }
                @unknown default:
                    posterPlaceholder
                }
            }
            .aspectRatio(2/3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .topTrailing) {
                ratingBadge
            }
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            // MARK: - Title
            Text(movie.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .foregroundStyle(.primary)

            // MARK: - Release Year
            Text(movie.releaseYear)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Subviews

    private var posterPlaceholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
    }

    private var ratingBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.caption2)
            Text(movie.formattedRating)
                .font(.caption)
                .fontWeight(.bold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.black.opacity(0.7), in: Capsule())
        .padding(8)
    }
}

#Preview {
    MovieCardView(movie: .mock)
        .frame(width: 180)
        .padding()
}

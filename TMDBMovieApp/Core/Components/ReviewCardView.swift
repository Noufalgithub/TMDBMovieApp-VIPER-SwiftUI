//
//  ReviewCardView.swift
//  TMDBMovieApp
//
//  Reusable card for displaying a single movie review.
//

import SwiftUI

/// Displays a user review with author info, avatar, rating, and content.
struct ReviewCardView: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Avatar, Name, Rating
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                AsyncImage(url: review.avatarURL) { phase in
                    switch phase {
                    case .empty:
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 40, height: 40)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    case .failure:
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }

                // Name & Rating
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.authorDetails?.displayName ?? review.author)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if let rating = review.formattedRating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text(rating)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.black.opacity(0.8), in: Capsule())
                    }
                }
                Spacer()
            }

            // Review Content
            Text(review.content)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#if DEBUG
#Preview {
    ScrollView {
        ReviewCardView(review: .mock)
            .padding()
    }
}
#endif

//
//  EmptyStateView.swift
//  TMDBMovieApp
//
//  Reusable empty state view with customizable icon and message.
//

import SwiftUI

/// Displays an empty state with icon, title, and subtitle.
/// Used when API returns valid but empty data.
struct EmptyStateView: View {
    var systemImage: String = "film.stack"
    var title: String = "No Results"
    var message: String = "Nothing to show here."

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        systemImage: "film",
        title: "No Movies Found",
        message: "No movies available for this genre."
    )
}

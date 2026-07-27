//
//  LoadingView.swift
//  TMDBMovieApp
//
//  Reusable loading indicator view with an optional message.
//

import SwiftUI

/// Centered loading indicator with customizable message.
/// Used across modules for consistent loading states.
struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}

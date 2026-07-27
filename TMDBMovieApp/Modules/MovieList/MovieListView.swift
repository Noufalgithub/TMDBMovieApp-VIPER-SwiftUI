//
//  MovieListView.swift
//  TMDBMovieApp
//
//  View layer for MovieList module. Displays grid of movies with endless scrolling.
//

import SwiftUI

struct MovieListView: View {
    @StateObject private var presenter: MovieListPresenter

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    init(presenter: MovieListPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    var body: some View {
        Group {
            if presenter.isLoading && presenter.movies.isEmpty {
                LoadingView(message: "Loading movies...")
            } else if let error = presenter.errorMessage, presenter.movies.isEmpty {
                ErrorStateView(message: error, retryAction: presenter.retry)
            } else if presenter.movies.isEmpty {
                EmptyStateView(
                    systemImage: "film",
                    title: "No Movies",
                    message: "No movies found for \(presenter.genreName)."
                )
            } else {
                movieGrid
            }
        }
        .navigationTitle(presenter.genreName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if presenter.movies.isEmpty {
                await presenter.fetchMovies()
            }
        }
    }

    private var movieGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(presenter.movies) { movie in
                    NavigationLink(destination: MovieListRouter.makeMovieDetailView(for: movie)) {
                        MovieCardView(movie: movie)
                    }
                    .buttonStyle(.plain)
                }

                // Endless scrolling trigger
                if presenter.hasMorePages {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .task {
                            await presenter.fetchNextPage()
                        }
                }
            }
            .padding()
        }
        .refreshable {
            await presenter.fetchMovies()
        }
    }
}

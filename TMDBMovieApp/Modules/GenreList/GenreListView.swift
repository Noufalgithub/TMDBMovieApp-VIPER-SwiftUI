//
//  GenreListView.swift
//  TMDBMovieApp
//
//  View layer for GenreList module.
//

import SwiftUI

/// View displaying a list of movie genres.
struct GenreListView: View {
    @StateObject private var presenter: GenreListPresenter

    // Inject Presenter
    init(presenter: GenreListPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    var body: some View {
        NavigationView {
            Group {
                if presenter.isLoading && presenter.genres.isEmpty {
                    LoadingView(message: "Loading genres...")
                } else if let error = presenter.errorMessage, presenter.genres.isEmpty {
                    ErrorStateView(message: error, retryAction: presenter.retry)
                } else if presenter.genres.isEmpty {
                    EmptyStateView(
                        systemImage: "list.dash",
                        title: "No Genres",
                        message: "Could not find any movie genres."
                    )
                } else {
                    genreList
                }
            }
            .navigationTitle("Discover")
            .task {
                if presenter.genres.isEmpty {
                    await presenter.fetchGenres()
                }
            }
        }
    }

    private var genreList: some View {
        List(presenter.genres) { genre in
            // Temporary NavigationLink until MovieList is ready
            NavigationLink(destination: GenreListRouter.makeMovieListView(for: genre)) {
                HStack {
                    Text(genre.name)
                        .font(.headline)
                        .padding(.vertical, 8)
                    Spacer()
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await presenter.fetchGenres()
        }
    }
}

#Preview {
    let interactor = GenreListInteractor()
    let presenter = GenreListPresenter(interactor: interactor)
    return GenreListView(presenter: presenter)
}

//
//  GenreListPresenter.swift
//  TMDBMovieApp
//
//  Mediates between the GenreList View and Interactor.
//  Manages UI state and coordinates data flow.
//

import Foundation

/// GenreList Presenter — acts as the middleman between View and Interactor.
/// Holds all UI state as `@Published` properties observed by the View.
@MainActor
final class GenreListPresenter: ObservableObject, GenreListPresenterProtocol {

    // MARK: - Published Properties (View State)

    @Published private(set) var genres: [Genre] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let interactor: GenreListInteractorInput

    // MARK: - Init

    init(interactor: GenreListInteractorInput) {
        self.interactor = interactor
    }

    // MARK: - GenreListPresenterProtocol

    /// Fetches genres from the Interactor and updates published state.
    func fetchGenres() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            genres = try await interactor.fetchGenres()
        } catch let error as TMDBError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Retries genre fetch — called from ErrorStateView's retry button.
    func retry() {
        Task {
            await fetchGenres()
        }
    }
}

//
//  GenreListContracts.swift
//  TMDBMovieApp
//
//  VIPER contracts for the GenreList module.
//  Defines the communication boundaries between each VIPER layer.
//

import Foundation

// MARK: - GenreList VIPER Contracts
//
// Data Flow:
//   View → (user action) → Presenter → (data request) → Interactor
//   Interactor → (data response via async/await) → Presenter → (@Published) → View
//   View → (navigation) → Router (view factory)
//
// In SwiftUI, the View observes the Presenter directly via @StateObject,
// so a formal View protocol is not required.

// MARK: - View → Presenter

/// Defines what the View can ask the Presenter to do.
@MainActor
protocol GenreListPresenterProtocol: ObservableObject {
    var genres: [Genre] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    /// Fetches all movie genres from the API.
    func fetchGenres() async

    /// Retries the last failed fetch operation.
    func retry()
}

// MARK: - Presenter → Interactor

/// Defines the data operations the Interactor provides to the Presenter.
protocol GenreListInteractorInput {
    /// Fetches genre list from the TMDB API.
    /// - Returns: Array of `Genre` entities.
    /// - Throws: `TMDBError` on failure.
    func fetchGenres() async throws -> [Genre]
}

// MARK: - Router

/// Defines module assembly and navigation view creation.
@MainActor
protocol GenreListRouterProtocol {
    /// Creates and assembles the GenreList VIPER module.
    static func createModule() -> GenreListView
}

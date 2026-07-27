//
//  MovieListContracts.swift
//  TMDBMovieApp
//
//  VIPER contracts for the MovieList module.
//

import Foundation

// MARK: - View → Presenter

@MainActor
protocol MovieListPresenterProtocol: ObservableObject {
    var movies: [Movie] { get }
    var isLoading: Bool { get }
    var isFetchingNextPage: Bool { get }
    var errorMessage: String? { get }
    var hasMorePages: Bool { get }
    var genreName: String { get }

    func fetchMovies() async
    func fetchNextPage() async
    func retry()
}

// MARK: - Presenter → Interactor

protocol MovieListInteractorInput {
    func fetchMovies(genreId: Int, page: Int) async throws -> MovieResponse
}

// MARK: - Router

@MainActor
protocol MovieListRouterProtocol {
    static func createModule(for genre: Genre) -> MovieListView
}

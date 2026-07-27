//
//  GenreListInteractor.swift
//  TMDBMovieApp
//
//  Handles data fetching for the GenreList module.
//

import Foundation

/// GenreList Interactor — responsible for fetching genre data
/// from the TMDB API via the NetworkService.
final class GenreListInteractor: GenreListInteractorInput {

    // MARK: - Dependencies

    private let networkService: NetworkServiceProtocol

    // MARK: - Init

    /// - Parameter networkService: Injectable network service (defaults to `NetworkService`).
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    // MARK: - GenreListInteractorInput

    func fetchGenres() async throws -> [Genre] {
        let response: GenreResponse = try await networkService.request(.genres)
        return response.genres
    }
}

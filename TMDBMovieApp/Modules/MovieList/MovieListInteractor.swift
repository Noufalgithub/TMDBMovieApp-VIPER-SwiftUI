//
//  MovieListInteractor.swift
//  TMDBMovieApp
//
//  Handles data fetching for the MovieList module.
//

import Foundation

final class MovieListInteractor: MovieListInteractorInput {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchMovies(genreId: Int, page: Int) async throws -> MovieResponse {
        return try await networkService.request(.discoverMovies(genreId: genreId, page: page))
    }
}

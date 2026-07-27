//
//  MovieDetailInteractor.swift
//  TMDBMovieApp
//
//  Handles data fetching for the MovieDetail module.
//

import Foundation

final class MovieDetailInteractor: MovieDetailInteractorInput {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchMovieDetail(id: Int) async throws -> Movie {
        return try await networkService.request(.movieDetail(movieId: id))
    }
    
    func fetchMovieVideos(id: Int) async throws -> VideoResponse {
        return try await networkService.request(.movieVideos(movieId: id))
    }
    
    func fetchMovieReviews(id: Int, page: Int) async throws -> ReviewResponse {
        return try await networkService.request(.movieReviews(movieId: id, page: page))
    }
}

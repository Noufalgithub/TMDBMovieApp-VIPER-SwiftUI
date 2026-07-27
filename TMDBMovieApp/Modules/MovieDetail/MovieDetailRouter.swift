//
//  MovieDetailRouter.swift
//  TMDBMovieApp
//
//  Router for the MovieDetail module.
//

import SwiftUI

@MainActor
final class MovieDetailRouter: MovieDetailRouterProtocol {

    static func createModule(for movieId: Int) -> MovieDetailView {
        let interactor = MovieDetailInteractor()
        let presenter = MovieDetailPresenter(movieId: movieId, interactor: interactor)
        return MovieDetailView(presenter: presenter)
    }
}

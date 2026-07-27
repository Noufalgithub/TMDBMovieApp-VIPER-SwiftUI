//
//  MovieListRouter.swift
//  TMDBMovieApp
//
//  Router for the MovieList module.
//

import SwiftUI

@MainActor
final class MovieListRouter: MovieListRouterProtocol {

    static func createModule(for genre: Genre) -> MovieListView {
        let interactor = MovieListInteractor()
        let presenter = MovieListPresenter(genre: genre, interactor: interactor)
        return MovieListView(presenter: presenter)
    }
    
    static func makeMovieDetailView(for movie: Movie) -> some View {
        // To be implemented in Phase 3
        Text("Movie Detail for \(movie.title)")
    }
}

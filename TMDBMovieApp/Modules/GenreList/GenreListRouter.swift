//
//  GenreListRouter.swift
//  TMDBMovieApp
//
//  Handles assembly and navigation for the GenreList module.
//

import SwiftUI

/// Router for the GenreList module.
@MainActor
final class GenreListRouter: GenreListRouterProtocol {

    /// Assembles the VIPER components for GenreList.
    static func createModule() -> GenreListView {
        let interactor = GenreListInteractor()
        let presenter = GenreListPresenter(interactor: interactor)
        return GenreListView(presenter: presenter)
    }

    /// Navigation destination builder.
    /// In SwiftUI, the router often provides Views directly to `NavigationLink`.
    static func makeMovieListView(for genre: Genre) -> some View {
        return MovieListRouter.createModule(for: genre)
    }
}

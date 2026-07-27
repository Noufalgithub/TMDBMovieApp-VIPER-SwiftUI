//
//  MovieListPresenter.swift
//  TMDBMovieApp
//
//  Presenter for the MovieList module. Handles pagination state.
//

import Foundation

@MainActor
final class MovieListPresenter: ObservableObject, MovieListPresenterProtocol {

    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isFetchingNextPage = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasMorePages = true

    let genreName: String
    private let genreId: Int
    private var currentPage = 1

    private let interactor: MovieListInteractorInput

    init(genre: Genre, interactor: MovieListInteractorInput) {
        self.genreName = genre.name
        self.genreId = genre.id
        self.interactor = interactor
    }

    func fetchMovies() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        do {
            let response = try await interactor.fetchMovies(genreId: genreId, page: currentPage)
            movies = response.results
            hasMorePages = response.hasNextPage
        } catch let error as TMDBError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }

    func fetchNextPage() async {
        guard !isFetchingNextPage && hasMorePages && !isLoading else { return }
        
        isFetchingNextPage = true
        let nextPage = currentPage + 1
        
        do {
            let response = try await interactor.fetchMovies(genreId: genreId, page: nextPage)
            movies.append(contentsOf: response.results)
            currentPage = nextPage
            hasMorePages = response.hasNextPage
        } catch {
            // Silently fail or show a toast for pagination errors
            print("Failed to fetch next page: \(error)")
        }
        
        isFetchingNextPage = false
    }

    func retry() {
        Task {
            await fetchMovies()
        }
    }
}

//
//  MovieDetailContracts.swift
//  TMDBMovieApp
//
//  VIPER contracts for the MovieDetail module.
//

import Foundation

// MARK: - View → Presenter

@MainActor
protocol MovieDetailPresenterProtocol: ObservableObject {
    var movie: Movie? { get }
    var reviews: [Review] { get }
    var officialTrailer: Video? { get }
    
    // States
    var isLoadingDetail: Bool { get }
    var detailErrorMessage: String? { get }
    
    var isLoadingReviews: Bool { get }
    var isFetchingNextReviewPage: Bool { get }
    var reviewErrorMessage: String? { get }
    var hasMoreReviews: Bool { get }

    // Actions
    func fetchMovieDetail() async
    func fetchNextReviewPage() async
    func retryDetail()
    func retryReviews()
}

// MARK: - Presenter → Interactor

protocol MovieDetailInteractorInput {
    func fetchMovieDetail(id: Int) async throws -> Movie
    func fetchMovieVideos(id: Int) async throws -> VideoResponse
    func fetchMovieReviews(id: Int, page: Int) async throws -> ReviewResponse
}

// MARK: - Router

@MainActor
protocol MovieDetailRouterProtocol {
    static func createModule(for movieId: Int) -> MovieDetailView
}

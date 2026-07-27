//
//  MovieDetailPresenter.swift
//  TMDBMovieApp
//
//  Presenter for the MovieDetail module.
//  Coordinates fetching detail, trailer, and paginated reviews.
//

import Foundation
import Combine

@MainActor
final class MovieDetailPresenter: ObservableObject, MovieDetailPresenterProtocol {

    // MARK: - Detail State
    @Published private(set) var movie: Movie?
    @Published private(set) var officialTrailer: Video?
    @Published private(set) var isLoadingDetail = false
    @Published private(set) var detailErrorMessage: String?

    // MARK: - Reviews State
    @Published private(set) var reviews: [Review] = []
    @Published private(set) var isLoadingReviews = false
    @Published private(set) var isFetchingNextReviewPage = false
    @Published private(set) var reviewErrorMessage: String?
    @Published private(set) var hasMoreReviews = true

    private let movieId: Int
    private var currentReviewPage = 1

    private let interactor: MovieDetailInteractorInput

    // MARK: - Init

    init(movieId: Int, interactor: MovieDetailInteractorInput) {
        self.movieId = movieId
        self.interactor = interactor
    }

    // MARK: - Detail Operations

    func fetchMovieDetail() async {
        guard !isLoadingDetail else { return }
        
        isLoadingDetail = true
        detailErrorMessage = nil
        
        async let detailTask = try? interactor.fetchMovieDetail(id: movieId)
        async let videoTask = try? interactor.fetchMovieVideos(id: movieId)
        
        let (detailResult, videoResult) = await (detailTask, videoTask)
        
        if let detail = detailResult {
            self.movie = detail
            self.officialTrailer = videoResult?.officialTrailer
        } else {
            self.detailErrorMessage = "Failed to load movie details."
        }
        
        isLoadingDetail = false
        
        // After loading detail, start fetching first page of reviews
        await fetchInitialReviews()
    }
    
    func retryDetail() {
        Task {
            await fetchMovieDetail()
        }
    }

    // MARK: - Reviews Operations

    private func fetchInitialReviews() async {
        guard !isLoadingReviews else { return }
        
        isLoadingReviews = true
        reviewErrorMessage = nil
        currentReviewPage = 1
        
        do {
            let response = try await interactor.fetchMovieReviews(id: movieId, page: currentReviewPage)
            self.reviews = response.results
            self.hasMoreReviews = response.hasNextPage
        } catch {
            self.reviewErrorMessage = "Failed to load reviews."
        }
        
        isLoadingReviews = false
    }

    func fetchNextReviewPage() async {
        guard !isFetchingNextReviewPage && hasMoreReviews && !isLoadingReviews else { return }
        
        isFetchingNextReviewPage = true
        let nextPage = currentReviewPage + 1
        
        do {
            let response = try await interactor.fetchMovieReviews(id: movieId, page: nextPage)
            self.reviews.append(contentsOf: response.results)
            self.currentReviewPage = nextPage
            self.hasMoreReviews = response.hasNextPage
        } catch {
            print("Failed to fetch next review page: \(error)")
        }
        
        isFetchingNextReviewPage = false
    }
    
    func retryReviews() {
        Task {
            await fetchInitialReviews()
        }
    }
}

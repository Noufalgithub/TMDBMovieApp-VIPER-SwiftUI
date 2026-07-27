//
//  MovieListPresenterTests.swift
//  TMDBMovieAppTests
//
//  Tests for the MovieListPresenter validating state changes (loading, success, error, pagination).
//

import XCTest
@testable import TMDBMovieApp

@MainActor
final class MovieListPresenterTests: XCTestCase {

    var sut: MovieListPresenter!
    var mockInteractor: MockMovieListInteractor!
    let mockGenre = Genre(id: 28, name: "Action")

    override func setUp() {
        super.setUp()
        mockInteractor = MockMovieListInteractor()
        sut = MovieListPresenter(genre: mockGenre, interactor: mockInteractor)
    }

    override func tearDown() {
        sut = nil
        mockInteractor = nil
        super.tearDown()
    }

    // MARK: - Initial Fetch Tests

    func testFetchMovies_Success() async {
        // Given
        let mockResponse = MovieResponse(page: 1, results: [.mock], totalPages: 2, totalResults: 2)
        mockInteractor.mockResult = .success(mockResponse)

        XCTAssertTrue(sut.movies.isEmpty, "Initial state should be empty")
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")

        // When
        await sut.fetchMovies()

        // Then
        XCTAssertFalse(sut.isLoading, "Loading should be false after fetch")
        XCTAssertEqual(sut.movies.count, 1)
        XCTAssertNil(sut.errorMessage)
        XCTAssertTrue(sut.hasMorePages, "Should have more pages because totalPages is 2")
    }

    func testFetchMovies_Failure() async {
        // Given
        mockInteractor.mockResult = .failure(TMDBError.invalidResponse)

        // When
        await sut.fetchMovies()

        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.movies.isEmpty)
        XCTAssertEqual(sut.errorMessage, TMDBError.invalidResponse.errorDescription)
    }

    // MARK: - Pagination Tests

    func testFetchNextPage_Success_AppendsData() async {
        // Given: Already have page 1
        let firstPageResponse = MovieResponse(page: 1, results: [.mock], totalPages: 2, totalResults: 2)
        mockInteractor.mockResult = .success(firstPageResponse)
        await sut.fetchMovies()
        
        // Mock Page 2 response
        let secondPageResponse = MovieResponse(page: 2, results: [.mock], totalPages: 2, totalResults: 2)
        mockInteractor.mockResult = .success(secondPageResponse)

        // When
        await sut.fetchNextPage()

        // Then
        XCTAssertFalse(sut.isFetchingNextPage)
        XCTAssertEqual(sut.movies.count, 2, "Movies should be appended")
        XCTAssertFalse(sut.hasMorePages, "hasMorePages should be false since we reached totalPages = 2")
    }

    func testFetchNextPage_DoesNotTrigger_WhenNoMorePages() async {
        // Given: Page 1, but it's the ONLY page
        let firstPageResponse = MovieResponse(page: 1, results: [.mock], totalPages: 1, totalResults: 1)
        mockInteractor.mockResult = .success(firstPageResponse)
        await sut.fetchMovies()

        // When
        await sut.fetchNextPage() // This shouldn't do anything because hasMorePages = false

        // Then
        XCTAssertEqual(sut.movies.count, 1, "Movies count should not change")
    }
}

// MARK: - Mock Interactor
final class MockMovieListInteractor: MovieListInteractorInput {
    var mockResult: Result<MovieResponse, Error>?

    func fetchMovies(genreId: Int, page: Int) async throws -> MovieResponse {
        guard let result = mockResult else {
            fatalError("mockResult not set")
        }
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}

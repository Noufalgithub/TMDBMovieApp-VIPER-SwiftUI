//
//  MovieListInteractorTests.swift
//  TMDBMovieAppTests
//
//  Tests for the MovieListInteractor using a mocked NetworkService.
//

import XCTest
@testable import TMDBMovieApp

final class MovieListInteractorTests: XCTestCase {

    var sut: MovieListInteractor! // System Under Test
    var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = MovieListInteractor(networkService: mockNetworkService)
    }

    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }

    func testFetchMovies_Success() async throws {
        // Given
        let expectedGenreId = 28 // Action
        let expectedPage = 1
        let mockResponse = MovieResponse(
            page: 1,
            results: [.mock, .mock], // Mock array
            totalPages: 5,
            totalResults: 100
        )
        mockNetworkService.mockResult = .success(mockResponse)

        // When
        let response = try await sut.fetchMovies(genreId: expectedGenreId, page: expectedPage)

        // Then
        XCTAssertEqual(response.results.count, 2)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 5)
        
        // Verify endpoint constructed correctly
        if case .discoverMovies(let genreId, let page) = mockNetworkService.requestedEndpoint {
            XCTAssertEqual(genreId, expectedGenreId)
            XCTAssertEqual(page, expectedPage)
        } else {
            XCTFail("Endpoint should be .discoverMovies")
        }
    }

    func testFetchMovies_Failure() async {
        // Given
        mockNetworkService.mockResult = .failure(.networkError)

        // When & Then
        do {
            _ = try await sut.fetchMovies(genreId: 28, page: 1)
            XCTFail("Expected fetchMovies to throw an error, but it succeeded.")
        } catch let error as TMDBError {
            XCTAssertEqual(error, .networkError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

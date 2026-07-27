//
//  MockNetworkService.swift
//  TMDBMovieAppTests
//
//  A mock implementation of NetworkServiceProtocol for Unit Testing.
//

import Foundation
@testable import TMDBMovieApp

final class MockNetworkService: NetworkServiceProtocol {
    
    /// The result that will be returned when `request` is called.
    var mockResult: Result<Any, TMDBError>?
    
    /// Tracks which endpoint was requested.
    private(set) var requestedEndpoint: TMDBEndpoint?

    func request<T: Decodable>(_ endpoint: TMDBEndpoint) async throws -> T {
        self.requestedEndpoint = endpoint
        
        guard let result = mockResult else {
            fatalError("mockResult not set in MockNetworkService")
        }
        
        switch result {
        case .success(let data):
            guard let expectedData = data as? T else {
                throw TMDBError.decodingError
            }
            return expectedData
        case .failure(let error):
            throw error
        }
    }
}

//
//  MockURLSession.swift
//  share-api
//
//  Created by Laurent Jacques on 12/02/2025.
//
import Foundation
@testable import share_api

class MockURLSession: NetworkSession,  @unchecked Sendable {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        return (mockData ?? Data(), mockResponse ?? HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
    }
}

//
//  NetworkManagerTests.swift
//  share-api
//
//  Created by Laurent Jacques on 12/02/2025.
//


import XCTest
@testable import share_api

final class NetworkManagerTests: XCTestCase {
    var mockSession: MockURLSession!
    var networkManager: NetworkManager!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        networkManager = NetworkManager(session: mockSession)
    }

    override func tearDown() {
        mockSession = nil
        networkManager = nil
        super.tearDown()
    }

    func testPostUserData_Success() async throws {
        let expectedResponse = "Success"
        let responseData = expectedResponse.data(using: .utf8)
        let httpResponse = HTTPURLResponse(url: URL(string: Constants.serverURL)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        mockSession.mockData = responseData
        mockSession.mockResponse = httpResponse

        let result = try await networkManager.postUserData(data: ShareData(url: "url", name: "Shared Data", status: "Shared" ))
        XCTAssertEqual(result, expectedResponse)
    }

    func testPostUserData_BadResponse() async {
        let httpResponse = HTTPURLResponse(url: URL(string: Constants.serverURL)!, statusCode: 500, httpVersion: nil, headerFields: nil)
        mockSession.mockResponse = httpResponse

        do {
            _ = try await networkManager.postUserData(data: ShareData(url: "url", name: "Shared Data", status: "Shared"))
            XCTFail("Expected to throw an error but succeeded")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, URLError.badServerResponse)
        }
    }

    func testPostUserData_ThrowsError() async {
        mockSession.mockError = URLError(.timedOut)

        do {
            _ = try await networkManager.postUserData(data: ShareData(url: "url", name: "Shared Data", status: "Shared"))
            XCTFail("Expected a timeout error")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, URLError.timedOut)
        }
    }
}

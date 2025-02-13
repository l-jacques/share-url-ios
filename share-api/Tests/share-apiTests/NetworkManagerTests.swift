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
    func testFetchDownloads_Success() async throws {
        // Arrange: Create mock data
        let jsonString = """
            [
                {"ended":"Thu, 13 Feb 2025 10:19:46 GMT","errored":null,"filePath":"/downloads/test1","started":"Thu, 13 Feb 2025 10:19:31 GMT","status":"Downloaded","title":"Test Download"}
            ]
            """
        mockSession.mockData = jsonString.data(using: .utf8)!
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)!
        
        let networkManager = NetworkManager(session: mockSession)
        
        // Act
        let downloads = try await networkManager.fetchDownloads(from: "https://example.com")
        
        // Assert
        XCTAssertEqual(downloads.count, 1)
        XCTAssertEqual(downloads.first?.title, "Test Download")
        XCTAssertEqual(downloads.first?.status, "Downloaded")
    }
    
    func testFetchDownloads_InvalidURL_ThrowsError() async {
        // Arrange: Pass an invalid URL string
        mockSession.mockData = Data()
        mockSession.mockResponse = nil
        let networkManager = NetworkManager(session: mockSession)

        do {
            // Act: Call the method with an invalid URL
            _ = try await networkManager.fetchDownloads(from: "")
            XCTFail("Expected error but got success")  // This line ensures that we fail if no error is thrown
        } catch {
            // Assert: Check if the correct error is thrown
            if let urlError = error as? URLError {
                XCTAssertEqual(urlError.code, .badURL)
            } else {
                XCTFail("Expected URLError but got \(error)")
            }
        }
    }
    
    func testFetchDownloads_ServerError_ThrowsError() async {
        // Arrange: Mock 500 Server Error
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                                   statusCode: 500,
                                                   httpVersion: nil,
                                                   headerFields: nil)!
        
        mockSession.mockData = Data()
        
        let networkManager = NetworkManager(session: mockSession)
        
        do {
            _ = try await networkManager.fetchDownloads(from: "https://example.com")
            XCTFail("Expected error but got success")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .badServerResponse)
        }
    }
    
    func testFetchDownloads_InvalidJSON_ThrowsError() async {
        // Arrange: Invalid JSON
        mockSession.mockData = "invalid json".data(using: .utf8)!
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)!
        
        let networkManager = NetworkManager(session: mockSession)
        
        // Act & Assert
        do {
            _ = try await networkManager.fetchDownloads(from: "https://example.com")
            XCTFail("Expected error but got success")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }
}

//
//  NetworkShareURL.swift
//  share-api
//
//  Created by Laurent Jacques on 13/02/2025.
//


public protocol NetworkShareURL {
    func postUserData(data: ShareData, urlStr: String) async throws -> String
    func sendData(url: String, resolution: String) async throws
}

// Default implementation for backward compatibility
extension NetworkShareURL {
    public func sendData(url: String) async throws {
        try await sendData(url: url, resolution: "medium")
    }
}

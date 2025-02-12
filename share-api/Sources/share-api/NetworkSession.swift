//
//  NetworkSession.swift
//  share-api
//
//  Created by Laurent Jacques on 12/02/2025.
//


import Foundation

public protocol NetworkSession: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession, @unchecked Sendable {}

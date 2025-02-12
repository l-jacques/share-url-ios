//
//  NetworkManager.swift
//  share-api
//
//  Created by Laurent Jacques on 12/02/2025.
//
import Foundation

public struct NetworkManager: Sendable  {
    
    private let session: NetworkSession

    public init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    public func postUserData(data: ShareData) async throws -> String {
        let url = URL(string: Constants.serverURL)!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonData = try JSONEncoder().encode(data)
        request.httpBody = jsonData

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return String(data: data, encoding: .utf8) ?? "Success"
    }
    
    public func sendData(url: String) async throws {
        do {
            try await self.postUserData(data: ShareData(url: url, name: "Shared Data", status: "Shared"))
        } catch {
            throw error
        }
    }
}

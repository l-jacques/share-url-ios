//
//  APIClient.swift
//  share-url
//
//  Created by Laurent Jacques on 10/02/2025.
//


import Foundation

public struct APIClient {
    
    public static func postUserData(data: ShareData) async throws -> String {
        let url = URL(string: Constants.serverURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Set JSON header

        // Convert User model to JSON
        let jsonData = try JSONEncoder().encode(data)
        request.httpBody = jsonData
        
        // Perform network request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return String(data: data, encoding: .utf8) ?? "Success"
    }
    
    public static func sendData(url: String) async throws {
        do {
            try await APIClient.postUserData(data: ShareData(url: url, name: "Shared Data", status: "Shared"))
        } catch {
            throw error
        }
    }
}

//
//  NetworkManager.swift
//  share-api
//
//  Created by Laurent Jacques on 12/02/2025.
//
import Foundation

public struct NetworkManager: Sendable {
    
    private let session: NetworkSession
    
    public init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

}

extension NetworkManager: NetworkShareURL {
    
    public func postUserData(data: ShareData, urlStr: String = ServerSettings.url(Constants.downloadPath)) async throws -> String {
        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }
        
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
    
    public func sendData(url: String, resolution: String = "medium") async throws {
        do {
            _ = try await self.postUserData(data: ShareData(url: url, name: "Shared Data", status: "Shared", resolution: resolution))
        } catch {
            throw error
        }
    }
}


extension NetworkManager: NetworkStatus  {
    
    // Fetch downloads
    public func fetchDownloads(from urlString: String) async throws -> [DownloadItem] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 60
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decodedData = try JSONDecoder().decode([DownloadItem].self, from: data)
        return decodedData
    }
    
    // Clear download history
    public func clearDownloadHistory(urlString: String = ServerSettings.url(Constants.clearHistoryPath))  async throws {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Check if the response indicates success
        if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let success = jsonResponse["success"] as? Bool, !success,
           let errorMessage = jsonResponse["error"] as? String {
            throw NSError(domain: "ServerError", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
    }
    
    // Get available resolutions
    public func getAvailableResolutions(urlString: String = ServerSettings.url(Constants.resolutionPath)) async throws -> [String] {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let options = jsonResponse["options"] as? [String] {
            return options
        } else {
            return ["low", "medium", "high", "hd", "best"]
        }
    }

    /// True when the server answers /health.
    public func isServerReachable(baseURL: String = ServerSettings.serverURL) async -> Bool {
        guard let url = URL(string: baseURL + Constants.healthPath) else { return false }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        guard let (_, response) = try? await session.data(for: request) else { return false }
        return (response as? HTTPURLResponse)?.statusCode == 200
    }
}

//
//  NetworkStatus.swift
//  share-api
//
//  Created by Laurent Jacques on 13/02/2025.
//


public protocol NetworkStatus {
    func fetchDownloads(from urlString: String) async throws -> [DownloadItem]
    func clearDownloadHistory(urlString: String) async throws
    func getAvailableResolutions(urlString: String) async throws -> [String]
}

// Default implementation to maintain backward compatibility
extension NetworkStatus {
    public func clearDownloadHistory(urlString: String) async throws {
        // Default empty implementation
        // Will be overridden in concrete implementations
    }
    
    public func getAvailableResolutions(urlString: String) async throws -> [String] {
        // Default implementation returns standard options
        return ["low", "medium", "high", "hd", "best"]
    }
}

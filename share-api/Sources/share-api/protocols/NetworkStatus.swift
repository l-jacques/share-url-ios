//
//  NetworkStatus.swift
//  share-api
//
//  Created by Laurent Jacques on 13/02/2025.
//


public protocol NetworkStatus {
    func fetchDownloads(from urlString: String) async throws -> [DownloadItem]
}
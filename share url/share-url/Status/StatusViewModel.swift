//
//  StatusViewModel.swift
//  share-url
//
//  Created by Laurent Jacques on 12/02/2025.
//
import Foundation
import share_api

@MainActor
protocol StatusViewModelProtocol: ObservableObject {
    var downloadedItems: [DownloadItem] {get set }
    func fetchDownloadedItems() async
    func clearDownloadHistory() async throws
}

@MainActor
class StatusViewModel: StatusViewModelProtocol {
    @Published public var downloadedItems: [DownloadItem] = []
    private let network: NetworkStatus
    private let loadData: AccessDataProtocol
    
    init(network: NetworkStatus, loadData: AccessDataProtocol) {
        self.network = network
        self.loadData = loadData
        
    }
    
    func fetchDownloadedItems() async {
        do {
            let serverUrl = (loadData.load(key: "serverUrl") ?? Constants.defaultServerURL) + Constants.statusPath
            self.downloadedItems = try await network.fetchDownloads(from: serverUrl)
        } catch {
            print("Failed to fetch data:", error)
        }
    }
    
    func clearDownloadHistory() async throws {
        let serverUrl = (loadData.load(key: "serverUrl") ?? Constants.defaultServerURL) + Constants.clearHistoryPath
        try await network.clearDownloadHistory(urlString: serverUrl)
        self.downloadedItems = [] // Clear local data immediately
    }
}

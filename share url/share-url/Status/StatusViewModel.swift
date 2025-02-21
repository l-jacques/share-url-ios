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
}

@MainActor
class StatusViewModel: StatusViewModelProtocol {
    @Published public var downloadedItems: [DownloadItem] = []
    private let network: NetworkStatus
    
    init(network: NetworkStatus) {
        self.network = network
    }
    
    func fetchDownloadedItems() async {
        do {
            self.downloadedItems = try await network.fetchDownloads(from: Constants.serverURLStatus)
        } catch {
            print("Failed to fetch data:", error)
        }
    }
}

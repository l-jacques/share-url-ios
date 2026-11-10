//
//  ShareExtensionViewModel.swift
//  share-url
//
//  Created by Laurent Jacques on 19/02/2025.
//
import Foundation
import share_api

@MainActor
protocol ShareExtensionViewModelProtocol {
    var url: String { get }
    /// Sends the URL to the server saved in Settings (App Group), and only returns once the server accepted it.
    func postData(_ url: String, resolution: String) async throws
}

@MainActor
class ShareExtensionViewModel: ShareExtensionViewModelProtocol {
    private let networkManager: NetworkShareURL

    public private(set) var url: String

    init(networkManager: NetworkShareURL, url: String) {
        self.networkManager = networkManager
        self.url = url
    }

    func postData(_ url: String, resolution: String) async throws {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        try await networkManager.sendData(url: trimmed, resolution: resolution)
    }
}

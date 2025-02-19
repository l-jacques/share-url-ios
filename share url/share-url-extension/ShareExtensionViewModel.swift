//
//  ShareExtensionViewModel.swift
//  share-url
//
//  Created by Laurent Jacques on 19/02/2025.
//
import Foundation
import share_api

protocol ShareExtensionViewModelProtocol {
    var url: String {get}
    func postData(_ url: String) throws -> Void
}

@MainActor
class ShareExtensionViewModel: ShareExtensionViewModelProtocol {
    
    private let networkManager: NetworkShareURL
    
    public private(set) var url: String
    
    init (networkManager: NetworkShareURL, url: String) {
        self.networkManager = networkManager
        self.url = url
    }
    
    func postData(_ url: String) throws -> Void {
        Task {
            try await networkManager.sendData(url: url)
        }
    }
    
}

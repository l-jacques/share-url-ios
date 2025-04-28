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
    
    // This implementation is problematic - Tasks don't work well with synchronous functions
    // Let's fix this method to handle async properly
    func postData(_ url: String) throws -> Void {
        // Two options:
        
        // Option 1: If we want to keep the throws signature, we need a sync approach
        // Use a shared UserDefaults to store the URL for the main app to pick up
        let sharedDefaults = UserDefaults(suiteName: Constants.appGroupIdentifier)
        sharedDefaults?.set(url, forKey: Constants.userDefaultShareKey)
        
        // Option 2: For immediate API call, we'd need to change the function signature
        // Since we can't do that without breaking the protocol, we'll implement a hybrid approach
        
        // Store in UserDefaults AND try to send
        Task {
            do {
                try await networkManager.sendData(url: url)
                // If succeeded, clear the shared URL
                sharedDefaults?.removeObject(forKey: Constants.userDefaultShareKey)
            } catch {
                // If failed, the URL is still in UserDefaults for the main app to retry
                print("Error sending URL: \(error.localizedDescription)")
                // We don't rethrow here since the function has already returned
            }
        }
    }
}

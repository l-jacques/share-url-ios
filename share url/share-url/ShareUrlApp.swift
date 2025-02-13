//
//  share_urlApp.swift
//  share url
//
//  Created by Laurent Jacques on 08/02/2025.
//

import SwiftUI
import share_api

@main
struct ShareUrlApp: App {
    @Environment(\.openURL) var openURL
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var deepLinkURL: URL?
    let networkManager = NetworkManager()
    var body: some Scene {
        WindowGroup {
            ContentView(networkStatus: networkManager)
                .onReceive(NotificationCenter.default.publisher(for: .deepLinkReceived)) { notification in
                    
                    if let url = notification.object as? URL {
                        print("✅ onReceive: \(url.absoluteString)")
                        Task {
                            await handleDeepLink(url)
                        }
                    } else {
                        print(":(onReceive:  No URL provided.")
                    }
                }
                .onOpenURL { url in
                    print("✅ Opened via URL: \(url.absoluteString)")
                    Task {
                        await handleDeepLink(url)
                    }
                }
        }
        
    }
    
    func handleDeepLink(_ url: URL) async {
        if url.absoluteString == Constants.urlShare {
            // Handle the shared URL (e.g., read from UserDefaults)
            let sharedDefaults = UserDefaults(suiteName:  Constants.appGroupIdentifier)
            if let sharedURL = sharedDefaults?.string(forKey: Constants.userDefaultShareKey) {
                print("✅ Retrieved shared URL: \(sharedURL)")
                do {
                    try await self.networkManager.postUserData(data: ShareData(url: sharedURL, name: "Shared Data", status: "Shared"))
                    sharedDefaults?.set(nil, forKey: Constants.userDefaultShareKey)
                } catch {
                    print("Error: \(error)")
                }
                // Show it in the app or process it
            } else {
                print(":( No shared URL found.")
            }
        }
    }

}


extension Notification.Name {
    static let deepLinkReceived = Notification.Name("deepLinkReceived")
}

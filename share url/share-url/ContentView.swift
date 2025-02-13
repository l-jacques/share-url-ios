//
//  ContentView.swift
//  share url
//
//  Created by Laurent Jacques on 08/02/2025.
//

import SwiftUI
import share_api

struct ContentView: View {
    @AppStorage("deepLinkURL") private var deepLinkURL: String = "No deep link received yet"
    private let networkStatus: NetworkStatus
    private let statusViewModel: StatusViewModel
    init(networkStatus: NetworkStatus) {
        self.networkStatus = networkStatus
        self.statusViewModel = .init(network: networkStatus)
    }
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                let sharedDefaults = UserDefaults(suiteName:  Constants.appGroupIdentifier)
                if let sharedURL = sharedDefaults?.string(forKey: Constants.userDefaultShareKey) {
                    Text("✅ Retrieved shared URL: \(sharedURL)")
                    // Show it in the app or process it
                } else
                {
                    Text("❌ No shared URL found.")
                }
                Spacer()
                NavigationLink("Go to Status View",
                               destination: StatusView(viewModel: statusViewModel))
                                   .padding()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
    
    
}

fileprivate struct dumb: NetworkStatus {
    func fetchDownloads(from urlString: String) async throws -> [share_api.DownloadItem] {
       return []
    }
}

#Preview {
    ContentView(networkStatus: dumb())
}

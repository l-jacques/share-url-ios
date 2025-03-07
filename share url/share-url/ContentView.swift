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
    
    @State private var selectedTab = 0
    @State private var showSplash = true
    
    private let networkStatus: NetworkStatus
    private let networkShareUrl: NetworkShareURL
    private let statusViewModel: StatusViewModel
    private let settingsViewModel: SettingsViewModel
    
    init(networkStatus: NetworkStatus, networkShareUrl: NetworkShareURL) {
        self.networkStatus = networkStatus
        self.networkShareUrl = networkShareUrl
        self.statusViewModel = .init(network: networkStatus)
        self.settingsViewModel = .init(saveData: UserDefaultAccessData())
    }
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
                    .animation(.easeOut, value : showSplash)
            } else {
                TabView(selection: $selectedTab) {
                    LandingView(networkShareUrl: self.networkShareUrl)
                        .tabItem {
                            VStack {
                                Image(systemName: "house.fill")
                                Text("Home")
                            }
                        }
                        .tag(0)
                    
                    StatusView(viewModel: self.statusViewModel)
                        .tabItem {
                            VStack {
                                Image(systemName: "display")
                                Text("Status")
                            }
                        }
                        .tag(1)
                    
                    SettingsView(viewModel: settingsViewModel)
                        .tabItem {
                            VStack {
                                Image(systemName: "gear")
                                Text("Settings")
                            }
                        }
                        .tag(2)
                }
                .accentColor(.blue)
            }
        }.onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation{
                    self.showSplash.toggle()
                }
            }
                       
        }
    }
}


fileprivate struct dumb: NetworkStatus {
    func fetchDownloads(from urlString: String) async throws -> [share_api.DownloadItem] {
        return []
    }
}

fileprivate struct dumbdumb: NetworkShareURL {
    func postUserData(data: share_api.ShareData) async throws -> String {
        return "OK"
    }
    
    func sendData(url: String) async throws {
        
    }
}

#Preview {
    ContentView(networkStatus: dumb(), networkShareUrl: dumbdumb())
}

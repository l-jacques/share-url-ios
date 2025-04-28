import SwiftUICore
import share_api
import SwiftUI

struct ContentView: View {
    @AppStorage("deepLinkURL") private var deepLinkURL: String = "No deep link received yet"
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    
    @State private var selectedTab = 0
    @State private var showSplash = true
    @State private var showWelcomeSheet = false
    
    private let networkStatus: NetworkStatus
    private let networkShareUrl: NetworkShareURL
    private let statusViewModel: StatusViewModel
    private let settingsViewModel: SettingsViewModel
    
    init(networkStatus: NetworkStatus, networkShareUrl: NetworkShareURL) {
        let userData = UserDefaultAccessData()
        self.networkStatus = networkStatus
        self.networkShareUrl = networkShareUrl
        self.statusViewModel = .init(network: networkStatus, loadData: userData)
        self.settingsViewModel = .init(saveData: userData)
    }
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
                    .animation(.easeOut, value: showSplash)
            } else {
                TabView(selection: $selectedTab) {
                    LandingView(networkShareUrl: self.networkShareUrl)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    StatusView(viewModel: self.statusViewModel)
                        .tabItem {
                            Label("Status", systemImage: "arrow.down.circle.fill")
                        }
                        .tag(1)
                    
                    SettingsView(viewModel: settingsViewModel)
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(2)
                }
                .accentColor(.blue)
                .sheet(isPresented: $showWelcomeSheet) {
                    welcomeView
                }
            }
        }
        .onAppear {
            // Show splash screen for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    self.showSplash.toggle()
                    
                    // On first launch, show welcome sheet
                    if isFirstLaunch {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showWelcomeSheet = true
                            isFirstLaunch = false
                        }
                    }
                }
            }
        }
    }
    
    // Welcome onboarding view for first launch
    var welcomeView: some View {
        NavigationView {
            VStack(spacing: 25) {
                Spacer()
                
                Image(systemName: "link.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Welcome to Share It!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("A simple way to share URLs with your server")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    featureRow(icon: "link", title: "Share URLs", description: "Easily share web links to your server")
                    
                    featureRow(icon: "arrow.down.circle", title: "Track Downloads", description: "Monitor status of your server downloads")
                    
                    featureRow(icon: "gear", title: "Customize Settings", description: "Configure your server connection")
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    showWelcomeSheet = false
                }) {
                    Text("Get Started")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarItems(trailing: Button(action: {
                showWelcomeSheet = false
            }) {
                Text("Skip")
                    .foregroundColor(.blue)
            })
        }
    }
    
    // Helper for welcome view features
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

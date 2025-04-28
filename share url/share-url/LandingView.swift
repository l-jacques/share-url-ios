import SwiftUI
import share_api

struct LandingView: View {
    private let networkShareUrl: NetworkShareURL
    @State private var inputURL: String = ""
    @State private var showToast = false
    @State private var toastMessage: String? = nil
    @State private var isLoading = false
    @State private var selectedResolution = "medium"
    @State private var showResolutionPicker = false
    @State private var availableResolutions = ["low", "medium", "high", "hd", "best"]
    @FocusState private var isTextFieldFocused: Bool
    
    // Keep recent URLs
    @AppStorage("recentURLs") private var recentURLsData: Data = Data()
    @State private var recentURLs: [String] = []
    
    init(networkShareUrl: NetworkShareURL) {
        self.networkShareUrl = networkShareUrl
    }
    
    var isValidURL: Bool {
        guard let url = URL(string: inputURL), url.scheme == "http" || url.scheme == "https" else {
            return false
        }
        return true
    }
    
    private func loadRecentURLs() {
        if let urls = try? JSONDecoder().decode([String].self, from: recentURLsData) {
            recentURLs = urls
        }
    }
    
    private func saveRecentURL(_ url: String) {
        // Add URL to recent list (avoid duplicates and limit to 5)
        if !recentURLs.contains(url) {
            recentURLs.insert(url, at: 0)
            if recentURLs.count > 5 {
                recentURLs = Array(recentURLs.prefix(5))
            }
            
            // Save to AppStorage
            if let data = try? JSONEncoder().encode(recentURLs) {
                recentURLsData = data
            }
        }
    }
    
    fileprivate func showToast(message: String? = nil) {
        if let message = message {
            self.toastMessage = message
            
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showToast = false
                }
            }
        } else {
            showToast = false
        }
    }
    
    func validateInput() {
        isLoading = true
        showToast(message: String(localized: "sending_url"))
        
        Task {
            do {
                let loadData = UserDefaultAccessData()
                let serverUrl = (loadData.load(key: "serverUrl") ?? Constants.defaultServerURL) + Constants.downloadPath
               // Create ShareData with resolution
                let shareData = ShareData(
                    url: inputURL,
                    name: "Shared Data",
                    status: "Shared",
                    resolution: selectedResolution
                )
                
                // Post data to server
                try await networkShareUrl.postUserData(data: shareData, urlStr: serverUrl)
                saveRecentURL(inputURL)
                inputURL = ""
                isTextFieldFocused = false
            } catch {
                showToast(message: error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "link.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                            .padding(.bottom, 10)
                        
                        Text("Welcome!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Enter a URL to share with the server")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    // URL Input and Resolution Selector
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.secondary)
                            
                            TextField("Enter URL here", text: $inputURL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.URL)
                                .focused($isTextFieldFocused)
                                .submitLabel(.go)
                                .onSubmit {
                                    if isValidURL {
                                        validateInput()
                                    }
                                }
                            
                            if !inputURL.isEmpty {
                                Button(action: {
                                    inputURL = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        // Resolution picker button
                        Button(action: {
                            showResolutionPicker = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                Text("Resolution: \(selectedResolution)")
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        
                        Button(action: validateInput) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text("Send URL")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValidURL ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .animation(.easeInOut, value: isValidURL)
                        }
                        .disabled(!isValidURL || isLoading)
                    }
                    .padding(.horizontal)
                    
                    // Recent URLs
                    if !recentURLs.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recent URLs")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(recentURLs, id: \.self) { url in
                                Button(action: {
                                    inputURL = url
                                }) {
                                    HStack {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .foregroundColor(.secondary)
                                        
                                        Text(url)
                                            .lineLimit(1)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            }
                            
                            Button(action: {
                                recentURLs = []
                                recentURLsData = Data() // Clear storage
                            }) {
                                Text("Clear History")
                                    .font(.callout)
                                    .foregroundColor(.red)
                            }
                            .padding()
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            loadRecentURLs()
        }
        .overlay(
            ToastView(message: toastMessage ?? "")
                .opacity(showToast ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: showToast),
            alignment: .bottom
        )
        .actionSheet(isPresented: $showResolutionPicker) {
            ActionSheet(
                title: Text("Select Video Quality"),
                message: Text("Choose the video resolution"),
                buttons: [
                    .default(Text("240p (Low)")) { selectedResolution = "low" },
                    .default(Text("480p (Medium)")) { selectedResolution = "medium" },
                    .default(Text("720p (High)")) { selectedResolution = "high" },
                    .default(Text("1080p (HD)")) { selectedResolution = "hd" },
                    .default(Text("Best Quality")) { selectedResolution = "best" },
                    .cancel()
                ]
            )
        }
    }
}


struct LandingView_Previews: PreviewProvider {
    fileprivate struct DummyNetworkShareURL: NetworkShareURL {
        func postUserData(data: share_api.ShareData, urlStr: String) async throws -> String {
            return "OK"
        }
        
        func sendData(url: String, resolution: String) async throws {
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        func postUserData(data: share_api.ShareData) async throws -> String {
            return "OK"
        }
        
        func sendData(url: String) async throws {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }
    
    static var previews: some View {
        LandingView(networkShareUrl: DummyNetworkShareURL())
    }
}

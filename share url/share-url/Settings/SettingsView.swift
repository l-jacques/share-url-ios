import SwiftUI
import share_api

struct SettingsView: View {
    @State private var viewModel: SettingsViewModelProtocol
    @State private var isSaved = false
    @State private var showSavedAnimation = false
    @State private var serverStatus: ServerStatus = .unknown
    @State private var apiToken = ServerSettings.apiToken
    @FocusState private var isTextFieldFocused: Bool
    
    enum ServerStatus {
        case unknown, checking, online, offline
        
        var icon: String {
            switch self {
            case .unknown: return "questionmark.circle"
            case .checking: return "arrow.triangle.2.circlepath"
            case .online: return "checkmark.circle.fill"
            case .offline: return "exclamationmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .unknown: return .gray
            case .checking: return .orange
            case .online: return .green
            case .offline: return .red
            }
        }
        
        var text: String {
            switch self {
            case .unknown: return "Status Unknown"
            case .checking: return "Checking..."
            case .online: return "Server Online"
            case .offline: return "Server Offline"
            }
        }
    }
    
    init(viewModel: SettingsViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func checkServerStatus() {
        serverStatus = .checking
        
        let url = viewModel.serverUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !url.isEmpty else {
            serverStatus = .unknown
            return
        }
        Task {
            let reachable = await NetworkManager().isServerReachable(baseURL: url.hasSuffix("/") ? String(url.dropLast()) : url)
            serverStatus = reachable ? .online : .offline
        }
    }
    
    func saveServerUrl() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showSavedAnimation = true
            viewModel.saveServerUrl(viewModel.serverUrl)
            ServerSettings.apiToken = apiToken
        }
        
        // Check server status after saving
        checkServerStatus()
        
        // Hide the saved animation after a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSavedAnimation = false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Server URL")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "server.rack")
                                .foregroundColor(.secondary)
                            
                            TextField("http://example.com:3000", text: $viewModel.serverUrl)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.URL)
                                .focused($isTextFieldFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    if !viewModel.serverUrl.isEmpty {
                                        saveServerUrl()
                                    }
                                }
                            
                            if !viewModel.serverUrl.isEmpty {
                                Button(action: {
                                    viewModel.serverUrl = ""
                                    serverStatus = .unknown
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Token")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Image(systemName: "key")
                                .foregroundColor(.secondary)

                            SecureField("Same as API_TOKEN on the server", text: $apiToken)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($isTextFieldFocused)
                                .submitLabel(.done)
                                .onSubmit { saveServerUrl() }
                        }
                    }

                    Button(action: saveServerUrl) {
                        HStack {
                            Text("Save")
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Image(systemName: showSavedAnimation ? "checkmark" : "arrow.down.doc.fill")
                                .scaleEffect(showSavedAnimation ? 1.2 : 1.0)
                                .foregroundColor(showSavedAnimation ? .green : .blue)
                        }
                    }
                    .disabled(viewModel.serverUrl.isEmpty)
                    
                    HStack {
                        Label {
                            Text(serverStatus.text)
                        } icon: {
                            Image(systemName: serverStatus.icon)
                        }
                        .font(.subheadline)
                        .foregroundColor(serverStatus.color)
                        
                        Spacer()
                        
                        Button(action: checkServerStatus) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                        .disabled(viewModel.serverUrl.isEmpty)
                    }
                } header: {
                    Text("Server Configuration")
                }
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Default Server", systemImage: "network")
                        Spacer()
                        Text(Constants.defaultServerURL)
                            .foregroundColor(.secondary)
                            .font(.system(.subheadline, design: .monospaced))
                    }
                } header: { Text("About") }
                Section {
                    Button(action: {
                        // Reset to default server
                        viewModel.serverUrl = Constants.defaultServerURL
                        saveServerUrl()
                    }) {
                        HStack {
                            Image(systemName: "arrow.uturn.backward.circle")
                            Text("Reset to Default Server")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        // Clear app data functionality
                        // This would clear any stored preferences or local data
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear App Data")
                        }
                        .foregroundColor(.red)
                    }
                } header: {
                    Text("Actions")
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                if !viewModel.serverUrl.isEmpty {
                    checkServerStatus()
                }
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        isTextFieldFocused = false
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    fileprivate class SettViewModelMock: SettingsViewModelProtocol {
        func saveServerUrl(_ url: String) {
            serverUrl = url
        }
        
        @Published var serverUrl: String = Constants.defaultServerURL
    }
    
    static var previews: some View {
        SettingsView(viewModel: SettViewModelMock())
    }
}

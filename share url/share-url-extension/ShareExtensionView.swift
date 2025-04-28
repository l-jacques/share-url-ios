import SwiftUI
import share_api

struct ShareExtensionView: View {
    @State private var text: String
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.presentationMode) private var presentationMode
    
    private var viewModel: ShareExtensionViewModelProtocol
    
    var onError: ((Error) -> Void)?
    
    init(viewModel: ShareExtensionViewModelProtocol) {
        self.viewModel = viewModel
        // Use _text for state initialization
        _text = State(initialValue: viewModel.url)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Add an explicit background for visibility
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "link.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                        
                        Text("Share URL")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // URL Text Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("URL to share")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ZStack(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("Enter URL here")
                                    .foregroundColor(.gray.opacity(0.8))
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                            
                            TextEditor(text: $text)
                                .frame(minHeight: 100)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Options (Optional features to be implemented)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Options")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Toggle("Download immediately", isOn: .constant(true))
                            .font(.body)
                        
                        Toggle("Notify when complete", isOn: .constant(false))
                            .font(.body)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button {
                            sendUrl()
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                
                                Text(String(localized: "send_to_server"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(text.isEmpty || isLoading)
                        
                        Button {
                            close()
                        } label: {
                            Text(String(localized: "close"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .blur(radius: showSuccess || showError ? 3 : 0)
                
                // Success overlay
                if showSuccess {
                    successOverlay
                }
                
                // Error overlay
                if showError {
                    errorOverlay
                }
            }
            .navigationTitle("Share It")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        close()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private var successOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 70, height: 70)
                .foregroundColor(.green)
            
            Text("URL Sent Successfully!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your URL has been sent to the server")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                close()
            } label: {
                Text("Done")
                    .fontWeight(.medium)
                    .frame(width: 120)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .transition(.scale.combined(with: .opacity))
    }
    
    private var errorOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.circle.fill")
                .resizable()
                .frame(width: 70, height: 70)
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(errorMessage.isEmpty ? "Failed to send URL to server" : errorMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button {
                    showError = false
                } label: {
                    Text("Try Again")
                        .fontWeight(.medium)
                        .frame(width: 120)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                
                Button {
                    close()
                } label: {
                    Text("Cancel")
                        .fontWeight(.medium)
                        .frame(width: 120)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 10)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .transition(.scale.combined(with: .opacity))
    }
    
    private func sendUrl() {
        isLoading = true
        
        // Save to UserDefaults for the main app to pick up
        let sharedDefaults = UserDefaults(suiteName: Constants.appGroupIdentifier)
        sharedDefaults?.set(text, forKey: Constants.userDefaultShareKey)
        
        // Try to send immediately
        Task {
            do {
                try await Task.sleep(nanoseconds: 500_000_000) // Slight delay for UI feedback
                try viewModel.postData(text)
                
                withAnimation {
                    isLoading = false
                    showSuccess = true
                }
                
                // Automatically close after showing success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    close()
                }
            } catch {
                withAnimation {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
                onError?(error)
            }
        }
    }
    
    func close() {
        // Two ways to close:
        
        // 1. Dismiss presentation (if presented modally)
        presentationMode.wrappedValue.dismiss()
        
        // 2. Post notification (for older UIKit hosting)
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}

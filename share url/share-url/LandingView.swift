//
//  LandingView.swift
//  share-url
//
//  Created by Laurent Jacques on 14/02/2025.
//

import SwiftUI
import share_api

struct LandingView: View {
    private let networkShareUrl: NetworkShareURL
    @State private var inputURL: String = ""
    @State private var showToast = false
    @State private var toastMessage: String? = nil
    @FocusState private var isTextFieldFocused: Bool

    
    init(networkShareUrl: NetworkShareURL) {
        self.networkShareUrl = networkShareUrl
    }
    
    var isValidURL: Bool {
        guard let url = URL(string: inputURL), url.scheme == "http" || url.scheme == "https" else {
            return false
        }
        return true
    }
    
    fileprivate func showToast(message: String? = nil) {
        if let message = message {
            self.toastMessage = message
            
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showToast = false
            }
        } else {
            showToast = false
        }
    }
    
    func validateInput() {
        showToast(message: "Sending URL to server")
        Task {
            do {
                try await networkShareUrl.sendData(url: inputURL)
                inputURL = ""
                isTextFieldFocused = false
            } catch {
                showToast(message: error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Welcome!")
            Spacer()
            HStack {
                TextField("Enter URL here", text: $inputURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(10)
                    .padding(10)
                    .focused($isTextFieldFocused)
                Button("Validate") {
                    validateInput()
                }
                .padding(10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!isValidURL)
            }
            Spacer()
        
        }.overlay(
            showToast ? ToastView(message: toastMessage ?? "") : nil,
            alignment: .bottom
        )
        .animation(.easeInOut(duration: 0.3), value: showToast)

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
    LandingView(networkShareUrl: dumbdumb())
}

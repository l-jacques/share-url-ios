//
//  SettingsView.swift
//  share-url
//
//  Created by Laurent Jacques on 14/02/2025.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var viewModel: SettingsViewModelProtocol
    @State private var isSaved: Bool = false
    
    
    init(viewModel: SettingsViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter the serveur url")
                .font(.headline)
            HStack {
                TextField("Server URL", text: $viewModel.serverUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .layoutPriority(1)
                
                Button(action: {
                    withAnimation {
                        isSaved = true
                        viewModel.saveServerUrl(viewModel.serverUrl)
                    }
                    // Restore the icon after 1 second
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            isSaved = false
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                            .foregroundColor(.white)
                            .transition(.scale) // Smooth transition effect
                    }
                }
                .padding(10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .layoutPriority(2)
                .disabled(viewModel.serverUrl.isEmpty)
                
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettViewModelMock())
    }
}

fileprivate class SettViewModelMock: SettingsViewModelProtocol {
    func saveServerUrl(_ url: String) {
        
    }
    
    @Published var serverUrl: String = ""
    
}

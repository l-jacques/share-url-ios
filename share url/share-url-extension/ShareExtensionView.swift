//
//  ShareExtensionView.swift
//  share-url
//
//  Created by Laurent Jacques on 19/02/2025.
//

import SwiftUI

struct ShareExtensionView: View {
    @State private var text: String = ""
    
    private var viewModel: ShareExtensionViewModelProtocol
    
    var onError: ((Error) -> Void)?
    
    init(viewModel: ShareExtensionViewModelProtocol) {
        self.viewModel = viewModel
        text = self.viewModel.url
    }
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 20){
                TextField(String(localized: "shared_url"), text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    do {
                        try viewModel.postData(text)
                        close()
                    } catch {
                        onError?(error)
                    }
                } label: {
                    Text(String(localized: "send_to_server"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle(String(localized: "app_name"))
            .toolbar {
                Button(String(localized: "close")) {
                    close()
                }
            }
        }
    }
    
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
}

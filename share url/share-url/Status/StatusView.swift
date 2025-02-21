//
//  StatusView.swift
//  share url
//
//  Created by Laurent Jacques on 08/02/2025.
//

import SwiftUI
import share_api

struct StatusView<ViewModel: StatusViewModelProtocol>: View {
    @State private var isLoading = false
    @ObservedObject var viewModel: ViewModel
    @State private var hasLoaded = false
        
   init(viewModel: ViewModel) {
       self.viewModel = viewModel
   }
    
    var body: some View {
        if isLoading {
           ProgressView(String(localized: "Loading.."))
                .progressViewStyle(CircularProgressViewStyle())
                           .scaleEffect(2) // Agrandit l'animation
                           .tint(.blue) // Couleur personnalisée
               .padding()
        } else {
            List(viewModel.downloadedItems, id: \.started) { item in
                VStack(alignment: .leading) {
                    Text(item.title).bold()
                    Text(item.status)
                    Text(item.started)
                    Text(item.ended)
                }
            }
            .padding()
            .onAppear{
                if !hasLoaded {
                    hasLoaded = true
                    refreshData()
                }
            }
            .refreshable {
                refreshData()
            }
            .overlay(
                viewModel.downloadedItems.isEmpty ?
                    Text(String(localized: "no_files_downloaded_yet"))
                        .bold()
                        .padding()
                : nil
            )
            
        }
    }
    func refreshData() {
        Task {
            isLoading = true
            await viewModel.fetchDownloadedItems()
            isLoading = false
        }
    }
}

fileprivate class dumbViewModel: StatusViewModelProtocol {
    var downloadedItems: [share_api.DownloadItem] = []
    
    func fetchDownloadedItems() async {
        
    }
}
#Preview {
    StatusView(viewModel: dumbViewModel())
}

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
           ProgressView("Loading...")
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
                Task {
                    if !hasLoaded {
                        hasLoaded = true
                        refreshData()
                    }
                }
            }.refreshable {
                refreshData()
            }
        }
    }
    func refreshData() {
        isLoading = true
        Task {
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

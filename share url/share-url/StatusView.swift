//
//  StatusView.swift
//  share url
//
//  Created by Laurent Jacques on 08/02/2025.
//

import SwiftUI
import share_api

struct StatusView<ViewModel: StatusViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

   init(viewModel: ViewModel) {
       self.viewModel = viewModel
   }
    
    var body: some View {
        List(viewModel.downloadedItems, id: \.started) { item in
            VStack(alignment: .leading) {
                Text(item.title)
                Text(item.status)
                Text(item.started)
                Text(item.ended)
            }
        }
        .padding()
        .onAppear{
            Task {
                await viewModel.fetchDownloadedItems()
            }
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

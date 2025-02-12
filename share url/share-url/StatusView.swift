//
//  StatusView.swift
//  share url
//
//  Created by Laurent Jacques on 08/02/2025.
//

import SwiftUI
import share_api

struct StatusView: View {
    @StateObject var viewModel: StatusViewModel
    
    // Inject ViewModel through initializer
    init(viewModel: @autoclosure @escaping () -> StatusViewModel = StatusViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
 
    var body: some View {
        List(viewModel.shareData) { share in
            VStack(alignment: .leading) {
                Text(share.name ?? "No name")
                Text(share.status ?? "No status")
            }
        }
        .padding()
    }
    
   
}

#Preview {
    ContentView()
}

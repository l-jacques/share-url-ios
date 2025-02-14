//
//  ToastView.swift
//  share-url
//
//  Created by Laurent Jacques on 14/02/2025.
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .transition(.move(edge: .bottom))
    }
}

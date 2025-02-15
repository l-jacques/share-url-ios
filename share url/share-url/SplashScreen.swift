//
//  SplashScreen.swift
//  share-url
//
//  Created by Laurent Jacques on 15/02/2025.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        Image("SplashScreen")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .border(.blue)
    }
}

#Preview {
    SplashScreen()
}

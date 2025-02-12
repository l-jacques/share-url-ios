//
//  ContentView.swift
//  share url
//
//  Created by Laurent Jacques on 08/02/2025.
//

import SwiftUI
import share_api

struct ContentView: View {
    @AppStorage("deepLinkURL") private var deepLinkURL: String = "No deep link received yet"

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            let sharedDefaults = UserDefaults(suiteName:  Constants.appGroupIdentifier)
            if let sharedURL = sharedDefaults?.string(forKey: Constants.userDefaultShareKey) {
                Text("✅ Retrieved shared URL: \(sharedURL)")
                // Show it in the app or process it
            } else
            {
                Text("❌ No shared URL found.")
            }
        }
        .padding()
    }
    
   
}

#Preview {
    ContentView()
}

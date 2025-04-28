//
//  SplashScreen.swift
//  share-url
//
//  Created by Laurent Jacques on 15/02/2025.
//

import SwiftUI


struct SplashScreen: View {
    @State private var scale = 0.7
    @State private var opacity = 0.0
    @State private var rotation = 0.0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App icon/logo
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "link.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(rotation))
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                // App name
                Text("Share It")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .opacity(opacity)
                    .padding(.top, 20)
                
                // Tagline
                Text("Share URLs Seamlessly")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                rotation = 360.0
            }
        }
    }
}
/*
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
*/

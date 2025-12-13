//
//  SplashView.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var showTitle = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Stars background
            StarsBackground()
            
            VStack(spacing: 24) {
                // App icon/logo
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0.7 : 1.0)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                }
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                
                // App title
                if showTitle {
                    VStack(spacing: 8) {
                        Text("NASA APOD")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Astronomy Picture of the Day")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            isAnimating = true
            
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                showTitle = true
            }
        }
    }
}

struct StarsBackground: View {
    @State private var animateStars = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(animateStars ? Double.random(in: 0.3...1.0) : 0.5)
            }
        }
        .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: animateStars)
        .onAppear {
            animateStars = true
        }
    }
}

#Preview {
    SplashView()
}
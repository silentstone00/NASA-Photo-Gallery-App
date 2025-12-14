//
//  ContentView.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager.shared
    
    var body: some View {
        ZStack {
            APODHomeView()
            
            
            if !networkManager.isConnected {
                VStack {
                    NetworkBanner()
                    Spacer()
                }
                .transition(.move(edge: .top))
                .animation(.easeInOut, value: networkManager.isConnected)
            }
        }
        .preferredColorScheme(.none)
    }
}

struct NetworkBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
            
            Text("No Internet Connection")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.red)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}



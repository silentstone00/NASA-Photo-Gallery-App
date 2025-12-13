//
//  SettingsView.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("About") {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("NASA APOD Viewer")
                                .font(.headline)
                            Text("Explore the cosmos daily")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Data Source") {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("NASA APOD API")
                                .font(.subheadline)
                            Text("api.nasa.gov/planetary/apod")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Features") {
                    FeatureRow(icon: "photo", title: "High-Resolution Images", description: "Automatically loads HD versions when available")
                    FeatureRow(icon: "magnifyingglass", title: "Zoom & Pan", description: "Pinch to zoom up to 5x magnification")
                    FeatureRow(icon: "calendar", title: "Date Selection", description: "Browse APOD history from June 1995")
                    FeatureRow(icon: "play.circle", title: "Video Support", description: "Opens video content in browser")
                }
                
                Section("Tips") {
                    TipRow(icon: "hand.tap", title: "Double-tap to zoom in/out")
                    TipRow(icon: "arrow.down.and.line.horizontal.and.arrow.up", title: "Pull down to refresh")
                    TipRow(icon: "info.circle", title: "Tap image for full-screen view")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SettingsView()
}
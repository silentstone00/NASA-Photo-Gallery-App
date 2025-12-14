//
//  AsyncImageView.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

struct AsyncImageView: View {
    let url: String
    let contentMode: ContentMode
    let onTap: (() -> Void)?
    
    @State private var cachedImage: UIImage?
    @State private var isLoading = true
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var systemColorScheme
    
    private var effectiveColorScheme: ColorScheme {
        themeManager.colorSchemeOverride ?? systemColorScheme
    }
    
    init(url: String, contentMode: ContentMode = .fit, onTap: (() -> Void)? = nil) {
        self.url = url
        self.contentMode = contentMode
        self.onTap = onTap
    }
    
    var body: some View {
        Group {
            if let uiImage = cachedImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .onTapGesture {
                        onTap?()
                    }
            } else if isLoading {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        VStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(Color.secondaryText(for: effectiveColorScheme))
                            Text("Loading image...")
                                .font(.caption)
                                .foregroundColor(Color.secondaryText(for: effectiveColorScheme))
                        }
                    }
                    .aspectRatio(16/9, contentMode: .fit)
            } else {
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(Color.secondaryText(for: effectiveColorScheme))
                            Text("Failed to load image")
                                .font(.caption)
                                .foregroundColor(Color.secondaryText(for: effectiveColorScheme))
                        }
                    }
                    .aspectRatio(16/9, contentMode: .fit)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        
        if let cached = await ImageCacheManager.shared.getImage(for: url) {
            cachedImage = cached
            isLoading = false
            return
        }
        
        
        if let downloaded = await ImageCacheManager.shared.downloadAndCache(from: url) {
            cachedImage = downloaded
        }
        isLoading = false
    }
}


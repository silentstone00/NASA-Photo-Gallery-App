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
    
    init(url: String, contentMode: ContentMode = .fit, onTap: (() -> Void)? = nil) {
        self.url = url
        self.contentMode = contentMode
        self.onTap = onTap
    }
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .onTapGesture {
                    onTap?()
                }
        } placeholder: {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .overlay {
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading image...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .aspectRatio(16/9, contentMode: .fit)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AsyncImageView(url: "https://example.com/image.jpg")
        .padding()
}
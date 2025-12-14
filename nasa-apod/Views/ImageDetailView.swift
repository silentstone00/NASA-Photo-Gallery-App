//
//  ImageDetailView.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

struct ImageDetailView: View {
    let apod: APODModel
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showingMetadata = false
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var cachedImage: UIImage?
    @State private var isLoading = true
    @State private var showZoomHint = false
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                if let uiImage = cachedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .position(x: geometry.size.width / 2 + offset.width,
                                  y: geometry.size.height / 2 + offset.height)
                        .scaleEffect(scale)
                        .gesture(
                            
                            DragGesture()
                                .onChanged { value in
                                    let newOffset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                    offset = newOffset
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                    
                                    
                                    if scale <= minScale {
                                        withAnimation(.spring()) {
                                            offset = .zero
                                            lastOffset = .zero
                                        }
                                    }
                                }
                        )
                        .gesture(
                            
                            MagnificationGesture()
                                .onChanged { value in
                                    let newScale = lastScale * value
                                    scale = min(max(newScale, minScale), maxScale)
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    
                                    
                                    if scale < minScale {
                                        withAnimation(.spring()) {
                                            scale = minScale
                                            lastScale = minScale
                                            offset = .zero
                                            lastOffset = .zero
                                        }
                                    }
                                }
                        )
                        .onTapGesture(count: 2) {
                            
                            withAnimation(.spring()) {
                                if scale > minScale {
                                    scale = minScale
                                    lastScale = minScale
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = 2.5
                                    lastScale = 2.5
                                }
                            }
                        }
                        .onTapGesture(count: 1) {
                            
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingMetadata.toggle()
                            }
                        }
                } else if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Loading high-resolution image...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    
                    VStack(spacing: 16) {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Failed to load image")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .task {
                await loadImage()
            }
            
            
            VStack {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("High‑Res Image")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingMetadata.toggle()
                        }
                    }) {
                        Image(systemName: showingMetadata ? "info.circle.fill" : "info.circle")
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                
                Spacer()
            }
            .opacity(showingMetadata ? 1 : 0.7)
            
            
            if showingMetadata {
                VStack {
                    Spacer()
                    
                    MetadataOverlay(apod: apod)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            
            if scale > minScale {
                VStack {
                    HStack {
                        Spacer()
                        
                        Text("\(Int(scale * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .padding(.trailing)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                }
            }
            
            // Pinch to zoom hint
            if showZoomHint && cachedImage != nil && scale == minScale {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "hand.pinch")
                            .font(.system(size: 16))
                        Text("Pinch to zoom • Double-tap to zoom in")
                            .font(.subheadline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.7))
                    .clipShape(Capsule())
                    .padding(.bottom, 100)
                }
                .transition(.opacity)
            }
        }
        .statusBarHidden()
        .dismissOnVerticalDrag {
            if scale <= minScale {
                isPresented = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
            
            
            if scale > minScale {
                withAnimation(.spring()) {
                    scale = minScale
                    lastScale = minScale
                    offset = .zero
                    lastOffset = .zero
                }
            }
        }
        .onAppear {
            orientation = UIDevice.current.orientation
        }
        .onChange(of: cachedImage) { oldValue, newValue in
            // Show hint when image loads
            if newValue != nil && oldValue == nil {
                withAnimation(.easeIn(duration: 0.3)) {
                    showZoomHint = true
                }
                // Auto-hide after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showZoomHint = false
                    }
                }
            }
        }
    }
    
    
    
    private func loadImage() async {
        
        let imageUrl = apod.hdurl ?? apod.url
        
        
        if let cached = await ImageCacheManager.shared.getImage(for: imageUrl) {
            cachedImage = cached
            isLoading = false
            return
        }
        
        
        if let downloaded = await ImageCacheManager.shared.downloadAndCache(from: imageUrl) {
            cachedImage = downloaded
        }
        isLoading = false
    }
}

struct MetadataOverlay: View {
    let apod: APODModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(apod.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if let dateObject = apod.dateObject {
                Text(dateObject.formattedForDisplay())
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            if let copyright = apod.copyright {
                Text("© \(copyright)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            ScrollView {
                Text(apod.explanation)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineSpacing(4)
            }
            .frame(maxHeight: 150)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.8), Color.black.opacity(0.4)],
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
}


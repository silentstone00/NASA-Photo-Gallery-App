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
    
    // Constants for zoom limits
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                AsyncImage(url: URL(string: apod.bestImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
                                // Pinch to zoom gesture
                                MagnificationGesture()
                                    .onChanged { value in
                                        let newScale = lastScale * value
                                        scale = min(max(newScale, minScale), maxScale)
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                        
                                        // Snap back to minimum scale if too small
                                        if scale < minScale {
                                            withAnimation(.spring()) {
                                                scale = minScale
                                                lastScale = minScale
                                                offset = .zero
                                                lastOffset = .zero
                                            }
                                        }
                                    },
                                
                                // Drag gesture for panning
                                DragGesture()
                                    .onChanged { value in
                                        if scale > minScale {
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                        
                                        // Constrain offset to keep image visible
                                        let maxOffsetX = (geometry.size.width * (scale - 1)) / 2
                                        let maxOffsetY = (geometry.size.height * (scale - 1)) / 2
                                        
                                        let constrainedOffset = CGSize(
                                            width: min(max(offset.width, -maxOffsetX), maxOffsetX),
                                            height: min(max(offset.height, -maxOffsetY), maxOffsetY)
                                        )
                                        
                                        if constrainedOffset != offset {
                                            withAnimation(.spring()) {
                                                offset = constrainedOffset
                                                lastOffset = constrainedOffset
                                            }
                                        }
                                    }
                            )
                        )
                        .onTapGesture(count: 2) {
                            // Double tap to zoom in/out
                            withAnimation(.spring()) {
                                if scale > minScale {
                                    scale = minScale
                                    lastScale = minScale
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = 2.0
                                    lastScale = 2.0
                                }
                            }
                        }
                        .onTapGesture(count: 1) {
                            // Single tap to toggle metadata
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingMetadata.toggle()
                            }
                        }
                } placeholder: {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Loading high-resolution image...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
            }
            
            // Top toolbar
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
                
                Spacer()
            }
            .opacity(showingMetadata ? 1 : 0.7)
            
            // Metadata overlay
            if showingMetadata {
                VStack {
                    Spacer()
                    
                    MetadataOverlay(apod: apod)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Zoom indicator
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
        }
        .statusBarHidden()
        .dismissOnVerticalDrag {
            if scale <= minScale {
                isPresented = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
            
            // Reset zoom when orientation changes for better UX
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

#Preview {
    ImageDetailView(
        apod: APODModel(
            copyright: "Example Photographer",
            date: "2024-01-15",
            explanation: "This is an example explanation of today's astronomy picture. It contains detailed information about the celestial object or phenomenon shown in the image.",
            hdurl: "https://example.com/hd-image.jpg",
            mediaType: "image",
            serviceVersion: "v1",
            title: "Example Astronomy Picture",
            url: "https://example.com/image.jpg"
        ),
        isPresented: .constant(true)
    )
}
//
//  ZoomableImageView.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

struct ZoomableImageView: View {
    let imageURL: String
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(zoomGesture(in: geometry))
                    .onTapGesture(count: 2) {
                        doubleTapToZoom()
                    }
            } placeholder: {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .clipped()
    }
    
    private func zoomGesture(in geometry: GeometryProxy) -> some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    let newScale = lastScale * value
                    scale = min(max(newScale, minScale), maxScale)
                }
                .onEnded { _ in
                    lastScale = scale
                    snapToValidScale()
                },
            
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
                    constrainOffset(in: geometry)
                }
        )
    }
    
    private func doubleTapToZoom() {
        withAnimation(.spring()) {
            if scale > minScale {
                resetZoom()
            } else {
                scale = 2.0
                lastScale = 2.0
            }
        }
    }
    
    private func resetZoom() {
        scale = minScale
        lastScale = minScale
        offset = .zero
        lastOffset = .zero
    }
    
    private func snapToValidScale() {
        if scale < minScale {
            withAnimation(.spring()) {
                resetZoom()
            }
        }
    }
    
    private func constrainOffset(in geometry: GeometryProxy) {
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
}


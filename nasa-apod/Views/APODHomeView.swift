//
//  APODHomeView.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

struct APODHomeView: View {
    @StateObject private var viewModel = APODViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView(message: "Fetching astronomy picture...")
                } else if viewModel.hasError {
                    ErrorView(message: viewModel.errorMessage ?? "An unknown error occurred") {
                        Task {
                            await viewModel.retryLastRequest()
                        }
                    }
                } else if let apod = viewModel.currentAPOD {
                    APODContentView(apod: apod, viewModel: viewModel)
                } else {
                    // Initial empty state
                    VStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        Text("Welcome to NASA APOD")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Loading today's astronomy picture...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("NASA APOD")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showDatePicker()
                    }) {
                        Image(systemName: "calendar")
                    }
                    .disabled(viewModel.isLoading)
                    .keyboardShortcut("d", modifiers: .command)
                    
                    Menu {
                        Button(action: {
                            Task {
                                await viewModel.loadTodaysAPOD()
                            }
                        }) {
                            Label("Today's APOD", systemImage: "star.fill")
                        }
                        
                        Button(action: {
                            Task {
                                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                                await viewModel.loadAPOD(for: yesterday)
                            }
                        }) {
                            Label("Yesterday's APOD", systemImage: "star")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            viewModel.showDatePicker()
                        }) {
                            Label("Select Date", systemImage: "calendar")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .disabled(viewModel.isLoading)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task {
                            await viewModel.refresh()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibleButton(
                        label: "Refresh",
                        hint: "Refresh the current astronomy picture"
                    )
                    .disabled(viewModel.isLoading)
                    .keyboardShortcut("r", modifiers: .command)
                }
            }
            .sheet(isPresented: $viewModel.showingDatePicker) {
                DateSelectionView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $viewModel.showingImageDetail) {
                if let apod = viewModel.currentAPOD, apod.isImage {
                    ImageDetailView(apod: apod, isPresented: $viewModel.showingImageDetail)
                }
            }
        }
        .task {
            await viewModel.loadTodaysAPOD()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh content when app comes to foreground
            Task {
                await viewModel.refresh()
            }
        }

    }
}

struct APODContentView: View {
    let apod: APODModel
    let viewModel: APODViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(apod.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                // Date
                Text(viewModel.displayDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Media Content
                if apod.isImage {
                    AsyncImageView(url: apod.bestImageURL, contentMode: .fit) {
                        viewModel.showImageDetail()
                    }
                    .accessibleAPODContent(
                        label: AccessibilityHelper.apodContentLabel(for: apod),
                        hint: AccessibilityHelper.interactionHint(for: .tapToZoom),
                        traits: [.isButton, .isImage]
                    )
                    .padding(.horizontal)
                } else {
                    // Video content
                    VideoContentView(apod: apod)
                        .accessibleAPODContent(
                            label: "Video content: \(apod.title)",
                            hint: "Tap to open video in browser",
                            traits: [.isButton]
                        )
                        .padding(.horizontal)
                }
                
                // Copyright
                if let copyright = apod.copyright {
                    Text("© \(copyright)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Explanation
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(apod.explanation)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

struct VideoContentView: View {
    let apod: APODModel
    
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(16/9, contentMode: .fit)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Video Content")
                            .font(.headline)
                        
                        Text("Tap to view in browser")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onTapGesture {
                    if let url = URL(string: apod.url) {
                        UIApplication.shared.open(url)
                    }
                }
            
            Text("This APOD contains video content. Tap above to view in your browser.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    APODHomeView()
}
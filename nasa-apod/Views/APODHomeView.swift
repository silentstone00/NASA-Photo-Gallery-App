//
//  APODHomeView.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

struct APODHomeView: View {
    @StateObject private var viewModel = APODViewModel()
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var systemColorScheme
    
    
    private var effectiveColorScheme: ColorScheme {
        themeManager.colorSchemeOverride ?? systemColorScheme
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                AppBackgroundColor()
                
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showDatePicker()
                    }) {
                        Image(systemName: "calendar")
                    }
                    .disabled(viewModel.isLoading)
                    .keyboardShortcut("d", modifiers: .command)
                    
                    // Dark mode toggle button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeManager.toggleColorScheme()
                        }
                    }) {
                        Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(themeManager.isDarkMode ? .yellow : .primary)
                    }
                    .accessibilityLabel(themeManager.isDarkMode ? "Switch to light mode" : "Switch to dark mode")
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
            
            Task {
                await viewModel.refresh()
            }
        }
        .preferredColorScheme(themeManager.colorSchemeOverride)
    }
}

struct APODContentView: View {
    let apod: APODModel
    let viewModel: APODViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var isLoadingShare = false
    
    private var effectiveColorScheme: ColorScheme {
        themeManager.colorSchemeOverride ?? systemColorScheme
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text(apod.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryText(for: effectiveColorScheme))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                
                Text(viewModel.displayDate)
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryText(for: effectiveColorScheme))
                    .padding(.horizontal)
                
                
                if apod.isImage {
                    ZStack(alignment: .bottomTrailing) {
                        AsyncImageView(url: apod.bestImageURL, contentMode: .fit) {
                            viewModel.showImageDetail()
                        }
                        .accessibleAPODContent(
                            label: AccessibilityHelper.apodContentLabel(for: apod),
                            hint: AccessibilityHelper.interactionHint(for: .tapToZoom),
                            traits: [.isButton, .isImage]
                        )
                        
                        
                        Button(action: {
                            Task {
                                isLoadingShare = true
                                await loadImageForSharing()
                                isLoadingShare = false
                            }
                        }) {
                            Group {
                                if isLoadingShare {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                        }
                        .disabled(isLoadingShare)
                        .padding(12)
                        .accessibilityLabel("Share image")
                    }
                    .padding(.horizontal)
                } else {
                    
                    VideoContentView(apod: apod)
                        .accessibleAPODContent(
                            label: "Video content: \(apod.title)",
                            hint: "Tap to open video in browser",
                            traits: [.isButton]
                        )
                        .padding(.horizontal)
                }
                
            
                if let copyright = apod.copyright {
                    Text("© \(copyright)")
                        .font(.caption)
                        .foregroundColor(Color.secondaryText(for: effectiveColorScheme))
                        .padding(.horizontal)
                }
                
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primaryText(for: effectiveColorScheme))
                    
                    Text(apod.explanation)
                        .font(.body)
                        .foregroundColor(Color.primaryText(for: effectiveColorScheme))
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
    
    @MainActor
    private func loadImageForSharing() async {
        var image: UIImage?
        
        
        if let cached = await ImageCacheManager.shared.getImage(for: apod.bestImageURL) {
            image = cached
        } else if let downloaded = await ImageCacheManager.shared.downloadAndCache(from: apod.bestImageURL) {
            
            image = downloaded
        }
        
        
        if let imageToShare = image {
            let shareText = "\(apod.title)\n\nNASA Astronomy Picture of the Day"
            ShareHelper.share(items: [imageToShare, shareText])
        }
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
    
        controller.popoverPresentationController?.sourceView = UIView()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


struct ShareHelper {
    static func share(items: [Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        rootViewController.present(activityVC, animated: true)
    }
}

struct VideoContentView: View {
    let apod: APODModel
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var systemColorScheme
    
    private var effectiveColorScheme: ColorScheme {
        themeManager.colorSchemeOverride ?? systemColorScheme
    }
    
    
    private var youtubeVideoID: String? {
        let url = apod.url
        
        
        if url.contains("youtube.com/embed/") {
            return url.components(separatedBy: "youtube.com/embed/").last?.components(separatedBy: "?").first
        }
        
        
        if url.contains("youtube.com/watch") {
            if let urlComponents = URLComponents(string: url),
               let videoID = urlComponents.queryItems?.first(where: { $0.name == "v" })?.value {
                return videoID
            }
        }
        
        
        if url.contains("youtu.be/") {
            return url.components(separatedBy: "youtu.be/").last?.components(separatedBy: "?").first
        }
        
        return nil
    }
    
    
    private var vimeoVideoID: String? {
        let url = apod.url
        
        
        if url.contains("vimeo.com") {
            let components = url.components(separatedBy: "/")
            return components.last?.components(separatedBy: "?").first
        }
        
        return nil
    }
    
    
    private var thumbnailURL: String? {
        if let youtubeID = youtubeVideoID {
            
            
            return "https://img.youtube.com/vi/\(youtubeID)/hqdefault.jpg"
        }
        
        
        return nil
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                
                if let thumbnailURL = thumbnailURL {
                    AsyncImage(url: URL(string: thumbnailURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure:
                            videoPlaceholder
                        case .empty:
                            videoPlaceholder
                                .overlay {
                                    ProgressView()
                                }
                        @unknown default:
                            videoPlaceholder
                        }
                    }
                } else {
                    videoPlaceholder
                }
                
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 10)
            }
            .onTapGesture {
                if let url = URL(string: apod.url) {
                    UIApplication.shared.open(url)
                }
            }
            
            HStack {
                Image(systemName: "play.rectangle.fill")
                    .foregroundColor(.blue)
                Text("Tap to watch video")
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryText(for: effectiveColorScheme))
            }
        }
    }
    
    private var videoPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(16/9, contentMode: .fit)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Video Content")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
    }
}


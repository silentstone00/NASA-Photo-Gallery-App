# NASA APOD Viewer

A native iOS application built with SwiftUI that displays NASA's Astronomy Picture of the Day (APOD).

## Features

### Core Functionality

#### API Integration
- Integrates with NASA's APOD API (`https://api.nasa.gov/planetary/apod`)
- Fetches and displays the Astronomy Picture of the Day
- Handles both image and video media types appropriately

#### Home Screen
- Displays today's APOD with:
  - Title
  - High-quality image (or video thumbnail for video content)
  - Explanation/description
  - Date
  - Copyright information (when available)

#### Date Selection
- Date picker to view APOD for any historical date
- Validates date selections (June 16, 1995 to present)
- Quick select buttons for Today, Yesterday, and 1 Week Ago

#### Image Detail View
- Full-screen image viewing experience
- Pinch-to-zoom support (1x to 5x magnification)
- Double-tap to zoom in/out
- Pan/drag when zoomed
- Metadata overlay with title, date, copyright, and description

### Error Handling
- User-friendly error messages for:
  - Network failures
  - Invalid API responses
  - Invalid date selections
  - Missing media content
- Loading indicators during network requests
- Automatic retry mechanism with exponential backoff (up to 3 attempts)

### Bonus Features

#### Image Caching
- Memory cache (NSCache) - 50 images, 50MB limit
- Disk cache - 100MB limit with automatic cleanup
- Avoids redundant network calls

#### Share Functionality
- Share button overlay on images
- Share image with title via iOS share sheet

#### Dark Mode
- Full dark/light mode support
- Manual toggle button in navigation bar
- Custom theme colors:
  - Light mode: `#EBE6FF` (soft lavender)
  - Dark mode: `#5523B2` (deep purple)
- Persists user preference

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture pattern:

```
nasa-apod/
├── Models/
│   ├── APODModel.swift          # Data model for APOD response
│   ├── APODError.swift          # Custom error types
│   └── LoadingState.swift       # Loading state enum
├── Views/
│   ├── APODHomeView.swift       # Main home screen
│   ├── ImageDetailView.swift    # Full-screen image viewer
│   ├── DateSelectionView.swift  # Date picker view
│   └── Components/
│       ├── AsyncImageView.swift # Cached async image loading
│       ├── LoadingView.swift    # Loading indicator
│       └── ErrorView.swift      # Error display
├── ViewModels/
│   └── APODViewModel.swift      # Business logic & state management
├── Services/
│   ├── APODService.swift        # API communication
│   ├── NetworkManager.swift     # Network connectivity monitoring
│   ├── ImageCacheManager.swift  # Image caching (memory + disk)
│   └── RetryManager.swift       # Retry logic with exponential backoff
├── Repositories/
│   └── APODRepository.swift     # Data access layer
├── Extensions/
│   ├── Date+Extensions.swift    # Date formatting utilities
│   ├── Color+Extensions.swift   # Custom colors & hex support
│   ├── View+Extensions.swift    # View modifiers
│   └── Accessibility+Extensions.swift
├── Configuration/
│   └── APIConfiguration.swift   # API key & configuration
└── Utils/
    ├── ThemeManager.swift       # Dark/light mode management
    └── AppConstants.swift       # App-wide constants
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

1. Clone the repository
2. Open `nasa-apod.xcodeproj` in Xcode
3. Add your NASA API key in `Configuration/APIConfiguration.swift`:
   ```swift
   static let apiKey = "YOUR_API_KEY_HERE"
   ```
4. Build and run on simulator or device

## API Key

Get your free NASA API key at: https://api.nasa.gov/

## Technologies Used

- **SwiftUI** - Declarative UI framework
- **Swift Concurrency** - async/await for network calls
- **Combine** - Reactive programming for state management
- **NSCache** - Memory caching
- **FileManager** - Disk caching
- **URLSession** - Network requests

## Screenshots

| Home Screen | Date Picker | Image Detail |
|-------------|-------------|--------------|
| Light/Dark mode support | Historical date selection | Pinch-to-zoom |

## License

This project is for educational purposes.

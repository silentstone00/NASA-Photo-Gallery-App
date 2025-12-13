# NASA APOD Viewer

A SwiftUI iOS application that displays NASA's Astronomy Picture of the Day with advanced features like date selection, full-screen viewing, and zoom capabilities.

## Features

### Core Functionality
- ✅ **Daily APOD Display**: Automatically loads today's astronomy picture
- ✅ **Date Selection**: Browse APOD history from June 16, 1995 to present
- ✅ **High-Resolution Images**: Automatically uses HD versions when available
- ✅ **Video Support**: Handles video content with browser integration
- ✅ **Full-Screen Viewing**: Immersive image viewing experience
- ✅ **Zoom & Pan**: Pinch-to-zoom up to 5x with smooth pan gestures

### User Experience
- ✅ **Pull-to-Refresh**: Easy content refreshing
- ✅ **Error Handling**: Comprehensive error states with retry options
- ✅ **Loading States**: Clear feedback during network operations
- ✅ **Network Monitoring**: Offline state detection and user feedback
- ✅ **Orientation Support**: Adapts to device rotation
- ✅ **Dark Mode**: Full support for system appearance

### Technical Features
- ✅ **MVVM Architecture**: Clean separation of concerns
- ✅ **Repository Pattern**: Abstracted data access layer
- ✅ **Async/Await**: Modern Swift concurrency
- ✅ **Caching**: In-memory caching to reduce API calls
- ✅ **Retry Logic**: Automatic retry with exponential backoff
- ✅ **Type Safety**: Comprehensive error handling with typed errors

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   SwiftUI Views │    │   ViewModels    │    │  Repositories   │
│                 │    │                 │    │                 │
│ • APODHomeView  │◄──►│ • APODViewModel │◄──►│ • APODRepository│
│ • ImageDetail   │    │ • State Mgmt    │    │ • Caching       │
│ • DateSelection │    │ • Business Logic│    │ • Data Access   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                               ┌─────────────────┐
                                               │    Services     │
                                               │                 │
                                               │ • APODService   │
                                               │ • NetworkManager│
                                               │ • RetryManager  │
                                               └─────────────────┘
                                                        │
                                               ┌─────────────────┐
                                               │   NASA API      │
                                               │                 │
                                               │ • APOD Endpoint │
                                               │ • JSON Response │
                                               └─────────────────┘
```

## User Workflows

### 1. App Launch
1. App loads with today's APOD
2. Network connectivity check
3. Loading state with progress indicator
4. Content display or error handling

### 2. Date Selection
1. Tap calendar icon in toolbar
2. Date picker with validation (1995-06-16 to today)
3. Quick select buttons (Today, Yesterday, 1 Week Ago)
4. Load selected date's APOD

### 3. Image Viewing
1. Tap image for full-screen view
2. Pinch to zoom (1x to 5x)
3. Pan when zoomed in
4. Double-tap to zoom in/out
5. Single tap to toggle metadata
6. Swipe down to dismiss

### 4. Error Recovery
1. Network error detection
2. User-friendly error messages
3. Retry button with automatic retry logic
4. Offline state handling

## API Integration

- **Endpoint**: `https://api.nasa.gov/planetary/apod`
- **Authentication**: API Key included
- **Parameters**: 
  - `api_key`: Your NASA API key
  - `date`: Optional date in YYYY-MM-DD format
  - `hd`: Always true for high-resolution images

## Testing

The app includes comprehensive testing utilities:

```swift
// Test complete workflows
await WorkflowTester.testAPODLoadingWorkflow()
WorkflowTester.testDateValidationWorkflow()
WorkflowTester.testErrorHandlingWorkflow()
```

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Internet connection for API access

## Installation

1. Clone the repository
2. Open `nasa-apod.xcodeproj` in Xcode
3. Build and run on simulator or device

## Configuration

The app uses a NASA API key configured in `APIConfiguration.swift`. The current key is included for development purposes.

## Future Enhancements

- [ ] Favorites system with local storage
- [ ] Share functionality for images
- [ ] Search through historical APODs
- [ ] Widget support for iOS home screen
- [ ] iPad-optimized layout
- [ ] Accessibility improvements
- [ ] Unit and UI tests

## License

This project is for educational purposes and uses NASA's public APOD API.
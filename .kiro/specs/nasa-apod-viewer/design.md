# Design Document

## Overview

The NASA APOD Viewer is a SwiftUI-based iOS application following MVVM architecture with a Repository pattern for data management. The app uses async/await for network operations and provides a clean, intuitive interface for browsing NASA's Astronomy Picture of the Day content. The design emphasizes simplicity, performance, and maintainability while delivering a polished user experience within a 2-day development timeline.

## Architecture

The application follows a layered architecture pattern:

**Presentation Layer (SwiftUI Views)**
- ContentView: Main navigation and app structure
- APODHomeView: Today's APOD display
- DateSelectionView: Date picker interface
- ImageDetailView: Full-screen image viewer with zoom
- ErrorView: Error state presentations

**Business Logic Layer (ViewModels)**
- APODViewModel: Manages APOD data state and user interactions
- Handles loading states, error states, and data transformations
- Coordinates between UI and data layer

**Data Layer (Repository & Services)**
- APODRepository: Abstracts data access and caching logic
- APODService: Direct NASA API communication
- NetworkManager: HTTP client and error handling

**Models**
- APODModel: Core data structure matching NASA API response
- APODError: Typed error handling for various failure scenarios

## Components and Interfaces

### APODService
```swift
protocol APODServiceProtocol {
    func fetchAPOD(for date: Date?) async throws -> APODModel
}
```

### APODRepository
```swift
protocol APODRepositoryProtocol {
    func getAPOD(for date: Date?) async throws -> APODModel
    func getCurrentAPOD() async throws -> APODModel
}
```

### APODViewModel
```swift
@MainActor
class APODViewModel: ObservableObject {
    @Published var currentAPOD: APODModel?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func loadAPOD(for date: Date? = nil) async
    func retryLastRequest() async
}
```

## Data Models

### APODModel
```swift
struct APODModel: Codable, Identifiable {
    let id = UUID()
    let copyright: String?
    let date: String
    let explanation: String
    let hdurl: String?
    let mediaType: String
    let serviceVersion: String
    let title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case copyright, date, explanation, hdurl, title, url
        case mediaType = "media_type"
        case serviceVersion = "service_version"
    }
}
```

### APODError
```swift
enum APODError: Error, LocalizedError {
    case networkError(Error)
    case invalidResponse
    case invalidDate
    case missingContent
    case apiKeyMissing
    
    var errorDescription: String? {
        // Localized error messages
    }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

**Property Reflection:**
After reviewing all testable properties from the prework analysis, I identified several redundancies:
- Properties 1.5 and 5.3 both test hdurl usage - these can be combined
- Properties 4.3 and 5.4 both test media content failure handling - these can be combined
- Properties 5.1 and 5.2 can be combined into a single comprehensive media type handling property

**Property 1: Application startup loads content**
*For any* application launch, the system should automatically initiate a network request to fetch today's APOD content and display it to the user
**Validates: Requirements 1.1**

**Property 2: Content display completeness**
*For any* valid APOD response, all required fields (title, image, explanation, date, copyright when available) should be present in the rendered UI
**Validates: Requirements 1.2**

**Property 3: High-resolution image usage**
*For any* APOD response containing an hdurl field, the system should use the hdurl for image display rather than the standard url
**Validates: Requirements 1.5, 5.3**

**Property 4: Date selection triggers content update**
*For any* valid date selection, the system should fetch and display APOD content specific to that selected date
**Validates: Requirements 2.2, 2.5**

**Property 5: Zoom functionality preservation**
*For any* image in detail view, pinch-to-zoom gestures should allow magnification while maintaining image integrity
**Validates: Requirements 3.2**

**Property 6: Orientation adaptation**
*For any* device orientation change, the full-screen image display should adapt appropriately to the new orientation
**Validates: Requirements 3.5**

**Property 7: Network error handling**
*For any* network failure scenario, the system should display appropriate error messages and provide retry functionality
**Validates: Requirements 4.1, 4.5**

**Property 8: Invalid response handling**
*For any* malformed or invalid API response, the system should display appropriate error messages without crashing
**Validates: Requirements 4.2**

**Property 9: Loading state indication**
*For any* network operation in progress, the system should display loading indicators to inform the user of ongoing activity
**Validates: Requirements 4.4**

**Property 10: Media content failure handling**
*For any* scenario where media content fails to load or is unavailable, the system should display appropriate placeholder or error states
**Validates: Requirements 4.3, 5.4**

**Property 11: Media type handling**
*For any* media type returned by the API (image or video), the system should display appropriate UI elements and maintain consistent layout
**Validates: Requirements 5.1, 5.2, 5.5**

## Error Handling

The application implements comprehensive error handling across multiple layers:

**Network Layer Errors:**
- Connection timeouts and network unavailability
- HTTP status code errors (4xx, 5xx)
- SSL/TLS certificate issues
- Request timeout handling

**API Response Errors:**
- Malformed JSON responses
- Missing required fields in API response
- Invalid date formats
- API rate limiting responses

**Data Validation Errors:**
- Invalid date selections (before 1995-06-16 or future dates)
- Missing or corrupted media URLs
- Unsupported media types

**User Interface Errors:**
- Image loading failures
- Video playback issues
- Memory pressure during large image handling

**Error Recovery Strategies:**
- Automatic retry with exponential backoff for transient network errors
- Graceful degradation when high-resolution images fail to load
- User-initiated retry options for failed operations
- Offline state handling with appropriate messaging

## Testing Strategy

The testing approach combines unit testing and property-based testing to ensure comprehensive coverage and correctness validation.

**Unit Testing Framework:** XCTest (built-in iOS testing framework)
- Focus on specific examples and edge cases
- Test individual component behavior
- Verify integration points between layers
- Mock external dependencies for isolated testing

**Property-Based Testing Framework:** SwiftCheck (Swift property-based testing library)
- Each property-based test configured to run minimum 100 iterations
- Generate random test data to verify universal properties
- Test correctness properties across wide input ranges
- Each test tagged with format: **Feature: nasa-apod-viewer, Property {number}: {property_text}**

**Testing Coverage Areas:**
- API service layer with mocked network responses
- Data model serialization and validation
- ViewModel state management and error handling
- UI component behavior and user interactions
- Date validation and boundary conditions
- Media type handling across different content types

**Test Data Generation:**
- Random date generation within valid APOD date ranges
- Mock API responses with various media types and field combinations
- Simulated network failure scenarios
- Generated image and video content for UI testing

The dual testing approach ensures both specific functionality works correctly (unit tests) and general system properties hold across all inputs (property tests), providing confidence in the application's correctness and robustness.
//
//  Accessibility+Extensions.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

// MARK: - Accessibility Extensions

extension View {
    
    func accessibleAPODContent(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(traits)
    }
    

    func accessibleButton(
        label: String,
        hint: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
            .frame(minWidth: AppConstants.minimumTapTargetSize, minHeight: AppConstants.minimumTapTargetSize)
    }
    
    
    func accessibleImage(
        label: String,
        decorative: Bool = false
    ) -> some View {
        if decorative {
            return self.accessibilityHidden(true)
        } else {
            return self
                .accessibilityLabel(label)
                .accessibilityAddTraits(.isImage)
        }
    }
}

// MARK: - Accessibility Helpers

struct AccessibilityHelper {
    
    static func apodContentLabel(for apod: APODModel) -> String {
        var components: [String] = []
        
        components.append("Astronomy Picture of the Day")
        components.append(apod.title)
        
        if let dateObject = apod.dateObject {
            components.append("from \(dateObject.formattedForDisplay())")
        }
        
        if let copyright = apod.copyright {
            components.append("by \(copyright)")
        }
        
        return components.joined(separator: ", ")
    }
    

    static func interactionHint(for action: AccessibilityAction) -> String {
        switch action {
        case .tapToZoom:
            return "Double tap to open full screen view with zoom capabilities"
        case .tapToSelect:
            return "Tap to select this date"
        case .tapToRefresh:
            return "Tap to refresh content"
        case .tapToRetry:
            return "Tap to retry loading content"
        case .swipeToNavigate:
            return "Swipe up or down to navigate"
        case .pinchToZoom:
            return "Use pinch gestures to zoom in and out"
        }
    }
    

    static func dynamicValue(for state: ViewState) -> String {
        switch state {
        case .loading:
            return "Loading content"
        case .loaded(let count):
            return "Content loaded, \(count) items"
        case .error(let message):
            return "Error: \(message)"
        case .empty:
            return "No content available"
        }
    }
}

// MARK: - Accessibility Enums

enum AccessibilityAction {
    case tapToZoom
    case tapToSelect
    case tapToRefresh
    case tapToRetry
    case swipeToNavigate
    case pinchToZoom
}

enum ViewState {
    case loading
    case loaded(Int)
    case error(String)
    case empty
}

// MARK: - VoiceOver Announcements

struct VoiceOverAnnouncer {
    
    static func announce(_ message: String) {
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }

    
    static func announceContentLoaded(title: String) {
        announce("New astronomy picture loaded: \(title)")
    }
    
    static func announceError(_ error: String) {
        announce("Error: \(error)")
    }
    
    static func announceSuccess(_ message: String) {
        announce(message)
    }
}

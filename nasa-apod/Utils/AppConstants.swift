//
//  AppConstants.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

struct AppConstants {
    // App Information
    static let appName = "NASA APOD Viewer"
    static let appVersion = "1.0.0"
    
    // UI Constants
    static let defaultCornerRadius: CGFloat = 12
    static let defaultPadding: CGFloat = 16
    static let defaultAnimationDuration: Double = 0.3
    
    // Image Constants
    static let maxZoomScale: CGFloat = 5.0
    static let minZoomScale: CGFloat = 1.0
    static let defaultImageAspectRatio: CGFloat = 16/9
    
    // Network Constants
    static let requestTimeout: TimeInterval = 30
    static let maxRetryAttempts = 3
    static let retryDelay: TimeInterval = 1.0
    
    // Cache Constants
    static let maxCacheSize = 50 // Number of APOD entries to cache
    static let cacheExpirationTime: TimeInterval = 3600 // 1 hour
    
    // Date Constants
    static let apodStartDate = "1995-06-16"
    static let dateDisplayFormat = "EEEE, MMMM d, yyyy"
    static let dateAPIFormat = "yyyy-MM-dd"
    
    // Accessibility
    static let minimumTapTargetSize: CGFloat = 44
    
    // Deep Linking
    static let appScheme = "nasa-apod"
}

// MARK: - User Defaults Keys
extension AppConstants {
    enum UserDefaultsKeys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let lastViewedDate = "lastViewedDate"
        static let preferredImageQuality = "preferredImageQuality"
    }
}

// MARK: - Notification Names
extension AppConstants {
    enum NotificationNames {
        static let apodDataUpdated = "apodDataUpdated"
        static let networkStatusChanged = "networkStatusChanged"
    }
}
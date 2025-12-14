//
//  AppConstants.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

struct AppConstants {
    
    static let appName = "NASA APOD Viewer"
    static let appVersion = "1.0.0"
    
    static let defaultCornerRadius: CGFloat = 12
    static let defaultPadding: CGFloat = 16
    static let defaultAnimationDuration: Double = 0.3
    
    
    static let maxZoomScale: CGFloat = 5.0
    static let minZoomScale: CGFloat = 1.0
    static let defaultImageAspectRatio: CGFloat = 16/9
    
    
    static let requestTimeout: TimeInterval = 30
    static let maxRetryAttempts = 3
    static let retryDelay: TimeInterval = 1.0
    
    
    static let maxCacheSize = 50
    static let cacheExpirationTime: TimeInterval = 3600 // 1 hour
    
    
    static let apodStartDate = "1995-06-16"
    static let dateDisplayFormat = "EEEE, MMMM d, yyyy"
    static let dateAPIFormat = "yyyy-MM-dd"
    
    
    static let minimumTapTargetSize: CGFloat = 44
    
    
    static let appScheme = "nasa-apod"
}


extension AppConstants {
    enum UserDefaultsKeys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let lastViewedDate = "lastViewedDate"
        static let preferredImageQuality = "preferredImageQuality"
    }
}


extension AppConstants {
    enum NotificationNames {
        static let apodDataUpdated = "apodDataUpdated"
        static let networkStatusChanged = "networkStatusChanged"
    }
}

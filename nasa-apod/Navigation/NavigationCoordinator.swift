//
//  NavigationCoordinator.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI
import Combine

@MainActor
class NavigationCoordinator: ObservableObject {
    @Published var showingDatePicker = false
    @Published var showingImageDetail = false
    @Published var showingSettings = false
    
    // Navigation methods
    func showDatePicker() {
        showingDatePicker = true
    }
    
    func hideDatePicker() {
        showingDatePicker = false
    }
    
    func showImageDetail() {
        showingImageDetail = true
    }
    
    func hideImageDetail() {
        showingImageDetail = false
    }
    
    func showSettings() {
        showingSettings = true
    }
    
    func hideSettings() {
        showingSettings = false
    }
    
    
    func handleDeepLink(_ url: URL) {
        
        guard url.scheme == "apod" else { return }
        
        if url.host == "date", let dateString = url.pathComponents.last {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dateString) {
                
                NotificationCenter.default.post(
                    name: .loadSpecificDate,
                    object: date
                )
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let loadSpecificDate = Notification.Name("loadSpecificDate")
}

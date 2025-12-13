//
//  Date+Extensions.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

extension Date {
    /// Returns a formatted string for display in the UI
    func formattedForDisplay() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: self)
    }
    
    /// Returns a string formatted for the NASA API
    func formattedForAPI() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    /// Checks if this date is valid for APOD service
    var isValidAPODDate: Bool {
        return APIConfiguration.isValidDate(self)
    }
}
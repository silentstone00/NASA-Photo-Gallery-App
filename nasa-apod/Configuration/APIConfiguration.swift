//
//  APIConfiguration.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

struct APIConfiguration {
    static let baseURL = "https://api.nasa.gov/planetary/apod"
    static let apiKey = "9jKWkD7xQBhhksHxyKWcd1E8lCpwBzTP96Aiq6Ln"
    
    // APOD service started on this date
    static let earliestDate = Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 16))!
    
    // Helper method to check if date is valid for APOD service
    static func isValidDate(_ date: Date) -> Bool {
        let today = Date()
        return date >= earliestDate && date <= today
    }
    
    // Helper method to format date for API
    static func formatDateForAPI(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
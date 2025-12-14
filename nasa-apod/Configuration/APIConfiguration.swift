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
    
    
    static let earliestDate = Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 16))!
    
    
    static func isValidDate(_ date: Date) -> Bool {
        let today = Date()
        return date >= earliestDate && date <= today
    }
    
    static func formatDateForAPI(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

//
//  Date+Extensions.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

extension Date {
    
    func formattedForDisplay() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: self)
    }
    
    
    func formattedForAPI() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    
    var isValidAPODDate: Bool {
        return APIConfiguration.isValidDate(self)
    }
}

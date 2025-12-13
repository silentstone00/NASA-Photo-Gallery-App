//
//  APODError.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

enum APODError: Error, LocalizedError {
    case networkError(Error)
    case invalidResponse
    case invalidDate
    case missingContent
    case apiKeyMissing
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from NASA API"
        case .invalidDate:
            return "Invalid date selected. Please choose a date between June 16, 1995 and today."
        case .missingContent:
            return "Content is unavailable or missing"
        case .apiKeyMissing:
            return "API key is missing or invalid"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .invalidResponse, .decodingError:
            return "Please try again later."
        case .invalidDate:
            return "Please select a valid date."
        case .missingContent:
            return "Try selecting a different date."
        case .apiKeyMissing:
            return "Please check your API configuration."
        }
    }
}
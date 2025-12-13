//
//  RetryManager.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

struct RetryManager {
    static let maxRetries = 3
    static let baseDelay: TimeInterval = 1.0
    
    /// Executes an async operation with exponential backoff retry logic
    static func withRetry<T>(
        maxAttempts: Int = maxRetries,
        baseDelay: TimeInterval = baseDelay,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                // Don't retry for certain types of errors
                if let apodError = error as? APODError {
                    switch apodError {
                    case .invalidDate, .apiKeyMissing, .decodingError:
                        throw apodError // Don't retry these errors
                    default:
                        break // Retry other errors
                    }
                }
                
                // If this was the last attempt, throw the error
                if attempt == maxAttempts {
                    break
                }
                
                // Calculate delay with exponential backoff
                let delay = baseDelay * pow(2.0, Double(attempt - 1))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        throw lastError ?? APODError.networkError(URLError(.unknown))
    }
}
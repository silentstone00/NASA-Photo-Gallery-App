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
    
    
    static func withRetry<T>(
        maxAttempts: Int = 3,
        baseDelay: TimeInterval = 1.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                
                if let apodError = error as? APODError {
                    switch apodError {
                    case .invalidDate, .apiKeyMissing, .decodingError:
                        throw apodError
                    default:
                        break
                    }
                }
                
                
                if attempt == maxAttempts {
                    break
                }
                
                
                let delay = baseDelay * pow(2.0, Double(attempt - 1))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        throw lastError ?? APODError.networkError(URLError(.unknown))
    }
}

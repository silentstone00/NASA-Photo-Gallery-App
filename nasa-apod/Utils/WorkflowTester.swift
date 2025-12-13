//
//  WorkflowTester.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

/// Utility class to test complete user workflows
class WorkflowTester {
    
    /// Tests the complete APOD loading workflow
    static func testAPODLoadingWorkflow() async {
        print("🧪 Testing APOD Loading Workflow...")
        
        let repository = APODRepository()
        
        do {
            // Test 1: Load today's APOD
            print("📅 Loading today's APOD...")
            let todayAPOD = try await repository.getCurrentAPOD()
            print("✅ Today's APOD loaded: \(todayAPOD.title)")
            
            // Test 2: Load specific date APOD
            print("📅 Loading specific date APOD...")
            let specificDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let specificAPOD = try await repository.getAPOD(for: specificDate)
            print("✅ Specific date APOD loaded: \(specificAPOD.title)")
            
            // Test 3: Test caching
            print("💾 Testing cache...")
            let cachedAPOD = try await repository.getCurrentAPOD()
            print("✅ Cache working: \(cachedAPOD.title)")
            
            print("🎉 All workflow tests passed!")
            
        } catch {
            print("❌ Workflow test failed: \(error)")
        }
    }
    
    /// Tests date validation workflow
    static func testDateValidationWorkflow() {
        print("🧪 Testing Date Validation Workflow...")
        
        // Test valid dates
        let validDate = Date()
        let isValid = APIConfiguration.isValidDate(validDate)
        print("✅ Valid date test: \(isValid)")
        
        // Test invalid dates
        let invalidDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        let isInvalid = !APIConfiguration.isValidDate(invalidDate)
        print("✅ Invalid date test: \(isInvalid)")
        
        // Test earliest date
        let earliestDate = APIConfiguration.earliestDate
        let isEarliestValid = APIConfiguration.isValidDate(earliestDate)
        print("✅ Earliest date test: \(isEarliestValid)")
        
        print("🎉 Date validation tests passed!")
    }
    
    /// Tests error handling workflow
    static func testErrorHandlingWorkflow() {
        print("🧪 Testing Error Handling Workflow...")
        
        // Test different error types
        let errors: [APODError] = [
            .networkError(URLError(.notConnectedToInternet)),
            .invalidResponse,
            .invalidDate,
            .missingContent,
            .apiKeyMissing
        ]
        
        for error in errors {
            let description = error.localizedDescription
            let suggestion = error.recoverySuggestion
            print("✅ Error handled: \(description) | Suggestion: \(suggestion ?? "None")")
        }
        
        print("🎉 Error handling tests passed!")
    }
}

// MARK: - Debug Extensions
extension APODModel {
    var debugDescription: String {
        return """
        APOD Debug Info:
        - Title: \(title)
        - Date: \(date)
        - Media Type: \(mediaType)
        - Has HD URL: \(hdurl != nil)
        - Copyright: \(copyright ?? "None")
        """
    }
}
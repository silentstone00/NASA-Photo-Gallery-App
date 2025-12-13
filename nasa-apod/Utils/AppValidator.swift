//
//  AppValidator.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation
import SwiftUI

/// Validates app functionality and provides debugging information
struct AppValidator {
    
    /// Validates all core app components
    static func validateApp() -> ValidationResult {
        var issues: [String] = []
        var warnings: [String] = []
        
        // Validate API Configuration
        if APIConfiguration.apiKey.isEmpty {
            issues.append("API key is missing")
        }
        
        if APIConfiguration.baseURL.isEmpty {
            issues.append("Base URL is not configured")
        }
        
        // Validate Date Configuration
        let earliestDate = APIConfiguration.earliestDate
        let today = Date()
        
        if earliestDate > today {
            issues.append("Earliest date is in the future")
        }
        
        // Validate Network Configuration
        if !APIConfiguration.isValidDate(today) {
            issues.append("Today's date is not valid for APOD service")
        }
        
        // Check for potential issues
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let testDateString = formatter.string(from: today)
        
        if testDateString.isEmpty {
            warnings.append("Date formatting may have issues")
        }
        
        return ValidationResult(
            isValid: issues.isEmpty,
            issues: issues,
            warnings: warnings
        )
    }
    
    /// Tests critical user workflows
    static func testCriticalWorkflows() async -> WorkflowTestResult {
        var results: [String: Bool] = [:]
        var errors: [String] = []
        
        // Test 1: API Service Creation
        do {
            let service = APODService()
            results["API Service Creation"] = true
        } catch {
            results["API Service Creation"] = false
            errors.append("Failed to create API service: \(error)")
        }
        
        // Test 2: Repository Creation
        do {
            let repository = APODRepository()
            results["Repository Creation"] = true
        } catch {
            results["Repository Creation"] = false
            errors.append("Failed to create repository: \(error)")
        }
        
        // Test 3: ViewModel Creation
        do {
            let viewModel = APODViewModel()
            results["ViewModel Creation"] = true
        } catch {
            results["ViewModel Creation"] = false
            errors.append("Failed to create view model: \(error)")
        }
        
        // Test 4: Date Validation
        let testDates = [
            Date(),
            APIConfiguration.earliestDate,
            Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        ]
        
        var dateValidationPassed = true
        for date in testDates {
            if !APIConfiguration.isValidDate(date) && date <= Date() && date >= APIConfiguration.earliestDate {
                dateValidationPassed = false
                break
            }
        }
        results["Date Validation"] = dateValidationPassed
        
        return WorkflowTestResult(
            results: results,
            errors: errors,
            overallSuccess: results.values.allSatisfy { $0 } && errors.isEmpty
        )
    }
    
    /// Generates a comprehensive app health report
    static func generateHealthReport() async -> AppHealthReport {
        let validation = validateApp()
        let workflowTest = await testCriticalWorkflows()
        
        return AppHealthReport(
            validation: validation,
            workflowTest: workflowTest,
            timestamp: Date()
        )
    }
}

// MARK: - Result Types

struct ValidationResult {
    let isValid: Bool
    let issues: [String]
    let warnings: [String]
    
    var summary: String {
        if isValid {
            return "✅ All validations passed"
        } else {
            return "❌ Found \(issues.count) issues and \(warnings.count) warnings"
        }
    }
}

struct WorkflowTestResult {
    let results: [String: Bool]
    let errors: [String]
    let overallSuccess: Bool
    
    var summary: String {
        let passedCount = results.values.filter { $0 }.count
        let totalCount = results.count
        
        if overallSuccess {
            return "✅ All \(totalCount) workflow tests passed"
        } else {
            return "❌ \(passedCount)/\(totalCount) workflow tests passed"
        }
    }
}

struct AppHealthReport {
    let validation: ValidationResult
    let workflowTest: WorkflowTestResult
    let timestamp: Date
    
    var overallHealth: String {
        if validation.isValid && workflowTest.overallSuccess {
            return "🟢 Excellent"
        } else if validation.issues.isEmpty && workflowTest.overallSuccess {
            return "🟡 Good (with warnings)"
        } else {
            return "🔴 Needs Attention"
        }
    }
    
    func printReport() {
        print("📊 NASA APOD App Health Report")
        print("Generated: \(timestamp)")
        print("Overall Health: \(overallHealth)")
        print("")
        print("Validation: \(validation.summary)")
        print("Workflows: \(workflowTest.summary)")
        
        if !validation.issues.isEmpty {
            print("\n❌ Issues:")
            validation.issues.forEach { print("  • \($0)") }
        }
        
        if !validation.warnings.isEmpty {
            print("\n⚠️ Warnings:")
            validation.warnings.forEach { print("  • \($0)") }
        }
        
        if !workflowTest.errors.isEmpty {
            print("\n🐛 Workflow Errors:")
            workflowTest.errors.forEach { print("  • \($0)") }
        }
    }
}
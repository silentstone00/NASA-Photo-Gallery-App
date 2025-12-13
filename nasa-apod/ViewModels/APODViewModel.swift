//
//  APODViewModel.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class APODViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentAPOD: APODModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedDate = Date()
    @Published var showingDatePicker = false
    @Published var showingImageDetail = false
    
    // MARK: - Dependencies
    private let repository: APODRepositoryProtocol
    private var lastRequestedDate: Date?
    
    // MARK: - Initialization
    init(repository: APODRepositoryProtocol = APODRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    /// Loads APOD for the specified date, or today if no date provided
    func loadAPOD(for date: Date? = nil) async {
        let targetDate = date ?? Date()
        lastRequestedDate = targetDate
        
        await setLoadingState(true)
        clearError()
        
        do {
            // Pass nil for today's date to let the API return the latest available APOD
            let apod = try await repository.getAPOD(for: date)
            
            // Only update if this is still the most recent request
            if lastRequestedDate == targetDate {
                currentAPOD = apod
                
                // Announce to VoiceOver users
                VoiceOverAnnouncer.announceContentLoaded(title: apod.title)
            }
        } catch {
            // Only show error if this is still the most recent request
            if lastRequestedDate == targetDate {
                handleError(error)
            }
        }
        
        await setLoadingState(false)
    }
    
    /// Loads today's APOD
    func loadTodaysAPOD() async {
        await loadAPOD(for: nil)
    }
    
    /// Loads APOD for the currently selected date
    func loadSelectedDateAPOD() async {
        guard selectedDate.isValidAPODDate else {
            let errorMessage = "Invalid date selected. Please choose a date between June 16, 1995 and today."
            handleError(APODError.invalidDate)
            return
        }
        
        await loadAPOD(for: selectedDate)
    }
    
    /// Validates if a given date is valid for APOD service
    func isValidDate(_ date: Date) -> Bool {
        return date.isValidAPODDate
    }
    
    /// Gets a user-friendly error message for invalid dates
    func getDateValidationMessage(for date: Date) -> String? {
        if date < APIConfiguration.earliestDate {
            return "APOD service started on June 16, 1995. Please select a later date."
        } else if date > Date() {
            return "APOD is not available for future dates. Please select today or an earlier date."
        }
        return nil
    }
    
    /// Retries the last failed request
    func retryLastRequest() async {
        if let lastDate = lastRequestedDate {
            await loadAPOD(for: lastDate)
        } else {
            await loadTodaysAPOD()
        }
    }
    
    /// Refreshes the current content
    func refresh() async {
        if let currentDate = currentAPOD?.dateObject {
            await loadAPOD(for: currentDate)
        } else {
            await loadTodaysAPOD()
        }
    }
    
    // MARK: - UI State Management
    
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
    
    // MARK: - Computed Properties
    
    var hasError: Bool {
        errorMessage != nil
    }
    
    var canRetry: Bool {
        hasError && !isLoading
    }
    
    var hasContent: Bool {
        currentAPOD != nil && !hasError
    }
    
    var isImageContent: Bool {
        currentAPOD?.isImage ?? false
    }
    
    var displayDate: String {
        currentAPOD?.dateObject?.formattedForDisplay() ?? ""
    }
    
    // MARK: - Private Methods
    
    private func setLoadingState(_ loading: Bool) async {
        isLoading = loading
    }
    
    private func clearError() {
        errorMessage = nil
    }
    
    private func handleError(_ error: Error) {
        if let apodError = error as? APODError {
            errorMessage = apodError.localizedDescription
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        // Announce error to VoiceOver users
        if let errorMsg = errorMessage {
            VoiceOverAnnouncer.announceError(errorMsg)
        }
        
        // Log error for debugging
        print("APODViewModel Error: \(error)")
    }
}
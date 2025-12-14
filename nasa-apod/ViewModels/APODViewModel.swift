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
    
    @Published var currentAPOD: APODModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedDate = Date()
    @Published var showingDatePicker = false
    @Published var showingImageDetail = false
    
    
    private let repository: APODRepositoryProtocol
    private var lastRequestedDate: Date?
    
    
    init(repository: APODRepositoryProtocol = APODRepository()) {
        self.repository = repository
    }
    
    
    
    
    func loadAPOD(for date: Date? = nil) async {
        let targetDate = date ?? Date()
        lastRequestedDate = targetDate
        
        await setLoadingState(true)
        clearError()
        
        do {
            
            let apod = try await repository.getAPOD(for: date)
            
            
            if lastRequestedDate == targetDate {
                currentAPOD = apod
                
                
                VoiceOverAnnouncer.announceContentLoaded(title: apod.title)
            }
        } catch {
            
            if lastRequestedDate == targetDate {
                handleError(error)
            }
        }
        
        await setLoadingState(false)
    }
    
    
    func loadTodaysAPOD() async {
        await loadAPOD(for: nil)
    }
    
    
    func loadSelectedDateAPOD() async {
        guard selectedDate.isValidAPODDate else {
            let errorMessage = "Invalid date selected. Please choose a date between June 16, 1995 and today."
            handleError(APODError.invalidDate)
            return
        }
        
        await loadAPOD(for: selectedDate)
    }
    
    
    func isValidDate(_ date: Date) -> Bool {
        return date.isValidAPODDate
    }
    
    
    func getDateValidationMessage(for date: Date) -> String? {
        if date < APIConfiguration.earliestDate {
            return "APOD service started on June 16, 1995. Please select a later date."
        } else if date > Date() {
            return "APOD is not available for future dates. Please select today or an earlier date."
        }
        return nil
    }
    
    
    func retryLastRequest() async {
        if let lastDate = lastRequestedDate {
            await loadAPOD(for: lastDate)
        } else {
            await loadTodaysAPOD()
        }
    }
    
    
    func refresh() async {
        if let currentDate = currentAPOD?.dateObject {
            await loadAPOD(for: currentDate)
        } else {
            await loadTodaysAPOD()
        }
    }
    
    
    
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
        
        
        if let errorMsg = errorMessage {
            VoiceOverAnnouncer.announceError(errorMsg)
        }
        
        
        print("APODViewModel Error: \(error)")
    }
}

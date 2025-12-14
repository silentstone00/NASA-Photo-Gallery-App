//
//  DateSelectionView.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

struct DateSelectionView: View {
    @ObservedObject var viewModel: APODViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var showingInvalidDateAlert = false
    
    private var effectiveColorScheme: ColorScheme {
        themeManager.colorSchemeOverride ?? systemColorScheme
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background matching app theme
                AppBackgroundColor()
                
                VStack(spacing: 20) {
                    Text("Select a Date")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryText(for: effectiveColorScheme))
                        .padding(.top)
                    
                    Text("Choose any date from June 16, 1995 to today")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText(for: effectiveColorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Date range info
                    VStack(spacing: 4) {
                        HStack {
                            Text("First APOD:")
                                .foregroundColor(Color.secondaryText(for: effectiveColorScheme))
                            Spacer()
                            Text("June 16, 1995")
                                .fontWeight(.medium)
                                .foregroundColor(Color.primaryText(for: effectiveColorScheme))
                        }
                        HStack {
                            Text("Latest APOD:")
                                .foregroundColor(Color.secondaryText(for: effectiveColorScheme))
                            Spacer()
                            Text("Today")
                                .fontWeight(.medium)
                                .foregroundColor(Color.primaryText(for: effectiveColorScheme))
                        }
                    }
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(effectiveColorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
                    
                    DatePicker(
                        "",
                        selection: $viewModel.selectedDate,
                        in: APIConfiguration.earliestDate...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.horizontal)
                    .colorScheme(effectiveColorScheme)
                    
                    VStack(spacing: 8) {
                        Text("Quick Select")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.primaryText(for: effectiveColorScheme))
                        
                        HStack(spacing: 12) {
                            QuickDateButton(title: "Today", date: Date(), colorScheme: effectiveColorScheme) {
                                viewModel.selectedDate = Date()
                            }
                            
                            QuickDateButton(title: "Yesterday", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), colorScheme: effectiveColorScheme) {
                                viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                            }
                            
                            QuickDateButton(title: "1 Week Ago", date: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date(), colorScheme: effectiveColorScheme) {
                                viewModel.selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            if viewModel.selectedDate.isValidAPODDate {
                                Task {
                                    await viewModel.loadSelectedDateAPOD()
                                    dismiss()
                                }
                            } else {
                                showingInvalidDateAlert = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Load APOD for \(viewModel.selectedDate.formattedForAPI())")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.selectedDate.isValidAPODDate
                                    ? (effectiveColorScheme == .dark ? Color(hex: "9D4EDD") : Color(hex: "5523B2"))
                                    : Color.gray
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(Color.primaryText(for: effectiveColorScheme))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(effectiveColorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarHidden(true)
            .alert("Invalid Date", isPresented: $showingInvalidDateAlert) {
                Button("OK") { }
            } message: {
                Text("Please select a date between June 16, 1995 and today.")
            }
        }
        .preferredColorScheme(themeManager.colorSchemeOverride)
    }
}



struct QuickDateButton: View {
    let title: String
    let date: Date
    let colorScheme: ColorScheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? .white : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(colorScheme == .dark ? Color.white.opacity(0.15) : Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

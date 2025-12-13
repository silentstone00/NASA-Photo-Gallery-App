//
//  DateSelectionView.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

struct DateSelectionView: View {
    @ObservedObject var viewModel: APODViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingInvalidDateAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select a Date")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Choose any date from June 16, 1995 to today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Date range info
                VStack(spacing: 4) {
                    HStack {
                        Text("First APOD:")
                        Spacer()
                        Text("June 16, 1995")
                            .fontWeight(.medium)
                    }
                    HStack {
                        Text("Latest APOD:")
                        Spacer()
                        Text("Today")
                            .fontWeight(.medium)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
                
                DatePicker(
                    "Select Date",
                    selection: $viewModel.selectedDate,
                    in: APIConfiguration.earliestDate...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .padding(.horizontal)
                
                // Quick date selection buttons
                VStack(spacing: 8) {
                    Text("Quick Select")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        QuickDateButton(title: "Today", date: Date()) {
                            viewModel.selectedDate = Date()
                        }
                        
                        QuickDateButton(title: "Yesterday", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()) {
                            viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                        }
                        
                        QuickDateButton(title: "1 Week Ago", date: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()) {
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
                        .background(viewModel.selectedDate.isValidAPODDate ? Color.blue : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarHidden(true)
            .alert("Invalid Date", isPresented: $showingInvalidDateAlert) {
                Button("OK") { }
            } message: {
                Text("Please select a date between June 16, 1995 and today.")
            }
        }
    }
}

#Preview {
    DateSelectionView(viewModel: APODViewModel())
}

struct QuickDateButton: View {
    let title: String
    let date: Date
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
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
                
                DatePicker(
                    "Select Date",
                    selection: $viewModel.selectedDate,
                    in: APIConfiguration.earliestDate...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await viewModel.loadSelectedDateAPOD()
                            dismiss()
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
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!viewModel.selectedDate.isValidAPODDate)
                    
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
        }
    }
}

#Preview {
    DateSelectionView(viewModel: APODViewModel())
}
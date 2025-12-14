//
//  LoadingView.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var systemColorScheme
    
    private var effectiveColorScheme: ColorScheme {
        themeManager.colorSchemeOverride ?? systemColorScheme
    }
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.secondaryText(for: effectiveColorScheme))
            
            Text(message)
                .font(.headline)
                .foregroundColor(Color.secondaryText(for: effectiveColorScheme))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppBackgroundColor())
    }
}


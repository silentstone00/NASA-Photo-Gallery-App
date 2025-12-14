//
//  ThemeManager.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/14/25.
//

import SwiftUI
import Combine


@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    
    @Published var colorSchemeOverride: ColorScheme? {
        didSet {
            savePreference()
        }
    }
    
    private let userDefaultsKey = "appColorScheme"
    
    private init() {
        loadPreference()
    }
    
    
    func toggleColorScheme() {
        if colorSchemeOverride == .dark {
            colorSchemeOverride = .light
        } else {
            colorSchemeOverride = .dark
        }
    }
    
    
    var isDarkMode: Bool {
        colorSchemeOverride == .dark
    }
    
    private func savePreference() {
        if let scheme = colorSchemeOverride {
            UserDefaults.standard.set(scheme == .dark ? "dark" : "light", forKey: userDefaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }
    
    private func loadPreference() {
        if let saved = UserDefaults.standard.string(forKey: userDefaultsKey) {
            colorSchemeOverride = saved == "dark" ? .dark : .light
        }
    }
}

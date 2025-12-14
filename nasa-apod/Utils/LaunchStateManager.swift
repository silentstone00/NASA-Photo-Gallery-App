//
//  LaunchStateManager.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import SwiftUI
import Combine

@MainActor
class LaunchStateManager: ObservableObject {
    @Published var isFirstLaunch = false
    @Published var isLoading = true
    
    init() {
        checkFirstLaunch()
    }
    
    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.hasLaunchedBefore)
        
        if !hasLaunchedBefore {
            isFirstLaunch = true
            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.hasLaunchedBefore)
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
    }
    
    func completeFirstLaunch() {
        isFirstLaunch = false
    }
}

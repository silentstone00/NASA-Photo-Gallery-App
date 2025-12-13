//
//  LoadingState.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .failed(let message) = self {
            return message
        }
        return nil
    }
    
    var hasError: Bool {
        if case .failed = self {
            return true
        }
        return false
    }
    
    var isLoaded: Bool {
        if case .loaded = self {
            return true
        }
        return false
    }
}
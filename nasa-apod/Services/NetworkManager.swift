//
//  NetworkManager.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation
import Network

@MainActor
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    @Published var isConnected = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    // Helper method to check network connectivity before making requests
    func checkConnectivity() throws {
        guard isConnected else {
            throw APODError.networkError(URLError(.notConnectedToInternet))
        }
    }
}
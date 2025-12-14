//
//  APODRepository.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

protocol APODRepositoryProtocol {
    func getAPOD(for date: Date?) async throws -> APODModel
    func getCurrentAPOD() async throws -> APODModel
}

class APODRepository: APODRepositoryProtocol {
    private let apodService: APODServiceProtocol
    private let networkManager: NetworkManager?
    
    
    private var cache: [String: APODModel] = [:]
    private let cacheQueue = DispatchQueue(label: "APODRepository.cache", attributes: .concurrent)
    
    init(apodService: APODServiceProtocol = APODService(), networkManager: NetworkManager? = nil) {
        self.apodService = apodService
        self.networkManager = networkManager
    }
    
    func getAPOD(for date: Date?) async throws -> APODModel {
        
        let isConnected = await MainActor.run { 
            (networkManager ?? NetworkManager.shared).isConnected 
        }
        if !isConnected {
            throw APODError.networkError(URLError(.notConnectedToInternet))
        }
        
        let cacheKey = date?.formattedForAPI() ?? "today"
        
        
        if let cachedAPOD = await getCachedAPOD(for: cacheKey) {
            return cachedAPOD
        }
        
        
        let apod = try await apodService.fetchAPOD(for: date)
        
        
        await cacheAPOD(apod, for: cacheKey)
        
        return apod
    }
    
    func getCurrentAPOD() async throws -> APODModel {
        return try await getAPOD(for: nil)
    }
    
    // MARK: - Cache Management
    
    private func getCachedAPOD(for key: String) async -> APODModel? {
        return await withCheckedContinuation { continuation in
            cacheQueue.async {
                continuation.resume(returning: self.cache[key])
            }
        }
    }
    
    private func cacheAPOD(_ apod: APODModel, for key: String) async {
        await withCheckedContinuation { continuation in
            cacheQueue.async(flags: .barrier) {
                self.cache[key] = apod
                continuation.resume()
            }
        }
    }
    
    
    func clearCache() async {
        await withCheckedContinuation { continuation in
            cacheQueue.async(flags: .barrier) {
                self.cache.removeAll()
                continuation.resume()
            }
        }
    }
}

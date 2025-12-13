//
//  APODService.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

protocol APODServiceProtocol {
    func fetchAPOD(for date: Date?) async throws -> APODModel
}

class APODService: APODServiceProtocol {
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetchAPOD(for date: Date? = nil) async throws -> APODModel {
        return try await RetryManager.withRetry {
            try await self.performFetch(for: date)
        }
    }
    
    private func performFetch(for date: Date?) async throws -> APODModel {
        let url = try buildURL(for: date)
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            // Check HTTP response status
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APODError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw APODError.networkError(URLError(.badServerResponse))
            }
            
            // Decode the JSON response
            let decoder = JSONDecoder()
            let apodModel = try decoder.decode(APODModel.self, from: data)
            
            return apodModel
            
        } catch let decodingError as DecodingError {
            throw APODError.decodingError(decodingError)
        } catch let urlError as URLError {
            throw APODError.networkError(urlError)
        } catch let apodError as APODError {
            throw apodError
        } catch {
            throw APODError.networkError(error)
        }
    }
    
    private func buildURL(for date: Date?) throws -> URL {
        guard !APIConfiguration.apiKey.isEmpty else {
            throw APODError.apiKeyMissing
        }
        
        var components = URLComponents(string: APIConfiguration.baseURL)!
        
        var queryItems = [
            URLQueryItem(name: "api_key", value: APIConfiguration.apiKey),
            URLQueryItem(name: "hd", value: "true") // Always request high-definition images
        ]
        
        // Add date parameter if provided
        if let date = date {
            guard APIConfiguration.isValidDate(date) else {
                throw APODError.invalidDate
            }
            queryItems.append(URLQueryItem(name: "date", value: date.formattedForAPI()))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw APODError.invalidResponse
        }
        
        return url
    }
}
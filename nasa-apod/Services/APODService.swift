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
        
        print("APODService: Fetching from URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APODError.invalidResponse
            }
            
            print("APODService: HTTP Status Code: \(httpResponse.statusCode)")
            
            
            if httpResponse.statusCode == 403 {
                print("APODService: API key may be invalid or rate limited")
                throw APODError.apiKeyMissing
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                
                if let errorString = String(data: data, encoding: .utf8) {
                    print("APODService: Error response: \(errorString)")
                }
                throw APODError.networkError(URLError(.badServerResponse))
            }
            
            
            let decoder = JSONDecoder()
            let apodModel = try decoder.decode(APODModel.self, from: data)
            
            return apodModel
            
        } catch let decodingError as DecodingError {
            print("APODService: Decoding error: \(decodingError)")
            throw APODError.decodingError(decodingError)
        } catch let urlError as URLError {
            print("APODService: URL error: \(urlError)")
            throw APODError.networkError(urlError)
        } catch let apodError as APODError {
            throw apodError
        } catch {
            print("APODService: Unknown error: \(error)")
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
            URLQueryItem(name: "hd", value: "true")
        ]
        
        
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

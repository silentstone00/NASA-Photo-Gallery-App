//
//  APODModel.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/13/25.
//

import Foundation

struct APODModel: Codable, Identifiable {
    let id = UUID()
    let copyright: String?
    let date: String
    let explanation: String
    let hdurl: String?
    let mediaType: String
    let serviceVersion: String
    let title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case copyright, date, explanation, hdurl, title, url
        case mediaType = "media_type"
        case serviceVersion = "service_version"
    }
    
    // Computed property to check if content is an image
    var isImage: Bool {
        return mediaType.lowercased() == "image"
    }
    
    // Computed property to get the best available image URL
    var bestImageURL: String {
        return hdurl ?? url
    }
    
    // Computed property to parse date string to Date object
    var dateObject: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }
}
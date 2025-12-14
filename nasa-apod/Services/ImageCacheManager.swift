//
//  ImageCacheManager.swift
//  nasa-apod
//
//  Created by Aviral Saxena on 12/14/25.
//

import SwiftUI
import UIKit


actor ImageCacheManager {
    static let shared = ImageCacheManager()
    

    private let memoryCache = NSCache<NSString, UIImage>()
    
    
    private let diskCacheDirectory: URL
    
    
    private let maxDiskCacheSize: Int = 100 * 1024 * 1024
    
    private init() {
        
        memoryCache.countLimit = 50
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
        
        
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheDirectory = cacheDir.appendingPathComponent("ImageCache", isDirectory: true)
        
        
        try? FileManager.default.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }
    
    

    func getImage(for url: String) -> UIImage? {
        let key = cacheKey(for: url)
        
        if let image = memoryCache.object(forKey: key as NSString) {
            return image
        }

        
        if let image = loadFromDisk(key: key) {
            
            memoryCache.setObject(image, forKey: key as NSString)
            return image
        }
        
        return nil
    }
    
    
    func cacheImage(_ image: UIImage, for url: String) {
        let key = cacheKey(for: url)
        
    
        memoryCache.setObject(image, forKey: key as NSString)
        
        
        saveToDisk(image: image, key: key)
    }
    

    func downloadAndCache(from urlString: String) async -> UIImage? {

        if let cached = getImage(for: urlString) {
            return cached
        }
        

        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            

            cacheImage(image, for: urlString)
            
            return image
        } catch {
            print("ImageCacheManager: Failed to download image: \(error)")
            return nil
        }
    }
    

    func clearCache() {

        memoryCache.removeAllObjects()
        

        try? FileManager.default.removeItem(at: diskCacheDirectory)
        try? FileManager.default.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }
    

    func diskCacheSize() -> Int {
        var size = 0
        if let files = try? FileManager.default.contentsOfDirectory(at: diskCacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for file in files {
                if let fileSize = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    size += fileSize
                }
            }
        }
        return size
    }
    

    
    private func cacheKey(for url: String) -> String {

        return url.data(using: .utf8)?.base64EncodedString() ?? url.replacingOccurrences(of: "/", with: "_")
    }
    
    private func diskPath(for key: String) -> URL {
        diskCacheDirectory.appendingPathComponent(key)
    }
    
    private func loadFromDisk(key: String) -> UIImage? {
        let path = diskPath(for: key)
        guard let data = try? Data(contentsOf: path) else { return nil }
        return UIImage(data: data)
    }
    
    private func saveToDisk(image: UIImage, key: String) {
        let path = diskPath(for: key)
        
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        try? data.write(to: path)
        
        
        cleanupDiskCacheIfNeeded()
    }
    
    private func cleanupDiskCacheIfNeeded() {
        let currentSize = diskCacheSize()
        
        if currentSize > maxDiskCacheSize {
            
            guard let files = try? FileManager.default.contentsOfDirectory(
                at: diskCacheDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: .skipsHiddenFiles
            ) else { return }
            
            let sortedFiles = files.sorted { file1, file2 in
                let date1 = (try? file1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
                let date2 = (try? file2.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
                return date1 < date2
            }
            
            
            var deletedSize = 0
            let targetDeletion = currentSize - (maxDiskCacheSize / 2) 
            
            for file in sortedFiles {
                if deletedSize >= targetDeletion { break }
                
                if let fileSize = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    try? FileManager.default.removeItem(at: file)
                    deletedSize += fileSize
                }
            }
        }
    }
}

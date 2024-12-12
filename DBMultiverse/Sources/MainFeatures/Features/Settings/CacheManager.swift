//
//  CacheManager.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/12/24.
//

import Foundation

final class CacheManager: ObservableObject {
    @Published var showingErrorAlert = false
    @Published var showingClearedCacheAlert = false
    @Published var cachedChapters: [CachedChapter] = []
    
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
}


// MARK: - Actions
extension CacheManager {
    func clearCache() {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!

        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in contents {
                try fileManager.removeItem(at: file)
            }
            
            cachedChapters = []
            showingClearedCacheAlert = true
        } catch {
            showingErrorAlert = true
        }
    }
    
    func loadCachedChapters() {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let chaptersDirectory = cacheDirectory.appendingPathComponent("Chapters")

        var chapters: [CachedChapter] = []
        do {
            let chapterFolders = try fileManager.contentsOfDirectory(at: chaptersDirectory, includingPropertiesForKeys: nil)
            
            for folder in chapterFolders {
                let chapterNumber = folder.lastPathComponent.replacingOccurrences(of: "Chapter_", with: "")
                let images = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
                let imageCount = images.filter { $0.pathExtension.lowercased() == "jpg" }.count

                chapters.append(CachedChapter(number: chapterNumber, imageCount: imageCount))
            }
        } catch {
            print("Failed to load cached chapters: \(error.localizedDescription)")
        }
        cachedChapters = chapters
    }
}


// MARK: - Dependencies
struct CachedChapter: Identifiable {
    let id = UUID()
    let number: String
    let imageCount: Int
}

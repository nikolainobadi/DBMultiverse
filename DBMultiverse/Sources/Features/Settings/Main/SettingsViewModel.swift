//
//  SettingsViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/12/24.
//

import Foundation
import DBMultiverseComicKit

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var route: SettingsRoute?
    @Published var showingErrorAlert = false
    @Published var showingClearedCacheAlert = false
    @Published var cachedChapters: [CachedChapter] = []

    private let fileManager: any CacheDelegate

    init(fileManager: CacheDelegate = CacheDelegateAdapter()) {
        self.fileManager = fileManager
    }
}

// MARK: - Actions
extension SettingsViewModel {
    func showView(_ route: SettingsRoute) {
        self.route = route
    }
    
    func makeURL(for link: SettingsLinkItem, language: ComicLanguage) -> URL? {
        return URLFactory.makeURL(language: language, pathComponent: link.pathComponent)
    }
    
    func clearCache() {
        guard let cacheDirectory = fileManager.getCacheDirectoryURL() else {
            return
        }
        
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

    /// Loads cached chapter data from the cache directory.
    func loadCachedChapters() {
        guard let chaptersDirectory = fileManager.getCacheDirectoryURL()?.appendingPathComponent("Chapters") else {
            return
        }
        
        var chapters: [CachedChapter] = []
        
        do {
            let chapterFolders = try fileManager.contentsOfDirectory(at: chaptersDirectory, includingPropertiesForKeys: nil)
            for folder in chapterFolders {
                let chapterNumber = folder.lastPathComponent.replacingOccurrences(of: "Chapter_", with: "")
                let images = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
                let imageCount = images.filter { $0.pathExtension.lowercased() == "jpg" }.count
                chapters.append(.init(number: chapterNumber, imageCount: imageCount))
            }
        } catch {
            print("Failed to load cached chapters: \(error.localizedDescription)")
        }
        cachedChapters = chapters
    }
}


// MARK: - Dependencies
protocol CacheDelegate {
    func getCacheDirectoryURL() -> URL?
    func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?) throws -> [URL]
    func removeItem(at URL: URL) throws
}

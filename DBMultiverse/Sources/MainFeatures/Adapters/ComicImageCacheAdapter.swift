//
//  ComicImageCacheAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation
import DBMultiverseComicKit

/// An adapter that implements the `ComicImageCache` protocol, providing functionality for caching comic images, managing chapter progress, and interacting with the filesystem.
final class ComicImageCacheAdapter {
    /// The type of comic (e.g., story or specials) for which the adapter is responsible.
    private let comicType: ComicType
    
    /// The file manager instance used for accessing and modifying the file system.
    private let fileManager: FileManager
    
    /// The storel used for updating page progress.
    private let store: ComicPageStore
    
    /// A shared cache for storing cover images and progress metadata.
    private let coverImageCache: CoverImageCache
    
    /// Initializes the `ComicImageCacheAdapter` with its dependencies.
    /// - Parameters:
    ///   - comicType: The type of comic (story or specials).
    ///   - store: The store for managing chapter progress.
    ///   - fileManager: The file manager instance for file operations. Defaults to `.default`.
    ///   - coverImageCache: The shared cache for cover images.
    init(comicType: ComicType, store: ComicPageStore, fileManager: FileManager = .default, coverImageCache: CoverImageCache = .init()) {
        self.comicType = comicType
        self.store = store
        self.fileManager = fileManager
        self.coverImageCache = coverImageCache
    }
}

// MARK: - Cache
extension ComicImageCacheAdapter: ComicImageCache {
    /// Updates the current page number and read progress in the cache.
    /// - Parameters:
    ///   - pageNumber: The current page number being read.
    ///   - readProgress: The read progress as a percentage.
    func updateCurrentPageNumber(_ pageNumber: Int, readProgress: Int) {
        coverImageCache.updateProgress(to: readProgress)
        
        DispatchQueue.main.async { [unowned self] in
            store.updateCurrentPageNumber(pageNumber, comicType: comicType)
        }
    }
    
    /// Saves a chapter cover image and its metadata to the cache.
    /// - Parameters:
    ///   - imageData: The image data of the cover.
    ///   - metadata: The metadata associated with the cover image.
    /// - Throws: An error if the image data cannot be saved.
    func saveChapterCoverImage(imageData: Data, metadata: CoverImageMetaData) throws {
        coverImageCache.saveCurrentChapterData(imageData: imageData, metadata: metadata)
    }
    
    /// Loads a cached image for a specific chapter and page.
    /// - Parameters:
    ///   - chapter: The chapter number.
    ///   - page: The page number.
    /// - Returns: The cached `PageInfo` object if available.
    /// - Throws: An error if the image cannot be loaded.
    func loadCachedImage(chapter: Int, page: Int) throws -> PageInfo? {
        let singlePagePath = getCacheDirectory(for: chapter, page: page)
        
        if let data = fileManager.contents(atPath: singlePagePath.path) {
            return PageInfo(chapter: chapter, pageNumber: page, secondPageNumber: nil, imageData: data)
        }

        let chapterFolder = singlePagePath.deletingLastPathComponent()
        let metadataFile = chapterFolder.appendingPathComponent("metadata.json")
        
        if let metadataData = fileManager.contents(atPath: metadataFile.path),
           let metadata = try? JSONSerialization.jsonObject(with: metadataData, options: []) as? [String: Any],
           let pages = metadata["pages"] as? [[String: Any]],
           let pageEntry = pages.first(where: { $0["pageNumber"] as? Int == page }),
           let fileName = pageEntry["fileName"] as? String,
           let secondPageNumber = pageEntry["secondPageNumber"] as? Int {
            
            let twoPagePath = chapterFolder.appendingPathComponent(fileName)
            if let data = fileManager.contents(atPath: twoPagePath.path) {
                return PageInfo(chapter: chapter, pageNumber: page, secondPageNumber: secondPageNumber, imageData: data)
            }
        }
        
        return nil
    }
    
    /// Saves a page image and its metadata to the cache.
    /// - Parameter pageInfo: The `PageInfo` object containing image data and metadata.
    /// - Throws: An error if the image data or metadata cannot be saved.
    func savePageImage(pageInfo: PageInfo) throws {
        let filePath = getCacheDirectory(for: pageInfo.chapter, page: pageInfo.pageNumber, secondPageNumber: pageInfo.secondPageNumber)
        let chapterFolder = filePath.deletingLastPathComponent()
        try fileManager.createDirectory(at: chapterFolder, withIntermediateDirectories: true)
        
        try pageInfo.imageData.write(to: filePath)
        
        if let secondPageNumber = pageInfo.secondPageNumber {
            let metadataFile = chapterFolder.appendingPathComponent("metadata.json")
            var metadata: [String: Any] = [:]
            
            if let existingData = fileManager.contents(atPath: metadataFile.path),
               let existingMetadata = try? JSONSerialization.jsonObject(with: existingData, options: []) as? [String: Any] {
                metadata = existingMetadata
            }
            
            var pages = metadata["pages"] as? [[String: Any]] ?? []
            let pageEntry: [String: Any] = [
                "pageNumber": pageInfo.pageNumber,
                "secondPageNumber": secondPageNumber,
                "fileName": "Page_\(pageInfo.pageNumber)-\(secondPageNumber).jpg"
            ]
            
            pages.append(pageEntry)
            metadata["pages"] = pages
            
            let updatedData = try JSONSerialization.data(withJSONObject: metadata, options: [.prettyPrinted])
            try updatedData.write(to: metadataFile)
        }
    }
}

// MARK: - Private Methods
private extension ComicImageCacheAdapter {
    /// Constructs the file path for caching a page image.
    /// - Parameters:
    ///   - chapter: The chapter number.
    ///   - page: The page number.
    ///   - secondPageNumber: The second page number if applicable.
    /// - Returns: A `URL` representing the file path in the cache directory.
    func getCacheDirectory(for chapter: Int, page: Int, secondPageNumber: Int? = nil) -> URL {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = secondPageNumber != nil ? "Page_\(page)-\(secondPageNumber!).jpg" : "Page_\(page).jpg"
        
        return cacheDirectory.appendingPathComponent("Chapters/Chapter_\(chapter)/\(fileName)")
    }
}


// MARK: - Dependencies
protocol ComicPageStore {
    func updateCurrentPageNumber(_ pageNumber: Int, comicType: ComicType)
}

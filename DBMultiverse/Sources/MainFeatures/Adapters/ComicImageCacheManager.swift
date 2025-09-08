//
//  ComicImageCacheManager.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation
import DBMultiverseComicKit

@MainActor
struct ComicImageCacheManager {
    /// The type of comic (e.g., story or specials) for which the manager is responsible.
    private let comicType: ComicType
    
    /// The file system operations abstraction for accessing and modifying the file system.
    private let fileSystemOperations: FileSystemOperations
    
    /// The store used for updating page progress.
    private let store: ComicPageStore
    
    /// The delegate for managing cover images and progress metadata.
    private let coverImageDelegate: CoverImageDelegate
    
    /// Initializes the `ComicImageCacheManager` with its dependencies.
    /// - Parameters:
    ///   - comicType: The type of comic (story or specials).
    ///   - store: The store for managing chapter progress.
    ///   - fileSystemOperations: The file system operations abstraction.
    ///   - coverImageDelegate: The delegate for cover image operations.
    init(comicType: ComicType, store: ComicPageStore, fileSystemOperations: FileSystemOperations, coverImageDelegate: CoverImageDelegate) {
        self.comicType = comicType
        self.store = store
        self.fileSystemOperations = fileSystemOperations
        self.coverImageDelegate = coverImageDelegate
    }
}

// MARK: - Cache
extension ComicImageCacheManager: ComicImageCache {
    /// Updates the current page number and read progress in the cache.
    /// - Parameters:
    ///   - pageNumber: The current page number being read.
    ///   - readProgress: The read progress as a percentage.
    func updateCurrentPageNumber(_ pageNumber: Int, readProgress: Int) {
        coverImageDelegate.updateProgress(to: readProgress)
        
        let store = self.store
        let comicType = self.comicType
        DispatchQueue.main.async {
            store.updateCurrentPageNumber(pageNumber, comicType: comicType)
        }
    }
    
    /// Saves a chapter cover image and its metadata to the cache.
    /// - Parameters:
    ///   - imageData: The image data of the cover.
    ///   - metadata: The metadata associated with the cover image.
    /// - Throws: An error if the image data cannot be saved.
    func saveChapterCoverImage(imageData: Data, metadata: CoverImageMetaData) throws {
        coverImageDelegate.saveCurrentChapterData(imageData: imageData, metadata: metadata)
    }
    
    /// Loads a cached image for a specific chapter and page.
    /// - Parameters:
    ///   - chapter: The chapter number.
    ///   - page: The page number.
    /// - Returns: The cached `PageInfo` object if available.
    /// - Throws: An error if the image cannot be loaded.
    func loadCachedImage(chapter: Int, page: Int) throws -> PageInfo? {
        let singlePagePath = getCacheDirectory(for: chapter, page: page)
        
        if let data = fileSystemOperations.contents(atPath: singlePagePath.path) {
            return PageInfo(chapter: chapter, pageNumber: page, secondPageNumber: nil, imageData: data)
        }

        let chapterFolder = singlePagePath.deletingLastPathComponent()
        let metadataFile = chapterFolder.appendingPathComponent("metadata.json")
        
        if let metadataData = fileSystemOperations.contents(atPath: metadataFile.path),
           let metadata = try? JSONSerialization.jsonObject(with: metadataData, options: []) as? [String: Any],
           let pages = metadata["pages"] as? [[String: Any]],
           let pageEntry = pages.first(where: { $0["pageNumber"] as? Int == page }),
           let fileName = pageEntry["fileName"] as? String,
           let secondPageNumber = pageEntry["secondPageNumber"] as? Int {
            
            let twoPagePath = chapterFolder.appendingPathComponent(fileName)
            if let data = fileSystemOperations.contents(atPath: twoPagePath.path) {
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
        try fileSystemOperations.createDirectory(at: chapterFolder, withIntermediateDirectories: true)
        
        try fileSystemOperations.write(data: pageInfo.imageData, to: filePath)
        
        if let secondPageNumber = pageInfo.secondPageNumber {
            let metadataFile = chapterFolder.appendingPathComponent("metadata.json")
            var metadata: [String: Any] = [:]
            
            if let existingData = fileSystemOperations.contents(atPath: metadataFile.path),
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
            try fileSystemOperations.write(data: updatedData, to: metadataFile)
        }
    }
}

// MARK: - Private Methods
private extension ComicImageCacheManager {
    /// Constructs the file path for caching a page image.
    /// - Parameters:
    ///   - chapter: The chapter number.
    ///   - page: The page number.
    ///   - secondPageNumber: The second page number if applicable.
    /// - Returns: A `URL` representing the file path in the cache directory.
    func getCacheDirectory(for chapter: Int, page: Int, secondPageNumber: Int? = nil) -> URL {
        let cacheDirectory = fileSystemOperations.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = secondPageNumber != nil ? "Page_\(page)-\(secondPageNumber!).jpg" : "Page_\(page).jpg"
        
        return cacheDirectory.appendingPathComponent("Chapters/Chapter_\(chapter)/\(fileName)")
    }
}


// MARK: - Dependencies
@MainActor
protocol ComicPageStore {
    func updateCurrentPageNumber(_ pageNumber: Int, comicType: ComicType)
}

@MainActor
protocol CoverImageDelegate {
    func updateProgress(to newProgress: Int)
    func saveCurrentChapterData(imageData: Data, metadata: CoverImageMetaData)
}

protocol FileSystemOperations: Sendable {
    func write(data: Data, to url: URL) throws
    func contents(atPath path: String) -> Data?
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
}

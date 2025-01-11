//
//  ComicPageManager.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation
import DBMultiverseComicKit

/// Manages comic pages, handling caching, fetching, and progress updates for a specific chapter.
final class ComicPageManager {
    /// The current chapter being managed.
    private let chapter: Chapter
    
    /// The language of the comic being managed.
    private let language: ComicLanguage
    
    /// Handles caching of comic images.
    private let imageCache: ComicImageCache
    
    /// Handles network requests for fetching comic pages.
    private let networkService: ComicPageNetworkService
    
    /// Handles chapter progress updates such as marking chapters as read.
    private let chapterProgressHandler: ChapterProgressHandler
    
    /// Initializes the comic page manager with its dependencies.
    /// - Parameters:
    ///   - chapter: The chapter to be managed.
    ///   - language: The language of the comic.
    ///   - imageCache: A cache for storing and retrieving comic images.
    ///   - networkService: A service for fetching comic pages from a network.
    ///   - chapterProgressHandler: A handler for updating chapter progress.
    init(chapter: Chapter, language: ComicLanguage, imageCache: ComicImageCache, networkService: ComicPageNetworkService, chapterProgressHandler: ChapterProgressHandler) {
        self.chapter = chapter
        self.language = language
        self.imageCache = imageCache
        self.networkService = networkService
        self.chapterProgressHandler = chapterProgressHandler
    }
}

// MARK: - Delegate
extension ComicPageManager: ComicPageDelegate {
    /// Saves the chapter cover page to the cache with associated metadata.
    /// - Parameter info: The `PageInfo` containing image data and page details.
    func saveChapterCoverPage(_ info: PageInfo) {
        let readProgress = calculateProgress(page: info.pageNumber)
        let metadata = CoverImageMetaData(chapterName: chapter.name, chapterNumber: chapter.number, readProgress: readProgress)
        
        try? imageCache.saveChapterCoverImage(imageData: info.imageData, metadata: metadata)
    }
    
    /// Updates the last read page number and caches the progress.
    /// - Parameter pageNumber: The page number to update as the last read.
    func updateCurrentPageNumber(_ pageNumber: Int) {
        updateChapterProgress(lastReadPage: pageNumber)
        imageCache.updateCurrentPageNumber(pageNumber, readProgress: calculateProgress(page: pageNumber))
    }

    /// Loads a list of comic pages, either from the cache or by fetching them from the network.
    /// - Parameter pages: The list of page numbers to load.
    /// - Returns: An array of `PageInfo` for the requested pages.
    /// - Throws: An error if the pages cannot be loaded or cached.
    func loadPages(_ pages: [Int]) async throws -> [PageInfo] {
        var infoList = [PageInfo]()
        
        // TODO: - Handle thrown errors properly
        for page in pages {
            if !page.isSecondPage {
                if let cachedInfo = try? imageCache.loadCachedImage(chapter: chapter.number, page: page) {
                    infoList.append(cachedInfo)
                } else if let fetchedInfo = await fetchPageInfo(page: page) {
                    infoList.append(fetchedInfo)
                    try? imageCache.savePageImage(pageInfo: fetchedInfo)
                }
            }
        }
        
        return infoList
    }
}

// MARK: - Private Methods
private extension ComicPageManager {
    /// Updates the chapter progress based on the last read page.
    /// - Parameter lastReadPage: The last page number read in the chapter.
    func updateChapterProgress(lastReadPage: Int) {
        chapterProgressHandler.updateLastReadPage(page: lastReadPage, chapter: chapter)
        
        if chapter.endPage == lastReadPage {
            chapterProgressHandler.markChapterAsRead(chapter)
        }
    }
    
    /// Calculates the read progress of the chapter as a percentage.
    /// - Parameter page: The page number currently being read.
    /// - Returns: The progress as a percentage (0–100).
    func calculateProgress(page: Int) -> Int {
        let totalPages = chapter.endPage - chapter.startPage + 1
        let pagesRead = page - chapter.startPage + 1
        
        return max(0, min((pagesRead * 100) / totalPages, 100))
    }
    
    /// Fetches information about a specific comic page from the network.
    /// - Parameter page: The page number to fetch.
    /// - Returns: A `PageInfo` object if the page is successfully fetched; otherwise, `nil`.
    func fetchPageInfo(page: Int) async -> PageInfo? {
        do {
            let url = URLFactory.makeURL(language: language, pathComponent: .comicPage(page))
            let imageData = try await networkService.fetchImageData(from: url)

            return .init(chapter: chapter.number, pageNumber: page, secondPageNumber: page.secondPage, imageData: imageData)
        } catch {
            return nil
        }
    }
}

// MARK: - Dependencies
/// Protocol defining a service for fetching comic page data from the network.
protocol ComicPageNetworkService {
    /// Fetches image data from a given URL.
    /// - Parameter url: The URL to fetch image data from.
    /// - Returns: The image data fetched from the network.
    /// - Throws: An error if the data cannot be fetched.
    func fetchImageData(from url: URL?) async throws -> Data
}

/// Protocol defining methods for managing chapter progress.
protocol ChapterProgressHandler {
    /// Marks the given chapter as read.
    /// - Parameter chapter: The chapter to mark as read.
    func markChapterAsRead(_ chapter: Chapter)
    
    /// Updates the last read page for the given chapter.
    /// - Parameters:
    ///   - page: The last page number read.
    ///   - chapter: The chapter to update progress for.
    func updateLastReadPage(page: Int, chapter: Chapter)
}

/// Protocol defining a cache for comic images.
protocol ComicImageCache {
    /// Saves the given page image data to the cache.
    /// - Parameter pageInfo: The `PageInfo` to save.
    /// - Throws: An error if the image cannot be saved.
    func savePageImage(pageInfo: PageInfo) throws
    
    /// Loads cached image data for a specific chapter and page.
    /// - Parameters:
    ///   - chapter: The chapter number.
    ///   - page: The page number.
    /// - Returns: The cached `PageInfo` if available.
    /// - Throws: An error if the image cannot be loaded.
    func loadCachedImage(chapter: Int, page: Int) throws -> PageInfo?
    
    /// Updates the current page number and read progress in the cache.
    /// - Parameters:
    ///   - pageNumber: The current page number.
    ///   - readProgress: The read progress as a percentage.
    func updateCurrentPageNumber(_ pageNumber: Int, readProgress: Int)
    
    /// Saves the chapter cover image with associated metadata.
    /// - Parameters:
    ///   - imageData: The image data to save.
    ///   - metadata: The metadata describing the cover image.
    /// - Throws: An error if the image cannot be saved.
    func saveChapterCoverImage(imageData: Data, metadata: CoverImageMetaData) throws
}

// MARK: - Extension Dependencies
/// There are 2 instances where the comic displays  2 pages at a time. This handles those scenarios
fileprivate extension Int {
    /// Determines if the page is a second page (e.g., page 9 or 21).
    var isSecondPage: Bool {
        return self == 9 || self == 21
    }
    
    /// Returns the associated second page number if applicable.
    var secondPage: Int? {
        return self == 8 ? 9 : self == 20 ? 21 : nil
    }
}

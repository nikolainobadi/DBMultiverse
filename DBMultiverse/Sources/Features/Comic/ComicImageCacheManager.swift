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
    private let comicType: ComicType
    private let store: any ComicPageStore
    private let coverImageDelegate: any CoverImageDelegate
    private let widgetTimelineReloader: any WidgetTimelineReloader
    private let comicImageCacheDelegate: any ComicImageCacheDelegate

    /// Creates a new comic image cache manager.
    /// - Parameters:
    ///   - comicType: The type of comic being cached.
    ///   - store: The store for persisting comic page data.
    ///   - coverImageDelegate: The delegate for managing cover image data and metadata.
    ///   - widgetTimelineReloader: The reloader for updating widget timelines when cache changes occur.
    ///   - comicImageCacheDelegate: The delegate for file system operations on cached images.
    init(comicType: ComicType, store: any ComicPageStore, coverImageDelegate: any CoverImageDelegate, widgetTimelineReloader: any WidgetTimelineReloader, comicImageCacheDelegate: any ComicImageCacheDelegate) {
        self.comicType = comicType
        self.store = store
        self.coverImageDelegate = coverImageDelegate
        self.widgetTimelineReloader = widgetTimelineReloader
        self.comicImageCacheDelegate = comicImageCacheDelegate
    }
}


// MARK: - Cache
extension ComicImageCacheManager: ComicImageCache {
    func updateCurrentPageNumber(_ pageNumber: Int, readProgress: Int) {
        coverImageDelegate.updateProgress(to: readProgress)
        store.updateCurrentPageNumber(pageNumber, comicType: comicType)
        widgetTimelineReloader.notifyProgressChange(progress: readProgress)
    }
    
    func saveChapterCoverImage(imageData: Data, metadata: CoverImageMetaData) throws {
        coverImageDelegate.saveCurrentChapterData(imageData: imageData, metadata: metadata)
        widgetTimelineReloader.notifyChapterChange(chapter: metadata.chapterNumber, progress: metadata.readProgress)
    }
    
    func loadCachedImage(chapter: Int, page: Int) throws -> PageInfo? {
        let singlePagePath = getCacheDirectory(for: chapter, page: page)
        
        if let data = comicImageCacheDelegate.contents(atPath: singlePagePath.path) {
            return PageInfo(chapter: chapter, pageNumber: page, secondPageNumber: nil, imageData: data)
        }

        let chapterFolder = singlePagePath.deletingLastPathComponent()
        let metadataFile = chapterFolder.appendingPathComponent("metadata.json")
        
        if let metadataData = comicImageCacheDelegate.contents(atPath: metadataFile.path),
           let metadata = try? JSONSerialization.jsonObject(with: metadataData, options: []) as? [String: Any],
           let pages = metadata["pages"] as? [[String: Any]],
           let pageEntry = pages.first(where: { $0["pageNumber"] as? Int == page }),
           let fileName = pageEntry["fileName"] as? String,
           let secondPageNumber = pageEntry["secondPageNumber"] as? Int {
            
            let twoPagePath = chapterFolder.appendingPathComponent(fileName)
            if let data = comicImageCacheDelegate.contents(atPath: twoPagePath.path) {
                return PageInfo(chapter: chapter, pageNumber: page, secondPageNumber: secondPageNumber, imageData: data)
            }
        }
        
        return nil
    }
    
    func savePageImage(pageInfo: PageInfo) throws {
        let filePath = getCacheDirectory(for: pageInfo.chapter, page: pageInfo.pageNumber, secondPageNumber: pageInfo.secondPageNumber)
        let chapterFolder = filePath.deletingLastPathComponent()
        try comicImageCacheDelegate.createDirectory(at: chapterFolder, withIntermediateDirectories: true)
        try comicImageCacheDelegate.write(data: pageInfo.imageData, to: filePath)
        
        if let secondPageNumber = pageInfo.secondPageNumber {
            let metadataFile = chapterFolder.appendingPathComponent("metadata.json")
            var metadata: [String: Any] = [:]
            
            if let existingData = comicImageCacheDelegate.contents(atPath: metadataFile.path),
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
            try comicImageCacheDelegate.write(data: updatedData, to: metadataFile)
        }
    }
}


// MARK: - Private Methods
private extension ComicImageCacheManager {
    func getCacheDirectory(for chapter: Int, page: Int, secondPageNumber: Int? = nil) -> URL {
        let cacheDirectory = comicImageCacheDelegate.getCacheDirectoryURL()!
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

@MainActor
protocol WidgetTimelineReloader: AnyObject {
    func notifyChapterChange(chapter: Int, progress: Int)
    func notifyProgressChange(progress: Int)
}

protocol ComicImageCacheDelegate: Sendable {
    func getCacheDirectoryURL() -> URL?
    func write(data: Data, to url: URL) throws
    func contents(atPath path: String) -> Data?
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws
}

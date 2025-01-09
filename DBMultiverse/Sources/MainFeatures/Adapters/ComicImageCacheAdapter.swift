//
//  ComicImageCacheAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation
import DBMultiverseComicKit

final class ComicImageCacheAdapter {
    private let comicType: ComicType
    private let fileManager: FileManager
    private let coverImageCache: CoverImageCache
    private let viewModel: MainFeaturesViewModel
    
    init(comicType: ComicType, viewModel: MainFeaturesViewModel, fileManager: FileManager = .default, coverImageCache: CoverImageCache = .shared) {
        self.comicType = comicType
        self.viewModel = viewModel
        self.fileManager = fileManager
        self.coverImageCache = coverImageCache
    }
}


// MARK: - Cache
extension ComicImageCacheAdapter: ComicImageCache {
    func savePageImage(pageInfo: PageInfo) {
        // TODO: - maybe move to coverImageCache?
        try? throwingSavePageImage(pageInfo: pageInfo)
    }
    
    func loadCachedImage(chapter: Int, page: Int) -> PageInfo? {
        return try? throwingloadCachedImage(chapter: chapter, page: page)
    }
    
    func updateCurrentPageNumber(_ pageNumber: Int, readProgress: Int) {
        viewModel.updateCurrentPageNumber(pageNumber, comicType: comicType)
        coverImageCache.updateProgress(to: pageNumber)
    }
    
    func saveChapterCoverImage(imageData: Data, metadata: CoverImageMetaData) throws {
        coverImageCache.saveCurrentChapterData(imageData: imageData, metadata: metadata)
    }
}


// MARK: - Private Methods
private extension ComicImageCacheAdapter {
    func getCacheDirectory(for chapter: Int, page: Int, secondPageNumber: Int? = nil) -> URL {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = secondPageNumber != nil ? "Page_\(page)-\(secondPageNumber!).jpg" : "Page_\(page).jpg"
        return cacheDirectory.appendingPathComponent("Chapters/Chapter_\(chapter)/\(fileName)")
    }
    
    func throwingSavePageImage(pageInfo: PageInfo) throws {
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
    
    func throwingloadCachedImage(chapter: Int, page: Int) throws -> PageInfo? {
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
}

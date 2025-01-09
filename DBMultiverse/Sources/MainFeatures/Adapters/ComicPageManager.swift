//
//  ComicPageManager.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation
import DBMultiverseComicKit

final class ComicPageManager {
    private let chapter: Chapter
    private let imageCache: ComicImageCache
    private let networkService: ComicPageNetworkService
    
    init(chapter: Chapter, imageCache: ComicImageCache, networkService: ComicPageNetworkService) {
        self.chapter = chapter
        self.imageCache = imageCache
        self.networkService = networkService
    }
}


// MARK: - Delegate
extension ComicPageManager: ComicPageDelegate {
    func saveChapterCoverPage(_ info: PageInfo) {
        let readProgress = calculateProgress(page: info.pageNumber)
        let metadata = CoverImageMetaData(chapterName: chapter.name, chapterNumber: chapter.number, readProgress: readProgress)
        
        try? imageCache.saveChapterCoverImage(imageData: info.imageData, metadata: metadata)
    }
    
    func updateCurrentPageNumber(_ pageNumber: Int) {
        imageCache.updateCurrentPageNumber(pageNumber, readProgress: calculateProgress(page: pageNumber))
    }

    func loadPages(_ pages: [Int]) async throws -> [PageInfo] {
        var infoList = [PageInfo]()
        
        for page in pages {
            if !page.isSecondPage {
                if let cachedInfo = imageCache.loadCachedImage(chapter: chapter.number, page: page) {
                    print("found page \(page) in cache for chapter \(chapter.number)")
                    infoList.append(cachedInfo)
                } else if let fetchedInfo = await fetchPageInfo(page: page) {
                    infoList.append(fetchedInfo)
                    imageCache.savePageImage(pageInfo: fetchedInfo)
                }
            }
        }
        
        return infoList
    }
}


// MARK: - Private Methods
private extension ComicPageManager {
    func calculateProgress(page: Int) -> Int {
        let totalPages = chapter.endPage - chapter.startPage + 1
        let pagesRead = page - chapter.startPage + 1
        
        return max(0, min((pagesRead * 100) / totalPages, 100))
    }
    
    func fetchPageInfo(page: Int) async -> PageInfo? {
        print("fetching page \(page) for chapter \(chapter.number)")
        do {
            let url = URL(string: .makeFullURLString(suffix: "/en/page-\(page).html"))
            let imageData = try await networkService.fetchImageData(from: url)

            return .init(chapter: chapter.number, pageNumber: page, secondPageNumber: page.secondPage, imageData: imageData)
        } catch {
            return nil
        }
    }
}


// MARK: - Dependencies
protocol ComicPageNetworkService {
    func fetchImageData(from url: URL?) async throws -> Data
}

protocol ComicImageCache {
    func savePageImage(pageInfo: PageInfo)
    func loadCachedImage(chapter: Int, page: Int) -> PageInfo?
    func updateCurrentPageNumber(_ pageNumber: Int, readProgress: Int)
    func saveChapterCoverImage(imageData: Data, metadata: CoverImageMetaData) throws
}


// MARK: - Extension Dependencies
fileprivate extension Int {
    var isSecondPage: Bool {
        return self == 9 || self == 21
    }
    
    var secondPage: Int? {
        return self == 8 ? 9 : self == 20 ? 21 : nil
    }
}



// MARK: - Networker
import SwiftSoup

final class ComicPageNetworkServiceAdapter: ComicPageNetworkService {
    func fetchImageData(from url: URL?) async throws -> Data {
        let data = try await fetchData(from: url)
        let imageURL = try parseURL(from: data)
        
        return try await fetchData(from: imageURL)
    }
}


// MARK: - Private Methods
private extension ComicPageNetworkServiceAdapter {
    func fetchData(from url: URL?) async throws -> Data {
        guard let url else {
            throw CustomError.urlError
        }
        
        return try await URLSession.shared.data(from: url).0
    }
    
    func parseURL(from data: Data) throws -> URL? {
        let html = String(data: data, encoding: .utf8) ?? ""
        let document = try SwiftSoup.parse(html)
        
        guard let imgElement = try document.select("img[id=balloonsimg]").first() else {
            return nil
        }
        
        let imgSrc = try imgElement.attr("src")
        
        return .init(string: .makeFullURLString(suffix: imgSrc))
    }
}


// MARK: - Adapter
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

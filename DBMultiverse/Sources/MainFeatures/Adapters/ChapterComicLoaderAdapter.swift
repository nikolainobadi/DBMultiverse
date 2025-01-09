//
//  ChapterComicLoaderAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/12/24.
//

import SwiftSoup
import Foundation
import DBMultiverseComicKit

final class ChapterComicLoaderAdapter {
    private let imageCache: ComicPageImageCache
    private let imageParser: ComicPageImageParser
    private let networkService: ComicPageNetworkService
    
    init(imageCache: ComicPageImageCache = ComicPageImageCacheAdapter(), imageParser: ComicPageImageParser = ComicImageParserAdapter(), networkService: ComicPageNetworkService = ComicPageNetworkServiceAdapter()) {
        self.imageCache = imageCache
        self.imageParser = imageParser
        self.networkService = networkService
    }
}

// MARK: - Loader
extension ChapterComicLoaderAdapter {
    func loadPages(chapterNumber: Int, pages: [Int]) async -> [PageInfo] {
        var infoList: [PageInfo] = []

        for page in pages {
            if !page.isSecondPage {
                if let cachedResult = try? imageCache.loadCachedImage(for: chapterNumber, page: page) {
                    infoList.append(cachedResult)
                } else if let pageInfo = await fetchImage(page: page, chapter: chapterNumber) {
                    infoList.append(pageInfo)
                    try? imageCache.saveImageToCache(pageInfo: pageInfo)
                }
            }
        }

        return infoList
    }
}


// MARK: - Fetch Image
private extension ChapterComicLoaderAdapter {
    func fetchImage(page: Int, chapter: Int) async -> PageInfo? {
        do {
            let url = URL(string: .makeFullURLString(suffix: "/en/page-\(page).html"))
            let data = try await networkService.fetchData(from: url)
            let imageURL = try imageParser.parseURL(from: data)
            let imageData = try await networkService.fetchData(from: imageURL)
            
            return .init(chapter: chapter, pageNumber: page, secondPageNumber: page.secondPage, imageData: imageData)
        } catch {
            print("failed to load image for chapter \(chapter), page: \(page)")
            return nil
        }
    }
}


// MARK: - Dependencies
protocol ComicPageNetworkService {
    func fetchData(from url: URL?) async throws -> Data
}

protocol ComicPageImageParser {
    func parseURL(from data: Data) throws -> URL?
}

protocol ComicPageImageCache {
    func saveImageToCache(pageInfo: PageInfo) throws
    func loadCachedImage(for chapter: Int, page: Int) throws -> PageInfo?
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
final class ComicPageNetworkServiceAdapter: ComicPageNetworkService {
    func fetchData(from url: URL?) async throws -> Data {
        guard let url else {
            throw CustomError.urlError
        }
        
        return try await URLSession.shared.data(from: url).0
    }
}


// MARK: - Parser
final class ComicImageParserAdapter: ComicPageImageParser {
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


// MARK: - ImageCache
final class ComicPageImageCacheAdapter {
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
}


// MARK: - Cache
extension ComicPageImageCacheAdapter: ComicPageImageCache {
    func loadCachedImage(for chapter: Int, page: Int) throws -> PageInfo? {
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
    
    func saveImageToCache(pageInfo: PageInfo) throws {
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
private extension ComicPageImageCacheAdapter {
    func getCacheDirectory(for chapter: Int, page: Int, secondPageNumber: Int? = nil) -> URL {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = secondPageNumber != nil ? "Page_\(page)-\(secondPageNumber!).jpg" : "Page_\(page).jpg"
        return cacheDirectory.appendingPathComponent("Chapters/Chapter_\(chapter)/\(fileName)")
    }
}

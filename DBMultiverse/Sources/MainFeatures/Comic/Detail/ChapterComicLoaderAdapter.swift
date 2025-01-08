//
//  ChapterComicLoaderAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/12/24.
//

import SwiftSoup
import Foundation

/// Adapter responsible for loading comic pages from the network or cache.
final class ChapterComicLoaderAdapter {
    /// The file manager used for handling file-related operations.
    private let fileManager: FileManager
    
    /// Initializes the loader adapter.
    /// - Parameter fileManager: The file manager instance to use (default is `.default`).
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
}

// MARK: - Loader
extension ChapterComicLoaderAdapter: ChapterComicLoader {
    /// Loads pages for a given chapter and list of page numbers.
    /// - Parameters:
    ///   - chapterNumber: The chapter number to load.
    ///   - pages: The page numbers to load.
    /// - Returns: An array of `PageInfo` objects for the requested pages.
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo] {
        var infoList: [PageInfo] = []

        for page in pages {
            if let cachedResult = try? loadCachedImage(for: chapterNumber, page: page) {
                infoList.append(cachedResult)
            } else if let pageInfo = try await fetchImage(page: page) {
                infoList.append(pageInfo)
                try saveImageToCache(pageInfo: pageInfo)
            }
        }

        return infoList
    }
}

// MARK: - Private Methods
private extension ChapterComicLoaderAdapter {
    /// Fetches an image for a specific page from the network.
    /// - Parameter page: The page number to fetch.
    /// - Returns: A `PageInfo` object if the image is successfully fetched.
    func fetchImage(page: Int) async throws -> PageInfo? {
        guard let url = URL(string: .makeFullURLString(suffix: "/en/page-\(page).html")) else {
            return nil
        }

        let data = try await URLSession.shared.data(from: url).0
        let imageURLInfo = try parseHTMLForImageURL(data: data)

        return try await downloadImage(from: imageURLInfo)
    }

    /// Parses HTML to extract the URL for an image.
    /// - Parameter data: The HTML data to parse.
    /// - Returns: A `PageImageURLInfo` object containing the image URL and metadata.
    func parseHTMLForImageURL(data: Data) throws -> PageImageURLInfo? {
        let html = String(data: data, encoding: .utf8) ?? ""
        let document = try SwiftSoup.parse(html)

        guard let metaTag = try document.select("meta[property=og:title]").first() else {
            return nil
        }

        let content = try metaTag.attr("content")
        let chapterRegex = try NSRegularExpression(pattern: #"Chapter (\d+)"#)
        let pageRegex = try NSRegularExpression(pattern: #"Page (\d+)"#)
        let chapterMatch = chapterRegex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content))
        let pageMatch = pageRegex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content))
        let chapter = chapterMatch.flatMap { match in
            Range(match.range(at: 1), in: content).flatMap { Int(content[$0]) }
        }
        let page = pageMatch.flatMap { match in
            Range(match.range(at: 1), in: content).flatMap { Int(content[$0]) }
        }

        let secondPage: Int? = {
            if let pageSpan = try? document.select("span.page").first(),
               let pageText = try? pageSpan.text() {
                let rangePattern = #"Page \d+-(\d+)"#
                let rangeRegex = try? NSRegularExpression(pattern: rangePattern)
                let rangeMatch = rangeRegex?.firstMatch(in: pageText, range: NSRange(pageText.startIndex..., in: pageText))
                return rangeMatch.flatMap { match in
                    Range(match.range(at: 1), in: pageText).flatMap { Int(pageText[$0]) }
                }
            }
            return nil
        }()

        guard let imgElement = try document.select("img[id=balloonsimg]").first() else {
            return nil
        }

        let imgSrc = try imgElement.attr("src")
        let url = URL(string: .makeFullURLString(suffix: imgSrc))

        guard let chapter, let page else {
            return nil
        }

        return .init(url: url, chapter: chapter, pageNumber: page, secondPageNumber: secondPage)
    }

    /// Downloads an image from a given URL.
    /// - Parameter info: The image URL and metadata.
    /// - Returns: A `PageInfo` object if the download is successful.
    func downloadImage(from info: PageImageURLInfo?) async throws -> PageInfo? {
        guard let info, let url = info.url else {
            return nil
        }

        let data = try await URLSession.shared.data(from: url).0
        return PageInfo(chapter: info.chapter, pageNumber: info.pageNumber, secondPageNumber: info.secondPageNumber, imageData: data)
    }

    /// Retrieves the cache directory for a specific chapter and page.
    /// - Parameters:
    ///   - chapter: The chapter number.
    ///   - page: The page number.
    ///   - secondPageNumber: The optional second page number for double-page spreads.
    /// - Returns: The file URL of the cached image.
    func getCacheDirectory(for chapter: Int, page: Int, secondPageNumber: Int? = nil) -> URL {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = secondPageNumber != nil ? "Page_\(page)-\(secondPageNumber!).jpg" : "Page_\(page).jpg"
        return cacheDirectory.appendingPathComponent("Chapters/Chapter_\(chapter)/\(fileName)")
    }

    /// Loads a cached image for a specific chapter and page.
    /// - Parameters:
    ///   - chapter: The chapter number.
    ///   - page: The page number.
    /// - Returns: A `PageInfo` object if the image is found in the cache.
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

    /// Saves a downloaded image to the cache.
    /// - Parameter pageInfo: The `PageInfo` object containing the image data.
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

// MARK: - Dependencies
/// Represents metadata and data for a single page.
struct PageInfo {
    let chapter: Int
    let pageNumber: Int
    let secondPageNumber: Int?
    let imageData: Data
}

/// Represents metadata for an image URL.
struct PageImageURLInfo {
    let url: URL?
    let chapter: Int
    let pageNumber: Int
    let secondPageNumber: Int?
}

// MARK: - Extension Dependencies
extension SwiftDataChapter {
    /// Checks if the given page number is within the chapter's range.
    /// - Parameter page: The page number to check.
    /// - Returns: `true` if the page is within range, otherwise `false`.
    func containsPage(_ page: Int) -> Bool {
        return page >= startPage && page <= endPage
    }
}

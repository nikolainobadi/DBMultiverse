//
//  ChapterComicLoaderAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/12/24.
//

import SwiftSoup
import Foundation

final class ChapterComicLoaderAdapter {
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
}


// MARK: - Loader
extension ChapterComicLoaderAdapter: ChapterComicLoader {
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo] {
        var pageInfos: [PageInfo] = []

        for page in pages {
            if let cachedImageData = try? loadCachedImage(for: chapterNumber, page: page) {
                pageInfos.append(PageInfo(chapter: chapterNumber, pageNumber: page, imageData: cachedImageData))
            } else {
                if let pageInfo = try await fetchImage(page: page) {
                    pageInfos.append(pageInfo)
                    try saveImageToCache(pageInfo: pageInfo)
                }
            }
        }

        return pageInfos
    }
    
    func loadPages(chapterNumber: Int, start: Int, end: Int) async throws -> [PageInfo] {
        var pages: [PageInfo] = []

        for page in start...end {
            if let cachedImageData = try? loadCachedImage(for: chapterNumber, page: page) {
                pages.append(PageInfo(chapter: chapterNumber, pageNumber: page, imageData: cachedImageData))
            } else {
                if let pageInfo = try await fetchImage(page: page) {
                    pages.append(pageInfo)
                    
                    try saveImageToCache(pageInfo: pageInfo)
                }
            }
        }

        return pages
    }
    
    func loadPages(chapter: SwiftDataChapter) async throws -> [PageInfo] {
        var pages: [PageInfo] = []

        for page in chapter.startPage...chapter.endPage {
            if let cachedImageData = try? loadCachedImage(for: chapter.number, page: page) {
                pages.append(PageInfo(chapter: chapter.number, pageNumber: page, imageData: cachedImageData))
            } else {
                if let pageInfo = try await fetchImage(page: page) {
                    pages.append(pageInfo)
                    
                    try saveImageToCache(pageInfo: pageInfo)
                }
            }
        }

        return pages
    }
}


// MARK: - Private Methods
private extension ChapterComicLoaderAdapter {
    func fetchImage(page: Int) async throws -> PageInfo? {
        guard let url = URL(string: .makeFullURLString(suffix: "/en/page-\(page).html")) else {
            return nil
        }

        let data = try await URLSession.shared.data(from: url).0
        let imageURLInfo = try parseHTMLForImageURL(data: data)

        return try await downloadImage(from: imageURLInfo)
    }

    func parseHTMLForImageURL(data: Data) throws -> PageImageURLInfo? {
        let html = String(data: data, encoding: .utf8) ?? ""
        let document = try SwiftSoup.parse(html)

        var chapter: Int?
        var page: Int?

        guard let metaTag = try document.select("meta[property=og:title]").first() else {
            return nil
        }

        let content = try metaTag.attr("content")
        let chapterRegex = try NSRegularExpression(pattern: #"Chapter (\d+)"#)
        let pageRegex = try NSRegularExpression(pattern: #"Page (\d+)"#)
        let chapterMatch = chapterRegex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content))
        let pageMatch = pageRegex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content))
        chapter = {
            if let match = chapterMatch, let range = Range(match.range(at: 1), in: content) {
                return Int(content[range])
            }
            return nil
        }()

        page = {
            if let match = pageMatch, let range = Range(match.range(at: 1), in: content) {
                return Int(content[range])
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

        return .init(url: url, chapter: chapter, pageNumber: page)
    }

    func downloadImage(from info: PageImageURLInfo?) async throws -> PageInfo? {
        guard let info, let url = info.url else {
            return nil
        }

        let data = try await URLSession.shared.data(from: url).0
        return PageInfo(chapter: info.chapter, pageNumber: info.pageNumber, imageData: data)
    }

    func getCacheDirectory(for chapter: Int, page: Int) -> URL {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let filePath = cacheDirectory.appendingPathComponent("Chapters/Chapter_\(chapter)/Page_\(page).jpg")
        
        return filePath
    }

    func loadCachedImage(for chapter: Int, page: Int) throws -> Data? {
        let filePath = getCacheDirectory(for: chapter, page: page)
        
        return fileManager.contents(atPath: filePath.path)
    }

    func saveImageToCache(pageInfo: PageInfo) throws {
        let filePath = getCacheDirectory(for: pageInfo.chapter, page: pageInfo.pageNumber)
        let chapterFolder = filePath.deletingLastPathComponent()
        try fileManager.createDirectory(at: chapterFolder, withIntermediateDirectories: true)
        
        try pageInfo.imageData.write(to: filePath)
    }
}


// MARK: - Dependencies
struct PageInfo {
    let chapter: Int
    let pageNumber: Int
    let imageData: Data
}

struct PageImageURLInfo {
    let url: URL?
    let chapter: Int
    let pageNumber: Int
}


// MARK: - Extension Dependencies
extension SwiftDataChapter {
    func containsPage(_ page: Int) -> Bool {
        return page >= startPage && page <= endPage
    }
}

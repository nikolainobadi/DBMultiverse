//
//  ComicViewDelegateAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/15/24.
//

import SwiftSoup
import Foundation

final class ComicViewDelegateAdapter {
    private let baseURL = "https://www.dragonball-multiverse.com/en/page-"
}


// MARK: - Delegate
extension ComicViewDelegateAdapter: ComicViewDelegate {
    func loadChapterPages(_ chapter: Chapter) async throws -> [OldPageInfo] {
        var pages: [OldPageInfo] = []
        
        for page in chapter.startPage...chapter.endPage {
            if let pageInfo = try await fetchImage(page: page) {
                pages.append(pageInfo)
            }
        }
        
        return pages
    }
}


// MARK: - Private Methods
private extension ComicViewDelegateAdapter {
    func fetchImage(page: Int) async throws -> OldPageInfo? {
        guard let url = URL(string: "\(baseURL)\(page).html") else {
            return nil
        }
        
        let data = try await URLSession.shared.data(from: url).0
        let imageURLInfo = try parseHTMLForImageURL(data: data)
        
        return try await downloadImage(from: imageURLInfo)
    }
    
    func parseHTMLForImageURL(data: Data) throws -> OldPageImageURLInfo? {
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
        let url = URL(string: "https://www.dragonball-multiverse.com" + imgSrc)
        
        guard let chapter, let page else {
            return nil
        }
        
        return .init(url: url, chapter: "\(chapter)", pageNumber: "\(page)")
    }
    
    func downloadImage(from info: OldPageImageURLInfo?) async throws -> OldPageInfo? {
        guard let info, let url = info.url else {
            return nil
        }
        
        let data = try await URLSession.shared.data(from: url).0
        
        return .init(imageData: data, chapter: info.chapter, pageNumber: info.pageNumber)
    }
}

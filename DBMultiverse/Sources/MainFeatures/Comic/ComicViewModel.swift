//
//  ComicViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/13/24.
//

import SwiftSoup
import Foundation

final class ComicViewModel: ObservableObject {
    @Published var currentPageNumber: Int
    @Published var pages: [NewPageInfo] = []
    
    private let chapter: Chapter
    private let baseURL = "https://www.dragonball-multiverse.com/en/page-"
    private let onChapterFinished: (String) -> Void
    
    init(chapter: Chapter, currentPageNumber: Int, onChapterFinished: @escaping (String) -> Void) {
        self.chapter = chapter
        self.currentPageNumber = currentPageNumber
        self.onChapterFinished = onChapterFinished
    }
}


// MARK: - DisplayData
extension ComicViewModel {
    var isLastPage: Bool {
        guard let currentPage, let pageNumber = Int(currentPage.pageNumber) else {
            return false
        }
        
        return pageNumber == chapter.endPage
    }
    
    var currentPage: NewPageInfo? {
        return pages[safe: currentPageNumber]
    }
    
    var previousButtonDisabled: Bool {
        return currentPageNumber <= chapter.startPage
    }
    
    var nextButtonDisabled: Bool {
        return currentPageNumber >= chapter.endPage
    }
    
    var currentPagePosition: String {
        let totalPages = chapter.endPage - chapter.startPage + 1
        let currentPageIndex = currentPageNumber - chapter.startPage + 1
        
        return "\(currentPageIndex)/\(totalPages)"
    }
}


// MARK: - Actions
extension ComicViewModel {
    func loadPages() async throws {
        var pages: [NewPageInfo] = []
        
        for page in chapter.startPage...chapter.endPage {
            if let pageInfo = try await fetchImage(page: page) {
                pages.append(pageInfo)
            }
        }
        
        await setPages(pages)
    }
    
    func previousPage() {
        if currentPageNumber > 0 {
            currentPageNumber -= 1
        }
    }
    
    func nextPage() {
        if currentPageNumber < pages.count - 1 {
            currentPageNumber += 1
        }
    }
    
    func finishChapter() {
        onChapterFinished(chapter.number)
    }
}


// MARK: MainActor
@MainActor
private extension ComicViewModel {
    func setPages(_ pages: [NewPageInfo]) {
        self.pages = pages
    }
}


// MARK: - Private Methods
private extension ComicViewModel {
    func fetchImage(page: Int) async throws -> NewPageInfo? {
        guard let url = URL(string: "\(baseURL)\(page).html") else {
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
        let url = URL(string: "https://www.dragonball-multiverse.com" + imgSrc)
        
        guard let chapter, let page else {
            return nil
        }
        
        return .init(url: url, chapter: "\(chapter)", pageNumber: "\(page)")
    }
    
    func downloadImage(from info: PageImageURLInfo?) async throws -> NewPageInfo? {
        guard let info, let url = info.url else {
            return nil
        }
        
        let data = try await URLSession.shared.data(from: url).0
        
        return .init(imageData: data, chapter: info.chapter, pageNumber: info.pageNumber)
    }
}

struct NewPageInfo {
    let imageData: Data
    let chapter: String
    let pageNumber: String
}

extension NewPageInfo {
    var title: String {
        if pageNumber == "0" {
            return ""
        }
        
        return "Chapter \(chapter) page \(pageNumber)"
    }
}


// MARK: - Exension Dependeencies
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

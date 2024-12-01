//
//  ChapterLoaderAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import SwiftSoup
import Foundation

final class ChapterLoaderAdapter {
    private let url = URL(string: "https://www.dragonball-multiverse.com/en/chapters.html?comic=page&chaptersmode=1")!
}


// MARK: - Loader
extension ChapterLoaderAdapter: ChapterLoader {
    func loadChapters() async throws -> [Chapter] {
        guard let html = try await loadHTML() else {
            return []
        }
        
        return try parseHTML(html)
    }
}


// MARK: - Private Methods
private extension ChapterLoaderAdapter {
    func loadHTML() async throws -> String? {
        let data = try await URLSession.shared.data(from: url).0
        
        return .init(data: data, encoding: .utf8)
    }
    
    func parseHTML(_ html: String) throws -> [Chapter] {
        let document = try SwiftSoup.parse(html)
        let chapterElements = try document.select("div.cadrelect.chapter")
        
        var loadedChapters: [Chapter] = []

        for chapterElement in chapterElements {
            let chapterTitle = try chapterElement.select("h4").text()
            if let match = chapterTitle.range(of: #"Chapter (\d+):"#, options: .regularExpression) {
                let numberString = String(chapterTitle[match])
                    .replacingOccurrences(of: "Chapter ", with: "")
                    .replacingOccurrences(of: ":", with: "")
                    .trimmingCharacters(in: .whitespaces)
                
                let pageLinks = try chapterElement.select("p a")
                
                if let startPageText = try? pageLinks.first()?.text(),
                   let endPageText = try? pageLinks.last()?.text(),
                   let startPage = Int(startPageText),
                   let endPage = Int(endPageText) {
                    
                    loadedChapters.append(.init(name: chapterTitle, number: numberString, startPage: startPage, endPage: endPage))
                }
            }
        }

        return loadedChapters
    }
}

//
//  ChapterLoaderAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import SwiftSoup
import Foundation
import DBMultiverseComicKit

/// Adapter responsible for loading chapter lists from a remote source and parsing the data.
final class ChapterLoaderAdapter {
    /// The URL used to fetch the chapter list HTML.
    private let url = URL(string: .makeFullURLString(suffix: "/en/chapters.html?comic=page&chaptersmode=1"))!
}

extension ChapterLoaderAdapter: ChapterLoader {
    func loadChapters() async throws -> [Chapter] {
        guard let html = try await loadHTML() else {
            throw CustomError.loadHTMLError
        }
        
        return try parseHTML(html)
    }
}

// MARK: - Private Methods
private extension ChapterLoaderAdapter {
    /// Fetches the HTML content of the chapter list from the remote URL.
    /// - Returns: The HTML content as a string, or `nil` if it cannot be decoded.
    /// - Throws: An error if the network request fails.
    func loadHTML() async throws -> String? {
        let data = try await URLSession.shared.data(from: url).0
        return .init(data: data, encoding: .utf8)
    }
    
    func parseHTML(_ html: String) throws -> [Chapter] {
        do {
            let document = try SwiftSoup.parse(html)
            let sections = try document.select("h1.horscadrelect")
            
            var allChapters: [Chapter] = []

            for section in sections {
                let sectionTitle = try section.text()
                let universe = extractUniverseNumber(sectionTitle)
                
                var currentElement = try section.nextElementSibling()
                var currentChapters: [Chapter] = []
                
                while let element = currentElement, element.tagName() != "h1" {
                    if element.hasClass("cadrelect") {
                        if let chapter = try parseChapter(element, universe: universe) {
                            currentChapters.append(chapter)
                        }
                    }
                    
                    currentElement = try element.nextElementSibling()
                }
                
                allChapters.append(contentsOf: currentChapters)
            }
            
            return allChapters
        } catch {
            throw CustomError.parseHTMLError
        }
    }

    /// Parses a chapter element from the HTML to create a `Chapter` object.
    /// - Parameter element: The HTML element representing a chapter.
    /// - Returns: A `Chapter` object, or `nil` if parsing fails.
    func parseChapter(_ element: Element, universe: Int?) throws -> Chapter? {
        let chapterTitle = try element.select("h4").text()
        
        if let match = chapterTitle.range(of: #"Chapter (\d+):"#, options: .regularExpression) {
            let numberString = String(chapterTitle[match])
                .replacingOccurrences(of: "Chapter ", with: "")
                .replacingOccurrences(of: ":", with: "")
                .trimmingCharacters(in: .whitespaces)
            
            let cleanedTitle = chapterTitle.replacingOccurrences(of: #"Chapter \d+:"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespaces)
            let pageLinks = try element.select("p a")
            
            if let startPageText = try? pageLinks.first()?.text(),
               let endPageText = try? pageLinks.last()?.text(),
               let startPage = Int(startPageText),
               let endPage = Int(endPageText),
               let number = Int(numberString) {
                
                let coverImageElement = try element.select("img").first()
                let coverImageURL = try coverImageElement?.attr("src") ?? ""
                
                return .init(name: cleanedTitle, number: number, startPage: startPage, endPage: endPage, universe: universe, lastReadPage: nil, coverImageURL: coverImageURL, didFinishReading: false)
            }
        }
        
        return nil
    }
    
    /// Extracts the universe number from a section title.
    /// - Parameter title: The section title.
    /// - Returns: The universe number, or `nil` if it cannot be extracted.
    func extractUniverseNumber(_ title: String) -> Int? {
        if title.lowercased().contains("tournament") {
            return nil
        } else if title.lowercased().contains("special") {
            let pattern = #"Special Universe (\d+)"#
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            if let match = regex?.firstMatch(in: title, options: [], range: NSRange(title.startIndex..., in: title)),
               let range = Range(match.range(at: 1), in: title) {
                return Int(title[range]) ?? Int.max
            }
        }
        
        return nil
    }
}
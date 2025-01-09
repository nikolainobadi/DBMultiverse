//
//  ComicHTMLParser.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import SwiftSoup
import Foundation
import DBMultiverseComicKit

enum ComicHTMLParser {
    static func parseChapterListHTML(_ html: String?) throws -> [Chapter] {
        do {
            guard let html else {
                throw ComicParseError.missingHTML
            }
            
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
            throw ComicParseError.chapterListParsingError
        }
    }
}


// MARK: - ChapterList Methods
private extension ComicHTMLParser {
    static func extractUniverseNumber(_ title: String) -> Int? {
        if title.lowercased().contains("dbmultiverse") {
            return nil
        }
        
        // Regex to match any number preceded by the word "Special" (case-insensitive)
        let pattern = #"(?i)\bSpecial\s+Universe\s+(\d+)\b"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        if let match = regex?.firstMatch(in: title, options: [], range: NSRange(title.startIndex..., in: title)),
           let range = Range(match.range(at: 1), in: title) {
            // Extract and return the number
            return Int(title[range]) ?? Int.max
        }
        
        if title.lowercased().contains("broly") {
            return 20
        }
        
        return nil
    }
    
    static func parseChapter(_ element: Element, universe: Int?) throws -> Chapter? {
        // Extract the chapter title
        let chapterTitle = try element.select("h4").text()
        
        // Use regex to find the first number in the title (before the colon)
        let numberPattern = #"\b(\d+)\b"#
        let numberMatch = chapterTitle.range(of: numberPattern, options: .regularExpression)
        
        // Extract the chapter number
        let chapterNumber: Int?
        if let numberMatch = numberMatch {
            let numberString = String(chapterTitle[numberMatch])
            chapterNumber = Int(numberString)
        } else {
            chapterNumber = nil // No number found
        }
        
        // Extract everything after the first colon
        let cleanedTitle: String
        if let colonRange = chapterTitle.range(of: ":") {
            cleanedTitle = String(chapterTitle[colonRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            cleanedTitle = chapterTitle // Fallback in case there's no colon
        }
        
        // Ensure chapter number exists (skip invalid entries)
        guard let number = chapterNumber else { return nil }
        
        // Extract page links
        let pageLinks = try element.select("p a")
        if let startPageText = try? pageLinks.first()?.text(),
           let endPageText = try? pageLinks.last()?.text(),
           let startPage = Int(startPageText),
           let endPage = Int(endPageText) {
            
            // Extract the cover image URL
            let coverImageElement = try element.select("img").first()
            let coverImageURL = try coverImageElement?.attr("src") ?? ""
            
            // Return the parsed Chapter object
            return .init(
                name: cleanedTitle,
                number: number,
                startPage: startPage,
                endPage: endPage,
                universe: universe,
                lastReadPage: nil,
                coverImageURL: coverImageURL,
                didFinishReading: false
            )
        }
        
        return nil
    }
}

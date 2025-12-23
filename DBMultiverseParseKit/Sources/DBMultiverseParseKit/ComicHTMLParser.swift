//
//  ComicHTMLParser.swift
//
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import SwiftSoup
import Foundation

public enum ComicHTMLParser {
    public static func parseComicPageImageSource(data: Data) throws -> String {
        do {
            let html = try makeHTML(from: data)
            let document = try SwiftSoup.parse(html)
    
            guard let imgElement = try document
                .select("#balloonsimg img")
                .first()
            else {
                throw ComicParseError.imageElementNotFound
            }
            
            return try imgElement.attr("src")
        } catch let error as ComicParseError {
            throw error // Re-throw the specific ComicParseError
        } catch {
            throw ComicParseError.invalidImageSource // Wrap any other error
        }
    }
    
    public static func parseChapterList(data: Data) throws -> [ParsedChapter] {
        do {
            let html = try makeHTML(from: data)
            let document = try SwiftSoup.parse(html)
            let sections = try document.select("h1.horscadrelect")
            
            var allChapters: [ParsedChapter] = []

            for section in sections {
                let sectionTitle = try section.text()
                let universe = extractUniverseNumber(sectionTitle)
                
                var currentElement = try section.nextElementSibling()
                var currentChapters: [ParsedChapter] = []

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
            throw ComicParseError.chapterListParsingFailure
        }
    }
}


// MARK: - Private Methods
private extension ComicHTMLParser {
    static func makeHTML(from data: Data) throws -> String {
        guard let html = String(data: data, encoding: .utf8) else {
            throw ComicParseError.missingHTMLDocument
        }
        
        return html
    }
    
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
    
    static func parseChapter(_ element: Element, universe: Int?) throws -> ParsedChapter? {
        do {
            // Extract the chapter title
            let chapterTitle = try element.select("h4").text()
            
            // Extract the chapter number using regex
            let numberPattern = #"\b(\d+)\b"#
            let chapterNumber = chapterTitle.range(of: numberPattern, options: .regularExpression)
                .flatMap { Int(chapterTitle[$0]) }
            
            // Ensure chapter number exists
            guard let number = chapterNumber else {
                throw ComicParseError.invalidChapterNumber
            }
            
            // Extract and clean the chapter title (everything after the colon, if present)
            let cleanedTitle = chapterTitle
                .split(separator: ":", maxSplits: 1)
                .dropFirst()
                .joined(separator: ":")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Extract page links and parse start and end pages
            let pageLinks = try element.select("p a")
            guard
                let startPage = try pageLinks.first().flatMap({ Int(try $0.text()) }),
                let endPage = try pageLinks.last().flatMap({ Int(try $0.text()) })
            else {
                throw ComicParseError.missingPageLinks
            }
            
            // Extract the cover image URL
            let coverImageURL = try element.select("img").first()?.attr("src") ?? ""
            
            // Return the parsed chapter object
            return .init(
                name: cleanedTitle,
                number: number,
                startPage: startPage,
                endPage: endPage,
                universe: universe,
                coverImageURL: coverImageURL
            )
        } catch let error as ComicParseError {
            throw error // Re-throw specific parsing errors
        } catch {
            throw ComicParseError.generalParsingFailure // Wrap other errors in a general parsing error
        }
    }
}

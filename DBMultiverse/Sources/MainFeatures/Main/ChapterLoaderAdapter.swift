//
//  ChapterLoaderAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import SwiftSoup
import Foundation

/// Adapter responsible for loading chapter lists from a remote source and parsing the data.
final class ChapterLoaderAdapter {
    /// The URL used to fetch the chapter list HTML.
    private let url = URL(string: .makeFullURLString(suffix: "/en/chapters.html?comic=page&chaptersmode=1"))!
}

// MARK: - DataStore
extension ChapterLoaderAdapter: ChapterDataStore {
    /// Loads and parses the list of chapters, splitting them into main story and specials.
    /// - Returns: A tuple containing arrays of main story chapters and specials.
    /// - Throws: `CustomError.loadHTMLError` or `CustomError.parseHTMLError` if loading or parsing fails.
    func loadChapterLists() async throws -> (mainStory: [OldChapter], specials: [OldSpecial]) {
        guard let html = try await loadHTML() else {
            throw CustomError.loadHTMLError
        }
        
        return try parseHTMLWithSpecials(html)
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
    
    /// Parses the provided HTML to extract main story and special chapters.
    /// - Parameter html: The HTML content to parse.
    /// - Returns: A tuple containing arrays of main story chapters and specials.
    /// - Throws: `CustomError.parseHTMLError` if parsing fails.
    func parseHTMLWithSpecials(_ html: String) throws -> ([OldChapter], [OldSpecial]) {
        do {
            let document = try SwiftSoup.parse(html)
            let sections = try document.select("h1.horscadrelect")
            
            var mainStory: [OldChapter] = []
            var specials: [OldSpecial] = []
            
            for section in sections {
                let sectionTitle = try section.text()
                
                var currentElement = try section.nextElementSibling()
                var currentChapters: [OldChapter] = []
                
                // Iterate over elements until the next section header.
                while let element = currentElement, element.tagName() != "h1" {
                    if element.hasClass("cadrelect") {
                        if let chapter = try parseChapter(element) {
                            currentChapters.append(chapter)
                        }
                    }
                    currentElement = try element.nextElementSibling()
                }
                
                // Categorize sections based on their titles.
                if sectionTitle.lowercased().contains("tournament") {
                    mainStory.append(contentsOf: currentChapters)
                } else if sectionTitle.lowercased().contains("special"),
                          let universeNumber = extractUniverseNumber(sectionTitle) {
                    specials.append(.init(universe: universeNumber, chapters: currentChapters))
                }
            }
            
            return (mainStory, specials)
        } catch {
            throw CustomError.parseHTMLError
        }
    }

    /// Parses a chapter element from the HTML to create a `Chapter` object.
    /// - Parameter element: The HTML element representing a chapter.
    /// - Returns: A `Chapter` object, or `nil` if parsing fails.
    func parseChapter(_ element: Element) throws -> OldChapter? {
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
                
                return OldChapter(name: cleanedTitle, number: number, startPage: startPage, endPage: endPage, coverImageURL: coverImageURL)
            }
        }
        
        return nil
    }
    
    /// Extracts the universe number from a section title.
    /// - Parameter title: The section title.
    /// - Returns: The universe number, or `nil` if it cannot be extracted.
    func extractUniverseNumber(_ title: String) -> Int? {
        let pattern = #"Special Universe (\d+)"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        if let match = regex?.firstMatch(in: title, options: [], range: NSRange(title.startIndex..., in: title)),
           let range = Range(match.range(at: 1), in: title) {
            return Int(title[range]) ?? Int.max
        }
        
        return nil
    }
}

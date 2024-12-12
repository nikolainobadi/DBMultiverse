//
//  ChapterLoaderAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import SwiftSoup
import Foundation

final class ChapterLoaderAdapter {
    private let url = URL(string: .makeFullURLString(suffix: "/en/chapters.html?comic=page&chaptersmode=1"))!
}

extension ChapterLoaderAdapter: ChapterDataStore {
    func loadChapterLists() async throws -> (mainStory: [Chapter], specials: [Special]) {
        guard let html = try await loadHTML() else {
            throw CustomError.loadHTMLError
        }
        
        print("---------- Start ----------")
        print(html)
        print("---------- END ----------")
        
        return try parseHTMLWithSpecials(html)
    }
}


// MARK: - Private Methods
private extension ChapterLoaderAdapter {
    func loadHTML() async throws -> String? {
        let data = try await URLSession.shared.data(from: url).0
        
        return .init(data: data, encoding: .utf8)
    }
    
    func parseHTMLWithSpecials(_ html: String) throws -> ([Chapter], [Special]) {
        do {
            let document = try SwiftSoup.parse(html)
            let sections = try document.select("h1.horscadrelect")
            
            var mainStory: [Chapter] = []
            var specials: [Special] = []
            
            // Iterate over each section
            for section in sections {
                let sectionTitle = try section.text()
                var currentElement = try section.nextElementSibling()
                
                // Iterate through all sibling elements until the next <h1> or end of document
                var currentChapters: [Chapter] = []
                while let element = currentElement, element.tagName() != "h1" {
                    if element.hasClass("cadrelect") {
                        if let chapter = try parseChapter(element) {
                            currentChapters.append(chapter)
                        }
                    }
                    currentElement = try element.nextElementSibling()
                }
                
                // Classify the section
                if sectionTitle.lowercased().contains("tournament") {
                    mainStory.append(contentsOf: currentChapters)
                } else if sectionTitle.lowercased().contains("special") {
                    specials.append(Special(title: sectionTitle, chapters: currentChapters))
                }
            }
            
            return (mainStory, specials)
        } catch {
            throw CustomError.parseHTMLError
        }
    }

    func parseChapter(_ element: Element) throws -> Chapter? {
        let chapterTitle = try element.select("h4").text()
        
        if let match = chapterTitle.range(of: #"Chapter (\d+):"#, options: .regularExpression) {
            let numberString = String(chapterTitle[match])
                .replacingOccurrences(of: "Chapter ", with: "")
                .replacingOccurrences(of: ":", with: "")
                .trimmingCharacters(in: .whitespaces)
            
            // Remove "Chapter", the number, and the colon from the title
            let cleanedTitle = chapterTitle.replacingOccurrences(of: #"Chapter \d+:"#, with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
            
            let pageLinks = try element.select("p a")
            if let startPageText = try? pageLinks.first()?.text(),
               let endPageText = try? pageLinks.last()?.text(),
               let startPage = Int(startPageText),
               let endPage = Int(endPageText),
               let number = Int(numberString) {
                
                // Extract cover image URL
                let coverImageElement = try element.select("img").first()
                let coverImageURL = try coverImageElement?.attr("src") ?? ""
                
                return Chapter(name: cleanedTitle, number: number, startPage: startPage, endPage: endPage, coverImageURL: coverImageURL)
            }
        }
        
        return nil
    }
}

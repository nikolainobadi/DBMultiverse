//
//  SwiftDataChapterStorageViewModifier.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import SwiftData
import DBMultiverseComicKit

struct SwiftDataChapterStorageViewModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @Query private var existingChapters: [SwiftDataChapter]
    
    let chapters: [Chapter]
    
    private func printChapterTuple(prefix: String, existing: SwiftDataChapter, chapter: Chapter) {
        print("\(prefix)!!! -> existing (number(\(existing.number)) name(\(existing.name), universe(\(existing.universe ?? 0), fetched (number(\(chapter.number)) name(\(chapter.name) universe(\(chapter.universe ?? 0)))")
    }
    
    private func shouldUpdateChapter(existing: SwiftDataChapter, chapter: Chapter) -> Bool {
        if existing.universe != chapter.universe {
            printChapterTuple(prefix: "WRONG UNIVERSE", existing: existing, chapter: chapter)
            return true
        } else if existing.name != chapter.name {
            printChapterTuple(prefix: "LANGUAGE CHANGE", existing: existing, chapter: chapter)
            return true
        } else if existing.endPage != chapter.endPage {
            printChapterTuple(prefix: "NEW PAGES", existing: existing, chapter: chapter)
            return true
        }
        
        return false
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: chapters) { _, newList in
                print("---------- existing chapters ----------")
                print("fetched \(existingChapters.count) chapters")
                print("---------- end existing chapters ----------\n\n")
                
                var missingChapters = 0
                for chapter in newList {
                    if let index = existingChapters.firstIndex(where: { $0.number == chapter.number }) {
                        if shouldUpdateChapter(existing: existingChapters[index], chapter: chapter) {
//                            modelContext.delete(existingChapters[index])
//                            modelContext.insert(SwiftDataChapter(chapter: chapter))
                        }
                    } else {
                        missingChapters += 1
                        print("should add chapter \(chapter.number): \(chapter.name)")
//                        modelContext.insert(SwiftDataChapter(chapter: chapter))
                    }
                }
                
                print("\n\nmissing \(missingChapters) chapters. 103 - \(missingChapters) = \(103 - missingChapters)")
            }
    }
}

extension View {
    func syncChaptersWithSwiftData(chapters: [Chapter]) -> some View {
        modifier(SwiftDataChapterStorageViewModifier(chapters: chapters))
    }
}


// MARK: - Extension Dependencies
fileprivate extension SwiftDataChapter {
    convenience init(chapter: Chapter) {
        self.init(name: chapter.name, number: chapter.number, startPage: chapter.startPage, endPage: chapter.endPage, universe: chapter.universe, lastReadPage: chapter.lastReadPage, coverImageURL: chapter.coverImageURL)
    }
}

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
    
    private func shouldUpdateChapter(existing: SwiftDataChapter, chapter: Chapter) -> Bool {
        if existing.universe != chapter.universe {
            return true
        } else if existing.name != chapter.name {
            return true
        } else if existing.endPage != chapter.endPage {
            return true
        }
        
        return false
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: chapters) { _, newList in
                for chapter in newList {
                    if let index = existingChapters.firstIndex(where: { $0.number == chapter.number }) {
                        if shouldUpdateChapter(existing: existingChapters[index], chapter: chapter) {
                            modelContext.delete(existingChapters[index])
                            modelContext.insert(SwiftDataChapter(chapter: chapter))
                        }
                    } else {
                        modelContext.insert(SwiftDataChapter(chapter: chapter))
                    }
                }
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

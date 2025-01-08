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
    
    func body(content: Content) -> some View {
        content
            .onChange(of: chapters) { _, newList in
                for chapter in newList {
                    if let existingChapterIndex = existingChapters.firstIndex(where: { $0.number == chapter.number }) {
                        if existingChapters[existingChapterIndex].endPage != chapter.endPage {
                            // TODO: -
                            print("chapter \(chapter.number) has received new pages, should update in SwiftData, currentEndPage: \(existingChapters[existingChapterIndex].endPage), newEndPage: \(chapter.endPage)")
                        }
                    } else {
                        print("adding chapter \(chapter.name) to SwiftData")
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

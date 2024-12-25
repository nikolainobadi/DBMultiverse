//
//  FetchChapterListViewModifier.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import SwiftData
import NnSwiftUIKit

struct FetchChapterListViewModifier: ViewModifier {
    @StateObject var repo: ChapterListRepository
    @Environment(\.isPreview) private var isPreview
    @Environment(\.modelContext) private var modelContext
    
    let existingChapterNumbers: [Int]
    
    // TODO: - will need to adjust to account for chapters that get new pages
    private func shouldAddChapter(_ chapter: Chapter) -> Bool {
        return !existingChapterNumbers.contains(chapter.number)
    }
    
    func body(content: Content) -> some View {
        if isPreview {
            content
        } else {
            content
                .asyncTask {
                    try await repo.loadData()
                }
                .onChange(of: repo.chapters) { _, newValue in
                    newValue.forEach { chapter in
                        if shouldAddChapter(chapter) {
                            repo.addNewStoryChapter(chapter, modelContext: modelContext)
                        }
                    }
                }
                .onChange(of: repo.specials) { _, newValue in
                    newValue.forEach { special in
                        special.chapters.forEach { chapter in
                            if shouldAddChapter(chapter) {
                                repo.addNewSpecialChapter(chapter, universe: special.universe, modelContext: modelContext)
                            }
                        }
                    }
                }
        }
    }
}

extension View {
    func fetchingChapters(existingChapterNumbers: [Int], loader: ChapterDataStore = ChapterLoaderAdapter()) -> some View {
        modifier(FetchChapterListViewModifier(repo: .init(loader: loader), existingChapterNumbers: existingChapterNumbers))
    }
}


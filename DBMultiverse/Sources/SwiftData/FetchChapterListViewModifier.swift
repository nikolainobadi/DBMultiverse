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
    @Environment(\.modelContext) private var modelContext
    
    let existingChapterNumbers: [String]
    
    func body(content: Content) -> some View {
        content
            .asyncTask {
                try await repo.loadData()
            }
            .onChange(of: repo.chapters) { _, newValue in
                newValue.forEach { chapter in
                    if !existingChapterNumbers.contains(chapter.number) {
                        repo.addNewStoryChapter(chapter, modelContext: modelContext)
                    }
                }
            }
            .onChange(of: repo.specials) { _, newValue in
                newValue.forEach { special in
                    special.chapters.forEach { chapter in
                        if !existingChapterNumbers.contains(chapter.number) {
                            repo.addNewSpecialChapter(chapter, specialTitle: special.title, modelContext: modelContext)
                        }
                    }
                }
            }
    }
}

extension View {
    func fetchingChapters(existingChapterNumbers: [String], loader: ChapterDataStore = ChapterLoaderAdapter()) -> some View {
        modifier(FetchChapterListViewModifier(repo: .init(loader: loader), existingChapterNumbers: existingChapterNumbers))
    }
}

final class ChapterListRepository: ObservableObject {
    @Published var chapters: [Chapter] = []
    @Published var specials: [Special] = []
    
    private let loader: ChapterDataStore
    
    init(loader: ChapterDataStore) {
        self.loader = loader
    }
}


// MARK: - Actions
extension ChapterListRepository {
    func loadData() async throws {
        let (storyChapters, specials) = try await loader.loadChapterLists()
        
        await setStoryChapters(storyChapters)
        await setSpecials(specials)
    }
    
    func addNewStoryChapter(_ chapter: Chapter, modelContext: ModelContext) {
        
    }
    
    func addNewSpecialChapter(_ chapter: Chapter, specialTitle: String, modelContext: ModelContext) {
        
    }
    
    
}


// MARK: - MainActor
@MainActor
private extension ChapterListRepository {
    func setStoryChapters(_ chapters: [Chapter]) {
        self.chapters = chapters
    }
    
    func setSpecials(_ specials: [Special]) {
        self.specials = specials
    }
}


// MARK: - Private Methods
private extension ChapterListRepository {
    func addNewSwiftDataChapter(_ chapter: Chapter, universe: String?, modelContext: ModelContext) {
        modelContext.insert(SwiftDataChapter(name: chapter.number, number: chapter.number, universe: universe, lastReadPage: nil))
    }
}

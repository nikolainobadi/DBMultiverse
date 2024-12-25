//
//  ChapterListRepository.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/24/24.
//

import SwiftData
import Foundation

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
        addNewSwiftDataChapter(chapter, universe: nil, modelContext: modelContext)
    }
    
    func addNewSpecialChapter(_ chapter: Chapter, universe: Int, modelContext: ModelContext) {
        addNewSwiftDataChapter(chapter, universe: universe, modelContext: modelContext)
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
    func addNewSwiftDataChapter(_ chapter: Chapter, universe: Int?, modelContext: ModelContext) {
        modelContext.insert(SwiftDataChapter(chapter: chapter, universe: universe))
    }
}


// MARK: - Extension Dependencies
fileprivate extension SwiftDataChapter {
    convenience init(chapter: Chapter, universe: Int?) {
        self.init(
            name: chapter.name,
            number: chapter.number,
            startPage: chapter.startPage,
            endPage: chapter.endPage,
            universe: universe,
            lastReadPage: nil,
            coverImageURL: chapter.coverImageURL
        )
    }
}

//
//  ChapterListViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import Foundation

final class ChapterListViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    
    private let loader: ChapterLoader
    private let defaults: UserDefaults
    
    init(loader: ChapterLoader = ChapterLoaderAdapter(), defaults: UserDefaults = .standard) {
        self.loader = loader
        self.defaults = defaults
    }
}


// MARK: - Actions
extension ChapterListViewModel {
    func unreadChapter(_ chapter: Chapter) {
        var completedChapterList = (defaults.value(forKey: .completedChapterListKey) as? [String]) ?? []
        
        if let index = completedChapterList.firstIndex(where: { $0 == chapter.number }) {
            completedChapterList.remove(at: index)
            
            defaults.setValue(completedChapterList, forKey: .completedChapterListKey)
        }
        
        if let index = chapters.firstIndex(where: { $0.number == chapter.number }) {
            chapters[index].didRead = false
        }
    }
    
    func loadChapters() async throws {
        let completedChapterList = (defaults.value(forKey: .completedChapterListKey) as? [String]) ?? []
        let chapters = try await loader.loadChapters().map { chapter in
            guard completedChapterList.contains(chapter.number) else {
                return chapter
            }
            var updated = chapter
            updated.didRead = true
            return updated
        }
        
        await setChapters(chapters)
    }
}


// MARK: - MainActor
@MainActor
private extension ChapterListViewModel {
    func setChapters(_ chapters: [Chapter]) {
        self.chapters = chapters
    }
}


// MARK: - Dependencies
protocol ChapterLoader {
    func loadChapters() async throws -> [Chapter]
}

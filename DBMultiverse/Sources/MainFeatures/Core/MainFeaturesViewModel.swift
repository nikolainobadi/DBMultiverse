//
//  MainFeaturesViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

final class MainFeaturesViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    @Published var nextChapterToRead: Chapter?
    @AppStorage(.lastReadSpecialPage) var lastReadSpecialPage: Int = 168
    @AppStorage(.lastReadMainStoryPage) var lastReadMainStoryPage: Int = 0
    
    private let loader: ChapterLoader
    
    init(loader: ChapterLoader) {
        self.loader = loader
    }
}


// MARK: - Actions
extension MainFeaturesViewModel {
    func loadData(language: ComicLanguage) async throws {
        let url = URLFactory.makeURL(language: language, pathComponent: .chapterList)
        let fetchedList = try await loader.loadChapters(url: url)
        
        print("---------- fetched chapters ----------")
        print("fetched \(fetchedList.count) chapters")
        print("---------- end fetched chapters ----------\n\n")
        
        await setChapters(fetchedList)
    }
    
    func updateCurrentPageNumber(_ pageNumber: Int, comicType: ComicType) {
        Task { @MainActor [unowned self] in
            switch comicType {
            case .story:
                print("updated last read story page")
                lastReadMainStoryPage = pageNumber
            case .specials:
                print("updating last read special page")
                lastReadSpecialPage = pageNumber
            }
        }
    }
    
    func getCurrentPageNumber(for type: ComicType) -> Int {
        switch type {
        case .story:
            return lastReadMainStoryPage
        case .specials:
            return lastReadSpecialPage
        }
    }
    
    func startNextChapter(_ chapter: Chapter) {
        nextChapterToRead = chapter
    }
}


// MARK: - MainActor
@MainActor
private extension MainFeaturesViewModel {
    func setChapters(_ chapters: [Chapter]) {
        self.chapters = chapters
    }
}


// MARK: - Dependencies
protocol ChapterLoader {
    func loadChapters(url: URL?) async throws -> [Chapter]
}

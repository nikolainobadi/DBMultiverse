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
    @AppStorage(.lastReadSpecialPage) var lastReadSpecialPage: Int = 168
    @AppStorage(.lastReadMainStoryPage) var lastReadMainStoryPage: Int = 0
    
    private let loader: ChapterLoader
    
    init(loader: ChapterLoader) {
        self.loader = loader
    }
}


// MARK: - Actions
extension MainFeaturesViewModel {
    func loadData() async throws {
        let fetchedList = try await loader.loadChapters()
        
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
    func loadChapters() async throws -> [Chapter]
}

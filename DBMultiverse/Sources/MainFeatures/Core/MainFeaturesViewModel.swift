//
//  MainFeaturesViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

@MainActor
final class MainFeaturesViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    @Published var nextChapterToRead: Chapter?
    @AppStorage var lastReadSpecialPage: Int
    @AppStorage var lastReadMainStoryPage: Int
    
    private let loader: ChapterLoader
    
    /// Initializes the `MainFeaturesViewModel`.
    /// - Parameters:
    ///   - loader: A dependency responsible for fetching chapter data.
    ///   - userDefaults: The `UserDefaults` instance to store and retrieve page tracking data. Defaults to `.standard`.
    init(loader: ChapterLoader, userDefaults: UserDefaults? = .standard) {
        self.loader = loader
        
        // Initialize AppStorage properties with custom or standard UserDefaults.
        self._lastReadSpecialPage = .init(wrappedValue: 168, .lastReadSpecialPage, store: userDefaults)
        self._lastReadMainStoryPage = .init(wrappedValue: 0, .lastReadMainStoryPage, store: userDefaults)
    }
}

// MARK: - Actions
extension MainFeaturesViewModel {
    /// Loads chapter data for a specific language asynchronously.
    /// - Parameter language: The language of the comics to fetch.
    /// - Throws: An error if the chapter data cannot be fetched.
    func loadData(language: ComicLanguage) async throws {
        let url = URLFactory.makeURL(language: language, pathComponent: .chapterList)
        let fetchedList = try await loader.loadChapters(url: url)
        
        chapters = fetchedList
    }
    
    /// Retrieves the current page number for a given comic type.
    /// - Parameter type: The type of comic (e.g., story or specials).
    /// - Returns: The last read page number for the specified comic type.
    func getCurrentPageNumber(for type: ComicType) -> Int {
        switch type {
        case .story:
            return lastReadMainStoryPage
        case .specials:
            return lastReadSpecialPage
        }
    }
    
    /// Sets the next chapter to read for the user.
    /// - Parameter chapter: The chapter to mark as next.
    func startNextChapter(_ chapter: Chapter) {
        nextChapterToRead = chapter
    }
}


// MARK: - ComicPageStore
extension MainFeaturesViewModel: ComicPageStore {
    /// Updates the last read page number for a given comic type.
    /// - Parameters:
    ///   - pageNumber: The page number to update.
    ///   - comicType: The type of comic (e.g., story or specials).
    func updateCurrentPageNumber(_ pageNumber: Int, comicType: ComicType) {
        switch comicType {
        case .story:
            lastReadMainStoryPage = pageNumber
        case .specials:
            lastReadSpecialPage = pageNumber
        }
    }
}


// MARK: - Dependencies
/// Protocol defining the requirements for loading chapter data.
protocol ChapterLoader {
    /// Loads chapters from a specified URL.
    /// - Parameter url: The URL to load chapter data from.
    /// - Returns: An array of `Chapter` objects.
    /// - Throws: An error if the data cannot be fetched or decoded.
    func loadChapters(url: URL?) async throws -> [Chapter]
}

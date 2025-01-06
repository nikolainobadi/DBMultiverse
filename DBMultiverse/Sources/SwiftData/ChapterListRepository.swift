//
//  ChapterListRepository.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/24/24.
//

import SwiftData
import Foundation

/// A repository responsible for managing and loading chapter data.
/// Provides published properties for observing changes to chapters and specials.
final class ChapterListRepository: ObservableObject {
    /// A list of main story chapters.
    @Published var chapters: [Chapter] = []
    
    /// A list of special chapters grouped by universe.
    @Published var specials: [Special] = []
    
    /// A data loader responsible for fetching chapter data from a remote source or cache.
    private let loader: ChapterDataStore
    
    /// Initializes the repository with a chapter data loader.
    /// - Parameter loader: An instance conforming to `ChapterDataStore` for fetching chapter data.
    init(loader: ChapterDataStore) {
        self.loader = loader
    }
}

// MARK: - Actions
extension ChapterListRepository {
    /// Loads chapter data, including main story chapters and specials, and updates the repository's properties.
    /// - Throws: Errors from the `ChapterDataStore` if loading fails.
    func loadData() async throws {
        let (storyChapters, specials) = try await loader.loadChapterLists()
        
        await setStoryChapters(storyChapters)
        await setSpecials(specials)
    }
    
    /// Adds a new main story chapter to the `SwiftData` context.
    /// - Parameters:
    ///   - chapter: The chapter to add.
    ///   - modelContext: The `ModelContext` used for persistence.
    func addNewStoryChapter(_ chapter: Chapter, modelContext: ModelContext) {
        addNewSwiftDataChapter(chapter, universe: nil, modelContext: modelContext)
    }
    
    /// Adds a new special chapter to the `SwiftData` context.
    /// - Parameters:
    ///   - chapter: The chapter to add.
    ///   - universe: The universe associated with the special chapter.
    ///   - modelContext: The `ModelContext` used for persistence.
    func addNewSpecialChapter(_ chapter: Chapter, universe: Int, modelContext: ModelContext) {
        addNewSwiftDataChapter(chapter, universe: universe, modelContext: modelContext)
    }
}

// MARK: - MainActor
@MainActor
private extension ChapterListRepository {
    /// Updates the repository's `chapters` property with new main story chapters.
    /// - Parameter chapters: The new list of main story chapters.
    func setStoryChapters(_ chapters: [Chapter]) {
        self.chapters = chapters
    }
    
    /// Updates the repository's `specials` property with new special chapters.
    /// - Parameter specials: The new list of special chapters grouped by universe.
    func setSpecials(_ specials: [Special]) {
        self.specials = specials
    }
}

// MARK: - Private Methods
private extension ChapterListRepository {
    /// Inserts a new chapter into the `SwiftData` context.
    /// - Parameters:
    ///   - chapter: The chapter to add.
    ///   - universe: The universe associated with the chapter, if any.
    ///   - modelContext: The `ModelContext` used for persistence.
    func addNewSwiftDataChapter(_ chapter: Chapter, universe: Int?, modelContext: ModelContext) {
        modelContext.insert(SwiftDataChapter(chapter: chapter, universe: universe))
    }
}

// MARK: - Dependencies
/// A protocol defining the data store for loading chapters.
protocol ChapterDataStore {
    /// Loads the main story and special chapters.
    /// - Returns: A tuple containing arrays of main story chapters and specials.
    /// - Throws: An error if loading fails.
    func loadChapterLists() async throws -> (mainStory: [Chapter], specials: [Special])
}

// MARK: - Extension Dependencies
fileprivate extension SwiftDataChapter {
    /// Convenience initializer for creating a `SwiftDataChapter` from a `Chapter` object.
    /// - Parameters:
    ///   - chapter: The chapter data to initialize with.
    ///   - universe: The universe associated with the chapter, if any.
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

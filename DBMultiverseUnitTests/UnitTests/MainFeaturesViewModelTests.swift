//
//  MainFeaturesViewModelTests.swift
//  DBMultiverseUnitTests
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import Testing
import Foundation
import DBMultiverseComicKit
import NnSwiftTestingHelpers
@testable import DBMultiverse

@MainActor
@LeakTracked
final class MainFeaturesViewModelTests {
    @Test("Starting values are empty")
    func startingValuesAreEmpty() {
        let (sut, loader) = makeSUT()

        #expect(loader.urlPath == nil)
        #expect(sut.chapters.isEmpty)
        #expect(sut.nextChapterToRead == nil)
        #expect(sut.lastReadMainStoryPage == 0)
        #expect(sut.lastReadSpecialPage != sut.lastReadMainStoryPage)
    }
}

// MARK: - Load Data
extension MainFeaturesViewModelTests {
    @Test("URL contains correct language parameter for all languages")
    func urlContainsCorrectLanguageParameter() async throws {
        for language in ComicLanguage.allCases {
            let (sut, loader) = makeSUT()

            try await sut.loadData(language: language)

            guard let urlPath = loader.urlPath else {
                #expect(Bool(false), "URL path should be set after loading data")
                continue
            }

            #expect(urlPath.contains(language.rawValue))
        }
    }

    @Test("Loads and sets chapters correctly")
    func loadsAndSetsChaptersCorrectly() async throws {
        let chaptersToLoad = [makeChapter(name: "Chapter 1"), makeChapter(name: "Chapter 2")]
        let sut = makeSUT(chaptersToLoad: chaptersToLoad).sut

        try await sut.loadData(language: .english)

        #expect(sut.chapters.count == chaptersToLoad.count)
        #expect(sut.chapters.map(\.name).sorted() == chaptersToLoad.map(\.name).sorted())
    }

    @Test("Chapters remain consistent after multiple load operations")
    func chaptersRemainConsistentAfterMultipleLoads() async throws {
        let initialChapters = [makeChapter(name: "Chapter 1"), makeChapter(name: "Chapter 2")]
        let sut = makeSUT(chaptersToLoad: initialChapters).sut

        try await sut.loadData(language: .english)
        let firstLoadCount = sut.chapters.count

        try await sut.loadData(language: .french)
        let secondLoadCount = sut.chapters.count

        #expect(firstLoadCount == secondLoadCount)
        #expect(sut.chapters.count == initialChapters.count)
    }
}

// MARK: - Current Page Number
extension MainFeaturesViewModelTests {
    @Test("Updates current page number based on comic type")
    func updatesCurrentPageNumberBasedOnComicType() {
        let sut = makeSUT().sut

        sut.updateCurrentPageNumber(42, comicType: .story)
        #expect(sut.lastReadMainStoryPage == 42)
        #expect(sut.lastReadSpecialPage != 42)

        sut.updateCurrentPageNumber(99, comicType: .specials)
        #expect(sut.lastReadSpecialPage == 99)
        #expect(sut.lastReadMainStoryPage != 99)
    }

    @Test("Returns current page number based on comic type")
    func returnsCurrentPageNumberBasedOnComicType() {
        let sut = makeSUT().sut

        sut.updateCurrentPageNumber(21, comicType: .story)
        #expect(sut.getCurrentPageNumber(for: .story) == 21)
        #expect(sut.getCurrentPageNumber(for: .specials) == sut.lastReadSpecialPage)

        sut.updateCurrentPageNumber(84, comicType: .specials)
        #expect(sut.getCurrentPageNumber(for: .specials) == 84)
        #expect(sut.getCurrentPageNumber(for: .story) == 21)
    }

    @Test("Preserves page numbers across different comic types")
    func preservesPageNumbersAcrossDifferentComicTypes() {
        let sut = makeSUT().sut

        sut.updateCurrentPageNumber(10, comicType: .story)
        sut.updateCurrentPageNumber(25, comicType: .specials)

        #expect(sut.getCurrentPageNumber(for: .story) == 10)
        #expect(sut.getCurrentPageNumber(for: .specials) == 25)

        sut.updateCurrentPageNumber(15, comicType: .story)
        #expect(sut.getCurrentPageNumber(for: .story) == 15)
        #expect(sut.getCurrentPageNumber(for: .specials) == 25)
    }
}

// MARK: - Next Chapter
extension MainFeaturesViewModelTests {
    @Test("Sets next chapter to read")
    func setsNextChapterToRead() {
        let sut = makeSUT().sut
        let chapter = makeChapter(name: "Next Chapter")

        sut.startNextChapter(chapter)

        #expect(sut.nextChapterToRead == chapter)
    }

    @Test("Next chapter to read resets properly")
    func nextChapterToReadResetsProperly() {
        let sut = makeSUT().sut
        let firstChapter = makeChapter(name: "First Chapter")
        let secondChapter = makeChapter(name: "Second Chapter")

        sut.startNextChapter(firstChapter)
        #expect(sut.nextChapterToRead == firstChapter)

        sut.startNextChapter(secondChapter)
        #expect(sut.nextChapterToRead == secondChapter)
        #expect(sut.nextChapterToRead != firstChapter)
    }
}

// MARK: - Error Handling
extension MainFeaturesViewModelTests {
    @Test("Handles loading errors gracefully")
    func handlesLoadingErrorsGracefully() async {
        let sut = makeSUT(throwError: true).sut

        await #expect(throws: (any Error).self) {
            try await sut.loadData(language: .english)
        }

        #expect(sut.chapters.isEmpty)
    }
}

// MARK: - SUT
private extension MainFeaturesViewModelTests {
    func makeSUT(
        throwError: Bool = false,
        chaptersToLoad: [Chapter] = [],
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) -> (sut: MainFeaturesViewModel, loader: MockLoader) {
        let defaults = makeTestDefaults()
        let loader = MockLoader(throwError: throwError, chaptersToLoad: chaptersToLoad)
        let sut = MainFeaturesViewModel(loader: loader, userDefaults: defaults)

        trackForMemoryLeaks(sut, fileID: fileID, filePath: filePath, line: line, column: column)
        trackForMemoryLeaks(loader, fileID: fileID, filePath: filePath, line: line, column: column)

        return (sut, loader)
    }
}

// MARK: - Test Helpers
private extension MainFeaturesViewModelTests {
    func makeTestDefaults(name: String = "testSuite") -> UserDefaults? {
        let defaults = UserDefaults(suiteName: name)
        defaults?.removePersistentDomain(forName: name)
        return defaults
    }

    func makeChapter(name: String = "Test Chapter", number: Int = 1, startPage: Int = 1, endPage: Int = 20) -> Chapter {
        return .init(
            name: name,
            number: number,
            startPage: startPage,
            endPage: endPage,
            universe: nil,
            lastReadPage: nil,
            coverImageURL: "",
            didFinishReading: false
        )
    }
}

// MARK: - Mocks
private extension MainFeaturesViewModelTests {
    final class MockLoader: ChapterLoader, @unchecked Sendable {
        private let throwError: Bool
        private let chaptersToLoad: [Chapter]
        private(set) var urlPath: String?

        init(throwError: Bool, chaptersToLoad: [Chapter]) {
            self.throwError = throwError
            self.chaptersToLoad = chaptersToLoad
        }

        func loadChapters(url: URL?) async throws -> [Chapter] {
            if throwError { throw NSError(domain: "Test", code: 0) }

            urlPath = url?.path

            return chaptersToLoad
        }
    }
}

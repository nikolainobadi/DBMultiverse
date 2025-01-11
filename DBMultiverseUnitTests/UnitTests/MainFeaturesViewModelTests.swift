//
//  MainFeaturesViewModelTests.swift
//  DBMultiverseUnitTests
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import XCTest
import Combine
import NnTestHelpers
import DBMultiverseComicKit
@testable import DBMultiverse

final class MainFeaturesViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }
}


// MARK: - Unit Tests
extension MainFeaturesViewModelTests {
    func test_starting_values_are_empty() {
        let (sut, loader) = makeSUT()
        
        XCTAssertNil(loader.urlPath)
        XCTAssert(sut.chapters.isEmpty)
        XCTAssertNil(sut.nextChapterToRead)
        XCTAssertEqual(sut.lastReadMainStoryPage, 0)
        XCTAssertNotEqual(sut.lastReadSpecialPage, sut.lastReadMainStoryPage)
    }
    
    func test_url_contains_correct_language_parameter() async {
        for language in ComicLanguage.allCases {
            let (sut, loader) = makeSUT()
            
            await asyncAssertNoErrorThrown {
                try await sut.loadData(language: language)
            }
            
            assertProperty(loader.urlPath) { path in
                XCTAssert(path.contains(language.rawValue))
            }
        }
    }
    
    func test_loads_and_sets_chapters_correctly() async {
        let chaptersToLoad = [makeChapter(name: "Chapter 1"), makeChapter(name: "Chapter 2")]
        let (sut, loader) = makeSUT(chaptersToLoad: chaptersToLoad)
        
        await asyncAssertNoErrorThrown {
            try await sut.loadData(language: .english)
        }
        
        assertArray(sut.chapters, contains: chaptersToLoad)
    }
    
    func test_updates_current_page_number_based_on_comic_type() {
        let (sut, _) = makeSUT()
        
        sut.updateCurrentPageNumber(42, comicType: .story)
        XCTAssertEqual(sut.lastReadMainStoryPage, 42)
        XCTAssertNotEqual(sut.lastReadSpecialPage, 42)
        
        sut.updateCurrentPageNumber(99, comicType: .specials)
        XCTAssertEqual(sut.lastReadSpecialPage, 99)
        XCTAssertNotEqual(sut.lastReadMainStoryPage, 99)
    }
    
    func test_returns_current_page_number_based_on_comic_type() {
        let (sut, _) = makeSUT()
        
        sut.updateCurrentPageNumber(21, comicType: .story)
        XCTAssertEqual(sut.getCurrentPageNumber(for: .story), 21)
        XCTAssertEqual(sut.getCurrentPageNumber(for: .specials), sut.lastReadSpecialPage)
        
        sut.updateCurrentPageNumber(84, comicType: .specials)
        XCTAssertEqual(sut.getCurrentPageNumber(for: .specials), 84)
        XCTAssertEqual(sut.getCurrentPageNumber(for: .story), 21)
    }
    
    func test_sets_next_chapter_to_read() {
        let (sut, _) = makeSUT()
        let chapter = makeChapter(name: "Next Chapter")
        
        sut.startNextChapter(chapter)
        
        assertPropertyEquality(sut.nextChapterToRead, expectedProperty: chapter)
    }
}


// MARK: - SUT
extension MainFeaturesViewModelTests {
    func makeSUT(throwError: Bool = false, chaptersToLoad: [Chapter] = [], file: StaticString = #filePath, line: UInt = #line) -> (sut: MainFeaturesViewModel, loader: MockLoader) {
        let defaults = makeTestDefaults()
        let loader = MockLoader(throwError: throwError, chaptersToLoad: chaptersToLoad)
        let sut = MainFeaturesViewModel(loader: loader, userDefaults: defaults)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    func makeTestDefaults(name: String = "testSuite") -> UserDefaults? {
        let defaults = UserDefaults(suiteName: name)
        defaults?.removePersistentDomain(forName: name)
        return defaults
    }
}


// MARK: - Helper Classes
extension MainFeaturesViewModelTests {
    class MockLoader: ChapterLoader {
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

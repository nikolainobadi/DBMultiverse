//
//  ChapterListRepositoryTests.swift
//  DBMultiverseUnitTests
//
//  Created by Nikolai Nobadi on 12/24/24.
//

import XCTest
import Combine
import SwiftData
import NnTestHelpers
@testable import DBMultiverse

@MainActor
final class ChapterListRepositoryTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }
}


// MARK: - Unit Tests
extension ChapterListRepositoryTests {
    func test_starting_values_are_empty() {
        let (sut, _) = makeSUT()
        
        XCTAssert(sut.chapters.isEmpty)
        XCTAssert(sut.specials.isEmpty)
    }
    
    func test_story_chapters_are_loaded() async {
        let chapter = makeChapter()
        let sut = makeSUT(chaptersToLoad: [chapter]).sut
        
        await asyncAssertNoErrorThrown(action: sut.loadData)
        
        waitForCondition(publisher: sut.$chapters, cancellables: &cancellables, condition: { !$0.isEmpty })
    }
    
    func test_special_chapters_are_loaded() async {
        let chapter = makeChapter()
        let special = makeSpecial(chapters: [chapter])
        let sut = makeSUT(specialsToLoad: [special]).sut
        
        await asyncAssertNoErrorThrown(action: sut.loadData)
        
        waitForCondition(publisher: sut.$specials, cancellables: &cancellables, condition: { !$0.isEmpty })
    }
    
    func test_loadData_sets_story_and_special_chapters() async {
        let storyChapter = makeChapter(name: "Story Chapter")
        let specialChapter = makeSpecial(chapters: [makeChapter(name: "Special Chapter")])
        let (sut, _) = makeSUT(chaptersToLoad: [storyChapter], specialsToLoad: [specialChapter])
        
        await asyncAssertNoErrorThrown(action: sut.loadData)
        
        waitForCondition(publisher: sut.$chapters, cancellables: &cancellables) {
            $0 == [storyChapter]
        }
        
        waitForCondition(publisher: sut.$specials, cancellables: &cancellables) {
            $0 == [specialChapter]
        }
    }
    
    func test_addNewStoryChapter_inserts_story_chapter() throws {
        let sut = makeSUT().sut
        let context = try makeModelContext()
        let chapter = makeChapter()
        
        sut.addNewStoryChapter(chapter, modelContext: context)
        
        assertPropertyEquality(try? context.fetch(makeFetchDescriptor()).count, expectedProperty: 1)
    }
    
    func test_addNewSpecialChapter_inserts_special_chapter_with_universe() throws {
        let sut = makeSUT().sut
        let context = try makeModelContext()
        let chapter = makeChapter()
        let universe = 3
        
        sut.addNewSpecialChapter(chapter, universe: universe, modelContext: context)
        
        assertProperty(try? context.fetch(makeFetchDescriptor()).first) { fetchedChapter in
            XCTAssertEqual(fetchedChapter.name, chapter.name)
            XCTAssertEqual(fetchedChapter.universe, universe)
        }
    }
}


// MARK: - SUT
extension ChapterListRepositoryTests {
    func makeSUT(chaptersToLoad: [OldChapter] = [], specialsToLoad: [OldSpecial] = [], throwError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: ChapterListRepository, store: MockStore) {
        let store = MockStore(throwError: throwError, chaptersToLoad: chaptersToLoad, specialsToLoad: specialsToLoad)
        let sut = ChapterListRepository(loader: store)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    func makeChapter(name: String = "First Chapter", number: Int = 1, start: Int = 1, end: Int = 5) -> OldChapter {
        return .init(name: name, number: number, startPage: start, endPage: end, coverImageURL: "")
    }
    
    func makeFetchDescriptor() -> FetchDescriptor<SwiftDataChapter> {
        return .init()
    }
    
    func makeSpecial(universe: Int = 1, chapters: [OldChapter] = []) -> OldSpecial {
        return .init(universe: universe, chapters: chapters)
    }
    
    func makeModelContext() throws -> ModelContext {
        return try ModelContainer(for: SwiftDataChapter.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    }
}


// MARK: - Helper Classes
extension ChapterListRepositoryTests {
    class MockStore: ChapterDataStore {
        private let throwError: Bool
        private let chaptersToLoad: [OldChapter]
        private let specialsToLoad: [OldSpecial]
        
        init(throwError: Bool, chaptersToLoad: [OldChapter], specialsToLoad: [OldSpecial]) {
            self.throwError = throwError
            self.chaptersToLoad = chaptersToLoad
            self.specialsToLoad = specialsToLoad
        }
        
        func loadChapterLists() async throws -> (mainStory: [OldChapter], specials: [OldSpecial]) {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return (chaptersToLoad, specialsToLoad)
        }
    }
}

//
//  ChapterListRepositoryTests.swift
//  DBMultiverseUnitTests
//
//  Created by Nikolai Nobadi on 12/24/24.
//

import XCTest
import NnTestHelpers
@testable import DBMultiverse

final class ChapterListRepositoryTests: XCTestCase {
    func test_starting_values_are_empty() {
        let (sut, _) = makeSUT()
        
        XCTAssert(sut.chapters.isEmpty)
        XCTAssert(sut.specials.isEmpty)
    }
}


// MARK: - SUT
extension ChapterListRepositoryTests {
    func makeSUT(throwError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: ChapterListRepository, store: MockStore) {
        let store = MockStore(throwError: throwError)
        let sut = ChapterListRepository(loader: store)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
}


// MARK: - Helper Classes
extension ChapterListRepositoryTests {
    class MockStore: ChapterDataStore {
        private let throwError: Bool
        
        init(throwError: Bool) {
            self.throwError = throwError
        }
        
        func loadChapterLists() async throws -> (mainStory: [Chapter], specials: [Special]) {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return ([], [])
        }
    }
}

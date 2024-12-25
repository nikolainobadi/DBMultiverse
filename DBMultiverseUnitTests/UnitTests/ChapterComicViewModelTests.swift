//
//  ChapterComicViewModelTests.swift
//  DBMultiverseUnitTests
//
//  Created by Nikolai Nobadi on 12/24/24.
//

import XCTest
import NnTestHelpers
@testable import DBMultiverse

final class ChapterComicViewModelTests: XCTestCase {
    func test_starting_values_are_empty() {
        let (sut, loader) = makeSUT()
        
        XCTAssert(sut.pages.isEmpty)
        XCTAssertFalse(sut.didFetchPages)
    }
}


// MARK: - SUT
extension ChapterComicViewModelTests {
    func makeSUT(currentPageNumber: Int = 0, throwError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: ChapterComicViewModel, loader: MockLoader) {
        let loader = MockLoader(throwError: throwError)
        let sut = ChapterComicViewModel(currentPageNumber: currentPageNumber, loader: loader)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
}


// MARK: - Helper Classes
extension ChapterComicViewModelTests {
    class MockLoader: ChapterComicLoader {
        private let throwError: Bool
        private(set) var pages: [Int] = []
        private(set) var chapterNumber: Int?
        
        init(throwError: Bool) {
            self.throwError = throwError
        }
        
        func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo] {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            self.pages = pages
            self.chapterNumber = chapterNumber
            
            return []
        }
    }
}

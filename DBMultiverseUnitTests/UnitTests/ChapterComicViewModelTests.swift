//
//  ChapterComicViewModelTests.swift
//  DBMultiverseUnitTests
//
//  Created by Nikolai Nobadi on 12/24/24.
//

import XCTest
import Combine
import SwiftData
import NnTestHelpers
@testable import DBMultiverse

final class ChapterComicViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }
}

extension ChapterComicViewModelTests {
    func test_starting_values_are_empty() {
        let (sut, loader) = makeSUT()
        
        XCTAssert(sut.pages.isEmpty)
        XCTAssertFalse(sut.didFetchPages)
        XCTAssert(loader.pages.isEmpty)
        XCTAssertNil(loader.chapterNumber)
    }
    
    func test_previousPage_updates_currentPageNumber() {
        let pages = (1...5).map({ makePageInfo(pageNumber: $0) })
        let sut = makeSUT(currentPageNumber: 5, pages: pages).sut
        
        sut.previousPage(start: 1)
        
        XCTAssertEqual(sut.currentPageNumber, 4, "currentPageNumber should decrement when greater than start")
    }

    func test_previousPage_does_not_update_currentPageNumber_below_start() {
        let sut = makeSUT(currentPageNumber: 1).sut
        
        sut.previousPage(start: 1)
        
        XCTAssertEqual(sut.currentPageNumber, 1, "currentPageNumber should not go below start")
    }
    
    func test_previousPage_skips_invalid_pages() {
        let pages = [makePageInfo(pageNumber: 1), makePageInfo(pageNumber: 3), makePageInfo(pageNumber: 4)]
        let sut = makeSUT(currentPageNumber: 3, pages: pages).sut

        sut.previousPage(start: 1)
        
        XCTAssertEqual(sut.currentPageNumber, 1, "currentPageNumber should skip invalid pages")
    }
    
    func test_nextPage_updates_currentPageNumber_to_nextPage() {
        let pages = [
            makePageInfo(pageNumber: 1, secondPageNumber: nil),
            makePageInfo(pageNumber: 2, secondPageNumber: nil)
        ]
        let sut = makeSUT(currentPageNumber: 1, pages: pages).sut
        
        sut.nextPage(end: 3)
        
        XCTAssertEqual(sut.currentPageNumber, 2, "currentPageNumber should update to the next page")
    }

    func test_nextPage_does_not_update_when_at_last_page() {
        let pages = [makePageInfo(pageNumber: 3, secondPageNumber: nil)]
        let sut = makeSUT(currentPageNumber: 3, pages: pages).sut
        
        sut.nextPage(end: 3)
        
        XCTAssertEqual(sut.currentPageNumber, 3, "currentPageNumber should not update when already at the last page")
    }
    
    func test_currentPageInfo_returns_nil_when_page_is_missing() {
        let pages = [makePageInfo(pageNumber: 1)]
        let sut = makeSUT(currentPageNumber: 2, pages: pages).sut
        
        XCTAssertNil(sut.currentPageInfo, "currentPageInfo should return nil when the page is not found")
    }

    func test_currentPageInfo_returns_correct_page_info() {
        let pageInfo = makePageInfo(pageNumber: 2)
        let pages = [makePageInfo(pageNumber: 1), pageInfo, makePageInfo(pageNumber: 3)]
        let sut = makeSUT(currentPageNumber: 2, pages: pages).sut
        
        assertPropertyEquality(sut.currentPageInfo?.pageNumber, expectedProperty: pageInfo.pageNumber)
    }
    
    func test_getCurrentPagePosition_for_single_page() {
        let pages = [makePageInfo(pageNumber: 1)]
        let sut = makeSUT(currentPageNumber: 1, pages: pages).sut
        let info = makeChapterInfo()
        let position = sut.getCurrentPagePosition(chapterInfo: info)
        
        XCTAssertEqual(position, "0/4", "getCurrentPagePosition should correctly calculate the single-page position")
    }

    func test_getCurrentPagePosition_for_double_page() {
        let pages = [makePageInfo(pageNumber: 1, secondPageNumber: 2)]
        let sut = makeSUT(currentPageNumber: 1, pages: pages).sut
        let info = makeChapterInfo()
        let position = sut.getCurrentPagePosition(chapterInfo: info)
        
        XCTAssertEqual(position, "0-1/4", "getCurrentPagePosition should correctly calculate the double-page position")
    }
    
    func test_loadInitialPages_does_not_reload_when_already_fetched() async {
        let sut = makeSUT().sut
        let info = makeChapterInfo()
        
        sut.didFetchPages = true
        
        await asyncAssertNoErrorThrown {
            try await sut.loadInitialPages(for: info)
        }
        
        XCTAssert(sut.pages.isEmpty, "loadInitialPages should not fetch pages when didFetchPages is true")
    }

    func test_loadInitialPages_fetches_correct_pages() async {
        let (sut, loader) = makeSUT()
        let info = makeChapterInfo(endPage: 10, lastReadPage: 2)
        
        await asyncAssertNoErrorThrown {
            try await sut.loadInitialPages(for: info)
        }
        
        XCTAssertEqual(loader.pages, [2, 3, 4, 5, 6], "loadInitialPages should fetch the correct range of pages")
    }
    
    func test_loadRemainingPages_fetches_missing_pages() {
        let pages = [makePageInfo(pageNumber: 1), makePageInfo(pageNumber: 2)]
        let pagesToLoad = (3...5).map({ makePageInfo(pageNumber: $0) })
        let (sut, loader) = makeSUT(pages: pages, pagesToLoad: pagesToLoad)
        let info = makeChapterInfo()
        
        sut.loadRemainingPages(for: info)
        
        waitForCondition(publisher: sut.$pages, cancellables: &cancellables, condition: { $0.count > 2 })
        
        XCTAssertEqual(loader.pages, [3, 4, 5], "loadRemainingPages should fetch the missing pages")
    }
}


// MARK: - SUT
extension ChapterComicViewModelTests {
    func makeSUT(currentPageNumber: Int = 0, pages: [PageInfo] = [], pagesToLoad: [PageInfo] = [], throwError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: ChapterComicViewModel, loader: MockLoader) {
        let loader = MockLoader(throwError: throwError, pagesToLoad: pagesToLoad)
        let sut = ChapterComicViewModel(currentPageNumber: currentPageNumber, loader: loader, pages: pages)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    func makePageInfo(chapter: Int = 1, pageNumber: Int, secondPageNumber: Int? = nil) -> PageInfo {
        return .init(chapter: chapter, pageNumber: pageNumber, secondPageNumber: secondPageNumber, imageData: .init())
    }
    
    func makeChapterInfo(number: Int = 1, startPage: Int = 1, endPage: Int = 5, lastReadPage: Int? = nil) -> ChapterInfo {
        return .init(number: number, startPage: startPage, endPage: endPage, lastReadPage: lastReadPage)
    }
}


// MARK: - Helper Classes
extension ChapterComicViewModelTests {
    class MockLoader: ChapterComicLoader {
        private let throwError: Bool
        private let pagesToLoad: [PageInfo]
        private(set) var pages: [Int] = []
        private(set) var chapterNumber: Int?
        
        init(throwError: Bool, pagesToLoad: [PageInfo]) {
            self.throwError = throwError
            self.pagesToLoad = pagesToLoad
        }
        
        func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo] {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            self.pages = pages
            self.chapterNumber = chapterNumber
            
            return pagesToLoad
        }
    }
}

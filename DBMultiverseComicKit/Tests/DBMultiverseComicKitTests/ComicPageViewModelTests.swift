//
//  ComicPageViewModelTests.swift
//  DBMultiverseComicKit
//
//  Created by Nikolai Nobadi on 9/7/25.
//

import Testing
import Foundation
import NnSwiftTestingHelpers
@testable import DBMultiverseComicKit

final class ComicPageViewModelTests: TrackingMemoryLeaks {
    @Test("Starting values are initialized correctly")
    func emptyStartingValues() {
        let currentPageNumber = 1
        let (sut, delegate) = makeSUT(currentPageNumber: currentPageNumber)
        
        #expect(sut.pages.isEmpty)
        #expect(!sut.didFetchInitialPages)
        #expect(sut.currentPageNumber == currentPageNumber)
        #expect(delegate.savedPageInfo == nil)
    }
    
    // MARK: - Display Data Tests
    
    @Test("Current page position reflects single page correctly")
    func currentPagePositionSinglePage() {
        let pageInfo = makePageInfo(pageNumber: 5, secondPageNumber: nil)
        let chapter = makeChapter(startPage: 1, endPage: 10)
        let (sut, _) = makeSUT(chapter: chapter, currentPageNumber: 5, currentPages: [pageInfo])
        
        let position = sut.currentPagePosition
        
        #expect(position.page == 5)
        #expect(position.secondPage == nil)
        #expect(position.endPage == 10)
    }
    
    @Test("Current page position reflects double page spread correctly")
    func currentPagePositionDoublePage() {
        let pageInfo = makePageInfo(pageNumber: 4, secondPageNumber: 5)
        let chapter = makeChapter(startPage: 1, endPage: 10)
        let (sut, _) = makeSUT(chapter: chapter, currentPageNumber: 4, currentPages: [pageInfo])
        
        let position = sut.currentPagePosition
        
        #expect(position.page == 4)
        #expect(position.secondPage == 5)
        #expect(position.endPage == 10)
    }
    
    @Test("Current page info returns nil when page not loaded", .disabled())
    func currentPageInfoMissing() {
        let (sut, _) = makeSUT(currentPageNumber: 5, currentPages: [])
        
        #expect(sut.currentPageInfo == nil)
    }
    
    @Test("Current page info returns correct page when loaded")
    func currentPageInfoPresent() {
        let pageInfo = makePageInfo(pageNumber: 5)
        let (sut, _) = makeSUT(currentPageNumber: 5, currentPages: [pageInfo])
        
        let result = sut.currentPageInfo
        
        #expect(result?.pageNumber == 5)
        #expect(result?.imageData == pageInfo.imageData)
    }
    
    @Test("Current page returns nil when page info missing")
    func currentPageMissing() {
        let (sut, _) = makeSUT(currentPageNumber: 5, currentPages: [])
        
        #expect(sut.currentPage == nil)
    }
    
    @Test("Current page returns complete page data when available")
    func currentPageComplete() {
        let chapterName = "Test Chapter"
        let pageInfo = makePageInfo(pageNumber: 5, secondPageNumber: 6)
        let chapter = makeChapter(name: chapterName, startPage: 1, endPage: 10)
        let (sut, _) = makeSUT(chapter: chapter, currentPageNumber: 5, currentPages: [pageInfo])
        
        let result = sut.currentPage
        
        #expect(result?.number == 5)
        #expect(result?.chapterName == chapterName)
        #expect(result?.pagePosition.page == 5)
        #expect(result?.pagePosition.secondPage == 6)
        #expect(result?.pagePosition.endPage == 10)
        #expect(result?.imageData == pageInfo.imageData)
    }
    
    // MARK: - Load Data Tests
    
    @Test("Loading data fetches initial pages when not previously loaded", .disabled())
    func loadDataFetchesInitialPages() async throws {
        let pagesToLoad = [makePageInfo(pageNumber: 3), makePageInfo(pageNumber: 4), makePageInfo(pageNumber: 5)]
        let chapter = makeChapter(startPage: 1, endPage: 20)
        let sut = makeSUT(chapter: chapter, currentPageNumber: 3, pagesToLoad: pagesToLoad).sut
        
        try await sut.loadData()
        
        #expect(sut.pages.count == 3)
        #expect(sut.didFetchInitialPages)
        #expect(sut.pages.map(\.pageNumber).sorted() == [3, 4, 5])
    }
    
    @Test("Loading data skips fetch when initial pages already loaded", .disabled())
    func loadDataSkipsWhenAlreadyLoaded() async throws {
        let existingPages = [makePageInfo(pageNumber: 1), makePageInfo(pageNumber: 2)]
        let (sut, _) = makeSUT(currentPages: existingPages)
        
        try await sut.loadData()
        try await sut.loadData()
        
        #expect(sut.pages.count == 2)
        #expect(sut.pages.map(\.pageNumber).sorted() == [1, 2])
    }
    
    @Test("Loading data respects chapter end page limit", .disabled())
    func loadDataRespectsEndPageLimit() async throws {
        let pagesToLoad = [makePageInfo(pageNumber: 9), makePageInfo(pageNumber: 10)]
        let chapter = makeChapter(startPage: 1, endPage: 10)
        let (sut, _) = makeSUT(chapter: chapter, currentPageNumber: 9, pagesToLoad: pagesToLoad)
        
        try await sut.loadData()
        
        #expect(sut.pages.count == 2)
        #expect(sut.pages.map(\.pageNumber).sorted() == [9, 10])
    }
    
    @Test("Loading data propagates delegate errors")
    func loadDataPropagatesErrors() async {
        let (sut, _) = makeSUT(throwError: true)
        
        
        await #expect(throws: (any Error).self) {
            try await sut.loadData()
        }
        
        #expect(!sut.didFetchInitialPages)
        #expect(sut.pages.isEmpty)
    }
    
    // MARK: - Page Navigation Tests
    
    @Test("Moving to next page advances to correct page number")
    func nextPageAdvancesCorrectly() {
        let currentPageInfo = makePageInfo(pageNumber: 5, secondPageNumber: nil)
        let chapter = makeChapter(startPage: 1, endPage: 10)
        let (sut, _) = makeSUT(chapter: chapter, currentPageNumber: 5, currentPages: [currentPageInfo])
        
        sut.nextPage()
        
        #expect(sut.currentPageNumber == 6)
    }
    
    @Test("Moving to next page from double spread advances correctly")
    func nextPageFromDoubleSpread() {
        let currentPageInfo = makePageInfo(pageNumber: 4, secondPageNumber: 5)
        let chapter = makeChapter(startPage: 1, endPage: 10)
        let (sut, _) = makeSUT(chapter: chapter, currentPageNumber: 4, currentPages: [currentPageInfo])
        
        sut.nextPage()
        
        #expect(sut.currentPageNumber == 6)
    }
    
    @Test("Moving to next page stops at chapter end")
    func nextPageStopsAtEnd() {
        let currentPageInfo = makePageInfo(pageNumber: 10, secondPageNumber: nil)
        let chapter = makeChapter(startPage: 1, endPage: 10)
        let (sut, _) = makeSUT(chapter: chapter, currentPageNumber: 10, currentPages: [currentPageInfo])
        
        sut.nextPage()
        
        #expect(sut.currentPageNumber == 10)
    }
    
    @Test("Moving to previous page decrements correctly")
    func previousPageDecrementsCorrectly() throws {
        let page4 = makePageInfo(pageNumber: 4)
        let page5 = makePageInfo(pageNumber: 5)
        let currentPages = [page4, page5]
        let (sut, delegate) = makeSUT(currentPageNumber: page5.pageNumber, currentPages: currentPages)
        
        sut.previousPage()
        
        #expect(sut.currentPageNumber == page4.pageNumber)
        
        let delegatePage = try #require(delegate.updatedPageNumber)
        
        #expect(delegatePage == page4.pageNumber)
    }
    
    @Test("Moving to previous page on a 'double page' skips a page number")
    func previousPageFromDoublePageSkipsNumber() throws {
        let page2 = makePageInfo(pageNumber: 2)
        let page4 = makePageInfo(pageNumber: 4)
        let currentPages = [page2, page4]
        let (sut, delegate) = makeSUT(currentPageNumber: page4.pageNumber, currentPages: currentPages)
        
        sut.previousPage()
        
        #expect(sut.currentPageNumber == page2.pageNumber)
        
        let delegatePage = try #require(delegate.updatedPageNumber)
        
        #expect(delegatePage == page2.pageNumber)
    }
    
    @Test("Moving to previous page stops at chapter start")
    func previousPageStopsAtStart() {
        let chapter = makeChapter(startPage: 1, endPage: 10)
        let (sut, _) = makeSUT(chapter: chapter, currentPageNumber: 1)
        
        sut.previousPage()
        
        #expect(sut.currentPageNumber == 1)
    }
    
    @Test("Moving to previous page skips missing page info")
    func previousPageSkipsMissingInfo() {
        let (sut, _) = makeSUT(currentPageNumber: 5, currentPages: [])
        
        sut.previousPage()
        
        #expect(sut.currentPageNumber == 3)
    }
    
    // MARK: - Background Loading Tests
    
    @Test("Background loading fetches remaining pages after initial load", .disabled())
    func backgroundLoadingFetchesRemainingPages() async {
        let initialPages = [makePageInfo(pageNumber: 3), makePageInfo(pageNumber: 4)]
        let remainingPages = [makePageInfo(pageNumber: 1), makePageInfo(pageNumber: 2), makePageInfo(pageNumber: 5)]
        let chapter = makeChapter(startPage: 1, endPage: 5)
        let (sut, delegate) = makeSUT(chapter: chapter, currentPageNumber: 3, currentPages: initialPages, pagesToLoad: remainingPages)
        
        sut.loadRemainingPages()
        
        // Allow some time for background task
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(sut.pages.count == 5)
        #expect(sut.pages.map(\.pageNumber).sorted() == [1, 2, 3, 4, 5])
    }
    
    @Test("Background loading caches cover image when start page is loaded", .disabled())
    func backgroundLoadingCachesCoverImage() async {
        let coverPageInfo = makePageInfo(pageNumber: 1)
        let otherPages = [makePageInfo(pageNumber: 2), makePageInfo(pageNumber: 3)]
        let chapter = makeChapter(startPage: 1, endPage: 3)
        let (sut, delegate) = makeSUT(chapter: chapter, currentPageNumber: 2, currentPages: [makePageInfo(pageNumber: 2)], pagesToLoad: [coverPageInfo] + otherPages)
        
        sut.loadRemainingPages()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(delegate.savedPageInfo?.pageNumber == 1)
    }
    
    @Test("Background loading handles delegate errors gracefully", .disabled())
    func backgroundLoadingHandlesErrors() async {
        let chapter = makeChapter(startPage: 1, endPage: 5)
        let (sut, _) = makeSUT(chapter: chapter, currentPageNumber: 1, throwError: true)
        
        sut.loadRemainingPages()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should not crash and pages should remain empty
        #expect(sut.pages.isEmpty)
    }
}


// MARK: - SUT
private extension ComicPageViewModelTests {
    func makeSUT(chapter: Chapter? = nil, currentPageNumber: Int = 1, currentPages: [PageInfo] = [], pagesToLoad: [PageInfo] = [], throwError: Bool = false, fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) -> (sut: ComicPageViewModel, delegate: MockDelegate) {
        let delegate = MockDelegate(throwError: throwError, pagesToLoad: pagesToLoad)
        let sut = ComicPageViewModel(chapter: chapter ?? makeChapter(), currentPageNumber: currentPageNumber, delegate: delegate, pages: currentPages)
        
        trackForMemoryLeaks(sut, fileID: fileID, filePath: filePath, line: line, column: column)
        
        return (sut, delegate)
    }
    
    func makeChapter(name: String = "", number: Int = 0, startPage: Int = 0, endPage: Int = 10) -> Chapter {
        return .init(name: name, number: number, startPage: startPage, endPage: endPage, universe: nil, lastReadPage: nil, coverImageURL: "", didFinishReading: false)
    }
    
    func makePageInfo(pageNumber: Int, secondPageNumber: Int? = nil) -> PageInfo {
        return PageInfo(chapter: 0, pageNumber: pageNumber, secondPageNumber: secondPageNumber, imageData: Data("test\(pageNumber)".utf8))
    }
}


// MARK: - Mocks
private extension ComicPageViewModelTests {
    final class MockDelegate: ComicPageDelegate {
        private let throwError: Bool
        private let pagesToLoad: [PageInfo]
        private(set) var savedPageInfo: PageInfo?
        private(set) var updatedPageNumber: Int?
        
        init(throwError: Bool, pagesToLoad: [PageInfo]) {
            self.throwError = throwError
            self.pagesToLoad = pagesToLoad
        }
        
        func saveChapterCoverPage(_ info: PageInfo) {
            savedPageInfo = info
        }
        
        func updateCurrentPageNumber(_ pageNumber: Int) {
            updatedPageNumber = pageNumber
        }
        
        func loadPages(_ pages: [Int]) async throws -> [PageInfo] {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return pagesToLoad
        }
    }
}

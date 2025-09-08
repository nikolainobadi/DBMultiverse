//
//  ComicPageManagerTests.swift
//  DBMultiverseUnitTests
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import Testing
import Foundation
import NnSwiftTestingHelpers
import DBMultiverseComicKit
@testable import DBMultiverse

@MainActor
final class ComicPageManagerTests: TrackingMemoryLeaks {
    
    @Test("Starting values are empty")
    func startingValuesAreEmpty() {
        let (_, delegate) = makeSUT()
        
        #expect(delegate.savedMetadata == nil)
        #expect(delegate.lastPageReadInfo == nil)
        #expect(delegate.readProgressInfo == nil)
        #expect(delegate.chapterMarkedAsRead == nil)
        #expect(delegate.savedPageInfoList.isEmpty)
    }
    
    @Test("Saves cover image with metadata containing chapter name and progress")
    func savesCoverImageWithMetadata() {
        let chapter = makeChapter(name: "Test Chapter", startPage: 1, endPage: 20)
        let pageInfo = PageInfo(chapter: chapter.number, pageNumber: 10, secondPageNumber: nil, imageData: Data("image".utf8))
        let (sut, delegate) = makeSUT(chapter: chapter)
        
        sut.saveChapterCoverPage(pageInfo)
        
        #expect(delegate.savedMetadata?.chapterName == chapter.name)
        #expect(delegate.savedMetadata?.chapterNumber == chapter.number)
        #expect(delegate.savedMetadata?.readProgress == 50)
    }
    
    @Test("Loads cached pages and fetches missing pages from network")
    func loadsCachedPagesAndFetchesMissingPages() async throws {
        let cachedPageInfo = makePageInfo(page: 2)
        let chapter = makeChapter(startPage: 1, endPage: 20)
        let (sut, delegate) = makeSUT(chapter: chapter, cachedPages: [cachedPageInfo])
        let pages = try await sut.loadPages([2, 3])
        
        #expect(pages.map(\.pageNumber).sorted() == [2, 3])
        #expect(delegate.savedPageInfoList.map(\.pageNumber) == [3])
        #expect(!delegate.savedPageInfoList.map(\.pageNumber).contains(2))
    }
    
    @Test("Does not mark chapter as complete when end page is not read")
    func doesNotMarkChapterAsCompleteBeforeEnd() {
        let start = 1
        let end = 5
        let chapter = makeChapter(startPage: start, endPage: end)
       
        for page in start..<end {
            let (sut, delegate) = makeSUT(chapter: chapter)
            
            sut.updateCurrentPageNumber(page)
            
            #expect(delegate.chapterMarkedAsRead == nil)
        }
    }
    
    @Test("Marks chapter as read when last page is read")
    func marksChapterAsReadWhenLastPageIsRead() {
        let chapter = makeChapter(startPage: 1, endPage: 20)
        let (sut, delegate) = makeSUT(chapter: chapter)
        
        sut.updateCurrentPageNumber(chapter.endPage)
        
        #expect(delegate.chapterMarkedAsRead == chapter)
    }
    
    @Test("Updates last read page and progress when current page number changes")
    func updatesLastReadPageAndProgress() {
        let chapter = makeChapter(startPage: 1, endPage: 10)
        let pageNumber = 5
        let (sut, delegate) = makeSUT(chapter: chapter)
        
        sut.updateCurrentPageNumber(pageNumber)
        
        #expect(delegate.lastPageReadInfo?.0 == pageNumber)
        #expect(delegate.lastPageReadInfo?.1 == chapter)
        #expect(delegate.readProgressInfo?.0 == pageNumber)
        #expect(delegate.readProgressInfo?.1 == 50) // Page 5 of 10 = 50%
    }
    
    @Test("Calculates progress correctly for different page positions")
    func calculatesProgressCorrectly() {
        let chapter = makeChapter(startPage: 1, endPage: 10)
        let (sut, delegate) = makeSUT(chapter: chapter)
        
        // Test start page
        sut.updateCurrentPageNumber(1)
        #expect(delegate.readProgressInfo?.1 == 10) // 1 of 10 pages = 10%
        
        // Test middle page
        sut.updateCurrentPageNumber(5)
        #expect(delegate.readProgressInfo?.1 == 50) // 5 of 10 pages = 50%
        
        // Test end page
        sut.updateCurrentPageNumber(10)
        #expect(delegate.readProgressInfo?.1 == 100) // 10 of 10 pages = 100%
    }
    
    @Test("Handles chapters with non-zero start page correctly")
    func handlesNonZeroStartPage() {
        let chapter = makeChapter(startPage: 10, endPage: 20)
        let (sut, delegate) = makeSUT(chapter: chapter)
        
        sut.updateCurrentPageNumber(15)
        
        #expect(delegate.readProgressInfo?.1 == 54) // Page 6 of 11 total pages ≈ 54%
    }
    
    @Test("Skips second pages when loading")
    func skipsSecondPagesWhenLoading() async throws {
        let chapter = makeChapter(startPage: 1, endPage: 20)
        let (sut, _) = makeSUT(chapter: chapter)
        
        // Pages 9 and 21 are second pages based on the extension
        let pages = try await sut.loadPages([8, 9, 20, 21])
        
        // Should only load pages 8 and 20 (not the second pages)
        #expect(pages.count == 2)
        #expect(pages.map(\.pageNumber).sorted() == [8, 20])
    }
    
    @Test("Handles network errors gracefully when loading pages")
    func handlesNetworkErrorsGracefully() async throws {
        let chapter = makeChapter(startPage: 1, endPage: 20)
        let (sut, _) = makeSUT(chapter: chapter, throwError: true)
        
        let pages = try await sut.loadPages([1, 2, 3])
        
        // Should return empty array when network fails and no cache exists
        #expect(pages.isEmpty)
    }
    
    @Test("Saves fetched pages to cache")
    func savesFetchedPagesToCache() async throws {
        let chapter = makeChapter(startPage: 1, endPage: 20)
        let (sut, delegate) = makeSUT(chapter: chapter)
        
        _ = try await sut.loadPages([1, 2, 3])
        
        // All fetched pages should be saved to cache
        #expect(delegate.savedPageInfoList.count == 3)
        #expect(delegate.savedPageInfoList.map(\.pageNumber).sorted() == [1, 2, 3])
    }
}


// MARK: - SUT
private extension ComicPageManagerTests {
    func makeSUT(
        chapter: Chapter? = nil,
        cachedPages: [PageInfo] = [],
        throwError: Bool = false,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) -> (sut: ComicPageManager, delegate: MockDelegate) {
        let delegate = MockDelegate(throwError: throwError, cachedPages: cachedPages)
        let sut = ComicPageManager(
            chapter: chapter ?? makeChapter(),
            language: .english,
            imageCache: delegate,
            networkService: delegate,
            chapterProgressHandler: delegate
        )
        
        trackForMemoryLeaks(sut, fileID: fileID, filePath: filePath, line: line, column: column)
        trackForMemoryLeaks(delegate, fileID: fileID, filePath: filePath, line: line, column: column)
        
        return (sut, delegate)
    }
    
    func makeChapter(name: String = "Test Chapter", number: Int = 1, startPage: Int = 0, endPage: Int = 20) -> Chapter {
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
    
    func makePageInfo(page: Int, secondPage: Int? = nil) -> PageInfo {
        return .init(chapter: 1, pageNumber: page, secondPageNumber: secondPage, imageData: .init())
    }
}


// MARK: - Helper Classes
private class MockDelegate {
    private let throwError: Bool
    private var cachedPages: [PageInfo]
    private(set) var savedPageInfoList: [PageInfo] = []
    private(set) var chapterMarkedAsRead: Chapter?
    private(set) var lastPageReadInfo: (Int, Chapter)?
    private(set) var readProgressInfo: (Int, Int)?
    private(set) var savedMetadata: CoverImageMetaData?
    
    init(throwError: Bool, cachedPages: [PageInfo]) {
        self.throwError = throwError
        self.cachedPages = cachedPages
    }
}

extension MockDelegate: ComicPageNetworkService {
    func fetchImageData(from url: URL?) async throws -> Data {
        if throwError { throw NSError(domain: "Test", code: 0) }
        
        return .init()
    }
}

extension MockDelegate: ChapterProgressHandler {
    func markChapterAsRead(_ chapter: Chapter) {
        chapterMarkedAsRead = chapter
    }
    
    func updateLastReadPage(page: Int, chapter: Chapter) {
        lastPageReadInfo = (page, chapter)
    }
}

extension MockDelegate: ComicImageCache {
    func savePageImage(pageInfo: PageInfo) throws {
        if throwError { throw NSError(domain: "Test", code: 0) }
        
        savedPageInfoList.append(pageInfo)
    }
    
    func loadCachedImage(chapter: Int, page: Int) throws -> PageInfo? {
        if throwError { throw NSError(domain: "Test", code: 0) }
        
        return cachedPages.popLast()
    }
    
    func updateCurrentPageNumber(_ pageNumber: Int, readProgress: Int) {
        readProgressInfo = (pageNumber, readProgress)
    }
    
    func saveChapterCoverImage(imageData: Data, metadata: CoverImageMetaData) throws {
        if throwError { throw NSError(domain: "Test", code: 0) }
        
        savedMetadata = metadata
    }
}
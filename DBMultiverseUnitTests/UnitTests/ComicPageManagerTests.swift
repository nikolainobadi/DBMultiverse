//
//  ComicPageManagerTests.swift
//  DBMultiverseUnitTests
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import XCTest
import NnTestHelpers
import DBMultiverseComicKit
@testable import DBMultiverse

final class ComicPageManagerTests: XCTestCase {
    func test_starting_values_are_empty() {
        let (_, delegate) = makeSUT()
        
        XCTAssertNil(delegate.savedMetadata)
        XCTAssertNil(delegate.lastPageReadInfo)
        XCTAssertNil(delegate.readProgressInfo)
        XCTAssertNil(delegate.chapterMarkedAsRead)
        XCTAssert(delegate.savedPageInfoList.isEmpty)
    }
    
    func test_saves_cover_image_with_metadata_containing_chapter_name_and_progress() {
        let chapter = makeChapter(name: "Test Chapter", startPage: 1, endPage: 20)
        let pageInfo = PageInfo(chapter: chapter.number, pageNumber: 10, secondPageNumber: nil, imageData: Data("image".utf8))
        let (sut, delegate) = makeSUT(chapter: chapter)
        
        sut.saveChapterCoverPage(pageInfo)
        
        assertPropertyEquality(delegate.savedMetadata?.chapterName, expectedProperty: chapter.name)
        assertPropertyEquality(delegate.savedMetadata?.chapterNumber, expectedProperty: chapter.number)
        assertPropertyEquality(delegate.savedMetadata?.readProgress, expectedProperty: 50)
    }
    
    func test_loads_cached_pages_and_fetches_missing_pages_from_network() async throws {
        let cachedPageInfo = makePageInfo(page: 2)
        let chapter = makeChapter(startPage: 1, endPage: 20)
        let (sut, delegate) = makeSUT(chapter: chapter, cachedPages: [cachedPageInfo])
        let pages = try await sut.loadPages([2, 3])
        
        assertArray(pages.map(\.pageNumber), contains: [2, 3])
        assertArray(delegate.savedPageInfoList.map(\.pageNumber), contains: [3])
        assertArray(delegate.savedPageInfoList.map(\.pageNumber), doesNotContain: [2])
    }
    
    func test_does_not_mark_chapter_as_complete_when_end_page_is_not_read() {
        let start = 1
        let end = 5
        let chapter = makeChapter(startPage: start, endPage: end)
       
        for page in start..<end {
            let (sut, delegate) = makeSUT(chapter: chapter)
            
            sut.updateCurrentPageNumber(page)
            
            XCTAssertNil(delegate.chapterMarkedAsRead)
        }
    }
    
    func test_marks_chapter_as_read_when_last_page_is_read() {
        let chapter = makeChapter(startPage: 1, endPage: 20)
        let (sut, delegate) = makeSUT(chapter: chapter)
        
        sut.updateCurrentPageNumber(chapter.endPage)
        
        assertPropertyEquality(delegate.chapterMarkedAsRead, expectedProperty: chapter)
    }
}


// MARK: - SUT
extension ComicPageManagerTests {
    func makeSUT(chapter: Chapter? = nil, cachedPages: [PageInfo] = [], throwError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: ComicPageManager, delegate: MockDelegate) {
        let delegate = MockDelegate(throwError: throwError, cachedPages: cachedPages)
        let sut = ComicPageManager(chapter: chapter ?? makeChapter(), language: .english, imageCache: delegate, networkService: delegate, chapterProgressHandler: delegate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(delegate, file: file, line: line)
        
        return (sut, delegate)
    }
    
    func makePageInfo(page: Int, secondPage: Int? = nil) -> PageInfo {
        return .init(chapter: 1, pageNumber: page, secondPageNumber: secondPage, imageData: .init())
    }
}


// MARK: - Helper Classes
class MockDelegate {
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

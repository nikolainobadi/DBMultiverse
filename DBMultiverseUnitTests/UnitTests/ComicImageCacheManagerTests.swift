//
//  ComicImageCacheManagerTests.swift
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
struct ComicImageCacheManagerTests {
    @Test("Initialization starts with empty state")
    func initStartsWithEmptyState() {
        let (_, store, fileSystem, coverDelegate, _) = makeSUT()

        #expect(store.updateInfo == nil)
        #expect(coverDelegate.lastProgressUpdate == nil)
        #expect(coverDelegate.lastSavedImageData == nil)
        #expect(coverDelegate.lastSavedMetadata == nil)
        #expect(fileSystem.writtenData.isEmpty)
        #expect(fileSystem.createdDirectories.isEmpty)
    }
}


// MARK: - Update Current Page Number
extension ComicImageCacheManagerTests {
    @Test("Updates cover image progress")
    func updatesCoverImageProgress() {
        let pageNumber = 5
        let readProgress = 50
        let container = makeSUT()

        container.sut.updateCurrentPageNumber(pageNumber, readProgress: readProgress)

        #expect(container.coverDelegate.lastProgressUpdate == readProgress)
    }

    @Test("Updates store with page number and comic type", arguments: ComicType.allCases)
    func updatesStoreWithPageNumberAndComicType(comicType: ComicType) async throws {
        let pageNumber = 7
        let readProgress = 70
        let container = makeSUT(comicType: comicType)

        container.sut.updateCurrentPageNumber(pageNumber, readProgress: readProgress)
        
        let updateInfo = try #require(container.store.updateInfo)
        
        #expect(updateInfo.comicType == comicType)
        #expect(updateInfo.pageNumber == pageNumber)
    }
    
    @Test("Notifies widget reloader on progress updates")
    func notifiesWidgetReloaderOnProgressUpdates() {
        let readProgress = 60
        let container = makeSUT()
        
        container.sut.updateCurrentPageNumber(10, readProgress: readProgress)
        
        #expect(container.reloader.progressChanges == [readProgress])
    }
}


// MARK: - Save Chapter Cover Image
extension ComicImageCacheManagerTests {
    @Test("Delegates to cover image delegate")
    func delegatesToCoverImageDelegate() throws {
        let imageData = Data("test-image".utf8)
        let metadata = makeCoverImageMetadata()
        let container = makeSUT()

        try container.sut.saveChapterCoverImage(imageData: imageData, metadata: metadata)

        #expect(container.coverDelegate.lastSavedImageData == imageData)
        #expect(container.coverDelegate.lastSavedMetadata == metadata)
        #expect(container.reloader.chapterChanges.count == 1)
        #expect(container.reloader.chapterChanges.first?.chapter == metadata.chapterNumber)
        #expect(container.reloader.chapterChanges.first?.progress == metadata.readProgress)
    }
}


// MARK: - Load Cached Image
extension ComicImageCacheManagerTests {
    @Test("Returns single page when file exists")
    func returnsSinglePageWhenFileExists() throws {
        let chapter = 3
        let page = 5
        let expectedData = Data("cached-image".utf8)
        let container = makeSUT(fileContents: ["/Users/test/Library/Caches/Chapters/Chapter_3/Page_5.jpg": expectedData])
        let result = try container.sut.loadCachedImage(chapter: chapter, page: page)

        #expect(result?.chapter == chapter)
        #expect(result?.pageNumber == page)
        #expect(result?.secondPageNumber == nil)
        #expect(result?.imageData == expectedData)
    }

    @Test("Returns double page from metadata")
    func returnsDoublePageFromMetadata() throws {
        let chapter = 2
        let page = 8
        let secondPage = 9
        let expectedData = Data("double-page-image".utf8)
        let metadata: [String: Any] = [
            "pages": [
                ["pageNumber": page, "secondPageNumber": secondPage, "fileName": "Page_8-9.jpg"]
            ]
        ]
        
        let metadataData = try JSONSerialization.data(withJSONObject: metadata)
        let container = makeSUT(fileContents: [
            "/Users/test/Library/Caches/Chapters/Chapter_2/metadata.json": metadataData,
            "/Users/test/Library/Caches/Chapters/Chapter_2/Page_8-9.jpg": expectedData
        ])

        let result = try #require(try container.sut.loadCachedImage(chapter: chapter, page: page))

        #expect(result.chapter == chapter)
        #expect(result.pageNumber == page)
        #expect(result.secondPageNumber == secondPage)
        #expect(result.imageData == expectedData)
    }

    @Test("Returns nil when no file or metadata exists")
    func returnsNilWhenNoFileExists() throws {
        let container = makeSUT()

        let result = try container.sut.loadCachedImage(chapter: 1, page: 1)

        #expect(result == nil)
    }

    @Test("Handles corrupted metadata gracefully")
    func handlesCorruptedMetadataGracefully() throws {
        let chapter = 1
        let page = 1
        let container = makeSUT(fileContents: [
            "/Users/test/Library/Caches/Chapters/Chapter_1/metadata.json": Data("invalid json".utf8)
        ])

        let result = try container.sut.loadCachedImage(chapter: chapter, page: page)

        #expect(result == nil)
    }
}


// MARK: - Save Page Image
extension ComicImageCacheManagerTests {
    @Test("Creates directory and writes single page data")
    func createsDirectoryAndWritesSinglePageData() throws {
        let pageInfo = makePageInfo(chapter: 5, pageNumber: 10)
        let container = makeSUT()

        try container.sut.savePageImage(pageInfo: pageInfo)

        let expectedDir = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_5/")
        let expectedFile = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_5/Page_10.jpg")

        #expect(container.fileSystem.createdDirectories.contains(expectedDir))
        #expect(container.fileSystem.writtenData[expectedFile] == pageInfo.imageData)
    }

    @Test("Saves double page with metadata")
    func savesDoublePageWithMetadata() throws {
        let pageInfo = makePageInfo(chapter: 3, pageNumber: 20, secondPageNumber: 21)
        let container = makeSUT()

        try container.sut.savePageImage(pageInfo: pageInfo)

        let expectedImageFile = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_3/Page_20-21.jpg")
        let expectedMetadataFile = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_3/metadata.json")

        #expect(container.fileSystem.writtenData[expectedImageFile] == pageInfo.imageData)

        guard let metadataData = container.fileSystem.writtenData[expectedMetadataFile],
              let metadata = try? JSONSerialization.jsonObject(with: metadataData) as? [String: Any],
              let pages = metadata["pages"] as? [[String: Any]],
              let firstPage = pages.first else {
            #expect(Bool(false), "Metadata not properly saved")
            return
        }

        #expect(firstPage["pageNumber"] as? Int == 20)
        #expect(firstPage["secondPageNumber"] as? Int == 21)
        #expect(firstPage["fileName"] as? String == "Page_20-21.jpg")
    }

    @Test("Appends to existing metadata")
    func appendsToExistingMetadata() throws {
        let existingMetadata: [String: Any] = [
            "pages": [
                ["pageNumber": 8, "secondPageNumber": 9, "fileName": "Page_8-9.jpg"]
            ]
        ]
        let existingData = try JSONSerialization.data(withJSONObject: existingMetadata)
        let pageInfo = makePageInfo(chapter: 3, pageNumber: 20, secondPageNumber: 21, imageData: Data("new-double-page".utf8))
        let container = makeSUT(fileContents: [
            "/Users/test/Library/Caches/Chapters/Chapter_3/metadata.json": existingData
        ])

        try container.sut.savePageImage(pageInfo: pageInfo)

        let metadataFile = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_3/metadata.json")
        guard let updatedData = container.fileSystem.writtenData[metadataFile],
              let metadata = try? JSONSerialization.jsonObject(with: updatedData) as? [String: Any],
              let pages = metadata["pages"] as? [[String: Any]] else {
            #expect(Bool(false), "Updated metadata not properly saved")
            return
        }

        #expect(pages.count == 2)

        let newPage = pages.first { $0["pageNumber"] as? Int == 20 }
        #expect(newPage?["secondPageNumber"] as? Int == 21)
    }
}


// MARK: - Error Handling
extension ComicImageCacheManagerTests {
    @Test("Handles file system errors gracefully")
    func handlesFileSystemErrorsGracefully() {
        let pageInfo = makePageInfo(chapter: 1, pageNumber: 1)
        let container = makeSUT(throwError: true)

        #expect(throws: (any Error).self) {
            try container.sut.savePageImage(pageInfo: pageInfo)
        }
    }
}



// MARK: - SUT
private extension ComicImageCacheManagerTests {
    func makeSUT(comicType: ComicType = .story, fileContents: [String: Data] = [:], throwError: Bool = false) -> (sut: ComicImageCacheManager, store: MockComicPageStore, fileSystem: MockFileSystemOperations, coverDelegate: MockCoverImageDelegate, reloader: MockWidgetTimelineReloader) {
        let store = MockComicPageStore()
        let coverDelegate = MockCoverImageDelegate()
        let reloader = MockWidgetTimelineReloader()
        let fileSystem = MockFileSystemOperations(throwError: throwError, fileContents: fileContents)
        let sut = ComicImageCacheManager(
            comicType: comicType,
            store: store,
            coverImageDelegate: coverDelegate,
            widgetTimelineReloader: reloader,
            comicImageCacheDelegate: fileSystem
        )

        return (sut, store, fileSystem, coverDelegate, reloader)
    }
    
    func makeCoverImageMetadata(chapterName: String = "Chapter 1", chapterNumber: Int = 1, readProgress: Int = 25) -> CoverImageMetaData {
        return .init(chapterName: chapterName, chapterNumber: chapterNumber, readProgress: readProgress)
    }

    func makePageInfo(chapter: Int, pageNumber: Int, secondPageNumber: Int? = nil, imageData: Data = Data("page-data".utf8)) -> PageInfo {
        return .init(chapter: chapter, pageNumber: pageNumber, secondPageNumber: secondPageNumber, imageData: imageData)
    }
}

// MARK: - Mocks
private extension ComicImageCacheManagerTests {
    @MainActor
    final class MockComicPageStore: ComicPageStore {
        private(set) var updateInfo: (pageNumber: Int, comicType: ComicType)?
        
        func updateCurrentPageNumber(_ pageNumber: Int, comicType: ComicType) {
            updateInfo = (pageNumber, comicType)
        }
    }
    
    @MainActor
    final class MockCoverImageDelegate: CoverImageDelegate {
        private(set) var lastProgressUpdate: Int?
        private(set) var lastSavedImageData: Data?
        private(set) var lastSavedMetadata: CoverImageMetaData?

        func updateProgress(to newProgress: Int) {
            lastProgressUpdate = newProgress
        }

        func saveCurrentChapterData(imageData: Data, metadata: CoverImageMetaData) {
            lastSavedImageData = imageData
            lastSavedMetadata = metadata
        }
    }
    
    @MainActor
    final class MockWidgetTimelineReloader: WidgetTimelineReloader {
        private(set) var progressChanges: [Int] = []
        private(set) var chapterChanges: [(chapter: Int, progress: Int)] = []

        func notifyChapterChange(chapter: Int, progress: Int) {
            chapterChanges.append((chapter, progress))
        }

        func notifyProgressChange(progress: Int) {
            progressChanges.append(progress)
        }
    }
    
    final class MockFileSystemOperations: ComicImageCacheDelegate, @unchecked Sendable {
        private let throwError: Bool
        private let fileContents: [String: Data]
        private(set) var writtenData: [URL: Data] = [:]
        private(set) var createdDirectories: [URL] = []
        
        init(throwError: Bool, fileContents: [String: Data]) {
            self.throwError = throwError
            self.fileContents = fileContents
        }

        func getCacheDirectoryURL() -> URL? {
            return URL(fileURLWithPath: "/Users/test/Library/Caches")
        }

        func contents(atPath path: String) -> Data? {
            return fileContents[path]
        }

        func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws {
            if throwError {
                throw NSError(domain: "Test", code: 0)
            }
            createdDirectories.append(url)
        }

        func write(data: Data, to url: URL) throws {
            if throwError {
                throw NSError(domain: "Test", code: 0)
            }
            writtenData[url] = data
        }
    }
}

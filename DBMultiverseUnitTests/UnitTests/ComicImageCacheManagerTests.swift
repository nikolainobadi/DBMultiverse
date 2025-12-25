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
        #expect(coverDelegate.lastSavedChapterData == nil)
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
        let (sut, _, _, coverDelegate, reloader) = makeSUT()

        try sut.saveChapterCoverImage(imageData: imageData, metadata: metadata)

        let expectedData = MockCoverImageDelegate.SavedChapterData(imageData: imageData, metadata: metadata)
        #expect(coverDelegate.lastSavedChapterData == expectedData)
        #expect(reloader.chapterChanges == [MockWidgetTimelineReloader.ChapterChange(chapter: metadata.chapterNumber, progress: metadata.readProgress)])
    }
}


// MARK: - Load Cached Image
extension ComicImageCacheManagerTests {
    @Test("Returns single page when file exists")
    func returnsSinglePageWhenFileExists() throws {
        let chapter = 3
        let page = 5
        let expectedData = Data("cached-image".utf8)
        let (sut, _, fileSystem, _, _) = makeSUT()
        fileSystem.fileContents["/Users/test/Library/Caches/Chapters/Chapter_3/Page_5.jpg"] = expectedData

        let result = try sut.loadCachedImage(chapter: chapter, page: page)

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
        let (sut, _, fileSystem, _, _) = makeSUT()

        let metadata: [String: Any] = [
            "pages": [
                ["pageNumber": page, "secondPageNumber": secondPage, "fileName": "Page_8-9.jpg"]
            ]
        ]
        let metadataData = try JSONSerialization.data(withJSONObject: metadata)
        fileSystem.fileContents["/Users/test/Library/Caches/Chapters/Chapter_2/metadata.json"] = metadataData
        fileSystem.fileContents["/Users/test/Library/Caches/Chapters/Chapter_2/Page_8-9.jpg"] = expectedData

        let result = try sut.loadCachedImage(chapter: chapter, page: page)

        #expect(result?.chapter == chapter)
        #expect(result?.pageNumber == page)
        #expect(result?.secondPageNumber == secondPage)
        #expect(result?.imageData == expectedData)
    }

    @Test("Returns nil when no file or metadata exists")
    func returnsNilWhenNoFileExists() throws {
        let sut = makeSUT().sut

        let result = try sut.loadCachedImage(chapter: 1, page: 1)

        #expect(result == nil)
    }

    @Test("Handles corrupted metadata gracefully")
    func handlesCorruptedMetadataGracefully() throws {
        let chapter = 1
        let page = 1
        let (sut, _, fileSystem, _, _) = makeSUT()

        fileSystem.fileContents["/Users/test/Library/Caches/Chapters/Chapter_1/metadata.json"] = Data("invalid json".utf8)

        let result = try sut.loadCachedImage(chapter: chapter, page: page)

        #expect(result == nil)
    }
}


// MARK: - Save Page Image
extension ComicImageCacheManagerTests {
    @Test("Creates directory and writes single page data")
    func createsDirectoryAndWritesSinglePageData() throws {
        let pageInfo = makePageInfo(chapter: 5, pageNumber: 10)
        let (sut, _, fileSystem, _, _) = makeSUT()

        try sut.savePageImage(pageInfo: pageInfo)

        let expectedDir = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_5/")
        let expectedFile = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_5/Page_10.jpg")

        #expect(fileSystem.createdDirectories.contains(expectedDir))
        #expect(fileSystem.writtenData[expectedFile] == pageInfo.imageData)
    }

    @Test("Saves double page with metadata")
    func savesDoublePageWithMetadata() throws {
        let pageInfo = makePageInfo(chapter: 3, pageNumber: 20, secondPageNumber: 21)
        let (sut, _, fileSystem, _, _) = makeSUT()

        try sut.savePageImage(pageInfo: pageInfo)

        let expectedImageFile = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_3/Page_20-21.jpg")
        let expectedMetadataFile = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_3/metadata.json")

        #expect(fileSystem.writtenData[expectedImageFile] == pageInfo.imageData)

        guard let metadataData = fileSystem.writtenData[expectedMetadataFile],
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
        let (sut, _, fileSystem, _, _) = makeSUT()
        fileSystem.fileContents["/Users/test/Library/Caches/Chapters/Chapter_3/metadata.json"] = existingData

        try sut.savePageImage(pageInfo: pageInfo)

        let metadataFile = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_3/metadata.json")
        guard let updatedData = fileSystem.writtenData[metadataFile],
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
        let (sut, _, fileSystem, _, _) = makeSUT()
        fileSystem.shouldThrowError = true

        #expect(throws: (any Error).self) {
            try sut.savePageImage(pageInfo: pageInfo)
        }
    }
}



// MARK: - SUT
private extension ComicImageCacheManagerTests {
    func makeSUT(comicType: ComicType = .story) -> (sut: ComicImageCacheManager, store: MockComicPageStore, fileSystem: MockFileSystemOperations, coverDelegate: MockCoverImageDelegate, reloader: MockWidgetTimelineReloader) {
        let store = MockComicPageStore()
        let fileSystem = MockFileSystemOperations()
        let coverDelegate = MockCoverImageDelegate()
        let reloader = MockWidgetTimelineReloader()
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
        var lastProgressUpdate: Int?
        var lastSavedChapterData: SavedChapterData?
        
        func updateProgress(to newProgress: Int) {
            lastProgressUpdate = newProgress
        }
        
        func saveCurrentChapterData(imageData: Data, metadata: CoverImageMetaData) {
            lastSavedChapterData = SavedChapterData(imageData: imageData, metadata: metadata)
        }
        
        struct SavedChapterData: Equatable {
            let imageData: Data
            let metadata: CoverImageMetaData
        }
    }
    
    @MainActor
    final class MockWidgetTimelineReloader: WidgetTimelineReloader {
        struct ChapterChange: Equatable {
            let chapter: Int
            let progress: Int
        }
        
        private(set) var progressChanges: [Int] = []
        private(set) var chapterChanges: [ChapterChange] = []
        
        func notifyChapterChange(chapter: Int, progress: Int) {
            chapterChanges.append(.init(chapter: chapter, progress: progress))
        }
        
        func notifyProgressChange(progress: Int) {
            progressChanges.append(progress)
        }
    }
    
    final class MockFileSystemOperations: ComicImageCacheDelegate, @unchecked Sendable {
        var fileContents: [String: Data] = [:]
        var writtenData: [URL: Data] = [:]
        var createdDirectories: [URL] = []
        var shouldThrowError = false
        
        func getCacheDirectoryURL() -> URL? {
            return URL(fileURLWithPath: "/Users/test/Library/Caches")
        }
        
        func contents(atPath path: String) -> Data? {
            return fileContents[path]
        }
        
        func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws {
            if shouldThrowError {
                throw NSError(domain: "Test", code: 0)
            }
            createdDirectories.append(url)
        }
        
        func write(data: Data, to url: URL) throws {
            if shouldThrowError {
                throw NSError(domain: "Test", code: 0)
            }
            writtenData[url] = data
        }
    }
}

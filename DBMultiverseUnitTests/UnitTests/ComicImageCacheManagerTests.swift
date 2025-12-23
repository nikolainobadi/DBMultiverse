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
@LeakTracked
final class ComicImageCacheManagerTests {
    @Test("Initialization starts with empty state")
    func initStartsWithEmptyState() {
        let (_, store, fileSystem, coverDelegate, _) = makeSUT()

        #expect(store.lastUpdateInfo == nil)
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
        let (sut, _, _, coverDelegate, _) = makeSUT()

        sut.updateCurrentPageNumber(pageNumber, readProgress: readProgress)

        #expect(coverDelegate.lastProgressUpdate == readProgress)
    }

    @Test("Updates store with page number and comic type")
    func updatesStoreWithPageNumberAndComicType() async throws {
        let pageNumber = 7
        let readProgress = 70
        let comicType = ComicType.specials
        let (sut, store, _, _, _) = makeSUT(comicType: comicType)

        sut.updateCurrentPageNumber(pageNumber, readProgress: readProgress)

        let expectedUpdate = MockComicPageStore.UpdateInfo(pageNumber: pageNumber, comicType: comicType)
        try await store.$lastUpdateInfo.waitUntil { $0 == expectedUpdate }
    }
    
    @Test("Notifies widget reloader on progress updates")
    func notifiesWidgetReloaderOnProgressUpdates() {
        let readProgress = 60
        let (sut, _, _, _, reloader) = makeSUT()
        
        sut.updateCurrentPageNumber(10, readProgress: readProgress)
        
        #expect(reloader.progressChanges == [readProgress])
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

// MARK: - Comic Types
extension ComicImageCacheManagerTests {
    @Test("Handles different comic types correctly")
    func handlesDifferentComicTypesCorrectly() async throws {
        let pageNumber = 10
        let readProgress = 75
        let storyType = ComicType.story
        let specialsType = ComicType.specials

        let (storySUT, storyStore, _, _, _) = makeSUT(comicType: storyType)
        let (specialsSUT, specialsStore, _, _, _) = makeSUT(comicType: specialsType)

        storySUT.updateCurrentPageNumber(pageNumber, readProgress: readProgress)
        specialsSUT.updateCurrentPageNumber(pageNumber, readProgress: readProgress)

        let expectedStoryUpdate = MockComicPageStore.UpdateInfo(pageNumber: pageNumber, comicType: storyType)
        let expectedSpecialsUpdate = MockComicPageStore.UpdateInfo(pageNumber: pageNumber, comicType: specialsType)
        try await storyStore.$lastUpdateInfo.waitUntil { $0 == expectedStoryUpdate }
        try await specialsStore.$lastUpdateInfo.waitUntil { $0 == expectedSpecialsUpdate }
    }
}

// MARK: - SUT
private extension ComicImageCacheManagerTests {
    func makeSUT(
        comicType: ComicType = .story,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) -> (sut: ComicImageCacheManager, store: MockComicPageStore, fileSystem: MockFileSystemOperations, coverDelegate: MockCoverImageDelegate, reloader: MockWidgetTimelineReloader) {
        let store = MockComicPageStore()
        let fileSystem = MockFileSystemOperations()
        let coverDelegate = MockCoverImageDelegate()
        let reloader = MockWidgetTimelineReloader()
        let sut = ComicImageCacheManager(
            comicType: comicType,
            store: store,
            fileSystemOperations: fileSystem,
            coverImageDelegate: coverDelegate,
            widgetTimelineReloader: reloader
        )

        trackForMemoryLeaks(store, fileID: fileID, filePath: filePath, line: line, column: column)
        trackForMemoryLeaks(fileSystem, fileID: fileID, filePath: filePath, line: line, column: column)
        trackForMemoryLeaks(coverDelegate, fileID: fileID, filePath: filePath, line: line, column: column)
        trackForMemoryLeaks(reloader, fileID: fileID, filePath: filePath, line: line, column: column)

        return (sut, store, fileSystem, coverDelegate, reloader)
    }
}

// MARK: - Test Helpers
private extension ComicImageCacheManagerTests {
    func makeCoverImageMetadata(
        chapterName: String = "Chapter 1",
        chapterNumber: Int = 1,
        readProgress: Int = 25
    ) -> CoverImageMetaData {
        CoverImageMetaData(chapterName: chapterName, chapterNumber: chapterNumber, readProgress: readProgress)
    }

    func makePageInfo(
        chapter: Int,
        pageNumber: Int,
        secondPageNumber: Int? = nil,
        imageData: Data = Data("page-data".utf8)
    ) -> PageInfo {
        PageInfo(chapter: chapter, pageNumber: pageNumber, secondPageNumber: secondPageNumber, imageData: imageData)
    }
}

// MARK: - Mocks
@MainActor
private final class MockComicPageStore: ComicPageStore {
    @Published var lastUpdateInfo: UpdateInfo?

    func updateCurrentPageNumber(_ pageNumber: Int, comicType: ComicType) {
        lastUpdateInfo = UpdateInfo(pageNumber: pageNumber, comicType: comicType)
    }

    struct UpdateInfo: Equatable, Sendable {
        let pageNumber: Int
        let comicType: ComicType
    }
}

@MainActor
private final class MockCoverImageDelegate: CoverImageDelegate {
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
private final class MockWidgetTimelineReloader: WidgetTimelineReloader {
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

private final class MockFileSystemOperations: FileSystemOperations, @unchecked Sendable {
    var fileContents: [String: Data] = [:]
    var writtenData: [URL: Data] = [:]
    var createdDirectories: [URL] = []
    var shouldThrowError = false
    
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
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        // Return a mock cache directory
        return [URL(fileURLWithPath: "/Users/test/Library/Caches")]
    }
}

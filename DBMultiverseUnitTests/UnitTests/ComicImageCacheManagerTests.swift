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
        let (_, store, fileSystem, coverDelegate) = makeSUT()
        
        #expect(store.lastUpdateInfo == nil)
        #expect(coverDelegate.lastProgressUpdate == nil)
        #expect(coverDelegate.lastSavedChapterData == nil)
        #expect(fileSystem.writtenData.isEmpty)
        #expect(fileSystem.createdDirectories.isEmpty)
    }
    
    // MARK: - Update Current Page Number Tests
    
    @Test("Update current page number updates cover image progress")
    func updateCurrentPageNumberUpdatesCoverImageProgress() {
        let pageNumber = 5
        let readProgress = 50
        let (sut, _, _, coverDelegate) = makeSUT()
        
        sut.updateCurrentPageNumber(pageNumber, readProgress: readProgress)
        
        #expect(coverDelegate.lastProgressUpdate == readProgress)
    }
    
    @Test("Update current page number updates store with page number and comic type")
    func updateCurrentPageNumberUpdatesStore() async {
        let pageNumber = 7
        let readProgress = 70
        let comicType = ComicType.specials
        let (sut, store, _, _) = makeSUT(comicType: comicType)
        
        sut.updateCurrentPageNumber(pageNumber, readProgress: readProgress)
        
        // Wait for async dispatch to complete
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(store.lastUpdateInfo?.pageNumber == pageNumber)
        #expect(store.lastUpdateInfo?.comicType == comicType)
    }
    
    // MARK: - Save Chapter Cover Image Tests
    
    @Test("Save chapter cover image delegates to cover image delegate")
    func saveChapterCoverImageDelegatesToCoverImageDelegate() throws {
        let imageData = Data("test-image".utf8)
        let metadata = CoverImageMetaData(chapterName: "Chapter 1", chapterNumber: 1, readProgress: 25)
        let (sut, _, _, coverDelegate) = makeSUT()
        
        try sut.saveChapterCoverImage(imageData: imageData, metadata: metadata)
        
        #expect(coverDelegate.lastSavedChapterData?.imageData == imageData)
        #expect(coverDelegate.lastSavedChapterData?.metadata.chapterName == metadata.chapterName)
        #expect(coverDelegate.lastSavedChapterData?.metadata.chapterNumber == metadata.chapterNumber)
        #expect(coverDelegate.lastSavedChapterData?.metadata.readProgress == metadata.readProgress)
    }
    
    // MARK: - Load Cached Image Tests
    
    @Test("Load cached image returns single page when file exists")
    func loadCachedImageReturnsSinglePageWhenFileExists() throws {
        let chapter = 3
        let page = 5
        let expectedData = Data("cached-image".utf8)
        let (sut, _, fileSystem, _) = makeSUT()
        fileSystem.fileContents["/Users/test/Library/Caches/Chapters/Chapter_3/Page_5.jpg"] = expectedData
        
        let result = try sut.loadCachedImage(chapter: chapter, page: page)
        
        #expect(result?.chapter == chapter)
        #expect(result?.pageNumber == page)
        #expect(result?.secondPageNumber == nil)
        #expect(result?.imageData == expectedData)
    }
    
    @Test("Load cached image returns double page from metadata")
    func loadCachedImageReturnsDoublePageFromMetadata() throws {
        let chapter = 2
        let page = 8
        let secondPage = 9
        let expectedData = Data("double-page-image".utf8)
        let (sut, _, fileSystem, _) = makeSUT()
        
        // Setup metadata
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
    
    @Test("Load cached image returns nil when no file or metadata exists")
    func loadCachedImageReturnsNilWhenNoFileExists() throws {
        let (sut, _, _, _) = makeSUT()
        
        let result = try sut.loadCachedImage(chapter: 1, page: 1)
        
        #expect(result == nil)
    }
    
    // MARK: - Save Page Image Tests
    
    @Test("Save page image creates directory and writes single page data")
    func savePageImageCreatesDirectoryAndWritesSinglePageData() throws {
        let pageInfo = PageInfo(chapter: 5, pageNumber: 10, secondPageNumber: nil, imageData: Data("page-data".utf8))
        let (sut, _, fileSystem, _) = makeSUT()
        
        try sut.savePageImage(pageInfo: pageInfo)
        
        let expectedDir = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_5/")
        let expectedFile = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_5/Page_10.jpg")
        
        #expect(fileSystem.createdDirectories.contains(expectedDir))
        #expect(fileSystem.writtenData[expectedFile] == pageInfo.imageData)
    }
    
    @Test("Save page image saves double page with metadata")
    func savePageImageSavesDoublePageWithMetadata() throws {
        let pageInfo = PageInfo(chapter: 3, pageNumber: 20, secondPageNumber: 21, imageData: Data("double-page".utf8))
        let (sut, _, fileSystem, _) = makeSUT()
        
        try sut.savePageImage(pageInfo: pageInfo)
        
        let expectedImageFile = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_3/Page_20-21.jpg")
        let expectedMetadataFile = URL(fileURLWithPath: "/Users/test/Library/Caches/Chapters/Chapter_3/metadata.json")
        
        #expect(fileSystem.writtenData[expectedImageFile] == pageInfo.imageData)
        
        // Verify metadata was written
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
    
    @Test("Save page image appends to existing metadata")
    func savePageImageAppendsToExistingMetadata() throws {
        let existingMetadata: [String: Any] = [
            "pages": [
                ["pageNumber": 8, "secondPageNumber": 9, "fileName": "Page_8-9.jpg"]
            ]
        ]
        let existingData = try JSONSerialization.data(withJSONObject: existingMetadata)
        
        let pageInfo = PageInfo(chapter: 3, pageNumber: 20, secondPageNumber: 21, imageData: Data("new-double-page".utf8))
        let (sut, _, fileSystem, _) = makeSUT()
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
        
        // Verify new page was added
        let newPage = pages.first { $0["pageNumber"] as? Int == 20 }
        #expect(newPage?["secondPageNumber"] as? Int == 21)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Save page image handles file system errors gracefully")
    func savePageImageHandlesFileSystemErrors() {
        let pageInfo = PageInfo(chapter: 1, pageNumber: 1, secondPageNumber: nil, imageData: Data("test".utf8))
        let (sut, _, fileSystem, _) = makeSUT()
        fileSystem.shouldThrowError = true
        
        #expect(throws: (any Error).self) {
            try sut.savePageImage(pageInfo: pageInfo)
        }
    }
    
    @Test("Load cached image handles corrupted metadata gracefully")
    func loadCachedImageHandlesCorruptedMetadata() throws {
        let chapter = 1
        let page = 1
        let (sut, _, fileSystem, _) = makeSUT()
        
        // Setup corrupted metadata
        fileSystem.fileContents["/Users/test/Library/Caches/Chapters/Chapter_1/metadata.json"] = Data("invalid json".utf8)
        
        let result = try sut.loadCachedImage(chapter: chapter, page: page)
        
        #expect(result == nil)
    }
    
    @Test("Handles different comic types correctly")
    func handlesDifferentComicTypesCorrectly() async {
        let pageNumber = 10
        let readProgress = 75
        let storyType = ComicType.story
        let specialsType = ComicType.specials
        
        let (storySUT, storyStore, _, _) = makeSUT(comicType: storyType)
        let (specialsSUT, specialsStore, _, _) = makeSUT(comicType: specialsType)
        
        storySUT.updateCurrentPageNumber(pageNumber, readProgress: readProgress)
        specialsSUT.updateCurrentPageNumber(pageNumber, readProgress: readProgress)
        
        // Wait for async dispatch
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(storyStore.lastUpdateInfo?.comicType == storyType)
        #expect(specialsStore.lastUpdateInfo?.comicType == specialsType)
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
    ) -> (sut: ComicImageCacheManager, store: MockComicPageStore, fileSystem: MockFileSystemOperations, coverDelegate: MockCoverImageDelegate) {
        let store = MockComicPageStore()
        let fileSystem = MockFileSystemOperations()
        let coverDelegate = MockCoverImageDelegate()
        let sut = ComicImageCacheManager(
            comicType: comicType,
            store: store,
            fileSystemOperations: fileSystem,
            coverImageDelegate: coverDelegate
        )
        
        trackForMemoryLeaks(store, fileID: fileID, filePath: filePath, line: line, column: column)
        trackForMemoryLeaks(fileSystem, fileID: fileID, filePath: filePath, line: line, column: column)
        trackForMemoryLeaks(coverDelegate, fileID: fileID, filePath: filePath, line: line, column: column)
        
        return (sut, store, fileSystem, coverDelegate)
    }
}

// MARK: - Mock Classes
@MainActor
private final class MockComicPageStore: ComicPageStore {
    var lastUpdateInfo: (pageNumber: Int, comicType: ComicType)?
    
    func updateCurrentPageNumber(_ pageNumber: Int, comicType: ComicType) {
        lastUpdateInfo = (pageNumber, comicType)
    }
}

@MainActor
private final class MockCoverImageDelegate: CoverImageDelegate {
    var lastProgressUpdate: Int?
    var lastSavedChapterData: (imageData: Data, metadata: CoverImageMetaData)?
    
    func updateProgress(to newProgress: Int) {
        lastProgressUpdate = newProgress
    }
    
    func saveCurrentChapterData(imageData: Data, metadata: CoverImageMetaData) {
        lastSavedChapterData = (imageData, metadata)
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

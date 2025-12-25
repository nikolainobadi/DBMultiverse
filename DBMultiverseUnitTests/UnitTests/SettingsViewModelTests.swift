//
//  SettingsViewModelTests.swift
//  DBMultiverseUnitTests
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Testing
import Foundation
import NnSwiftTestingHelpers
import DBMultiverseComicKit
@testable import DBMultiverse

@MainActor
@LeakTracked
final class SettingsViewModelTests {
    @Test("Initial state has default values")
    func initialStateHasDefaultValues() {
        let sut = makeSUT().sut

        #expect(sut.route == nil)
        #expect(sut.showingErrorAlert == false)
        #expect(sut.showingClearedCacheAlert == false)
        #expect(sut.cachedChapters.isEmpty)
    }
}

// MARK: - Show View
extension SettingsViewModelTests {
    @Test("Show view updates route correctly")
    func showViewUpdatesRouteCorrectly() {
        let sut = makeSUT().sut

        sut.showView(.cacheList)
        #expect(sut.route == .cacheList)

        sut.showView(.languageSelection)
        #expect(sut.route == .languageSelection)

        sut.showView(.disclaimer)
        #expect(sut.route == .disclaimer)
    }
}

// MARK: - Clear Cache
extension SettingsViewModelTests {
    @Test("Clear cache removes all files successfully")
    func clearCacheRemovesAllFilesSuccessfully() {
        let mockFiles = [
            URL(fileURLWithPath: "/cache/file1.jpg"),
            URL(fileURLWithPath: "/cache/file2.jpg"),
            URL(fileURLWithPath: "/cache/file3.jpg")
        ]
        let (sut, mockFileManager) = makeSUT(cacheContents: mockFiles)

        sut.cachedChapters = [
            CachedChapter(number: "1", imageCount: 10),
            CachedChapter(number: "2", imageCount: 15)
        ]

        sut.clearCache()

        #expect(mockFileManager.removeItemCallCount == mockFiles.count)
        #expect(mockFileManager.removedURLs == mockFiles)
        #expect(sut.cachedChapters.isEmpty)
        #expect(sut.showingClearedCacheAlert == true)
        #expect(sut.showingErrorAlert == false)
    }

    @Test("Clear cache shows error alert on failure")
    func clearCacheShowsErrorAlertOnFailure() {
        let (sut, mockFileManager) = makeSUT(shouldThrowError: true)

        sut.clearCache()

        #expect(sut.showingErrorAlert == true)
        #expect(sut.showingClearedCacheAlert == false)
        #expect(mockFileManager.removeItemCallCount == 0)
    }

    @Test("Clear cache preserves cached chapters on error")
    func clearCachePreservesCachedChaptersOnError() {
        let sut = makeSUT(shouldThrowError: true).sut
        let initialChapters = [
            CachedChapter(number: "1", imageCount: 10),
            CachedChapter(number: "2", imageCount: 15)
        ]
        sut.cachedChapters = initialChapters

        sut.clearCache()

        #expect(sut.cachedChapters == initialChapters)
    }
}


// MARK: - Load Cached Chapters
extension SettingsViewModelTests {
    @Test("Load cached chapters reads chapter folders correctly")
    func loadCachedChaptersReadsChapterFoldersCorrectly() {
        let chapter1Images = [
            URL(fileURLWithPath: "/cache/Chapters/Chapter_1/page1.jpg"),
            URL(fileURLWithPath: "/cache/Chapters/Chapter_1/page2.jpg"),
            URL(fileURLWithPath: "/cache/Chapters/Chapter_1/info.txt")
        ]
        let chapter2Images = [
            URL(fileURLWithPath: "/cache/Chapters/Chapter_2/page1.jpg"),
            URL(fileURLWithPath: "/cache/Chapters/Chapter_2/page2.jpg"),
            URL(fileURLWithPath: "/cache/Chapters/Chapter_2/page3.jpg")
        ]

        let chapterFolders = [
            URL(fileURLWithPath: "/cache/Chapters/Chapter_1"),
            URL(fileURLWithPath: "/cache/Chapters/Chapter_2")
        ]

        let (sut, mockFileManager) = makeSUT()
        mockFileManager.setupChapterData(folders: chapterFolders, folderContents: [
            "/cache/Chapters/Chapter_1": chapter1Images,
            "/cache/Chapters/Chapter_2": chapter2Images
        ])

        sut.loadCachedChapters()

        #expect(sut.cachedChapters.count == 2)
        #expect(sut.cachedChapters[0].number == "1")
        #expect(sut.cachedChapters[0].imageCount == 2)
        #expect(sut.cachedChapters[1].number == "2")
        #expect(sut.cachedChapters[1].imageCount == 3)
    }

    @Test("Load cached chapters handles empty cache directory")
    func loadCachedChaptersHandlesEmptyCacheDirectory() {
        let (sut, mockFileManager) = makeSUT()
        mockFileManager.setupChapterData(folders: [], folderContents: [:])

        sut.loadCachedChapters()

        #expect(sut.cachedChapters.isEmpty)
    }

    @Test("Load cached chapters handles error gracefully")
    func loadCachedChaptersHandlesErrorGracefully() {
        let (sut, mockFileManager) = makeSUT()
        mockFileManager.shouldThrowOnContentsOfDirectory = true

        sut.loadCachedChapters()

        #expect(sut.cachedChapters.isEmpty)
    }
}


// MARK: - SUT
private extension SettingsViewModelTests {
    func makeSUT(
        shouldThrowError: Bool = false,
        cacheContents: [URL] = [],
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) -> (sut: SettingsViewModel, mockFileManager: MockCacheDelegate) {
        let mockFileManager = MockCacheDelegate(
            shouldThrowError: shouldThrowError,
            cacheContents: cacheContents
        )
        let sut = SettingsViewModel(fileManager: mockFileManager)

        trackForMemoryLeaks(sut, fileID: fileID, filePath: filePath, line: line, column: column)
        trackForMemoryLeaks(mockFileManager, fileID: fileID, filePath: filePath, line: line, column: column)

        return (sut, mockFileManager)
    }
}


// MARK: - Mocks
private extension SettingsViewModelTests {
    final class MockCacheDelegate: CacheDelegate, @unchecked Sendable {
        private let shouldThrowError: Bool
        private let cacheContents: [URL]
        private var chapterFolders: [URL] = []
        private var folderContents: [String: [URL]] = [:]

        var shouldThrowOnContentsOfDirectory = false
        private(set) var removeItemCallCount = 0
        private(set) var removedURLs: [URL] = []

        init(shouldThrowError: Bool = false, cacheContents: [URL] = []) {
            self.shouldThrowError = shouldThrowError
            self.cacheContents = cacheContents
        }

        func setupChapterData(folders: [URL], folderContents: [String: [URL]]) {
            self.chapterFolders = folders
            self.folderContents = folderContents
        }

        func getCacheDirectoryURL() -> URL? {
            return URL(fileURLWithPath: "/cache")
        }

        func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?) throws -> [URL] {
            if shouldThrowError || shouldThrowOnContentsOfDirectory {
                throw MockError.testError
            }

            if url.path == "/cache" {
                return cacheContents
            }

            if url.path == "/cache/Chapters" {
                return chapterFolders
            }

            if let contents = folderContents[url.path] {
                return contents
            }

            return []
        }

        func removeItem(at URL: URL) throws {
            if shouldThrowError {
                throw MockError.testError
            }
            removeItemCallCount += 1
            removedURLs.append(URL)
        }
    }
    
    enum MockError: Error {
        case testError
    }
}

//
//  CoverImageManagerTests.swift
//  DBMultiverseComicKit
//
//  Created by Nikolai Nobadi on 9/7/25.
//

import Testing
import Foundation
import NnSwiftTestingHelpers
@testable import DBMultiverseComicKit

struct CoverImageManagerTests {
    @Test("Returns no data when file missing")
    func loadCurrentChapterDataReturnsNilWhenFileDoesntExist() {
        let (sut, mockFileSystem, _) = makeSUT(throwError: true)
        let result = sut.loadCurrentChapterData()

        #expect(result == nil)
        #expect(mockFileSystem.readDataCallCount == 1)
    }
}

// MARK: - Load Data
extension CoverImageManagerTests {
    @Test("Returns decoded data when file exists")
    func loadCurrentChapterDataReturnsDecodedData() throws {
        let expectedData = makeCurrentChapterData()
        let jsonData = try JSONEncoder().encode(expectedData)
        let (sut, mockFileSystem, _) = makeSUT(mockReadData: jsonData)

        let result = sut.loadCurrentChapterData()

        #expect(result == expectedData)
        #expect(mockFileSystem.readDataCallCount == 1)
    }

    @Test("Returns no data on decoding failure")
    func loadCurrentChapterDataReturnsNilWhenDecodingFails() {
        let (sut, mockFileSystem, _) = makeSUT(mockReadData: Data("invalid json".utf8))

        let result = sut.loadCurrentChapterData()

        #expect(result == nil)
        #expect(mockFileSystem.readDataCallCount == 1)
    }
}

// MARK: - Save Data
extension CoverImageManagerTests {
    @Test("Saves compressed image with metadata")
    func saveCurrentChapterDataWithMetadataCompressesAndSaves() {
        let imageData = Data("test image".utf8)
        let compressedData = Data("compressed".utf8)
        let metadata = makeImageMetaData()
        let (sut, mockFileSystem, mockCompressor) = makeSUT(mockCompressedData: compressedData)

        sut.saveCurrentChapterData(imageData: imageData, metadata: metadata)

        #expect(mockCompressor.compressCallCount == 1)
        #expect(mockCompressor.lastCompressedData == imageData)
        #expect(mockFileSystem.writeCallCount == 2)
        #expect(mockFileSystem.writtenData.contains(compressedData))
    }

    @Test("Skips save when compression fails")
    func saveCurrentChapterDataWithMetadataFailsWhenCompressionFails() {
        let imageData = Data("test image".utf8)
        let metadata = makeImageMetaData()
        let (sut, mockFileSystem, mockCompressor) = makeSUT(mockCompressedData: nil)

        sut.saveCurrentChapterData(imageData: imageData, metadata: metadata)

        #expect(mockCompressor.compressCallCount == 1)
        #expect(mockFileSystem.writeCallCount == 0)
    }

    @Test("Saves compressed image with parameters")
    func saveCurrentChapterDataWithParametersCompressesAndSaves() {
        let imageData = Data("test image".utf8)
        let compressedData = Data("compressed".utf8)
        let chapter = 42
        let name = "Test Chapter"
        let progress = 75
        let (sut, mockFileSystem, mockCompressor) = makeSUT(mockCompressedData: compressedData)

        sut.saveCurrentChapterData(chapter: chapter, name: name, progress: progress, imageData: imageData)

        #expect(mockCompressor.compressCallCount == 1)
        #expect(mockCompressor.lastCompressedData == imageData)
        #expect(mockFileSystem.writeCallCount == 2)
        #expect(mockFileSystem.writtenData.contains(compressedData))
    }

    @Test("Continues on write error")
    func saveCurrentChapterDataHandlesWriteErrors() {
        let imageData = Data("test image".utf8)
        let compressedData = Data("compressed".utf8)
        let metadata = makeImageMetaData()
        let (sut, mockFileSystem, mockCompressor) = makeSUT(mockCompressedData: compressedData, throwError: true)

        sut.saveCurrentChapterData(imageData: imageData, metadata: metadata)

        #expect(mockCompressor.compressCallCount == 1)
        #expect(mockFileSystem.writeCallCount == 1)
    }
}

// MARK: - Update Progress
extension CoverImageManagerTests {
    @Test("Updates existing progress data")
    func updateProgressReadsExistingDataAndSaves() throws {
        let originalData = makeCurrentChapterData(progress: 50)
        let jsonData = try JSONEncoder().encode(originalData)
        let newProgress = 85
        let (sut, mockFileSystem, _) = makeSUT(mockReadData: jsonData)

        sut.updateProgress(to: newProgress)

        #expect(mockFileSystem.readDataCallCount == 1)
        #expect(mockFileSystem.writeCallCount == 1)

        let savedData = mockFileSystem.writtenData.last
        let decodedData = try JSONDecoder().decode(CurrentChapterData.self, from: savedData!)
        #expect(decodedData.progress == newProgress)
        #expect(decodedData.number == originalData.number)
        #expect(decodedData.name == originalData.name)
        #expect(decodedData.coverImagePath == originalData.coverImagePath)
    }

    @Test("Skips update on read error")
    func updateProgressHandlesReadErrors() {
        let (sut, mockFileSystem, _) = makeSUT(throwError: true)

        sut.updateProgress(to: 85)

        #expect(mockFileSystem.readDataCallCount == 1)
        #expect(mockFileSystem.writeCallCount == 0)
    }

    @Test("Skips update on decoding error")
    func updateProgressHandlesDecodingErrors() {
        let (sut, mockFileSystem, _) = makeSUT(mockReadData: Data("invalid json".utf8))

        sut.updateProgress(to: 85)

        #expect(mockFileSystem.readDataCallCount == 1)
        #expect(mockFileSystem.writeCallCount == 0)
    }
}

// MARK: - SUT
private extension CoverImageManagerTests {
    func makeSUT(
        containerURL: URL = .init(fileURLWithPath: "/test/container"),
        mockReadData: Data = Data(),
        mockCompressedData: Data? = Data("compressed".utf8),
        throwError: Bool = false
    ) -> (sut: CoverImageManager, fileSystem: MockFileSystemManager, compressor: MockImageCompressor) {
        let mockCompressor = MockImageCompressor(mockCompressedData: mockCompressedData)
        let mockFileSystem = MockFileSystemManager(mockContainerURL: containerURL, mockReadData: mockReadData, shouldThrowError: throwError)
        let sut = CoverImageManager(appGroupIdentifier: "test.group.identifier", fileSystemManager: mockFileSystem, imageCompressor: mockCompressor)

        return (sut, mockFileSystem, mockCompressor)
    }
}

// MARK: - Test Helpers
private extension CoverImageManagerTests {
    func makeImageMetaData(name: String = "Test Chapter", number: Int = 42, readProgres: Int = 75) -> CoverImageMetaData {
        return .init(chapterName: name, chapterNumber: number, readProgress: readProgres)
    }

    func makeCurrentChapterData(number: Int = 42, name: String = "Test Chapter", progress: Int = 75, coverImagePath: String = "/path/to/image.jpg") -> CurrentChapterData {
        return .init(number: number, name: name, progress: progress, coverImagePath: coverImagePath)
    }
}

// MARK: - Mocks
private extension CoverImageManagerTests {
    final class MockFileSystemManager: FileSystem, @unchecked Sendable {
        private let shouldThrowError: Bool
        private(set) var mockContainerURL: URL
        private(set) var mockReadData: Data
        private(set) var requestedIdentifier: String?
        private(set) var readDataCallCount = 0
        private(set) var writeCallCount = 0
        private(set) var writtenData: [Data] = []
        private(set) var writtenURLs: [URL] = []

        init(mockContainerURL: URL, mockReadData: Data, shouldThrowError: Bool) {
            self.mockContainerURL = mockContainerURL
            self.mockReadData = mockReadData
            self.shouldThrowError = shouldThrowError
        }

        func containerURL(forSecurityApplicationGroupIdentifier identifier: String) -> URL? {
            requestedIdentifier = identifier
            return mockContainerURL
        }

        func write(data: Data, to url: URL) throws {
            writeCallCount += 1
            if shouldThrowError {
                throw NSError(domain: "TestError", code: 1, userInfo: nil)
            }
            writtenData.append(data)
            writtenURLs.append(url)
        }

        func readData(from url: URL) throws -> Data {
            readDataCallCount += 1
            if shouldThrowError {
                throw NSError(domain: "TestError", code: 1, userInfo: nil)
            }
            return mockReadData
        }
    }

    final class MockImageCompressor: ImageCompressing, @unchecked Sendable {
        private(set) var mockCompressedData: Data?
        private(set) var compressCallCount = 0
        private(set) var lastCompressedData: Data?

        init(mockCompressedData: Data? = Data("compressed".utf8)) {
            self.mockCompressedData = mockCompressedData
        }

        func compressImageData(_ data: Data) -> Data? {
            compressCallCount += 1
            lastCompressedData = data
            return mockCompressedData
        }
    }
}

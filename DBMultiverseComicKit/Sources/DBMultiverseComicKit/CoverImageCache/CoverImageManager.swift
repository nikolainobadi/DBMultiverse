//
//  CoverImageManager.swift
//
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import Foundation

public struct CoverImageManager: Sendable {
    private let sharedContainerDirectory: URL
    private let fileSystemManager: FileSystemManaging
    private let imageCompressor: ImageCompressing
    private let imageFileName = "chapterCoverImage.jpg"
    private let jsonFileName = "currentChapterData.json"
    
    init(appGroupIdentifier: String, fileSystemManager: FileSystemManaging, imageCompressor: ImageCompressing) {
        guard let appGroupDirectory = fileSystemManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            fatalError("Failed to get App Group directory")
        }
        
        self.sharedContainerDirectory = appGroupDirectory
        self.fileSystemManager = fileSystemManager
        self.imageCompressor = imageCompressor
    }
}


// MARK: - Init
public extension CoverImageManager {
    init() {
        self.init(appGroupIdentifier: "group.com.nobadi.dbm", fileSystemManager: DefaultFileSystemManager(), imageCompressor: DefaultImageCompressor())
    }
}


// MARK: - Load
public extension CoverImageManager {
    func loadCurrentChapterData() -> CurrentChapterData? {
        let jsonFileURL = sharedContainerDirectory.appendingPathComponent(jsonFileName)
        
        do {
            let jsonData = try fileSystemManager.readData(from: jsonFileURL)
            let chapterData = try JSONDecoder().decode(CurrentChapterData.self, from: jsonData)
            return chapterData
        } catch {
            print("Failed to load current chapter data JSON: \(error)")
            return nil
        }
    }
}


// MARK: - Save
public extension CoverImageManager {
    func saveCurrentChapterData(imageData: Data, metadata: CoverImageMetaData) {
        let imageFileURL = sharedContainerDirectory.appendingPathComponent(imageFileName)
        
        guard let compressedImageData = imageCompressor.compressImageData(imageData) else {
            print("Failed to compress image data for chapter \(metadata.chapterNumber)")
            return
        }
        
        do {
            try fileSystemManager.write(data: compressedImageData, to: imageFileURL)
        } catch {
            print("Unable to save compressed cover image for chapter \(metadata.chapterNumber): \(error)")
            return
        }
        
        let chapterData = CurrentChapterData(number: metadata.chapterNumber, name: metadata.chapterName, progress: metadata.readProgress, coverImagePath: imageFileURL.path)
        let jsonFileURL = sharedContainerDirectory.appendingPathComponent(jsonFileName)
        
        do {
            let jsonData = try JSONEncoder().encode(chapterData)
            try fileSystemManager.write(data: jsonData, to: jsonFileURL)
            print("Current chapter data saved successfully to \(jsonFileURL.path)")
        } catch {
            print("Failed to save current chapter data JSON: \(error)")
        }
    }
    
    func saveCurrentChapterData(chapter: Int, name: String, progress: Int, imageData: Data) {
        let imageFileURL = sharedContainerDirectory.appendingPathComponent(imageFileName)
        
        guard let compressedImageData = imageCompressor.compressImageData(imageData) else {
            print("Failed to compress image data for chapter \(chapter)")
            return
        }
        
        do {
            try fileSystemManager.write(data: compressedImageData, to: imageFileURL)
        } catch {
            print("Unable to save compressed cover image for chapter \(chapter): \(error)")
            return
        }
        
        let chapterData = CurrentChapterData(number: chapter, name: name, progress: progress, coverImagePath: imageFileURL.path)
        let jsonFileURL = sharedContainerDirectory.appendingPathComponent(jsonFileName)
        
        do {
            let jsonData = try JSONEncoder().encode(chapterData)
            try fileSystemManager.write(data: jsonData, to: jsonFileURL)
            print("Current chapter data saved successfully to \(jsonFileURL.path)")
        } catch {
            print("Failed to save current chapter data JSON: \(error)")
        }
    }
    
    func updateProgress(to newProgress: Int) {
        let jsonFileURL = sharedContainerDirectory.appendingPathComponent(jsonFileName)
        
        do {
            let jsonData = try fileSystemManager.readData(from: jsonFileURL)
            var chapterData = try JSONDecoder().decode(CurrentChapterData.self, from: jsonData)
            
            chapterData = CurrentChapterData(
                number: chapterData.number,
                name: chapterData.name,
                progress: newProgress,
                coverImagePath: chapterData.coverImagePath
            )
            
            saveChapterDataToFile(chapterData)
            print("Progress updated to \(newProgress)")
        } catch {
            print("Failed to update progress: \(error)")
        }
    }
}


// MARK: - Private Methods
private extension CoverImageManager {
    func saveChapterDataToFile(_ chapterData: CurrentChapterData) {
        let jsonFileURL = sharedContainerDirectory.appendingPathComponent(jsonFileName)

        do {
            let jsonData = try JSONEncoder().encode(chapterData)
            try fileSystemManager.write(data: jsonData, to: jsonFileURL)
            print("Chapter data saved successfully to \(jsonFileURL.path)")
        } catch {
            print("Failed to save chapter data JSON: \(error)")
        }
    }
}


// MARK: - Dependencies
public protocol ImageCompressing: Sendable {
    func compressImageData(_ data: Data) -> Data?
}

public protocol FileSystemManaging: Sendable {
    func write(data: Data, to url: URL) throws
    func readData(from url: URL) throws -> Data
    func containerURL(forSecurityApplicationGroupIdentifier: String) -> URL?
}

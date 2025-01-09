//
//  CoverImageCache.swift
//
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import UIKit
import Foundation

public class CoverImageCache {
    private let cachesDirectory: URL
    private let fileManager = FileManager.default
    private let imageFileName = "chapterCoverImage.jpg"
    private let jsonFileName = "currentChapterData.json"
    
    public static let shared = CoverImageCache()
    
    private init() {
        cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}


// MARK: - Load
public extension CoverImageCache {
    func loadCurrentChapterData() -> CurrentChapterData? {
        let jsonFileURL = cachesDirectory.appendingPathComponent(jsonFileName)
        
        do {
            let jsonData = try Data(contentsOf: jsonFileURL)
            let chapterData = try JSONDecoder().decode(CurrentChapterData.self, from: jsonData)
            return chapterData
        } catch {
            print("Failed to load current chapter data JSON: \(error)")
            return nil
        }
    }
}


// MARK: - Save
public extension CoverImageCache {
    func saveCurrentChapterData(chapter: Int, name: String, progress: Int, imageData: Data) {
        let imageFileURL = cachesDirectory.appendingPathComponent(imageFileName)
        
        guard let compressedImageData = compressImageData(imageData) else {
            print("Failed to compress image data for chapter \(chapter)")
            return
        }
        
        do {
            try compressedImageData.write(to: imageFileURL)
        } catch {
            print("Unable to save compressed cover image for chapter \(chapter): \(error)")
            return
        }
        
        let chapterData = CurrentChapterData(number: chapter, name: name, progress: progress, coverImagePath: imageFileURL.path)
        let jsonFileURL = cachesDirectory.appendingPathComponent(jsonFileName)
        
        do {
            let jsonData = try JSONEncoder().encode(chapterData)
            try jsonData.write(to: jsonFileURL)
            print("Current chapter data saved successfully to \(jsonFileURL.path)")
        } catch {
            print("Failed to save current chapter data JSON: \(error)")
        }
    }
    
    func updateProgress(to newProgress: Int) {
        let jsonFileURL = cachesDirectory.appendingPathComponent(jsonFileName)
        
        do {
            let jsonData = try Data(contentsOf: jsonFileURL)
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
private extension CoverImageCache {
    func compressImageData(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        
        return image.jpegData(compressionQuality: 0.7)
    }
    
    func saveChapterDataToFile(_ chapterData: CurrentChapterData) {
            let jsonFileURL = cachesDirectory.appendingPathComponent(jsonFileName)

            do {
                let jsonData = try JSONEncoder().encode(chapterData)
                try jsonData.write(to: jsonFileURL)
                print("Chapter data saved successfully to \(jsonFileURL.path)")
            } catch {
                print("Failed to save chapter data JSON: \(error)")
            }
        }
}

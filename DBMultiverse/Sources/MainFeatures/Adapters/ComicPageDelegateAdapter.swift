//
//  ComicPageDelegateAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import UIKit
import Foundation
import DBMultiverseComicKit

final class ComicPageDelegateAdapter {
    private let comicType: ComicType
    private let fileManager: FileManager
    private let userDefaults: UserDefaults
    private let store: MainFeaturesViewModel
    private let chapterCoverImageDataFileName = "lastReadChapterCoverImageData"
    
    init(comicType: ComicType, store: MainFeaturesViewModel, fileManager: FileManager = .default, userDefaults: UserDefaults = .standard) {
        self.store = store
        self.comicType = comicType
        self.fileManager = fileManager
        self.userDefaults = userDefaults
    }
}


// MARK: - Delegate
extension ComicPageDelegateAdapter: ComicPageDelegate  {
    func updateCurrentPageNumber(_ pageNumber: Int) {
        store.updateCurrentPageNumber(pageNumber, comicType: comicType)
    }
    
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo] {
        // TODO: -
        return try await ChapterComicLoaderAdapter().loadPages(chapterNumber: chapterNumber, pages: pages)
    }
    
    func saveChapterCoverPage(_ info: PageInfo) {
        guard let fileURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(chapterCoverImageDataFileName) else {
            print("Failed to get file URL for saving image")
            return
        }

        if let compressedData = compressImageData(info.imageData) {
            do {
                try compressedData.write(to: fileURL)
            
                userDefaults.set(info.chapter, forKey: .currentlyReadingChapterKey)
            } catch {
                print("Unable to save compressed cover image for chapter \(info.chapter): \(error)")
            }
        } else {
            print("Failed to compress image data for chapter \(info.chapter)")
        }
    }
}


// MARK: - Private Methods
private extension ComicPageDelegateAdapter {
    func compressImageData(_ data: Data) -> Data? {
        return UIImage(data: data)?.jpegData(compressionQuality: 0.7)
    }
}

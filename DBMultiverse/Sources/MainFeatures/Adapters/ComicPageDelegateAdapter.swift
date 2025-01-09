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
    private let chapter: Chapter
    private let comicType: ComicType
    private let store: MainFeaturesViewModel
    
    init(chapter: Chapter, comicType: ComicType, store: MainFeaturesViewModel) {
        self.store = store
        self.chapter = chapter
        self.comicType = comicType
    }
}


// MARK: - Delegate
extension ComicPageDelegateAdapter: ComicPageDelegate  {
    func updateCurrentPageNumber(_ pageNumber: Int) {
        store.updateCurrentPageNumber(pageNumber, comicType: comicType)
        
        CoverImageCache.shared.updateProgress(to: calculateProgress(page: pageNumber))
    }
    
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo] {
        // TODO: -
        return try await ChapterComicLoaderAdapter().loadPages(chapterNumber: chapterNumber, pages: pages)
    }
    
    func saveChapterCoverPage(_ info: PageInfo) {
        CoverImageCache.shared.saveCurrentChapterData(chapter: chapter.number, name: chapter.name, progress: chapter.progress, imageData: info.imageData)
    }
}


// MARK: - Private Methods
private extension ComicPageDelegateAdapter {
    func calculateProgress(page: Int) -> Int {
        let totalPages = chapter.endPage - chapter.startPage + 1
        let pagesRead = page - chapter.startPage + 1
        
        return max(0, min((pagesRead * 100) / totalPages, 100))
    }
}


// MARK: - Extension Dependencies
fileprivate extension Chapter {
    var progress: Int {
        guard let lastReadPage = lastReadPage, lastReadPage >= startPage else {
            return 0
        }
        
        let totalPages = endPage - startPage + 1
        let pagesRead = lastReadPage - startPage + 1
        
        return min((pagesRead * 100) / totalPages, 100)
    }
}

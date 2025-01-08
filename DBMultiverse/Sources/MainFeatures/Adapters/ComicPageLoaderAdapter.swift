//
//  ComicPageLoaderAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import Foundation
import DBMultiverseComicKit

final class ComicPageLoaderAdapter {
    private let comicType: ComicType
    private let store: MainFeaturesViewModel
    
    init(comicType: ComicType, store: MainFeaturesViewModel) {
        self.comicType = comicType
        self.store = store
    }
}


// MARK: - Delegate
extension ComicPageLoaderAdapter: ComicPageDelegate  {
    func updateCurrentPageNumber(_ pageNumber: Int) {
        store.updateCurrentPageNumber(pageNumber, comicType: comicType)
    }
    
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo] {
        // TODO: -
        return try await ChapterComicLoaderAdapter().loadPages(chapterNumber: chapterNumber, pages: pages)
    }
}

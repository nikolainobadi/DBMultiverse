//
//  ComicPageDelegateDecorator.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import Foundation
import DBMultiverseComicKit

final class ComicPageDelegateDecorator {
    private let chapter: Chapter
    private let decoratee: ComicPageDelegate
    private let chapterList: SwiftDataChapterList
    
    init(chapter: Chapter, decoratee: ComicPageDelegate, chapterList: SwiftDataChapterList) {
        self.chapter = chapter
        self.decoratee = decoratee
        self.chapterList = chapterList
    }
}


// MARK: - Delegate
extension ComicPageDelegateDecorator: ComicPageDelegate {
    func updateCurrentPageNumber(_ pageNumber: Int) {
        decoratee.updateCurrentPageNumber(pageNumber)
        chapterList.updateLastReadPage(page: pageNumber, chapter: chapter)
        
        if chapter.endPage == pageNumber {
            chapterList.read(chapter)
        }
    }
    
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo] {
        return try await decoratee.loadPages(chapterNumber: chapterNumber, pages: pages)
    }
}

//
//  SwiftDataChapterList.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import DBMultiverseComicKit

typealias SwiftDataChapterList = [SwiftDataChapter]


// MARK: - Helpers
extension SwiftDataChapterList {
    var chapters: [Chapter] {
        return map {
            .init(
                name: $0.name,
                number: $0.number,
                startPage: $0.startPage,
                endPage: $0.endPage,
                universe: $0.universe,
                lastReadPage: $0.lastReadPage,
                coverImageURL: $0.coverImageURL,
                didFinishReading: $0.didFinishReading
            )
        }
    }
    
    func read(_ chapter: Chapter) {
        getChapter(chapter)?.didFinishReading = true
    }
    
    func unread(_ chapter: Chapter) {
        getChapter(chapter)?.didFinishReading = false
    }
    
    func updateLastReadPage(page: Int, chapter: Chapter) {
        getChapter(chapter)?.lastReadPage = page
    }
    
    func getChapter(_ chapter: Chapter) -> SwiftDataChapter? {
        return first(where: { $0.name == chapter.name })
    }
}

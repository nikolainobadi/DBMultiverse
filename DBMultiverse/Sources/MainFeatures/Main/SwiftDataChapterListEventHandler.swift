//
//  SwiftDataChapterListEventHandler.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import Foundation
import DBMultiverseComicKit

struct SwiftDataChapterListEventHandler {
    let chapterList: SwiftDataChapterList

    var chapters: [Chapter] {
        return chapterList.chapters
    }
}


// MARK: - ChapterListEventHandler
extension SwiftDataChapterListEventHandler: ChapterListEventHandler {
    func makeImageURL(for chapter: Chapter) -> URL? {
        return .init(string: .makeFullURLString(suffix: chapter.coverImageURL))
    }
    
    func unreadChapter(_ chapter: DBMultiverseComicKit.Chapter) {
        if chapter.didFinishReading {
            chapterList.unread(chapter)
        } else {
            chapterList.read(chapter)
        }
    }
    
    func makeSections(type: ComicType) -> [ChapterSection] {
        switch type {
        case .story:
            return [.init(type: .chapterList(title: "Main Story Chapters"), chapters: chapters)]
        case .specials:
            return []
        }
    }
}

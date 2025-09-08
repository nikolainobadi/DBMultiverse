//
//  SwiftDataChapterListEventHandler.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import Foundation
import DBMultiverseComicKit

@MainActor
struct SwiftDataChapterListEventHandler {
    let lastReadSpecialPage: Int
    let lastReadMainStoryPage: Int
    let chapterList: SwiftDataChapterList
    let onStartNextChapter: (Chapter) -> Void
}


// MARK: - ChapterListEventHandler
extension SwiftDataChapterListEventHandler: ChapterListEventHandler {
    func makeImageURL(for chapter: Chapter) -> URL? {
        return .init(string: .makeFullURLString(suffix: chapter.coverImageURL))
    }
    
    func startNextChapter(currentChapter: Chapter) {
        if let nextChapter = getNextChapter(currentChapter: currentChapter) {
            onStartNextChapter(nextChapter)
        }
    }
    
    func toggleReadStatus(for chapter: DBMultiverseComicKit.Chapter) {
        if chapter.didFinishReading {
            chapterList.unread(chapter)
        } else {
            chapterList.markChapterAsRead(chapter)
        }
    }
    
    func makeSections(type: ComicType) -> [ChapterSection] {
        var sections = [ChapterSection]()
        let currentChapter = getCurrentChapter(type: type)
        
        if let currentChapter {
            sections.append(.init(type: .currentChapter, chapters: [currentChapter]))
        }
  
        switch type {
        case .story:
            sections.append(.init(type: .chapterList(title: "Main Story Chapters"), chapters: mainStoryChapters.filter({ $0 != currentChapter })))
        case .specials:
            Dictionary(grouping: univereSpecialChapters.filter({ $0 != currentChapter }), by: { $0.universe! })
                .sorted(by: { $0.key < $1.key })
                .map { ChapterSection(type: .chapterList(title: "Universe \($0.key)"), chapters: $0.value) }
                .forEach { sections.append($0) }
        }
        
        return sections
    }
}


// MARK: - Private Helpers
private extension SwiftDataChapterListEventHandler {
    var chapters: [Chapter] {
        return chapterList.chapters
    }
    
    var mainStoryChapters: [Chapter] {
        return chapters.filter({ $0.universe == nil })
    }
    
    var univereSpecialChapters: [Chapter] {
        return chapters.filter({ $0.universe != nil })
    }
    
    func getNextChapter(currentChapter: Chapter) -> Chapter? {
        guard let index = chapters.firstIndex(where: { $0.number == currentChapter.number }) else {
            return nil
        }
        
        let nextIndex = index + 1
        
        guard chapters.indices.contains(nextIndex) else {
            return nil
        }
        
        return chapters[nextIndex]
    }
    
    func getCurrentChapter(type: ComicType) -> Chapter? {
        switch type {
        case .story:
            return mainStoryChapters.first(where: { $0.containsPage(lastReadMainStoryPage) })
        case .specials:
            return univereSpecialChapters.first(where: { $0.containsPage(lastReadSpecialPage) })
        }
    }
}

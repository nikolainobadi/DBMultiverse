//
//  ChapterSection.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import Foundation

public struct ChapterSection {
    public let type: ChapterSectionType
    public let chapters: [Chapter]
    
    public init(type: ChapterSectionType, chapters: [Chapter]) {
        self.type = type
        self.chapters = chapters
    }
}


// MARK: - Display Helpers
extension ChapterSection {
    var isCurrentChapterSection: Bool {
        return type == .currentChapter
    }
    
    var title: String {
        switch type {
        case .currentChapter:
            return "Current Chapter"
        case .chapterList(let title):
            return title
        }
    }
}


// MARK: - Dependencies
public enum ChapterSectionType: Equatable {
    case currentChapter
    case chapterList(title: String)
}

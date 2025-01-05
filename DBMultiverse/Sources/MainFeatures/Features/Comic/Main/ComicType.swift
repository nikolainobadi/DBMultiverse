//
//  ComicType.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/12/24.
//

enum ComicType: Int, CaseIterable {
    case story, specials
}


// MARK: - Display Data
extension ComicType: Identifiable {
    var id: Int {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .story:
            return "Story"
        case .specials:
            return "Specials"
        }
    }
    
    var icon: String {
        switch self {
        case .story:
            return "book"
        case .specials:
            return "star"
        }
    }
    
    var navTitle: String {
        switch self {
        case .story:
            return "Main Story"
        case .specials:
            return "Universe Specials"
        }
    }
}


// MARK: - Helper Methods
extension ComicType {
    func chapterSections(chapters: [SwiftDataChapter]) -> [ChapterSection] {
        switch self {
        case .story:
            return [.init(title: "Main Story Chapters", chapters: chapters.filter({ $0.universe == nil }))]
        case .specials:
            return Dictionary(grouping: chapters.filter({ $0.universe != nil }), by: { $0.universe! })
                .sorted(by: { $0.key < $1.key })
                .map({ .init(title: "Universe \($0.key)", chapters: $0.value) })
        }
    }
}

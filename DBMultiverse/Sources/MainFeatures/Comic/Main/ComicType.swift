////
////  ComicType.swift
////  DBMultiverse
////
////  Created by Nikolai Nobadi on 12/12/24.
////
//
//import SwiftUI
//
///// Represents the type of comic, such as main story or specials.
//enum ComicType: Int, CaseIterable {
//    /// Main story type of comic.
//    case story
//    
//    /// Specials type of comic.
//    case specials
//}
//
//// MARK: - Display Data
//extension ComicType: Identifiable {
//    /// Unique identifier for each comic type, based on its raw value.
//    var id: Int {
//        return rawValue
//    }
//    
//    /// The display title for the comic type.
//    var title: String {
//        switch self {
//        case .story:
//            return "Story"
//        case .specials:
//            return "Specials"
//        }
//    }
//    
//    /// The icon name for the comic type, typically used in UI components.
//    var icon: String {
//        switch self {
//        case .story:
//            return "book"
//        case .specials:
//            return "star"
//        }
//    }
//    
//    /// The navigation title for the comic type.
//    var navTitle: String {
//        switch self {
//        case .story:
//            return "Main Story"
//        case .specials:
//            return "Universe Specials"
//        }
//    }
//    
//    /// The color associated with the comic type.
//    var color: Color {
//        switch self {
//        case .story:
//            return .blue
//        case .specials:
//            return .red
//        }
//    }
//}
//
//// MARK: - Helper Methods
//extension ComicType {
//    /// Organizes the provided chapters into sections based on the comic type.
//    /// - Parameter chapters: The list of chapters to organize.
//    /// - Returns: An array of `ChapterSection` objects representing grouped chapters.
//    func chapterSections(chapters: [SwiftDataChapter]) -> [ChapterSection] {
//        switch self {
//        case .story:
//            // Group chapters without a universe into a single section.
//            return [.init(title: "Main Story Chapters", chapters: chapters.filter({ $0.universe == nil }))]
//        case .specials:
//            // Group chapters by their universe and sort by universe number.
//            return Dictionary(grouping: chapters.filter({ $0.universe != nil }), by: { $0.universe! })
//                .sorted(by: { $0.key < $1.key })
//                .map({ .init(title: "Universe \($0.key)", chapters: $0.value) })
//        }
//    }
//}

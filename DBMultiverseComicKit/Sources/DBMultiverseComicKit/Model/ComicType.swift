//
//  ComicType.swift
//
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI

/// Represents the type of comic, such as main story or specials.
enum ComicType: Int, CaseIterable {
    /// Main story type of comic.
    case story
    
    /// Specials type of comic.
    case specials
}

// MARK: - Display Data
extension ComicType: Identifiable {
    /// Unique identifier for each comic type, based on its raw value.
    var id: Int {
        return rawValue
    }
    
    /// The display title for the comic type.
    var title: String {
        switch self {
        case .story:
            return "Story"
        case .specials:
            return "Specials"
        }
    }
    
    /// The icon name for the comic type, typically used in UI components.
    var icon: String {
        switch self {
        case .story:
            return "book"
        case .specials:
            return "star"
        }
    }
    
    /// The navigation title for the comic type.
    var navTitle: String {
        switch self {
        case .story:
            return "Main Story"
        case .specials:
            return "Universe Specials"
        }
    }
    
    /// The color associated with the comic type.
    var color: Color {
        switch self {
        case .story:
            return .blue
        case .specials:
            return .red
        }
    }
}

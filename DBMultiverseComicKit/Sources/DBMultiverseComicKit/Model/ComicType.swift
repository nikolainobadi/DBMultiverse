//
//  ComicType.swift
//
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI

/// Represents the type of comic, such as main story or specials.
public enum ComicType: Int, Identifiable, CaseIterable {
    case story
    case specials
    
    public var id: Int {
        return rawValue
    }
}


// MARK: - Display Data
public extension ComicType {
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

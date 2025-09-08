//
//  SettingsLinkItem.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/4/25.
//

/// Represents the different link items available in the settings.
enum SettingsLinkItem: CaseIterable {
    case authors
    case universeHelp
    case tournamentHelp
}

// MARK: - Helpers
extension SettingsLinkItem {
    /// Returns the display name of the link item.
    var name: String {
        switch self {
        case .authors: 
            return "Authors"
        case .universeHelp: 
            return "Universe Help"
        case .tournamentHelp: 
            return "Tournament Help"
        }
    }

    var pathComponent: URLWebsitePathComponent {
        switch self {
        case .authors:
            return .authors
        case .universeHelp:
            return .universeHelp
        case .tournamentHelp:
            return .tournamentHelp
        }
    }
}

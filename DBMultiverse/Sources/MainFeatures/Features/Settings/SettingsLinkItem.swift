//
//  SettingsLinkItem.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/4/25.
//

enum SettingsLinkItem: CaseIterable {
    case authors, universeHelp, tournamentHelp
}


// MARK: - Helpers
extension SettingsLinkItem {
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
    
    var linkSuffix: String {
        switch self {
        case .authors:
            return "/en/the-authors.html"
        case .universeHelp:
            return "/en/listing.html"
        case .tournamentHelp:
            return "/en/tournament.html"
        }
    }
}

//
//  URLFactory.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation

enum URLFactory {
    private static let baseWebsiteURLString = "https://www.dragonball-multiverse.com"
}


// MARK: - Factory
extension URLFactory {
    static func makeURL(language: ComicLanguage, pathComponent: URLWebsitePathComponent) -> URL? {
        return .init(string: "\(baseWebsiteURLString)/\(language.rawValue)/\(pathComponent.path)")
    }
}


// MARK: - Dependencies
enum URLWebsitePathComponent {
    case chapterList
    case comicPage(Int)
    case authors
    case universeHelp
    case tournamentHelp
}

extension URLWebsitePathComponent {
    var path: String {
        switch self {
        case .chapterList:
            return "chapters.html?comic=page&chaptersmode=1"
        case .comicPage(let page):
            return "page-\(page).html"
        case .authors:
            return "the-authors.html"
        case .universeHelp:
            return "listing.html"
        case .tournamentHelp:
            return "tournament.html"
        }
    }
}

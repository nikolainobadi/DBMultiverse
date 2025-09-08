//
//  URLFactory.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation

/// A factory for generating URLs used in the DBMultiverse application.
enum URLFactory {
    /// The base URL string for the Dragonball Multiverse website.
    private static let baseWebsiteURLString = "https://www.dragonball-multiverse.com"
}

// MARK: - Factory
extension URLFactory {
    /// Creates a URL for a specific language and path component.
    /// - Parameters:
    ///   - language: The language for the comic (e.g., English, French).
    ///   - pathComponent: The specific path component for the URL.
    /// - Returns: A URL object if the input parameters are valid; otherwise, `nil`.
    static func makeURL(language: ComicLanguage, pathComponent: URLWebsitePathComponent) -> URL? {
        return .init(string: "\(baseWebsiteURLString)/\(language.rawValue)/\(pathComponent.path)")
    }
}

// MARK: - Dependencies
/// Represents the different path components that can be appended to the base website URL.
enum URLWebsitePathComponent {
    case chapterList
    case comicPage(Int)
    case authors
    case universeHelp
    case tournamentHelp
}

extension URLWebsitePathComponent {
    /// Converts the `URLWebsitePathComponent` case into a path string to be appended to the base URL.
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

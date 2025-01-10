//
//  String+Extensions.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/14/24.
//

extension String {
    static let lastReadSpecialPage = "lastReadSpecialPage"
    static let lastReadMainStoryPage = "lastReadMainStoryPage"
    static let completedChapterListKey = "completedChapterListKey"
    static let currentlyReadingChapterKey = "currentlyReadingChapterKey"
    static let baseWebsiteURLString = "https://www.dragonball-multiverse.com"
    
    static func makeFullURLString(suffix: String) -> String {
        return "\(baseWebsiteURLString)\(suffix)"
    }
}

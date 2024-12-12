//
//  String+Extensions.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/14/24.
//

extension String {
    static let lastReadPageKey = "lastReadPage"
    static let completedChapterListKey = "completedChapterListKey"
    static let baseWebsiteURLString = "https://www.dragonball-multiverse.com"
    
    static func makeFullURLString(suffix: String) -> String {
        return "\(baseWebsiteURLString)\(suffix)"
    }
}

//
//  ChapterLoaderAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import SwiftSoup
import Foundation
import DBMultiverseComicKit

final class ChapterLoaderAdapter: ChapterLoader {
    func loadChapters(language: ComicLanguage) async throws -> [Chapter] {
        guard let url = URLFactory.makeURL(language: language, pathComponent: .chapterList) else {
            throw CustomError.urlError
        }
        
        let data = try await URLSession.shared.data(from: url).0

        return try ComicHTMLParser.parseChapterListHTML(.init(data: data, encoding: .utf8))
    }
}

//
//  ChapterLoaderAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import Foundation
import DBMultiverseComicKit
import DBMultiverseParseKit

final class ChapterLoaderAdapter: ChapterLoader {
    func loadChapters(url: URL?) async throws -> [Chapter] {
        let data = try await SharedComicNetworkingManager.fetchData(from: url)

        return try ComicHTMLParser.parseChapterList(data: data).map({ $0.toChapter() })
    }
}


// MARK: - Extension Dependencies
extension ParsedChapter {
    func toChapter() -> Chapter {
        return .init(
            name: name,
            number: number,
            startPage: startPage,
            endPage: endPage,
            universe: universe,
            lastReadPage: nil,
            coverImageURL: coverImageURL,
            didFinishReading: false
        )
    }
}

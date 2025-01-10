//
//  ChapterLoaderAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import Foundation
import DBMultiverseComicKit

final class ChapterLoaderAdapter: ChapterLoader {
    func loadChapters(url: URL?) async throws -> [Chapter] {
        let data = try await SharedComicNetworkingManager.fetchData(from: url)

        return try ComicHTMLParser.parseChapterList(data: data)
    }
}

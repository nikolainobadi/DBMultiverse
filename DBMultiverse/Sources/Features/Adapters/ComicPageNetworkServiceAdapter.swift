//
//  ComicPageNetworkServiceAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation
import DBMultiverseParseKit

final class ComicPageNetworkServiceAdapter: ComicPageNetworkService {
    func fetchImageData(from url: URL?) async throws -> Data {
        let networker = SharedComicNetworkingManager.self
        let data = try await networker.fetchData(from: url)
        let imgSrc = try ComicHTMLParser.parseComicPageImageSource(data: data)
        
        return try await networker.fetchData(from: .init(string: .makeFullURLString(suffix: imgSrc)))
    }
}

//
//  ComicPageNetworkServiceAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import SwiftSoup
import Foundation

final class ComicPageNetworkServiceAdapter: ComicPageNetworkService {
    func fetchImageData(from url: URL?) async throws -> Data {
        let networker = SharedComicNetworkingManager.self
        let data = try await networker.fetchData(from: url)
        let imageURL = try ComicHTMLParser.parseComicPageImageURL(data: data)
        
        return try await networker.fetchData(from: imageURL)
    }
}

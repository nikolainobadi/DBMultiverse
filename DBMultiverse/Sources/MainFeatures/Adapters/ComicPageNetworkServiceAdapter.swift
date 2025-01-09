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
        let data = try await fetchData(from: url)
        let imageURL = try ComicHTMLParser.parseComicPageImageURL(data: data)
        
        return try await fetchData(from: imageURL)
    }
}


// MARK: - Private Methods
private extension ComicPageNetworkServiceAdapter {
    func fetchData(from url: URL?) async throws -> Data {
        guard let url else {
            throw CustomError.urlError
        }
        
        return try await URLSession.shared.data(from: url).0
    }
}

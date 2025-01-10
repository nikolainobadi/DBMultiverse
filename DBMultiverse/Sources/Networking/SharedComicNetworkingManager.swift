//
//  SharedComicNetworkingManager.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation

enum SharedComicNetworkingManager {
    static func fetchData(from url: URL?) async throws -> Data {
        guard let url else {
            throw CustomError.urlError
        }
        
        return try await URLSession.shared.data(from: url).0
    }
}

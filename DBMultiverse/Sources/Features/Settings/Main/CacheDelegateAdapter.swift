//
//  CacheDelegateAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 9/8/25.
//

import Foundation

final class CacheDelegateAdapter: CacheDelegate {
    func getCacheDirectoryURL() -> URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?) throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: keys)
    }
    
    func removeItem(at URL: URL) throws {
        return try FileManager.default.removeItem(at: URL)
    }
}

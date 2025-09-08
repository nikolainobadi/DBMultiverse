//
//  FileManagingAdapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 9/8/25.
//

import Foundation

final class FileManagingAdapter: FileManaging {
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return FileManager.default.urls(for: directory, in: domainMask)
    }
    
    func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?) throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: keys)
    }
    
    func removeItem(at URL: URL) throws {
        return try FileManager.default.removeItem(at: URL)
    }
}

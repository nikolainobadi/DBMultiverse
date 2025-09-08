//
//  DefaultFileSystemOperations.swift
//  DBMultiverseComicKit
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import Foundation

/// Default implementation of FileSystemOperations using FileManager.
struct DefaultFileSystemOperations: FileSystemOperations {
    func contents(atPath path: String) -> Data? {
        return FileManager.default.contents(atPath: path)
    }
    
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: createIntermediates)
    }
    
    func write(data: Data, to url: URL) throws {
        try data.write(to: url)
    }
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return FileManager.default.urls(for: directory, in: domainMask)
    }
}

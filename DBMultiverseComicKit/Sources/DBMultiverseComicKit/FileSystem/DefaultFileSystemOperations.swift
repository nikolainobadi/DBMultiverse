//
//  DefaultFileSystemOperations.swift
//  DBMultiverseComicKit
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import Foundation

/// Default implementation of FileSystemOperations using FileManager.
public final class DefaultFileSystemOperations: FileSystemOperations {
    private let fileManager: FileManager
    
    /// Initializes with a FileManager instance.
    /// - Parameter fileManager: The FileManager to use. Defaults to .default.
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func contents(atPath path: String) -> Data? {
        return fileManager.contents(atPath: path)
    }
    
    public func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: createIntermediates)
    }
    
    public func write(data: Data, to url: URL) throws {
        try data.write(to: url)
    }
    
    public func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return fileManager.urls(for: directory, in: domainMask)
    }
}
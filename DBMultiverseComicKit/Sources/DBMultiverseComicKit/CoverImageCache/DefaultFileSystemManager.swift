//
//  DefaultFileSystemManager.swift
//  DBMultiverseComicKit
//
//  Created by Nikolai Nobadi on 9/7/25.
//

import Foundation

public final class DefaultFileSystemManager: FileSystemManaging, @unchecked Sendable {
    private let fileManager = FileManager.default
    
    public init() {}
    
    public func containerURL(forSecurityApplicationGroupIdentifier identifier: String) -> URL? {
        return fileManager.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
    
    public func write(data: Data, to url: URL) throws {
        try data.write(to: url)
    }
    
    public func readData(from url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }
}

//
//  FileSystemOperations.swift
//  DBMultiverseComicKit
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import Foundation

/// Protocol abstracting file system operations to enable testing and flexibility.
public protocol FileSystemOperations {
    /// Returns the contents of a file at the specified path.
    /// - Parameter path: The file path to read from.
    /// - Returns: The file contents as Data, or nil if the file doesn't exist.
    func contents(atPath path: String) -> Data?
    
    /// Creates a directory at the specified URL.
    /// - Parameters:
    ///   - url: The URL where the directory should be created.
    ///   - createIntermediates: If true, creates any missing intermediate directories.
    /// - Throws: An error if the directory cannot be created.
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws
    
    /// Writes data to a file at the specified URL.
    /// - Parameters:
    ///   - data: The data to write.
    ///   - url: The URL where the data should be written.
    /// - Throws: An error if the data cannot be written.
    func write(data: Data, to url: URL) throws
    
    /// Returns URLs for the specified directory in the specified domains.
    /// - Parameters:
    ///   - directory: The search path directory.
    ///   - domainMask: The search path domain mask.
    /// - Returns: An array of URLs for the specified directory.
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
}
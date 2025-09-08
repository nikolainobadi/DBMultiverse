//
//  Chapter.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import Foundation

public struct Chapter: Hashable, Sendable {
    public let name: String
    public let number: Int
    public let startPage: Int
    public let endPage: Int
    public let universe: Int?
    public let lastReadPage: Int?
    public let coverImageURL: String
    public let didFinishReading: Bool
    
    public init(name: String, number: Int, startPage: Int, endPage: Int, universe: Int?, lastReadPage: Int?, coverImageURL: String, didFinishReading: Bool) {
        self.name = name
        self.number = number
        self.startPage = startPage
        self.endPage = endPage
        self.universe = universe
        self.lastReadPage = lastReadPage
        self.coverImageURL = coverImageURL
        self.didFinishReading = didFinishReading
    }
}


// MARK: - Helpers
public extension Chapter {
    func containsPage(_ page: Int) -> Bool {
        return page >= startPage && page <= endPage
    }
}

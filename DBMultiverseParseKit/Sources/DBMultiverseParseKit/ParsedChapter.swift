//
//  ParsedChapter.swift
//
//
//  Created by Nikolai Nobadi on 1/10/25.
//

public struct ParsedChapter {
    public let name: String
    public let number: Int
    public let startPage: Int
    public let endPage: Int
    public let universe: Int?
    public let coverImageURL: String
    
    public init(name: String, number: Int, startPage: Int, endPage: Int, universe: Int?, coverImageURL: String) {
        self.name = name
        self.number = number
        self.startPage = startPage
        self.endPage = endPage
        self.universe = universe
        self.coverImageURL = coverImageURL
    }
}

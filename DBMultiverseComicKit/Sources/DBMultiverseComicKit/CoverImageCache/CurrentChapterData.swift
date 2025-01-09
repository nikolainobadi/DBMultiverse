//
//  CurrentChapterData.swift
//
//
//  Created by Nikolai Nobadi on 1/8/25.
//

public struct CurrentChapterData: Codable, Equatable {
    public let number: Int
    public let name: String
    public let progress: Int
    public let coverImagePath: String
    
    public init(number: Int, name: String, progress: Int, coverImagePath: String) {
        self.number = number
        self.name = name
        self.progress = progress
        self.coverImagePath = coverImagePath
    }
}

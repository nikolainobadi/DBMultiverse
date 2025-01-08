//
//  UniverseSpecial.swift
//
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import Foundation

public struct UniverseSpecial: Equatable {
    public let universe: Int
    public let chapters: [Chapter]
    
    public init(universe: Int, chapters: [Chapter]) {
        self.universe = universe
        self.chapters = chapters
    }
}

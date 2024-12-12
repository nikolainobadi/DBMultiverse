//
//  SwiftDataChapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/10/24.
//

import SwiftData

@Model
final class SwiftDataChapter {
    @Attribute(.unique) var name: String
    @Attribute(.unique) var number: Int
    
    var startPage: Int
    var endPage: Int
    var universe: String?
    var lastReadPage: Int?
    var didFinishReading: Bool = false
    
    init(name: String, number: Int, startPage: Int, endPage: Int, universe: String?, lastReadPage: Int?) {
        self.name = name
        self.number = number
        self.startPage = startPage
        self.endPage = endPage
        self.universe = universe
        self.lastReadPage = lastReadPage
    }
}

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
    
    var lastReadPage: Int
    
    init(name: String, lastReadPage: Int) {
        self.name = name
        self.lastReadPage = lastReadPage
    }
}

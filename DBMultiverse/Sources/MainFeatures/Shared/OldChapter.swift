//
//  OldChapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

struct OldChapter: Hashable, Identifiable {
    let name: String
    let number: Int
    let startPage: Int
    let endPage: Int
    let coverImageURL: String
    
    var id: String {
        return name
    }
}

struct OldSpecial: Equatable {
    let universe: Int
    let chapters: [OldChapter]
}

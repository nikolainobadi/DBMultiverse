//
//  Chapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

struct Chapter: Hashable, Identifiable {
    let name: String
    let number: Int
    let startPage: Int
    let endPage: Int
    let coverImageURL: String
    
    var id: String {
        return name
    }
}

struct Special: Identifiable, Equatable {
    let title: String
    let chapters: [Chapter]
    
    var id: String {
        return title
    }
}

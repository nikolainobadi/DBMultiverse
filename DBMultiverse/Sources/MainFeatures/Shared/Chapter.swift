//
//  Chapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

struct Chapter: Hashable, Identifiable {
    let name: String
    let number: String
    let startPage: Int
    let endPage: Int
    var didRead: Bool = false
    
    var id: String {
        return name
    }
    
    func containsLastReadPage(_ page: Int) -> Bool {
        return page >= startPage && page <= endPage
    }
}

struct Special: Identifiable, Equatable {
    let title: String
    let chapters: [Chapter]
    
    var id: String {
        return title
    }
}

//
//  Chapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

struct Chapter: Hashable {
    let name: String
    let number: String
    let startPage: Int
    let endPage: Int
    var didRead: Bool = false
    
    func containsLastReadPage(_ page: Int) -> Bool {
        return page >= startPage && page <= endPage
    }
}

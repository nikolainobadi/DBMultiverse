//
//  ChapterInfo.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/4/25.
//

/// Represents metadata about a comic chapter, including its number, page range, and the last read page.
struct ChapterInfo {
    /// The chapter number.
    let number: Int
    
    /// The starting page of the chapter.
    let startPage: Int
    
    /// The ending page of the chapter.
    let endPage: Int
    
    /// The last page read by the user, if available.
    let lastReadPage: Int?
}

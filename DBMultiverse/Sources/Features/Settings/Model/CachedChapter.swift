//
//  CachedChapter.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/5/25.
//

/// Represents a cached chapter with its number and image count.
struct CachedChapter: Hashable {
    let number: String
    let imageCount: Int

    static var sampleList: [CachedChapter] {
        [
            CachedChapter(number: "1", imageCount: 12),
            CachedChapter(number: "2", imageCount: 15),
            CachedChapter(number: "3", imageCount: 18),
            CachedChapter(number: "4", imageCount: 14),
            CachedChapter(number: "5", imageCount: 16)
        ]
    }
}

//
//  ChapterRoute.swift
//
//
//  Created by Nikolai Nobadi on 1/9/25.
//

public struct ChapterRoute: Hashable {
    public let chapter: Chapter
    public let comicType: ComicType
    
    public init(chapter: Chapter, comicType: ComicType) {
        self.chapter = chapter
        self.comicType = comicType
    }
}

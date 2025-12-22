//
//  FirstSchema.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/21/25.
//

import Foundation
@preconcurrency import SwiftData

public enum FirstSchema: VersionedSchema {
    public static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    public static var models: [any PersistentModel.Type] {
        return [
            SwiftDataChapter.self
        ]
    }
}


// MARK: - IntakeEvent
extension FirstSchema {
    @Model
    final class SwiftDataChapter {
        @Attribute(.unique) var name: String
        @Attribute(.unique) var number: Int
        
        var startPage: Int
        var endPage: Int
        var universe: Int?
        var lastReadPage: Int?
        var coverImageURL: String
        var didFinishReading: Bool = false
        
        /// Initializes a new `SwiftDataChapter` instance.
        /// - Parameters:
        ///   - name: The name of the chapter.
        ///   - number: The unique number of the chapter.
        ///   - startPage: The starting page of the chapter.
        ///   - endPage: The ending page of the chapter.
        ///   - universe: The universe number associated with the chapter, if any.
        ///   - lastReadPage: The last page read in this chapter, if any.
        ///   - coverImageURL: The URL for the chapter's cover image.
        init(name: String, number: Int, startPage: Int, endPage: Int, universe: Int?, lastReadPage: Int?, coverImageURL: String) {
            self.name = name
            self.number = number
            self.startPage = startPage
            self.endPage = endPage
            self.universe = universe
            self.lastReadPage = lastReadPage
            self.coverImageURL = coverImageURL
        }
    }
}

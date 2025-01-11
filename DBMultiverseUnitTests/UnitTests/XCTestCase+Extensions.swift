//
//  XCTestCase+Extensions.swift
//  DBMultiverseUnitTests
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import XCTest
import DBMultiverseComicKit

extension XCTestCase {
    func makeChapter(name: String = "first", startPage: Int = 0, endPage: Int = 20) -> Chapter {
        return .init(name: name, number: 1, startPage: startPage, endPage: endPage, universe: nil, lastReadPage: nil, coverImageURL: "", didFinishReading: false)
    }
}

//
//  ComicParseError.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation

enum ComicParseError: Error {
    case missingHTML
    case chapterListParsingError
}

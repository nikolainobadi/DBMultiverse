//
//  ComicParseError.swift
//
//
//  Created by Nikolai Nobadi on 1/10/25.
//

public enum ComicParseError: Error {
    case missingHTML
    case imageSourceError
    case generalParseError
    case imageNotFoundError
    case chapterListParsingError
}

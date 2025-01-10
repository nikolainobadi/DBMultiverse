//
//  ComicParseError.swift
//
//
//  Created by Nikolai Nobadi on 1/10/25.
//

public enum ComicParseError: Error {
    case missingHTMLDocument       // When the HTML document is missing or invalid
    case missingPageLinks          // When required page links are not found
    case invalidImageSource        // When the image source cannot be extracted
    case generalParsingFailure     // A catch-all for parsing-related failures
    case imageElementNotFound      // When the specific image element is missing
    case invalidChapterNumber      // When a chapter number cannot be parsed
    case chapterListParsingFailure // When the entire chapter list fails to parse
}

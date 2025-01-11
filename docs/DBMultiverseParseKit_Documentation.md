
# DBMultiverseParseKit Documentation

## Overview
The **DBMultiverseParseKit** module is responsible for parsing HTML content and extracting the necessary data for the DBMultiverse app. It serves as the backbone for data extraction, ensuring the app can dynamically fetch and process chapter information and comic images from the web.

## Features
- Extracts chapter details, including chapter number, name, page range, and cover image.
- Parses comic page HTML to fetch image sources.
- Handles errors with custom error types for detailed debugging.

## Components

### **ComicHTMLParser**
A utility for parsing comic-related HTML data.

#### Key Methods:
- `parseComicPageImageSource(data: Data) throws -> String`:
  Extracts the `src` attribute of the comic page image from the provided HTML data.
  - **Throws**: `ComicParseError` in case of failure.

- `parseChapterList(data: Data) throws -> [ParsedChapter]`:
  Extracts a list of chapters from the provided HTML data.
  - **Throws**: `ComicParseError` in case of failure.

### **ParsedChapter**
A model that represents a parsed chapter from the HTML data.

## Error Handling
The module utilizes `ComicParseError` for detailed error descriptions, enabling easier debugging and reliable error management.

## Dependencies
- **SwiftSoup**: A Swift-based HTML parser library for navigating and extracting data from HTML documents.
- **Foundation**: For general Swift utilities like `Data` and `URL`.

## Usage Example
```swift
let htmlData: Data = ... // Fetch HTML data
do {
    let chapterList = try ComicHTMLParser.parseChapterList(data: htmlData)
    print(chapterList)
} catch let error as ComicParseError {
    print("Parsing failed with error: \(error)")
}
```
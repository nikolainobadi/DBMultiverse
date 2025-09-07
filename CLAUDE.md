# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DBMultiverse is a modular iOS application for reading the DB Multiverse webcomic. Built with Swift 6, SwiftUI, and SwiftData, it targets iOS 17+ and consists of multiple modules organized as Swift Packages.

## Architecture

### Module Structure
- **DBMultiverse** - Main app target containing UI, navigation, and integration
- **DBMultiverseComicKit** - Comic display functionality, chapter management, and caching
- **DBMultiverseParseKit** - HTML parsing for extracting comic metadata  
- **DBMultiverseWidgetsExtension** - iOS widgets for home screen functionality

### Key Technologies
- **Swift 6** with strict concurrency checking
- **SwiftUI** for all UI components
- **SwiftData** for local persistence
- **Swift Package Manager** for dependency management
- **External packages**: SwiftSoup (HTML parsing), NnSwiftUIKit, NnSwiftDataKit

## Build & Development Commands

### Build the project
```bash
xcodebuild -project DBMultiverse.xcodeproj -scheme DBMultiverse -configuration Debug
```

### Run tests
```bash
# Run all unit tests
xcodebuild test -project DBMultiverse.xcodeproj -scheme DBMultiverse -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific module tests
xcodebuild test -project DBMultiverse.xcodeproj -scheme DBMultiverseComicKit -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Clean build
```bash
xcodebuild clean -project DBMultiverse.xcodeproj -scheme DBMultiverse
```

## Code Conventions

### Swift File Headers
When creating new Swift files, use "Nikolai Nobadi" as the creator name in file headers.

### Architecture Patterns
- **MVVM** pattern for views with ViewModels handling business logic
- **Adapter pattern** for bridging between modules (e.g., ChapterLoaderAdapter, ComicNetworkingManager)
- **Protocol-oriented** design for testability
- **@MainActor** for UI-related classes and ViewModels
- **Dependency injection** through initializers

### SwiftUI Conventions
- Platform-specific views in `Platforms/iPhone` and `Platforms/iPad` folders
- Shared views in `Shared` folders
- Custom view modifiers for reusable functionality
- Navigation using `NavigationStack` with proper path management

### Testing
- Unit tests use `XCTest` framework
- Test helpers from `NnTestHelpers` package
- Mock objects follow `Mock` prefix naming convention
- Tests follow `test_condition_expectedResult()` naming pattern

## Project-Specific Details

### URL Schemes
- Deep linking support via `dbmultiverse://` URL scheme
- Widget deep links route to specific comic pages

### Data Flow
1. HTML content fetched via `ComicNetworkingManager`
2. Parsed by `DBMultiverseParseKit` using SwiftSoup
3. Chapters stored in SwiftData via `SwiftDataChapterList`
4. UI displays data through ViewModels and adapters
5. Widgets sync via app groups

### Image Caching
- Custom `CoverImageCache` for managing comic cover images
- Metadata stored for tracking cached images
- Automatic cache management for optimal performance

### Language Support
Multiple languages supported via `ComicLanguage` enum with URL generation for different language versions of the comic.
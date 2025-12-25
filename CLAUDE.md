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
- **SwiftData** for local persistence with VersionedSchema
- **Swift Testing** framework for unit tests
- **Swift Package Manager** for dependency management
- **External packages**: SwiftSoup (HTML parsing), NnSwiftUIKit, NnSwiftDataKit, NnTestKit

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
- Unit tests use **Swift Testing** framework (`@Test`, `#expect`, `#require`)
- Test helpers from `NnSwiftTestingHelpers` package (part of NnTestKit)
- Use `@LeakTracked` and `trackForMemoryLeaks` for memory leak detection
- Mock objects follow `Mock` prefix naming convention
- Tests use descriptive names: `@Test("Description of behavior being tested")`
- Use `makeSUT` factory pattern for system under test creation
- Use `waitUntil` for `@Published` property assertions instead of sleeps

## Project-Specific Details

### Data Flow
1. HTML content fetched via `SharedComicNetworkingManager`
2. Parsed by `DBMultiverseParseKit` using SwiftSoup
3. Chapters stored in SwiftData via `SwiftDataChapterList`
4. UI displays data through ViewModels and adapters (ChapterLoaderAdapter, CoverImageDelegateAdapter, ComicPageNetworkServiceAdapter, FileSystemOperationsAdapter)
5. Images managed by `ComicPageManager` and cached via `ComicImageCacheManager`
6. Widgets sync via app groups (`group.com.nobadi.dbm`) and `WidgetTimelineManager`

### Image Caching
- `CoverImageManager` for managing comic cover images with widget synchronization
- `ComicImageCacheManager` for page-level image caching with metadata tracking
- Support for double-page spreads in cache metadata
- `CachedChapter` model for tracking cached comic pages
- `CacheChapterListView` for cache management UI
- Automatic cache management for optimal performance
- Shared via app group for widget access

### Widget Management
- `WidgetTimelineManager` handles widget timeline reloading with debouncing
- Smart reload logic with minimum delta of 5% progress to reduce unnecessary updates
- Tracks chapter and progress state changes
- Integrates with `ComicImageCacheManager` for timeline updates

### Deep Linking
- `DeepLinkNavigationViewModifier` implements deep link handling via `onOpenURL`
- Support for `dbmultiverse://` URL scheme
- Widget deep links route to specific comic pages

### Language Support
Multiple languages supported via `ComicLanguage` enum (46 languages) with URL generation for different language versions of the comic.

### SwiftData Integration
- Uses `VersionedSchema` with `FirstSchema` for schema versioning
- `SwiftDataChapterList` typealias with extensions for chapter list management
- `ChapterProgressHandler` protocol for progress tracking
- Custom SwiftData event handlers and view modifiers
- Models: Chapter data, CachedChapter tracking, progress state

### Additional Models & Types
- `ComicType` enum for distinguishing story vs specials
- `PageInfo` model for comic page metadata
- `ChapterRoute` for navigation routing
- Multiple adapter implementations for cross-module communication

## Project Guidelines
Project-specific guidelines are located in `.guidelines/claude/`

## iOS Architecture
- SwiftUI-based views
- No business logic inside SwiftUI views
- Modular feature-based architecture

## iOS Testing
- Prefer behavior-driven unit tests (Swift Testing, `@Test("…")`)
- Use `makeSUT` + `trackForMemoryLeaks` in tests
- No inline comments in test files; use `// MARK:` only for sectioning
- Default to type-safe assertions (`#expect`, `#require`)
- Use `waitUntil` for `@Published`/reactive assertions instead of sleeps
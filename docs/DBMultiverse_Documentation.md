
# DBMultiverse Documentation

## Overview

The **DBMultiverse** target serves as the core of the application, integrating functionality from the other modules (`DBMultiverseComicKit`, `DBMultiverseParseKit`, and `DBMultiverseWidgets`) to deliver the primary user experience. This target defines the main app logic, user interface, and navigation.

## Key Components

### `LaunchView.swift`
- **Purpose**: Entry point for the app.
- **Features**:
  - Displays the `WelcomeView` for first-time users.
  - Transitions to `MainFeaturesView` after the initial setup.
- **Dependencies**:
  - `ComicLanguage` for language preferences.
  - `ChapterLoaderAdapter` for chapter loading.

### `WelcomeView.swift`
- **Purpose**: Guides new users through initial setup.
- **Features**:
  - Language selection.
  - Disclaimer and introduction text.
  - Smooth animations for transitioning between states.
- **Dependencies**:
  - `LanguagePicker` for language selection.
  - `DisclaimerView` for displaying terms.

### `SettingsFeatureNavStack.swift`
- **Purpose**: Provides navigation for the settings feature.
- **Features**:
  - Dynamically loads cached chapters.
  - Allows clearing cache and updating language preferences.
  - Links to external resources (e.g., Authors, Help pages).
- **Dependencies**:
  - `SettingsViewModel` for business logic.
  - `SettingsFormView`, `LanguageSelectionView`, and `CacheChapterListView` for specific settings UI.

### `MainFeaturesView.swift`
- **Purpose**: Core view that displays chapters and comics.
- **Features**:
  - Navigation between comic pages and settings.
  - Synchronizes data with SwiftData.
  - Handles deep linking.
- **Dependencies**:
  - `SwiftDataChapterList` for chapter storage.
  - `ChapterLoaderAdapter` for loading chapters.

### `iPhoneMainTabView.swift` and `iPadMainNavStack.swift`
- **Purpose**: Provide navigation stacks for different devices.
- **Features**:
  - Tab-based navigation on iPhone.
  - Navigation stack with settings integration on iPad.
- **Dependencies**:
  - `ComicNavStack` for managing comic navigation.

### `ComicPageFeatureView.swift`
- **Purpose**: Displays individual comic pages.
- **Features**:
  - Handles navigation between pages.
  - Fetches and caches comic page images.
  - Updates reading progress.
- **Dependencies**:
  - `ComicPageViewModel` for handling page data.
  - `ComicPageManager` for business logic.

## Core ViewModels and Managers

### `MainFeaturesViewModel`
- **Purpose**: Central ViewModel managing chapters and user progress.
- **Key Functions**:
  - `loadData(language:)`: Fetches chapter data for the specified language.
  - `updateCurrentPageNumber(_:comicType:)`: Updates the user's current page.
  - `startNextChapter(_:)`: Prepares the next chapter for reading.
- **Dependencies**:
  - `ChapterLoader` for fetching chapter data.
  - `UserDefaults` for storing progress via `AppStorage`.

### `ComicPageManager`
- **Purpose**: Manages fetching, caching, and displaying comic pages.
- **Key Functions**:
  - `loadPages(_:)`: Fetches comic pages from cache or network.
  - `updateCurrentPageNumber(_:)`: Updates reading progress.
  - `saveChapterCoverPage(_:)`: Saves cover image metadata.
- **Dependencies**:
  - `ComicImageCache` for caching.
  - `ComicPageNetworkService` for fetching images.
  - `ChapterProgressHandler` for tracking progress.

## Widget Management

### `WidgetTimelineManager`
- **Purpose**: Manages smart widget timeline reloading with debouncing and optimization.
- **Location**: `DBMultiverse/Sources/Widgets/WidgetTimelineManager.swift`
- **Architecture**: `@MainActor final class` conforming to `WidgetTimelineReloader` protocol
- **Key Features**:
  - **Smart Debouncing**: 2-second delay on progress changes to prevent excessive widget updates
  - **Minimum Delta Threshold**: Only reloads widgets when progress changes by at least 5%
  - **State Caching**: Maintains cached `WidgetSyncState` to avoid redundant reloads
  - **Force Reload**: Chapter changes trigger immediate widget updates
  - **Automatic Completion Detection**: Progress of 100% always triggers widget reload
- **Key Methods**:
  - `notifyChapterChange(chapter:progress:)`: Forces immediate widget timeline reload when chapter changes
  - `notifyProgressChange(progress:)`: Debounced progress update that respects minimum delta threshold
- **Dependencies**:
  - `CoverImageManager` for widget synchronization state persistence
  - `WidgetCenter` for iOS widget timeline management
- **Implementation Details**:
  - Uses `Task` for async debouncing with cancellation support
  - Coordinates with `CoverImageManager` to persist widget sync state
  - Reloads timeline for widget kind defined by `WIDGET_KIND` constant

## Cache Management

### `ComicImageCacheManager`
- **Purpose**: Manages page-level comic image caching with metadata tracking and widget synchronization.
- **Location**: `DBMultiverse/Sources/Features/Comic/ComicImageCacheManager.swift`
- **Architecture**: `@MainActor struct` conforming to `ComicImageCache` protocol
- **Cache Structure**:
  - Directory: `Caches/Chapters/Chapter_X/Page_Y.jpg`
  - Metadata file: `Caches/Chapters/Chapter_X/metadata.json`
  - Supports both single-page and double-page spread images
- **Key Features**:
  - **Double-Page Spread Support**: Special handling for pages 8/9 and 20/21
  - **Metadata Tracking**: JSON metadata for multi-page entries with `secondPageNumber`
  - **Widget Integration**: Notifies `WidgetTimelineReloader` on cache changes
  - **Cover Image Persistence**: Delegates cover image saving to `CoverImageDelegate`
  - **Progress Tracking**: Coordinates page updates with `ComicPageStore`
- **Key Methods**:
  - `updateCurrentPageNumber(_:readProgress:)`: Updates progress and notifies widget timeline
  - `saveChapterCoverImage(imageData:metadata:)`: Saves cover with metadata and triggers chapter change notification
  - `loadCachedImage(chapter:page:)`: Loads cached image, checking both single-page and metadata.json for multi-page spreads
  - `savePageImage(pageInfo:)`: Saves page image and updates metadata.json for double-page spreads
- **Dependencies**:
  - `ComicPageStore`: Persists current page number to storage
  - `CoverImageDelegate`: Manages cover image data and progress
  - `WidgetTimelineReloader`: Notifies widget of cache changes
  - `ComicImageCacheDelegate`: Abstracts file system operations
- **Metadata Format** (for double-page spreads):
  ```json
  {
    "pages": [
      {
        "pageNumber": 8,
        "secondPageNumber": 9,
        "fileName": "Page_8-9.jpg"
      }
    ]
  }
  ```

## ViewModifiers

### `DeepLinkNavigationViewModifier`
- **Purpose**: Enables navigation via deep links using the `dbmultiverse://` URL scheme.
- **Location**: `DBMultiverse/Sources/Features/Main/DeepLinkNavigationViewModifier.swift`
- **Architecture**: `struct` conforming to `ViewModifier`
- **Features**:
  - Parses incoming URLs to extract chapter numbers from the last path component
  - Navigates directly to specific chapters using `NavigationPath`
  - Distinguishes between story and specials using `ComicType` based on chapter's universe property
  - Creates `ChapterRoute` for navigation stack management
- **URL Format**: `dbmultiverse://[path]/[chapterNumber]`
- **Usage**:
  ```swift
  view.withDeepLinkNavigation(path: $navigationPath, chapters: chapterList)
  ```
- **Implementation**:
  - Uses `.onOpenURL` modifier to intercept deep link URLs
  - Matches chapter number against available chapters array
  - Determines comic type: `.story` if universe is nil, `.specials` otherwise
  - Appends `ChapterRoute` to navigation path for navigation

### `SwiftDataChapterStorageViewModifier`
- **Purpose**: Synchronizes `Chapter` objects with SwiftData storage.
- **Features**:
  - Automatically updates chapters in the database when new data is available.

## Adapters

The DBMultiverse app uses the Adapter pattern to bridge between modules and abstract external dependencies. Adapters implement protocols defined in `DBMultiverseComicKit` while coordinating with other modules.

### `ChapterLoaderAdapter`
- **Purpose**: Converts parsed chapter data from `DBMultiverseParseKit` to `Chapter` models used by `DBMultiverseComicKit`.
- **Location**: `DBMultiverse/Sources/Features/Adapters/ChapterLoaderAdapter.swift`
- **Protocol**: Implements `ChapterLoader` from `DBMultiverseComicKit`
- **Dependencies**:
  - `SharedComicNetworkingManager`: Fetches HTML data
  - `ComicHTMLParser`: Parses chapter list from HTML
- **Implementation**:
  - Fetches data from provided URL
  - Parses HTML using `ComicHTMLParser.parseChapterList(data:)`
  - Maps `ParsedChapter` objects to `Chapter` objects via `.toChapter()` extension

### `ComicPageNetworkServiceAdapter`
- **Purpose**: Implements network fetching for comic page images.
- **Location**: `DBMultiverse/Sources/Features/Adapters/ComicPageNetworkServiceAdapter.swift`
- **Protocol**: Implements `ComicPageNetworkService` from `DBMultiverseComicKit`
- **Dependencies**:
  - `SharedComicNetworkingManager`: Network request manager
  - `ComicHTMLParser`: Extracts image source from page HTML
- **Implementation**:
  1. Fetches HTML page data from chapter URL
  2. Parses HTML to extract image source using `ComicHTMLParser.parseComicPageImageSource(data:)`
  3. Constructs full image URL using `.makeFullURLString(suffix:)`
  4. Fetches and returns the actual image data

### `CoverImageDelegateAdapter`
- **Purpose**: Bridges the `CoverImageDelegate` protocol with `CoverImageManager` implementation.
- **Location**: `DBMultiverse/Sources/Features/Adapters/CoverImageDelegateAdapter.swift`
- **Protocol**: Implements `CoverImageDelegate` (defined in `ComicImageCacheManager.swift`)
- **Dependencies**:
  - `CoverImageManager` from `DBMultiverseComicKit`
- **Implementation**:
  - Wraps `CoverImageManager` instance
  - Delegates `saveCurrentChapterData(imageData:metadata:)` to manager
  - Delegates `updateProgress(to:)` to manager
- **Usage**: Used by `ComicImageCacheManager` to persist cover images and widget sync state

### `FileSystemOperationsAdapter`
- **Purpose**: Abstracts file system operations for cache management.
- **Location**: `DBMultiverse/Sources/Features/Adapters/FileSystemOperationsAdapter.swift`
- **Protocol**: Implements `ComicImageCacheDelegate` (defined in `ComicImageCacheManager.swift`)
- **Dependencies**:
  - `FileManager` for file operations
  - `CacheDelegateAdapter` for cache directory URL resolution
- **Implementation**:
  - `contents(atPath:)`: Reads file data using `FileManager`
  - `createDirectory(at:withIntermediateDirectories:)`: Creates directory structure
  - `write(data:to:)`: Writes data to file URL
  - `getCacheDirectoryURL()`: Delegates to `CacheDelegateAdapter`

### Adapter Pattern Benefits
- **Module Separation**: Keeps `DBMultiverseComicKit` independent of parsing and networking details
- **Testability**: Protocols allow easy mocking in tests
- **Flexibility**: Implementation details can change without affecting ComicKit consumers
- **Dependency Inversion**: High-level modules depend on abstractions, not concrete implementations

## Language Support

### `ComicLanguage`
- **Purpose**: Defines supported comic languages with localized display names.
- **Location**: `DBMultiverse/Sources/Features/Shared/Language/ComicLanguage.swift`
- **Type**: `enum` with `String` raw values, conforming to `CaseIterable`
- **Total Languages**: 36 supported languages
- **Key Languages**:
  - Western European: English, French, Spanish, German, Italian, Portuguese, Catalan, Dutch
  - Eastern European: Polish, Russian, Croatian, Romanian, Bulgarian, Lithuanian, Hungarian
  - Nordic: Swedish, Norwegian, Danish, Finnish
  - Asian: Japanese, Chinese, Korean, Filipino
  - Middle Eastern: Arabic, Hebrew, Turkish
  - Regional Variants: Brazilian Portuguese, Latin Spanish, various French dialects
  - Special: Parodie Salagir (parody version)
- **Raw Value Format**: Language codes matching DB Multiverse website URL structure
  - Simple codes: `"en"`, `"fr"`, `"es"`
  - Regional codes: `"pt_BR"`, `"es_CO"`, `"hu_HU"`
- **Display Names**: Native language names (e.g., "Français" for French, "日本語" for Japanese)
- **Integration**:
  - Used by `URLFactory` to generate language-specific URLs
  - Persisted in `UserDefaults` via `@AppStorage` in `WelcomeView` and `SettingsView`
  - Affects chapter list fetching and page image URLs

## Protocols

### `WidgetTimelineReloader`
- **Location**: `DBMultiverse/Sources/Features/Comic/ComicImageCacheManager.swift`
- **Conformance**: `WidgetTimelineManager`
- **Actor Isolation**: `@MainActor`
- **Purpose**: Defines interface for notifying widget timeline updates
- **Methods**:
  - `notifyChapterChange(chapter:progress:)`: Notify when chapter changes
  - `notifyProgressChange(progress:)`: Notify when reading progress changes

### `ComicPageStore`
- **Location**: `DBMultiverse/Sources/Features/Comic/ComicImageCacheManager.swift`
- **Actor Isolation**: `@MainActor`
- **Purpose**: Abstracts persistence of current page number
- **Methods**:
  - `updateCurrentPageNumber(_:comicType:)`: Update and persist current page

### `CoverImageDelegate`
- **Location**: `DBMultiverse/Sources/Features/Comic/ComicImageCacheManager.swift`
- **Conformance**: `CoverImageDelegateAdapter`
- **Actor Isolation**: `@MainActor`
- **Purpose**: Manages cover image persistence and progress tracking
- **Methods**:
  - `updateProgress(to:)`: Update reading progress
  - `saveCurrentChapterData(imageData:metadata:)`: Save cover image with chapter metadata

### `ComicImageCacheDelegate`
- **Location**: `DBMultiverse/Sources/Features/Comic/ComicImageCacheManager.swift`
- **Conformance**: `FileSystemOperationsAdapter`
- **Sendable**: Yes
- **Purpose**: Abstracts file system operations for cache management
- **Methods**:
  - `getCacheDirectoryURL()`: Returns cache directory URL
  - `write(data:to:)`: Write data to file URL
  - `contents(atPath:)`: Read file contents at path
  - `createDirectory(at:withIntermediateDirectories:)`: Create directory structure

## Data Models

### `ChapterRoute`
- **Purpose**: Navigation routing model for comic chapters
- **Properties**:
  - `chapter`: The `Chapter` object to navigate to
  - `comicType`: `ComicType` enum (`.story` or `.specials`)
- **Usage**: Used by `DeepLinkNavigationViewModifier` and navigation system

### `WidgetSyncState`
- **Purpose**: Tracks chapter and progress state for widget synchronization
- **Properties**:
  - `chapter`: Current chapter number
  - `progress`: Reading progress percentage (0-100)
- **Usage**: Persisted by `CoverImageManager`, cached by `WidgetTimelineManager`

### `ComicType`
- **Type**: `enum`
- **Cases**:
  - `.story`: Main story chapters
  - `.specials`: Special/universe chapters
- **Purpose**: Distinguishes between different comic content types for navigation and storage

## Utilities

### `URLFactory`
- **Purpose**: Constructs URLs for fetching data using the base url for the website and the selected language.

### Persistence with SwiftData
- The app uses `SwiftDataChapter` as the primary model for storing chapter data.
- Data is synchronized automatically via view modifiers.
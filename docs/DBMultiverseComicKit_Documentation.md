
# ComicKit Module Documentation

## Overview

The **ComicKit** module is a core component of the **DBMultiverse** project. It provides tools for managing and displaying comic chapters, pages, and related metadata. It includes models, utilities, UI components, and caching mechanisms to enhance user experience in reading comics.

## Features

### 1. **Chapter Management**
   - **Structures:**
     - `Chapter`: Represents a comic chapter with metadata such as name, number, and page range.
   - **Protocols:**
     - `ChapterListEventHandler`: Defines methods for interacting with chapter lists, such as toggling read status or retrieving sections.

### 2. **Page Management**
   - **Structures:**
     - `PageInfo`: Stores information about a comic page, including image data and page numbers.
     - `PagePosition`: Represents current page position within a chapter for UI display.
     - `ComicPage`: View model data for displaying a single comic page.
   - **Classes:**
     - `ComicPageViewModel`: A view model for managing the state and actions related to comic pages.
   - **Protocols:**
     - `ComicPageDelegate`: Defines methods for saving and updating page-related information.

### 3. **Caching**
   - **Structures:**
     - `CoverImageMetaData`: Metadata for caching chapter cover images.
     - `CoverImageManager`: Manages caching of chapter cover images and progress data with app group support.
     - `CurrentChapterData`: Stores current chapter metadata with progress for widget synchronization.
     - `WidgetSyncState`: Tracks chapter and progress state for widget timeline updates.
   - **Protocols:**
     - `FileSystem`: Abstracts file system operations for testability.
     - `ImageCompressing`: Protocol for image compression operations.

### 4. **Custom UI Components**
   - `ZoomableImageView`: Provides a pinch-to-zoom interface for images.
   - `ComicPageImageView`: Displays a single comic page with its associated metadata.
   - `DynamicSection`: A reusable section component with optional gradients for headers.
   - `ComicNavStack`: A navigation stack for comic-specific content.

## Dependencies

The **ComicKit** module relies on the following dependencies:

- **NnSwiftUIKit**: Provides utilities and extensions for SwiftUI, such as gradients, reusable components, and view modifiers.

## Public Interfaces

### 1. Models
#### `Chapter`
Represents a comic chapter.
- **Properties:**
  - `name`: The chapter's name.
  - `number`: The chapter's number.
  - `startPage`, `endPage`: Page range.
  - `universe`: Associated universe (optional).
  - `lastReadPage`: Last read page (optional).
  - `coverImageURL`: URL for the chapter cover image.
  - `didFinishReading`: Whether the chapter is marked as read.

#### `PageInfo`
Represents information about a comic page.
- **Properties:**
  - `chapter`: Chapter number.
  - `pageNumber`: Page number.
  - `secondPageNumber`: Optional second page number.
  - `imageData`: Image data for the page.

### 2. UI Components
#### `ZoomableImageView`
Provides zoom and pan functionality for images.

#### `ComicPageImageView`
Displays a comic page with zoom functionality.

#### `DynamicSection`
A reusable section with a customizable gradient and dynamic section header font sizing.

## Detailed Component Documentation

### ComicPageViewModel

**Location**: `DBMultiverseComicKit/Sources/DBMultiverseComicKit/Page/ComicPageViewModel.swift`

**Architecture**: `@MainActor public final class` conforming to `ObservableObject`

**Purpose**: Manages the state and lifecycle of comic pages for a single chapter, including smart page loading, navigation, and progress tracking.

#### Published Properties
- `pages: [PageInfo]` - Array of loaded page information
- `currentPageNumber: Int` - Current page being viewed
- `didFetchInitialPages: Bool` - Flag indicating whether initial pages have been loaded (read-only)

#### Initialization
```swift
public init(chapter: Chapter, currentPageNumber: Int, delegate: any ComicPageDelegate, pages: [PageInfo] = [])
```
- Initializes with chapter metadata and delegate for page operations
- Automatically determines starting page (last read page, provided page if in range, or chapter start)
- Supports pre-loading pages for faster navigation

#### Display Data (Computed Properties)
- `currentPagePosition: PagePosition` - Returns position data for UI display (includes second page for double-page spreads)
- `currentPageInfo: PageInfo?` - Returns page info for current page number
- `currentPage: ComicPage?` - Returns complete page data ready for display

#### Key Methods

**`loadData() async throws`**
- Loads initial 5 pages (current page + 4 ahead) for immediate viewing
- Sets `didFetchInitialPages` to `true`
- Asynchronously loads remaining chapter pages in background
- Caches chapter cover image after all pages are loaded

**`nextPage()`**
- Navigates to next page
- Handles double-page spreads by using `PageInfo.nextPage` (skips second page number)
- Updates current page via delegate
- Validates against chapter end page

**`previousPage()`**
- Navigates to previous page
- Handles page gaps for double-page spreads (skips if previous page doesn't exist)
- Updates current page via delegate
- Validates against chapter start page

#### Smart Loading Strategy
1. **Initial Load**: Fetches current page + 4 pages ahead for immediate reading experience
2. **Background Load**: Fetches all remaining chapter pages asynchronously
3. **Deduplication**: Prevents duplicate page entries when adding remaining pages
4. **Sorting**: Maintains pages in ascending order by page number
5. **Cover Caching**: Automatically saves chapter cover (first page) after loading completes

#### Dependencies
- `ComicPageDelegate`: Protocol for page loading, saving, and progress updates
- `Chapter`: Chapter metadata including page range and chapter info

---

### CoverImageManager

**Location**: `DBMultiverseComicKit/Sources/DBMultiverseComicKit/CoverImageCache/CoverImageManager.swift`

**Architecture**: `public struct` conforming to `Sendable`

**Purpose**: Manages cover image caching and chapter metadata persistence for widget synchronization using iOS app groups.

#### App Group Integration
- **Identifier**: `group.com.nobadi.dbm`
- **Shared Directory**: Used to share cover images and metadata between main app and widgets
- **File Structure**:
  - `chapterCoverImage.jpg` - Compressed cover image
  - `currentChapterData.json` - Current chapter metadata and progress
  - `widgetSyncState.json` - Widget synchronization state

#### Initialization
```swift
public init() // Uses default configuration
init(appGroupIdentifier: String, fileSystemManager: FileSystem, imageCompressor: ImageCompressing)
```
- Default init uses `group.com.nobadi.dbm` app group
- Custom init allows dependency injection for testing

#### Key Methods

**Loading Methods**
- `loadCurrentChapterData() -> CurrentChapterData?`
  - Reads and decodes current chapter metadata from JSON
  - Returns nil if file doesn't exist or decoding fails
  - Used by widgets to display current reading progress

- `loadWidgetSyncState() -> WidgetSyncState?`
  - Loads widget synchronization state
  - Returns nil if not yet synchronized
  - Used by `WidgetTimelineManager` for state caching

**Saving Methods**
- `saveCurrentChapterData(imageData: Data, metadata: CoverImageMetaData)`
  - Compresses image data for optimal storage
  - Saves compressed image to app group directory
  - Creates `CurrentChapterData` from metadata and saves as JSON
  - Primary method for chapter change events

- `saveCurrentChapterData(chapter: Int, name: String, progress: Int, imageData: Data)`
  - Alternative save method with individual parameters
  - Performs same compression and persistence steps

- `saveWidgetSyncState(_ state: WidgetSyncState)`
  - Persists widget sync state to app group
  - Used by `WidgetTimelineManager` to track last widget update

- `updateProgress(to newProgress: Int)`
  - Updates only the progress field in existing chapter data
  - Reads current data, modifies progress, and saves back
  - Lightweight update for progress-only changes

#### Dependencies
- `FileSystem`: Protocol for file operations (reading, writing, app group access)
- `ImageCompressing`: Protocol for image compression to reduce storage size

#### Error Handling
- All errors are logged to console with descriptive messages
- Failures are graceful (methods return early or return nil)
- Image compression failure prevents saving (logs error and returns)

---

## Protocols

### ChapterListEventHandler

**Location**: `DBMultiverseComicKit/Sources/DBMultiverseComicKit/List/ChapterListView.swift`

**Actor Isolation**: Not specified (can be implemented on any actor)

**Purpose**: Defines the interface for handling chapter list interactions and data operations.

#### Methods
```swift
func toggleReadStatus(for chapter: Chapter)
```
- Toggles the read/unread status of a chapter
- Used by swipe actions in chapter list UI

```swift
func startNextChapter(currentChapter: Chapter)
```
- Initiates navigation to the next chapter after current chapter
- Handles chapter progression logic

```swift
func makeImageURL(for chapter: Chapter) -> URL?
```
- Constructs the URL for a chapter's cover image
- Returns nil if URL cannot be constructed

```swift
func makeSections(type: ComicType) -> [ChapterSection]
```
- Creates sectioned chapter data for list display
- Supports both `.story` and `.specials` comic types
- Returns array of `ChapterSection` for organized list display

---

### ComicPageDelegate

**Location**: `DBMultiverseComicKit/Sources/DBMultiverseComicKit/Page/ComicPageViewModel.swift`

**Actor Isolation**: `@MainActor`

**Purpose**: Defines the interface for page loading, caching, and progress tracking operations.

#### Methods
```swift
func saveChapterCoverPage(_ info: PageInfo)
```
- Saves the chapter cover page for widget display
- Called automatically after all pages are loaded
- Typically saves first page of chapter

```swift
func updateCurrentPageNumber(_ pageNumber: Int)
```
- Updates the current page number in persistent storage
- Called on every page navigation (next/previous)
- Used for progress tracking and resuming reading

```swift
func loadPages(_ pages: [Int]) async throws -> [PageInfo]
```
- Asynchronously loads page data for given page numbers
- Checks cache first, fetches from network if needed
- Returns array of `PageInfo` with image data
- Throws errors if network fetch fails

**Conformance**: Implemented by `ComicPageManager` in DBMultiverse target

---

### FileSystem

**Location**: `DBMultiverseComicKit/Sources/DBMultiverseComicKit/CoverImageCache/CoverImageManager.swift`

**Conformance**: `Sendable`

**Purpose**: Abstracts file system operations for dependency injection and testability.

#### Methods
```swift
func write(data: Data, to url: URL) throws
```
- Writes data to specified file URL
- Throws on file system errors

```swift
func readData(from url: URL) throws -> Data
```
- Reads data from specified file URL
- Throws if file doesn't exist or read fails

```swift
func containerURL(forSecurityApplicationGroupIdentifier: String) -> URL?
```
- Returns URL for app group shared container
- Returns nil if app group identifier is invalid

**Implementations**:
- `DefaultFileSystemManager` - Production implementation using `FileManager.default`
- Mock implementations for testing

---

### ImageCompressing

**Location**: `DBMultiverseComicKit/Sources/DBMultiverseComicKit/CoverImageCache/CoverImageManager.swift`

**Conformance**: `Sendable`

**Purpose**: Abstracts image compression for optimal storage and testability.

#### Methods
```swift
func compressImageData(_ data: Data) -> Data?
```
- Compresses image data to reduce file size
- Returns nil if compression fails
- Typically targets 0.7-0.8 compression quality for JPEGs

**Implementations**:
- `DefaultImageCompressor` - Production implementation using platform image APIs
- Mock implementations for testing

---

## Data Models

### CurrentChapterData

**Purpose**: Stores current chapter metadata with progress for widget synchronization.

**Properties**:
- `number: Int` - Chapter number
- `name: String` - Chapter name/title
- `progress: Int` - Reading progress percentage (0-100)
- `coverImagePath: String` - File path to cached cover image

**Codable**: Yes (JSON serialization for persistence)

**Usage**:
- Saved by `CoverImageManager` to app group
- Read by widgets to display current reading status
- Updated on chapter changes and progress updates

---

### WidgetSyncState

**Purpose**: Tracks chapter and progress state for widget timeline management.

**Properties**:
- `chapter: Int` - Current chapter number
- `progress: Int` - Reading progress percentage (0-100)

**Codable**: Yes (JSON serialization)

**Usage**:
- Cached by `WidgetTimelineManager` to detect state changes
- Persisted by `CoverImageManager` to app group
- Used to determine if widget timeline reload is needed (minimum 5% progress delta)

---

### PagePosition

**Purpose**: Represents current page position within a chapter for UI display.

**Properties**:
- `page: Int` - Current page number
- `secondPage: Int?` - Second page number for double-page spreads
- `endPage: Int` - Chapter's final page number

**Usage**:
- Computed by `ComicPageViewModel.currentPagePosition`
- Used by UI to display position like "Page 5-6 of 20" for double-page spreads
- Helps UI determine if next/previous buttons should be enabled

---

### ComicPage

**Purpose**: View model data for displaying a single comic page.

**Properties**:
- `number: Int` - Page number
- `chapterName: String` - Name of the chapter
- `pagePosition: PagePosition` - Position data for UI display
- `imageData: Data` - Raw image data for display

**Usage**:
- Computed by `ComicPageViewModel.currentPage`
- Passed to `ComicPageImageView` for rendering
- Combines all necessary data for page display in one model

---

### ChapterSection

**Purpose**: Represents a section of chapters for sectioned list display.

**Inferred Properties** (based on typical sectioning):
- Section header/title
- Array of chapters belonging to this section

**Usage**:
- Created by `ChapterListEventHandler.makeSections(type:)`
- Used by `ChapterListView` for sectioned chapter display
- Supports different organization for story vs specials


# DBMultiverseWidgets Documentation

## Overview
The **DBMultiverseWidgets** module provides a seamless way for users to interact with the DBMultiverse app directly from their home screen. The widget displays the chapter currently being read, as well as the current 'read' progress. The widget defaults to the small size for iPhone and the medium size for iPad.

## Features
- Display the current or next comic chapter with progress tracking.
- Visual representation of cover images.
- Dynamic deep links to quickly navigate to specific chapters.
- Conditional views for both small and medium widget sizes.

### **ComicImageEntry**
A model conforming to `TimelineEntry` that represents the widget’s data.

#### Properties:
- `date: Date`: The timestamp of the entry.
- `chapter: Int`: The current chapter number.
- `name: String`: The chapter name.
- `progress: Int`: The reading progress percentage.
- `image: Image?`: The chapter’s cover image.
- `family: WidgetFamily`: The widget family (small or medium).
- `deepLink: URL`: The deep link to navigate to the chapter.

## Architecture

### Provider

**Location**: `DBMultiverseWidgets/Sources/Widget/Provider.swift`

**Type**: `struct` conforming to `TimelineProvider`

**Purpose**: Provides timeline entries for the widget by loading data from the app group shared storage.

#### Dependencies
- `CoverImageManager` from `DBMultiverseComicKit` - Loads chapter data from app group

#### TimelineProvider Methods

**`placeholder(in context:) -> ComicImageEntry`**
- Returns a sample entry for widget gallery and initial display
- Uses `ComicImageEntry.makeSample(family:)` with appropriate widget family

**`getSnapshot(in context:completion:) -> Void`**
- Provides entry for widget preview and gallery
- Attempts to load real data, falls back to placeholder if unavailable
- Called when widget is displayed in widget center

**`getTimeline(in context:completion:) -> Void`**
- Provides timeline entries for widget display
- Loads current chapter data from `CoverImageManager`
- Creates single timeline entry with 1-hour refresh policy
- Falls back to placeholder entry if no data available
- Timeline policy: `.after(Date().addingTimeInterval(3600))` (refreshes hourly)

#### Entry Loading Logic
1. Calls `coverImageManager.loadCurrentChapterData()` to get chapter metadata
2. Constructs deep link URL: `dbmultiverse://chapter/[chapterNumber]`
3. Loads cover image from file path using `UIImage(contentsOfFile:)`
4. Creates `ComicImageEntry` with all data
5. Falls back to placeholder entry if data unavailable

---

### DBMultiverseWidgets

**Location**: `DBMultiverseWidgets/Sources/Widget/DBMultiverseWidgets.swift`

**Type**: `struct` conforming to `Widget`

**Purpose**: Main widget configuration defining appearance and behavior.

#### Configuration
- **Widget Kind**: Uses `WIDGET_KIND` constant for timeline identification
- **Configuration Type**: `StaticConfiguration` (no user customization)
- **Provider**: Uses `Provider` for timeline generation
- **Display Name**: "DBMultiverse Widget"
- **Description**: "Quickly jump back into the action where you last left off."

#### Supported Families
- **iPhone**: `.systemSmall` only
- **iPad**: `.systemMedium` only
- Platform-specific via `UIDevice.current.userInterfaceIdiom`

#### Visual Styling
- Container background: `LinearGradient.starrySky` (from NnSwiftUIKit)
- Applied using `.containerBackground(_:for:)` modifier

---

### DBMultiverseWidgetContentView

**Location**: `DBMultiverseWidgets/Sources/Widget/DBMultiverseWidgetContentView.swift`

**Type**: `struct` conforming to `View`

**Purpose**: Root view for widget content, routes to size-specific views.

#### Implementation
- Conditionally displays view based on `entry.family`:
  - `.systemSmall` → `SmallWidgetView(entry:)`
  - `.systemMedium` → `MediumWidgetView(entry:)`
- Applies `.widgetURL(entry.deepLink)` for tap-to-open functionality

#### Deep Link Behavior
- Entire widget tappable area opens deep link
- Deep link format: `dbmultiverse://chapter/[chapterNumber]`
- Handled by `DeepLinkNavigationViewModifier` in main app

---

## Widget Timeline Management

### Data Flow

**Main App → Widget Synchronization**:
1. User reads comic pages in main app
2. `ComicImageCacheManager` saves cover image via `CoverImageDelegate`
3. `CoverImageDelegateAdapter` calls `CoverImageManager.saveCurrentChapterData()`
4. Cover image compressed and saved to app group: `group.com.nobadi.dbm`
5. Chapter metadata saved as JSON: `currentChapterData.json`
6. `WidgetTimelineManager` triggers widget timeline reload via `WidgetCenter`

**Widget → Display**:
1. iOS requests timeline from `Provider.getTimeline()`
2. `Provider` loads data from app group using `CoverImageManager`
3. Constructs `ComicImageEntry` with chapter data and cover image
4. Widget displays entry via `DBMultiverseWidgetContentView`

### Smart Timeline Reloading

**Managed by**: `WidgetTimelineManager` in DBMultiverse target (see DBMultiverse_Documentation.md)

**Update Strategy**:
- **Chapter Changes**: Immediate widget reload (force=true)
- **Progress Changes**:
  - 2-second debounce to prevent rapid updates
  - Only reloads if progress delta ≥ 5%
  - Always reloads at 100% completion
- **State Caching**: `WidgetSyncState` cached to avoid redundant reloads

**Benefits**:
- Reduces unnecessary widget timeline reloads
- Preserves battery life
- Ensures timely updates for significant progress changes
- Immediate feedback on chapter changes

### App Group Integration

**Identifier**: `group.com.nobadi.dbm`

**Shared Files**:
- `chapterCoverImage.jpg` - Compressed cover image for widget display
- `currentChapterData.json` - Chapter metadata (number, name, progress, image path)
- `widgetSyncState.json` - Last synchronized state (tracked by WidgetTimelineManager)

**File Access**:
- Main app writes via `CoverImageManager` from `DBMultiverseComicKit`
- Widget reads via same `CoverImageManager` instance
- Shared storage enables data persistence across app/widget boundaries

---

## How It Works

### 1. Data Handling
- Data is fetched from the app's `CoverImageManager`, imported from `DBMultiverseComicKit`
- Chapter progress and cover images are retrieved from app group shared container
- Images are compressed before storage to minimize widget extension memory usage
- Data persisted as JSON for structured metadata and JPG for cover images

### 2. Dynamic View Content
- Displays current chapter data if available:
  - Chapter number and name
  - Reading progress percentage
  - Cover image
  - Deep link for navigation
- Defaults to placeholder view if no data is cached (never read any chapters yet)
- Updates automatically when timeline refreshes (hourly or on main app trigger)

### 3. Timeline Refresh Policy
- **Automatic**: Hourly refresh via `.after(Date().addingTimeInterval(3600))`
- **Manual**: Main app triggers reload via `WidgetCenter.shared.reloadTimelines(ofKind:)`
- **Smart Debouncing**: `WidgetTimelineManager` prevents excessive reloads
- **Network-Free**: Widget displays cached data only, no network requests

---

## Dependencies
- **DBMultiverseComicKit**: Supplies `CoverImageManager`, `ComicImageEntry`, and core models
- **SwiftUI** and **WidgetKit**: Core frameworks for UI and widget functionality
- **NnSwiftUIKit**: Provides `LinearGradient.starrySky` and UI utilities

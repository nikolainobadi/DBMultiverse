
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

## ViewModifiers

### `DeepLinkNavigationViewModifier`
- **Purpose**: Enables navigation via deep links.
- **Features**:
  - Parses URLs to navigate directly to specific chapters.

### `SwiftDataChapterStorageViewModifier`
- **Purpose**: Synchronizes `Chapter` objects with SwiftData storage.
- **Features**:
  - Automatically updates chapters in the database when new data is available.

## Utilities

### `URLFactory`
- **Purpose**: Constructs URLs for fetching data using the base url for the website and the selected language.

### Persistence with SwiftData
- The app uses `SwiftDataChapter` as the primary model for storing chapter data.
- Data is synchronized automatically via view modifiers.
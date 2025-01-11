
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

## How It Works
1. **Data Handling**:
   - Data is fetched from the app’s `CoverImageCache`, a dependency imported from the shared module `DBMultiverseComicKit`.
   - Chapter progress and cover images are dynamically retrieved.

2. **Dynamic View Content**:
   - Displays relevant chapter data if available.
   - Defaults to a placeholder view if no data is cached.

## Dependencies
- **DBMultiverseComicKit**: Supplies core models and data for widget entries.
- **SwiftUI** and **WidgetKit**: Core frameworks for UI and widget functionality.

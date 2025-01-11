
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
   - **Classes:**
     - `ComicPageViewModel`: A view model for managing the state and actions related to comic pages.
   - **Protocols:**
     - `ComicPageDelegate`: Defines methods for saving and updating page-related information.

### 3. **Caching**
   - **Structures:**
     - `CoverImageMetaData`: Metadata for caching chapter cover images.
   - **Classes:**
     - `CoverImageCache`: Manages caching of chapter cover images and progress data.

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

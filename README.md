
# DBMultiverse

A fan-made companion app for the [DragonBall Multiverse](https://www.dragonball-multiverse.com) website. This project was created with permission from the creators of DragonBall Multiverse and serves as a way to enhance your experience with the webcomic.

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
  - [Install with Xcode](docs/XcodeInstallation.md)
  - [Install with AltStore](docs/AltStoreInstallationCorrected.md)
- [Developer Overview](#developer-overview)
  - [Features](#features)
  - [Architecture](#architecture)
  - [Key Components](#key-components)
  - [How to Contribute](#how-to-contribute)

---

## Overview

The **DBMultiverse** app is a Swift-based iOS and iPadOS application designed to provide quick access to the DragonBall Multiverse webcomic, cached chapters, and additional functionality like clearing cache and exploring special universe sections. Whether you're a fan looking for an easier way to interact with the comic or a developer interested in the project’s architecture, this app is for you.

---

## Installation

This app can be installed using either of the following methods:

1. **[Install with Xcode](docs/XcodeInstallation.md)**: Follow this guide to build and install the app directly from Xcode.
2. **[Install with AltStore](docs/AltStoreInstallationCorrected.md)**: Use AltStore to install the app without needing Xcode.

---

## Developer Overview

This section is for developers interested in the technical details of the project.

### Features

- **Cached Chapters:** Users can view and manage cached chapters locally on their device.
- **Special Universe Sections:** Explore chapters grouped by their universe.
- **Web Links:** Direct access to DragonBall Multiverse webcomic pages.
- **Error Handling:** Alerts for cache clearing or data loading issues.

### Architecture

The app is designed with modularity and clean separation of concerns in mind:

- **MVVM Architecture:** Combines `View`, `ViewModel`, and `Model` layers for scalable and testable code.
- **SwiftData Integration:** Simplifies data persistence and management.
- **Composable Views:** Built with SwiftUI for a responsive and declarative UI.

### Key Components

#### 1. **Data Layer**
   - `ChapterListRepository`: Manages loading, caching, and organizing chapter data.
   - `ChapterDataStore Protocol`: Defines the interface for data fetching.
   - `ChapterLoaderAdapter`: Handles remote data loading and parsing using `SwiftSoup`.

#### 2. **UI Layer**
   - Built entirely with **SwiftUI**.
   - Includes reusable custom components like `DynamicSection` and `HapticButton`.

#### 3. **Persistence**
   - **SwiftData**: Used to persist chapters and maintain state across app sessions.

### How to Contribute

Any feedback or ideas to enhance `DBMultiverse` would be well received. Please feel free to [open an issue](https://github.com/nikolainobadi/DBMultiverse/issues/new) if you'd like to help improve this project.

---

## License

`DBMultiverse` is available under the MIT license. See the LICENSE file for more information.


# DBMultiverse

<div align="center">
  <img src="media/appIcon.jpeg" alt="App Icon" height="200" width="300"/>
</div>

A fan-made companion app for the [DragonBall Multiverse](https://www.dragonball-multiverse.com) website. 

I created this app independently, with permission from the creators of DragonBall Multiverse, to enhance your experience with the webcomic. The app is not affiliated with or developed by the official DragonBall Multiverse team.

## Table of Contents
- [Overview](#overview)
- [Screenshots](#screenshots)
  - [iPhone Screenshots](#iphone-screenshots)
  - [iPad Screenshots](#ipad-screenshots)
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

## Screenshots

### iPhone Screenshots

<table>
  <tr>
    <td align="center"><strong>Chapter List</strong></td>
    <td align="center"><strong>Comic View</strong></td>
  </tr>
  <tr>
    <td><img src="media/iphone_chapterList.png" alt="iPhone Chapter List" width="200"/></td>
    <td><img src="media/iphone_comicView.png" alt="iPhone Comic View" width="200"/></td>
  </tr>
</table>

### iPad Screenshots

<table>
  <tr>
    <td align="center"><strong>Chapter List</strong></td>
    <td align="center"><strong>Comic View</strong></td>
  </tr>
  <tr>
    <td><img src="media/ipad_chapterList.png" alt="iPad Chapter List" width="300"/></td>
    <td><img src="media/ipad_comicView.png" alt="iPad Comic View" width="300"/></td>
  </tr>
</table>

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

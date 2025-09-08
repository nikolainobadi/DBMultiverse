
# Multiverse Reader

![Build Status](https://github.com/nikolainobadi/DBMultiverse/actions/workflows/ci.yml/badge.svg)
![Swift Version](https://badgen.net/badge/swift/6.0/purple)
![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)
![License](https://img.shields.io/badge/license-MIT-lightgray)

Multiverse Reader is an iOS application designed to enhance the experience of reading and managing the DB Multiverse webcomic. The app integrates several modules, each providing specific functionality to ensure a seamless and enjoyable user experience.

## TestFlight
If you just want access to the app, it has been approved for beta testing through TestFlight (Apple's own beta testing app). 

[Install Multiverse Reader with TestFlight](https://testflight.apple.com/join/8B21HpTS)

If you don't have TestFlight installed on your device, the link should first prompt you to install TestFlight, then you should be able to install Multiverse Reader. 

## Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
  - [iPhone Screenshots](#iphone-screenshots)
  - [iPad Screenshots](#ipad-screenshots)
- [Installation](docs/XcodeInstallation.md)
- [Modules](#modules)
    - [DBMultiverse](docs/DBMultiverse_Documentation.md)
    - [ComicKit](docs/DBMultiverseComicKit_Documentation.md)
    - [ParseKit](docs/DBMultiverseParseKit_Documentation.md)
    - [Widgets](docs/DBMultiverseWidgets_Documentation.md)

- [License](LICENSE)

## Overview

Multiverse Reader is built with modularity in mind, utilizing distinct modules for:
- Parsing webcomic data from HTML sources (ParseKit).
- Managing and displaying comic chapters and pages (ComicKit).
- Extending functionality via home screen widgets (Widgets).

Each module is documented in detail, and their integration is explained within the core [DBMultiverse Documentation](docs/DBMultiverse_Documentation.md).

## Screenshots

### iPhone Screenshots
(The name of the app changed. I'll get around to updating the screenshots soon.)

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
(The name of the app changed. I'll get around to updating the screenshots soon.)

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

## Installation

To install the app using Xcode:

1. **Open** Xcode (or **Download** it from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12)).
2. **Clone the project** from the [GitHub repository](https://github.com/nikolainobadi/DBMultiverse).
3. **Open the project** in Xcode by selecting the `DBMultiverse.xcodeproj` file.
4. **Connect your iPhone or iPad** and select it as the target device in Xcode.
5. **Run the app** by clicking the play button in Xcode.

For detailed installation steps, refer to the [Xcode Installation Guide](docs/XcodeInstallation.md).

## Modules

The **DBMultiverse** app is architected with modularity at its core, leveraging the separation of concerns to ensure scalability, maintainability, and ease of testing. Each module has a clearly defined purpose:

### 1. Core Application
- **Documentation**: [MultiverseReader](docs/DBMultiverse_Documentation.md)
- **Purpose**: Acts as the central layer that integrates functionality from all modules, orchestrating the primary app logic and navigation.

### 2. ComicKit Module
- **Documentation**: [ComicKit](docs/DBMultiverseComicKit_Documentation.md)
- **Purpose**: Manages comic-related functionality, including chapter handling, caching, and displaying comic pages with interactive features.

### 3. ParseKit Module
- **Documentation**: [ParseKit](docs/DBMultiverseParseKit_Documentation.md)
- **Purpose**: Responsible for parsing HTML data to extract comic metadata dynamically, enabling updates and ensuring accurate content delivery.

### 4. Widgets Module
- **Documentation**: [Widgets](docs/DBMultiverseWidgets_Documentation.md)
- **Purpose**: Extends the app’s functionality to the home screen, providing widgets that display chapter progress and enable quick navigation.

### Architecture and Benefits
The **DBMultiverse** app’s modular architecture provides numerous benefits:
- **Reduced Coupling**: Each module operates independently, allowing easier updates and maintenance without impacting other parts of the app.
- **Scalability**: Adding new features or expanding existing ones is simplified due to the modular structure.
- **Ease of Testing**: Modules can be tested in isolation, ensuring robust functionality and easier debugging.
- **Code Reuse**: Core components, such as **ComicKit**, can be reused across different projects.

The modules fit together seamlessly:
- **ParseKit** supplies structured data to **ComicKit**, which processes and presents it.
- The core **DBMultiverse** app integrates these features to provide the main user experience.
- **Widgets** consume data from **ComicKit** to deliver dynamic and interactive home screen functionality.

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

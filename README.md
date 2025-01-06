
# DBMultiverse

A fan-made companion app for the [DragonBall Multiverse](https://www.dragonball-multiverse.com) website. This project was created with permission from the creators of DragonBall Multiverse and serves as a way to enhance your experience with the webcomic.

## Table of Contents
- [Overview](#overview)
- [Installation for Non-Tech Users](#installation-for-non-tech-users)
  - [Step 1: Download Xcode](#step-1-download-xcode)
  - [Step 2: Clone the Project](#step-2-clone-the-project)
  - [Step 3: Open the Project in Xcode](#step-3-open-the-project-in-xcode)
  - [Step 4: Pair Your iPhone or iPad](#step-4-pair-your-iphone-or-ipad)
  - [Step 5: Run the App](#step-5-run-the-app)
  - [Optional: Clone the Project Using Command Line](#optional-clone-the-project-using-command-line)
- [Developer Overview](#developer-overview)
  - [Features](#features)
  - [Architecture](#architecture)
  - [Key Components](#key-components)
  - [How to Contribute](#how-to-contribute)

---

## Overview

The **DBMultiverse** app is a Swift-based iOS and iPadOS application designed to provide quick access to the DragonBall Multiverse webcomic, cached chapters, and additional functionality like clearing cache and exploring special universe sections. Whether you're a fan looking for an easier way to interact with the comic or a developer interested in the project’s architecture, this app is for you.

---

## Installation for Non-Tech Users

This guide will walk you through installing the app on your iPhone or iPad using Xcode. Don't worry if you've never used Xcode or GitHub before—each step is explained in detail.

### Step 1: Download Xcode

1. Open the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12) on your Mac.
2. Search for **Xcode**.
3. Click **Get** or **Install** to download and install Xcode (it’s free).

### Step 2: Clone the Project

1. Open your web browser and navigate to the project repository: [DBMultiverse on GitHub](https://github.com/nikolainobadi/DBMultiverse).
2. Click the green **Code** button and select **Download ZIP**. This will download the project files to your computer.
   - Alternatively, you can follow the [command-line instructions](#optional-clone-the-project-using-command-line) below to clone the project using Git.
3. Locate the downloaded `.zip` file in your Downloads folder and double-click it to extract the contents.

### Step 3: Open the Project in Xcode

1. Open Xcode.
2. Click **File > Open...** from the menu bar.
3. Navigate to the extracted project folder, select `DBMultiverse.xcodeproj`, and click **Open**.

### Step 4: Pair Your iPhone or iPad

1. Connect your iPhone or iPad to your Mac using a USB cable.
2. In Xcode, click on the **Device Selector** near the top left of the window (it looks like a play button with a dropdown next to it).
3. Select your connected device from the list. If prompted, follow the on-screen instructions to pair your device and allow it to be used for development.
4. You may need to enable **Developer Mode** on your device:
   - Go to **Settings > Privacy & Security** and toggle **Developer Mode**.

### Note on Code Signing and Developer Accounts

To install the DBMultiverse app on your device, you will need to 'sign the app' using your own Apple Developer Team, which you can easily do with your own AppleID.

#### Free Apple ID
- You can use your regular Apple ID to sign the app for personal use.
- Apps signed with a free Apple ID will expire after **7 days**, meaning you’ll need to reinstall the app through Xcode to continue using it.

#### Paid Apple Developer Program
- If you have a paid Apple Developer account, the app will not expire after 7 days.

#### How to Select Your Developer Team in Xcode
1. In Xcode, click on the project name (the one with the blue icon next to DBMultiverse) in the Project Navigator (the left-hand sidebar).
2. Select the **Signing & Capabilities** tab from the center editor.
3. Under **Team**, select your Apple ID or Developer Program team from the dropdown.
   - If you don’t see your Apple ID, click **Add an Account** and log in with your Apple ID.
4. Xcode will handle the rest of the signing process for you.

### Step 5: Run the App

1. In Xcode, click the **Run** button (a triangle-shaped play icon) at the top left of the window.
2. Xcode will build the app and install it on your device.
3. Once the app launches on your device, you can start exploring DragonBall Multiverse through the app!

---

### Optional: Clone the Project Using Command Line

If you prefer to use the command line to download the project, follow these steps:

#### Step 1: Check if Git is Installed

1. Open **Terminal** on your Mac (search for "Terminal" in Spotlight).
2. Type the following command and press Enter:
   ```bash
   git --version
   ```
3. If you see something like `git version 2.x.x`, Git is installed, and you can proceed. If not, install Git by downloading it from [git-scm.com](https://git-scm.com).

#### Step 2: Navigate to Your Desktop

To make the project easier to find, we'll save it to your Desktop:

1. In Terminal, type the following command and press Enter:
   ```bash
   cd ~
   ```
   This takes you to your home directory.
   
2. Now, type this command and press Enter:
   ```bash
   cd Desktop
   ```
   You are now in the Desktop folder.

#### Step 3: Clone the Project

1. Type the following command in Terminal and press Enter:
   ```bash
   git clone https://github.com/nikolainobadi/DBMultiverse.git
   ```
2. This will download the project into a folder named `DBMultiverse` on your Desktop.

#### Step 4: Open the Project in Xcode

1. Use Finder to open the `DBMultiverse` folder on your Desktop.
2. Double-click the `DBMultiverse.xcodeproj` (or `.xcworkspace`) file to open it in Xcode.

Continue with **Step 4: Pair Your iPhone or iPad** and **Step 5: Run the App** from the instructions above.

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

Any feedback or ideas to enhance `DBMultiverse` would be well received. Please feel free to [open an issue](https://github.com/nikolainobadi/DBMultiverse/issues/new) if you'd like to help improve this swift package.

## License
`DBMultiverse` is available under the MIT license. See the LICENSE file for more information.
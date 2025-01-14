
# Xcode Installation Guide

This guide will walk you through installing the app on your iPhone or iPad using Xcode. Don't worry if you've never used Xcode or GitHub before—each step is explained in detail.

---

## Step 1: Download Xcode

1. Open the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12) on your Mac.
2. Search for **Xcode**.
3. Click **Get** or **Install** to download and install Xcode (it’s free).

---

## Step 2: Clone the Project

### Option 1: Download ZIP (Simple Method)

1. Navigate to the project repository: [DBMultiverse on GitHub](https://github.com/nikolainobadi/DBMultiverse).
2. Click the green **Code** button and select **Download ZIP**.
3. Locate the downloaded `.zip` file in your Downloads folder and double-click it to extract the contents.

### Option 2: Use Git Command Line (Advanced)

If you're comfortable using the Terminal, follow these steps to clone the repository directly:

1. Open **Terminal** (search for "Terminal" in Spotlight).
2. Check if Git is installed by running:
   ```bash
   git --version
   ```
   If Git is not installed, download it from [git-scm.com](https://git-scm.com).

3. Navigate to your Desktop (or another folder where you want to save the project):
   ```bash
   cd ~/Desktop
   ```

4. Clone the repository:
   ```bash
   git clone https://github.com/nikolainobadi/DBMultiverse.git
   ```

5. This will create a `DBMultiverse` folder in your chosen directory.

---

## Step 3: Open the Project in Xcode

1. Open Xcode.
2. Click **File > Open...** from the menu bar.
3. Navigate to the extracted or cloned project folder and select `DBMultiverse.xcodeproj`.

---

## Step 4: Pair Your iPhone or iPad

1. Connect your iPhone or iPad to your Mac using a USB cable.
2. In Xcode, click on the **Device Selector** near the top left of the window (it looks like a play button with a dropdown next to it).
3. Select your connected device from the list. If prompted, follow the on-screen instructions to pair your device and enable **Developer Mode**:
   - Go to **Settings > Privacy & Security** on your device and toggle **Developer Mode**.

---

## Step 5: Run the App

1. In Xcode, click the **Run** button (a triangle-shaped play icon) at the top left of the window.
2. Xcode will build the app and install it on your device.
3. Once the app launches on your device, you can start exploring DragonBall Multiverse through the app!

---

## Notes on Code Signing

To install the DBMultiverse app on your device, you will need to 'sign the app' using your own Apple Developer Team, which you can do with your Apple ID.

### Free Apple ID

- Apps signed with a free Apple ID will expire after **7 days**, requiring reinstallation via Xcode.

### Paid Apple Developer Program

- Apps signed with a paid Apple Developer account will not expire after 7 days.

### How to Select Your Developer Team in Xcode

1. Click on the project name (the blue icon) in the Project Navigator.
2. Open the **Signing & Capabilities** tab.
3. Under **Team**, select your Apple ID or Developer Program team.
4. If your Apple ID isn't listed, click **Add an Account** and log in with your credentials.

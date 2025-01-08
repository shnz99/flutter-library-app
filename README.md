# Mobile App for Book Tracking and Management

This mobile app allows users to track and manage the books they have read. Users can add books to their library by searching for them or scanning their barcodes. The app provides features like categorizing books, adding notes, and more. This app works on both Android and iOS platforms and operates locally on the user's smartphone. Users can also export their entire library and import it back into the app.

## Current App Features
- Track and manage books
- Add books by searching or scanning barcodes
- Categorize books
- Add notes to books
- Export and import library
- Works offline

## Current Build Version
The current build version for Android is 1.0.0+1. The APK build and release process is triggered only by merging to the `main` branch.

## Development Environment Setup

To set up the development environment for this project, follow these steps:

1. Install [Flutter](https://flutter.dev/docs/get-started/install) and [Dart](https://dart.dev/get-dart).
2. Install [Visual Studio Code](https://code.visualstudio.com/) and the Flutter extension.
3. Clone the repository:
   ```sh
   git clone https://github.com/shnz99/flutter-library-app.git
   ```
4. Navigate to the project directory:
   ```sh
   cd flutter-library-app
   ```
5. Get the Flutter packages:
   ```sh
   flutter pub get
   ```

All testing and new changes should be pushed to the `dev` branch.

## Running the App

To run the app on an emulator or a physical device, follow these steps:

1. Connect your device or start an emulator.
2. Run the app:
   ```sh
   flutter run
   ```

## Testing the App

To run the tests for the app, follow these steps:

1. Run the tests:
   ```sh
   flutter test
   ```

## Build Instructions

To build the app for Android, follow these steps:

1. Build the app for Android:
   ```sh
   flutter build apk
   ```

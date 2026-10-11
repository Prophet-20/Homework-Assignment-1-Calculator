# Setup and Build

## Setup

1. Install Git, Flutter with Dart 3.13.3 or later compatible with Dart 3.x, and Android Studio with the Android SDK.
2. Check the development environment and accept the Android SDK licenses:

   ```sh
   flutter doctor
   flutter doctor --android-licenses
   ```

3. Clone the repository and install dependencies:

   ```sh
   git clone https://github.com/Prophet-20/Homework-Assignment-1-Calculator.git
   cd Homework-Assignment-1-Calculator
   flutter pub get
   ```

## Run

Start an Android emulator or connect an Android device with USB debugging enabled, then run:

```sh
flutter run
```

## Build the APK

```sh
flutter build apk --release
```

The APK is saved to `build/app/outputs/flutter-apk/app-release.apk`.

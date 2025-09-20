#!/bin/bash
# Build script for the finance app

# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Clean and get dependencies
flutter clean
flutter pub get

# Build APK
flutter build apk

echo "Build completed. APK is located at build/app/outputs/flutter-apk/app-release.apk"
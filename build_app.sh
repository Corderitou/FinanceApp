#!/bin/bash
# Build script for the finance app

# Set JAVA_HOME to JDK 11 (adjust path as needed)
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk

# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Set ANDROID_HOME to user-specific SDK
export ANDROID_HOME=/home/cordero/Android/Sdk

# Clean and get dependencies
$HOME/flutter/bin/flutter clean
$HOME/flutter/bin/flutter pub get

# Build APK
$HOME/flutter/bin/flutter build apk

echo "Build completed. APK is located at build/app/outputs/flutter-apk/app-release.apk"
#!/bin/bash
# Enhanced build script for the finance app

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log "Starting build process..."

# Set JAVA_HOME to JDK 11 (adjust path as needed)
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk

# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Set ANDROID_HOME to user-specific SDK
export ANDROID_HOME=/home/cordero/Android/Sdk

# Validate environment
log "Validating environment..."
if [ ! -d "$JAVA_HOME" ]; then
    error "JAVA_HOME directory does not exist: $JAVA_HOME"
    exit 1
fi

if [ ! -d "$ANDROID_HOME" ]; then
    warn "ANDROID_HOME directory does not exist: $ANDROID_HOME"
fi

# Clean and get dependencies
log "Cleaning project..."
$HOME/flutter/bin/flutter clean

log "Getting dependencies..."
$HOME/flutter/bin/flutter pub get

# Build APK
log "Building APK..."
$HOME/flutter/bin/flutter build apk

# Check if build was successful
if [ $? -eq 0 ]; then
    log "APK build completed successfully"
    
    # Show build artifact details
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        APK_SIZE=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
        log "APK Size: $APK_SIZE"
        log "APK Location: build/app/outputs/flutter-apk/app-release.apk"
    fi
else
    error "APK build failed"
    exit 1
fi

log "Build process completed!"
#!/bin/bash
# Script to run the finance app in debug mode

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log "Starting FinanceApp in debug mode..."

# Set environment variables
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH="$PATH:$HOME/flutter/bin"
export ANDROID_HOME=/home/cordero/Android/Sdk

# Check if Flutter is installed
if ! command -v flutter >/dev/null 2>&1; then
    if [ -f "$HOME/flutter/bin/flutter" ]; then
        FLUTTER_CMD="$HOME/flutter/bin/flutter"
    else
        error "Flutter is not installed and not found at $HOME/flutter/bin/flutter"
        exit 1
    fi
else
    FLUTTER_CMD="flutter"
fi

# Validate Flutter installation
if ! $FLUTTER_CMD --version >/dev/null 2>&1; then
    error "Flutter installation appears to be invalid"
    exit 1
fi

# Get dependencies if pubspec.yaml has changed
if [ -f "pubspec.yaml" ] && [ -f "pubspec.lock" ]; then
    if [ "pubspec.yaml" -nt "pubspec.lock" ]; then
        log "pubspec.yaml is newer than pubspec.lock, getting dependencies..."
        $FLUTTER_CMD pub get
    fi
elif [ -f "pubspec.yaml" ]; then
    log "Getting dependencies..."
    $FLUTTER_CMD pub get
fi

# Run the app
log "Launching app on connected device/emulator..."
$FLUTTER_CMD run

log "App execution completed."
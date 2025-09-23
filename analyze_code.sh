#!/bin/bash
# Script to analyze the finance app code

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

log "Starting code analysis..."

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

# Get dependencies
log "Getting dependencies..."
$FLUTTER_CMD pub get

# Run Flutter analyze
log "Running Flutter analyzer..."
if $FLUTTER_CMD analyze; then
    log "Flutter analysis completed with no issues"
else
    warn "Flutter analysis completed with issues (see above)"
fi

# Run tests
log "Running tests..."
if $FLUTTER_CMD test; then
    log "All tests passed"
else
    error "Some tests failed"
    exit 1
fi

# Check for TODOs and FIXMEs in the code
log "Checking for TODOs and FIXMEs..."
TODO_COUNT=$(grep -r "TODO" lib/ --include="*.dart" | wc -l)
FIXME_COUNT=$(grep -r "FIXME" lib/ --include="*.dart" | wc -l)

if [ $TODO_COUNT -gt 0 ]; then
    warn "Found $TODO_COUNT TODO comments in the code"
fi

if [ $FIXME_COUNT -gt 0 ]; then
    warn "Found $FIXME_COUNT FIXME comments in the code"
fi

# Check for unused files (basic check)
log "Checking for potentially unused files..."
DART_FILES=$(find lib/ -name "*.dart" | wc -l)
log "Found $DART_FILES Dart files in lib/"

log "Code analysis completed."
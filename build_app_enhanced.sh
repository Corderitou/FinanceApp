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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Java
    if ! command_exists java; then
        error "Java is not installed"
        exit 1
    fi
    
    # Check Flutter
    if ! command_exists flutter; then
        warn "Flutter command not found in PATH, trying to use full path"
        if [ ! -f "$HOME/flutter/bin/flutter" ]; then
            error "Flutter SDK not found at $HOME/flutter/bin/flutter"
            exit 1
        fi
        FLUTTER_CMD="$HOME/flutter/bin/flutter"
    else
        FLUTTER_CMD="flutter"
    fi
    
    # Check Android SDK
    if [ ! -d "/home/cordero/Android/Sdk" ]; then
        warn "Android SDK not found at /home/cordero/Android/Sdk"
        warn "Please verify ANDROID_HOME is set correctly"
    fi
    
    log "Prerequisites check completed"
}

# Function to validate environment
validate_environment() {
    log "Validating environment..."
    
    # Validate Java version
    JAVA_VERSION=$($JAVA_HOME/bin/java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
    if [ "$JAVA_VERSION" != "11" ]; then
        warn "Java version is $JAVA_VERSION, recommended version is 11"
    fi
    
    # Validate Flutter installation
    if ! $FLUTTER_CMD --version >/dev/null 2>&1; then
        error "Flutter installation appears to be invalid"
        exit 1
    fi
    
    log "Environment validation completed"
}

# Function to clean project
clean_project() {
    log "Cleaning project..."
    $FLUTTER_CMD clean
}

# Function to get dependencies
get_dependencies() {
    log "Getting dependencies..."
    $FLUTTER_CMD pub get
    
    # Check for any dependency issues
    if [ ! -f "pubspec.lock" ]; then
        warn "pubspec.lock not found after getting dependencies"
    fi
}

# Function to run tests
run_tests() {
    log "Running tests..."
    if $FLUTTER_CMD test; then
        log "All tests passed"
    else
        error "Some tests failed"
        exit 1
    fi
}

# Function to analyze code
analyze_code() {
    log "Analyzing code..."
    $FLUTTER_CMD analyze
}

# Function to build APK
build_apk() {
    log "Building APK..."
    
    BUILD_TYPE="release"
    if [ "$1" == "debug" ]; then
        BUILD_TYPE="debug"
        log "Building debug APK"
        $FLUTTER_CMD build apk --debug
    else
        log "Building release APK"
        $FLUTTER_CMD build apk --release
    fi
    
    # Check if build was successful
    if [ $? -eq 0 ]; then
        log "APK build completed successfully"
    else
        error "APK build failed"
        exit 1
    fi
}

# Function to build App Bundle (AAB)
build_app_bundle() {
    log "Building App Bundle (AAB)..."
    $FLUTTER_CMD build appbundle
    
    if [ $? -eq 0 ]; then
        log "App Bundle build completed successfully"
    else
        error "App Bundle build failed"
        exit 1
    fi
}

# Function to show build artifacts
show_artifacts() {
    log "Build artifacts:"
    
    # APK
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        APK_SIZE=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
        echo "  - Release APK: build/app/outputs/flutter-apk/app-release.apk ($APK_SIZE)"
    fi
    
    if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
        APK_SIZE=$(du -h "build/app/outputs/flutter-apk/app-debug.apk" | cut -f1)
        echo "  - Debug APK: build/app/outputs/flutter-apk/app-debug.apk ($APK_SIZE)"
    fi
    
    # App Bundle
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        AAB_SIZE=$(du -h "build/app/outputs/bundle/release/app-release.aab" | cut -f1)
        echo "  - Release App Bundle: build/app/outputs/bundle/release/app-release.aab ($AAB_SIZE)"
    fi
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --debug        Build debug APK"
    echo "  --release      Build release APK (default)"
    echo "  --aab          Build App Bundle (AAB) in addition to APK"
    echo "  --test         Run tests before building"
    echo "  --analyze      Run code analysis before building"
    echo "  --clean        Clean project before building"
    echo "  --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Build release APK"
    echo "  $0 --debug          # Build debug APK"
    echo "  $0 --aab --test     # Build both APK and AAB, run tests"
}

# Main build function
main() {
    local build_debug=false
    local build_aab=false
    local run_tests=false
    local run_analyze=false
    local clean_first=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --debug)
                build_debug=true
                shift
                ;;
            --release)
                build_debug=false
                shift
                ;;
            --aab)
                build_aab=true
                shift
                ;;
            --test)
                run_tests=true
                shift
                ;;
            --analyze)
                run_analyze=true
                shift
                ;;
            --clean)
                clean_first=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    log "Starting build process..."
    
    # Set environment variables
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
    export PATH="$PATH:$HOME/flutter/bin"
    export ANDROID_HOME=/home/cordero/Android/Sdk
    
    # Check prerequisites
    check_prerequisites
    validate_environment
    
    # Clean if requested
    if [ "$clean_first" = true ]; then
        clean_project
    fi
    
    # Get dependencies
    get_dependencies
    
    # Run tests if requested
    if [ "$run_tests" = true ]; then
        run_tests
    fi
    
    # Run analysis if requested
    if [ "$run_analyze" = true ]; then
        analyze_code
    fi
    
    # Build APK
    if [ "$build_debug" = true ]; then
        build_apk "debug"
    else
        build_apk "release"
    fi
    
    # Build App Bundle if requested
    if [ "$build_aab" = true ]; then
        build_app_bundle
    fi
    
    # Show artifacts
    show_artifacts
    
    log "Build process completed successfully!"
}

# Run main function with all arguments
main "$@"
# FinanceApp Build Scripts

This directory contains several scripts to help with building, running, and analyzing the FinanceApp.

## Available Scripts

### 1. `build_app.sh` - Main Build Script
Builds the release APK for the FinanceApp.

**Usage:**
```bash
./build_app.sh
```

**Features:**
- Sets up environment variables (JAVA_HOME, ANDROID_HOME, PATH)
- Cleans the project
- Gets dependencies
- Builds release APK
- Provides build status and artifact information

### 2. `build_app_enhanced.sh` - Enhanced Build Script
Advanced build script with multiple options.

**Usage:**
```bash
./build_app_enhanced.sh [--debug] [--aab] [--test] [--analyze] [--clean] [--help]
```

**Options:**
- `--debug`: Build debug APK instead of release
- `--aab`: Also build Android App Bundle (.aab)
- `--test`: Run tests before building
- `--analyze`: Run code analysis before building
- `--clean`: Clean project before building
- `--help`: Show help message

**Examples:**
```bash
# Build release APK
./build_app_enhanced.sh

# Build debug APK and run tests
./build_app_enhanced.sh --debug --test

# Build both APK and AAB
./build_app_enhanced.sh --aab
```

### 3. `run_debug.sh` - Debug Runner
Runs the app in debug mode on a connected device or emulator.

**Usage:**
```bash
./run_debug.sh
```

**Features:**
- Sets up environment variables
- Validates Flutter installation
- Gets dependencies if needed
- Runs the app in debug mode

### 4. `analyze_code.sh` - Code Analyzer
Analyzes the code for issues and runs tests.

**Usage:**
```bash
./analyze_code.sh
```

**Features:**
- Runs Flutter analyzer
- Executes all tests
- Checks for TODO/FIXME comments
- Provides summary of findings

## Prerequisites

- Flutter SDK installed
- Android SDK installed
- JDK 11 installed
- Connected Android device or emulator for running/debugging

## Environment Variables

The scripts automatically set these environment variables:
- `JAVA_HOME`: Points to JDK 11
- `ANDROID_HOME`: Points to Android SDK
- `PATH`: Includes Flutter binaries

## Output Locations

- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

## Troubleshooting

1. **Permission denied**: Run `chmod +x script_name.sh` to make scripts executable
2. **Flutter not found**: Ensure Flutter is installed at `$HOME/flutter` or update paths in scripts
3. **Java version issues**: Ensure JDK 11 is installed and JAVA_HOME points to it
4. **Android SDK issues**: Verify ANDROID_HOME path is correct

## Customization

You can customize these scripts by modifying:
- Paths to JDK, Flutter, and Android SDK
- Build parameters
- Environment variables
- Additional build steps

Simply edit the `.sh` files with a text editor to make changes.
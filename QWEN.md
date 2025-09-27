# FinanceApp Project Context

## Project Overview
This is a Flutter-based personal finance application called "ingresos_costos_app" (income and expenses app in Spanish). The app allows users to track their personal finances including income, expenses, accounts, budgets, and savings goals. It also features work location tracking, reminders, and financial reporting capabilities.

### Key Features
- **Transaction Tracking**: Record income and expense transactions with categories
- **Account Management**: Manage multiple financial accounts with balances
- **Budget Planning**: Set and track budgets for different categories
- **Savings Goals**: Create and monitor savings targets with progress tracking
- **Work Location Tracking**: Record work locations with geolocation data
- **Reminders**: Set up recurring financial reminders (daily, weekly, monthly, yearly)
- **Reporting**: View financial reports and visualizations
- **Notifications**: Receive daily notifications for financial tracking
- **Recurring Transactions**: Automated income/expense entries with templates
- **Bill Reminders**: Smart bill detection and payment tracking
- **Advanced Analytics**: Spending trends and pattern analysis
- **Enhanced Dashboard**: Customizable widgets with visual data representations
- **Voice Commands**: Hands-free navigation and transaction entry
- **Dark/Light Theme**: System-aware theme switching with custom color schemes
- **Accessibility**: Improved contrast, screen reader support, and larger touch targets

### Technologies Used
- **Framework**: Flutter (Dart)
- **Database**: SQLite (using sqflite package)
- **State Management**: Riverpod
- **UI Components**: Flutter Material Design
- **Charts**: fl_chart for data visualization
- **File Handling**: CSV export and PDF generation
- **Notifications**: flutter_local_notifications
- **Internationalization**: intl package for date formatting
- **Voice Recognition**: speech_to_text package
- **Geolocation**: geolocator and geocoding packages
- **Image Processing**: image_picker for receipt capture

## Project Structure
```
lib/
├── data/                 # Data layer (models, repositories, database)
│   ├── database/         # Database helper and initialization
│   ├── models/           # Data models/entities
│   ├── repositories/     # Data access repositories
│   └── export/           # Export functionality
├── domain/               # Business logic layer
│   ├── entities/         # Business entities
│   ├── usecases/         # Business use cases
│   ├── reports/          # Report generation logic
│   ├── services/         # Business services (location, categorization, etc.)
│   └── export/           # Domain export logic
├── presentation/         # UI layer
│   ├── screens/          # Screen widgets
│   ├── widgets/          # Reusable UI components
│   ├── providers/        # Riverpod providers
│   ├── theme/            # App theme and styling
│   ├── navigation/       # Navigation components
│   ├── accessibility/    # Accessibility features
│   └── utils/            # UI utilities
└── services/             # Background services
```

## Database Schema
The application uses SQLite with the following tables:
- **users**: User information
- **accounts**: Financial accounts (bank accounts, wallets, etc.)
- **categories**: Transaction categories (food, transport, salary, etc.)
- **transactions**: Income and expense transactions
- **budgets**: Budget allocations by category
- **work_locations**: Geolocation data for work locations
- **reminders**: Recurring notification reminders
- **savings_goals**: Financial savings targets
- **recurring_transactions**: Templates for automated transactions
- **bills**: Bill tracking and payment history
- **receipts**: Receipt images and OCR data (planned)

## Development Conventions
- **State Management**: Uses Riverpod for state management
- **Architecture**: Follows a clean architecture pattern with separation of data, domain, and presentation layers
- **Dependency Injection**: Uses Riverpod providers for dependency injection
- **Code Style**: Follows Flutter linting rules (flutter_lints package)
- **Localization**: Uses the intl package for internationalization
- **Accessibility**: Follows WCAG guidelines for contrast and screen reader support

## Building and Running
### Prerequisites
- Flutter SDK (>=2.17.0 <3.0.0)
- Android SDK (for Android builds)
- Xcode (for iOS builds)
- JDK 11 (for Android builds)

### Build Commands
```bash
# Get dependencies
flutter pub get

# Run in debug mode
flutter run

# Build APK
flutter build apk

# Build for other platforms
flutter build ios
flutter build web
```

### Automated Build Scripts
The project includes several build scripts:

1. **`build_app.sh`** - Basic build script:
   - Sets environment variables (JAVA_HOME, ANDROID_HOME)
   - Cleans the project
   - Gets dependencies
   - Builds the APK
   - Enhanced with error handling and logging

2. **`build_app_enhanced.sh`** - Advanced build script with options:
   ```bash
   ./build_app_enhanced.sh [--debug] [--aab] [--test] [--analyze] [--clean] [--help]
   ```
   - Multiple build modes (debug/release)
   - App Bundle (AAB) support
   - Integrated testing and analysis
   - Command-line options for flexibility

3. **`run_debug.sh`** - Debug runner:
   - Runs the app in debug mode on connected devices
   - Automatic dependency management
   - Environment validation

4. **`analyze_code.sh`** - Code analyzer:
   - Runs Flutter analyzer
   - Executes all tests
   - Checks for TODO/FIXME comments
   - Provides code quality summary

### Testing
```bash
# Run tests
flutter test

# Run specific test file
flutter test test/unit_test.dart

# Run tests with coverage
flutter test --coverage
```

## Key Components
### Main Entry Point
The app initializes with:
- Database setup
- System category initialization
- Notification service initialization
- Daily notification scheduling

### Core Screens
- **TradingHomeScreen**: Main dashboard with navigation
- **Account Management**: Account creation and monitoring
- **Reports Dashboard**: Financial data visualization
- **Work Location Tracking**: Geolocation features
- **Reminders**: Notification management
- **Savings Goals**: Savings target tracking
- **Recurring Transactions**: Automated transaction templates
- **Bills**: Bill tracking and payment management
- **Analytics**: Advanced financial analytics and trends
- **Settings**: Theme, accessibility, and app settings

### Providers
- **AccountProvider**: Account state management
- **ReminderProvider**: Reminder state management
- **SavingsGoalProvider**: Savings goals state management
- **WorkLocationProvider**: Work location state management
- **RecurringTransactionProvider**: Recurring transaction templates
- **BillProvider**: Bill tracking and management
- **AnalyticsProvider**: Financial analytics and reporting
- **ThemeProvider**: Dark/light theme management
- **AccessibilityProvider**: Accessibility settings

## Dependencies
### Production Dependencies
- sqflite: SQLite database
- path: File path utilities
- provider: State management (legacy, being replaced by Riverpod)
- flutter_riverpod: Modern state management
- fl_chart: Data visualization
- csv: CSV export functionality
- pdf: PDF generation
- printing: Document printing
- path_provider: File system access
- open_file: File opening
- flutter_local_notifications: Local notifications
- intl: Internationalization
- speech_to_text: Voice command recognition
- geolocator: Location services
- geocoding: Address geocoding
- image_picker: Image selection and capture
- shared_preferences: Persistent settings storage
- permission_handler: Runtime permission management

### Development Dependencies
- flutter_test: Testing framework
- flutter_lints: Code linting

## Services
- **NotificationService**: Handles local notifications
- **NotificationHandler**: Processes notification interactions
- **LocationBasedCategorizationService**: Automatic category assignment based on location
- **SmartBillDetectionService**: Identifies bills from transaction patterns
- **CategoryPatternAnalyzer**: Analyzes spending patterns by category
- **PredictiveBudgetingService**: Forecasts future spending based on history

## Recent Enhancements
### 1. Recurring Transactions Feature
- Data models for recurring transactions with frequency, start/end dates, and templates
- Automated entry system that generates transactions based on recurring templates
- Template management UI for creating, editing, and managing recurring transaction templates
- Automatic categorization system using rule-based approaches
- Integration with existing notification service for reminders

### 2. Bill Reminders & Management
- Data models for bills including due dates, amounts, and payment history
- Smart bill detection system that identifies bills from transactions
- Due date tracking system with notifications
- Payment history tracking and forecasting system
- UI for bill management including list, detail, and creation views

### 3. Advanced Analytics
- Data models for analytics including trends, patterns, and reports
- Spending trends analysis with visualizations
- Category spending patterns and insights
- Predictive analytics for budgeting
- UI for analytics dashboard and reports

### 4. Dashboard Redesign
- Widget system for customizable dashboard
- Quick summary cards with key metrics
- Enhanced data visualizations for charts and graphs
- UI for dashboard customization

### 5. Enhanced Transaction Entry
- Receipt capture functionality with OCR
- Location-based automatic categorization
- Quick-add floating action button with smart defaults
- Enhanced transaction form with improved UX

### 6. Improved Navigation
- Persistent bottom navigation with all main sections
- Global search functionality across all data types
- Voice command system for hands-free navigation
- UI for improved navigation experience

### 7. Dark/Light Theme Toggle
- Theme mode provider with system-aware switching
- Custom color schemes support
- Theme toggle widget
- Color scheme selector UI

### 8. Accessibility Improvements
- Accessibility settings management
- Enhanced theme support for high contrast, larger text, and bold text
- Accessible widgets with proper touch targets
- Accessibility settings screen

## Future Development Notes
- The app has system categories that are pre-populated
- There's mock data in some UI components that should be replaced with real data
- The user ID is currently hardcoded to 1 in many places and should be made dynamic
- There are TODO comments indicating areas for improvement
- Consider implementing cloud synchronization for data backup
- Explore machine learning for smarter financial categorization and predictions
- Add support for bank account integration via Plaid or similar services
- Implement multi-currency support with exchange rate integration
- Add investment tracking module for stocks, bonds, and cryptocurrencies
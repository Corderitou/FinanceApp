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

### Technologies Used
- **Framework**: Flutter (Dart)
- **Database**: SQLite (using sqflite package)
- **State Management**: Riverpod
- **UI Components**: Flutter Material Design
- **Charts**: fl_chart for data visualization
- **File Handling**: CSV export and PDF generation
- **Notifications**: flutter_local_notifications
- **Internationalization**: intl package for date formatting

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
│   └── export/           # Domain export logic
├── presentation/         # UI layer
│   ├── screens/          # Screen widgets
│   ├── widgets/          # Reusable UI components
│   ├── providers/        # Riverpod providers
│   ├── theme/            # App theme and styling
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

## Development Conventions
- **State Management**: Uses Riverpod for state management
- **Architecture**: Follows a clean architecture pattern with separation of data, domain, and presentation layers
- **Dependency Injection**: Uses Riverpod providers for dependency injection
- **Code Style**: Follows Flutter linting rules (flutter_lints package)
- **Localization**: Uses the intl package for internationalization

## Building and Running
### Prerequisites
- Flutter SDK (>=2.17.0 <3.0.0)
- Android SDK (for Android builds)
- Xcode (for iOS builds)

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

### Automated Build Script
The project includes a build script (`build_app.sh`) that:
1. Sets environment variables (JAVA_HOME, ANDROID_HOME)
2. Cleans the project
3. Gets dependencies
4. Builds the APK

### Testing
```bash
# Run tests
flutter test
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

### Providers
- **AccountProvider**: Account state management
- **ReminderProvider**: Reminder state management
- **SavingsGoalProvider**: Savings goals state management
- **WorkLocationProvider**: Work location state management

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

### Development Dependencies
- flutter_test: Testing framework
- flutter_lints: Code linting

## Services
- **NotificationService**: Handles local notifications
- **NotificationHandler**: Processes notification interactions

## Future Development Notes
- The app has system categories that are pre-populated
- There's mock data in some UI components that should be replaced with real data
- The user ID is currently hardcoded to 1 in many places and should be made dynamic
- There are TODO comments indicating areas for improvement
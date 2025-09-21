import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingresos_costos_app/data/database/database_helper.dart';
import 'package:ingresos_costos_app/data/repositories/work_location_repository.dart';
import 'package:ingresos_costos_app/data/repositories/account_repository.dart';
import 'package:ingresos_costos_app/data/repositories/reminder_repository.dart';
import 'package:ingresos_costos_app/data/repositories/savings_goal_repository.dart';
import 'presentation/screens/trading_home_screen.dart';
import 'data/repositories/category_repository.dart';
import 'domain/usecases/category/manage_category_usecase.dart';
import 'services/notification_service.dart';
import 'services/notification_handler.dart';
import 'presentation/screens/work_location/work_location_form_screen.dart';
import 'presentation/screens/work_location/work_locations_list_screen.dart';
import 'presentation/screens/savings_goal/savings_goal_list_screen.dart';
import 'presentation/providers/work_location_riverpod_provider.dart';
import 'presentation/providers/account_provider.dart';
import 'presentation/providers/reminder_provider.dart';
import 'presentation/providers/savings_goal_provider.dart';
import 'presentation/theme/trading_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.init();
    
    // Request notification permissions
    await notificationService.requestNotificationPermissions();
    await notificationService.requestExactAlarmsPermission();
    
    // Schedule daily notification for user ID 1 (you might want to make this dynamic)
    await notificationService.scheduleDailyNotification(1);
    
    // Initialize system categories
    final categoryRepository = CategoryRepository();
    final manageCategoryUseCase = ManageCategoryUseCase(
      categoryRepository: categoryRepository,
    );
    
    await manageCategoryUseCase.initializeSystemCategoriesInDatabase();
  } catch (e) {
    // Print error to console for debugging
    print('Error during initialization: $e');
  }
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    
    // Set up notification handler
    NotificationHandler().onWorkLocationNotificationTap = (userId) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => WorkLocationFormScreen(userId: userId),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper.instance;
    final workLocationRepository = WorkLocationRepositoryImpl(dbHelper: dbHelper);
    final accountRepository = AccountRepository();
    final reminderRepository = ReminderRepository();
    final savingsGoalRepository = SavingsGoalRepository();
    
    return ProviderScope(
      overrides: [
        workLocationProvider.overrideWith(
          (ref) => WorkLocationNotifier(
            workLocationRepository: workLocationRepository,
          ),
        ),
        accountProvider.overrideWith(
          (ref) => AccountNotifier(
            accountRepository: accountRepository,
          ),
        ),
        reminderProvider.overrideWith(
          (ref) => ReminderNotifier(
            reminderRepository: reminderRepository,
          ),
        ),
        savingsGoalProvider.overrideWith(
          (ref) => SavingsGoalNotifier(
            savingsGoalRepository: savingsGoalRepository,
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Finanzas Personales',
        theme: TradingTheme.darkTheme,
        home: const TradingHomeScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/work-location-form': (context) => const WorkLocationFormScreen(userId: 1),
          '/work-locations-list': (context) => const WorkLocationsListScreen(userId: 1),
          '/savings-goals-list': (context) => const SavingsGoalListScreen(userId: 1),
        },
      ),
    );
  }
}
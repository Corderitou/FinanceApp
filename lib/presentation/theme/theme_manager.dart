import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemePreference();
  }

  static const String _themePrefKey = 'theme_mode';
  static const String _customColorPrefKey = 'custom_color_scheme';

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themePrefKey) ?? 'system';
      final themeMode = _themeModeFromString(themeModeString);
      state = themeMode;
    } catch (e) {
      print('Error loading theme preference: $e');
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, _themeModeToString(themeMode));
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  Future<void> setCustomColorScheme(ColorScheme colorScheme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_customColorPrefKey, _colorSchemeToString(colorScheme));
    } catch (e) {
      print('Error saving custom color scheme: $e');
    }
  }

  Future<ColorScheme?> getCustomColorScheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorSchemeString = prefs.getString(_customColorPrefKey);
      if (colorSchemeString != null) {
        return _colorSchemeFromString(colorSchemeString);
      }
    } catch (e) {
      print('Error loading custom color scheme: $e');
    }
    return null;
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _themeModeFromString(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _colorSchemeToString(ColorScheme colorScheme) {
    // Serialize color scheme to string
    return '${colorScheme.primary.value},'
        '${colorScheme.onPrimary.value},'
        '${colorScheme.secondary.value},'
        '${colorScheme.onSecondary.value},'
        '${colorScheme.surface.value},'
        '${colorScheme.onSurface.value}';
  }

  ColorScheme _colorSchemeFromString(String colorSchemeString) {
    // Deserialize color scheme from string
    final parts = colorSchemeString.split(',');
    if (parts.length >= 6) {
      return ColorScheme(
        primary: Color(int.parse(parts[0])),
        onPrimary: Color(int.parse(parts[1])),
        secondary: Color(int.parse(parts[2])),
        onSecondary: Color(int.parse(parts[3])),
        surface: Color(int.parse(parts[4])),
        onSurface: Color(int.parse(parts[5])),
        brightness: Brightness.light, // Default brightness
      );
    }
    // Return default color scheme if parsing fails
    return const ColorScheme.light();
  }
}

// Theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
      ),
    );
  }

  // Custom color schemes
  static final List<ColorScheme> predefinedColorSchemes = [
    ColorScheme.fromSeed(seedColor: Colors.blue),
    ColorScheme.fromSeed(seedColor: Colors.green),
    ColorScheme.fromSeed(seedColor: Colors.purple),
    ColorScheme.fromSeed(seedColor: Colors.orange),
    ColorScheme.fromSeed(seedColor: Colors.pink),
    ColorScheme.fromSeed(seedColor: Colors.teal),
  ];
}

// Theme toggle widget
class ThemeToggleWidget extends ConsumerWidget {
  const ThemeToggleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return PopupMenuButton<ThemeMode>(
      icon: const Icon(Icons.palette),
      onSelected: (ThemeMode mode) {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
        CheckedPopupMenuItem<ThemeMode>(
          value: ThemeMode.system,
          checked: themeMode == ThemeMode.system,
          child: const Text('System Default'),
        ),
        CheckedPopupMenuItem<ThemeMode>(
          value: ThemeMode.light,
          checked: themeMode == ThemeMode.light,
          child: const Text('Light Mode'),
        ),
        CheckedPopupMenuItem<ThemeMode>(
          value: ThemeMode.dark,
          checked: themeMode == ThemeMode.dark,
          child: const Text('Dark Mode'),
        ),
      ],
    );
  }
}

// Color scheme selector widget
class ColorSchemeSelector extends ConsumerWidget {
  const ColorSchemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Color Scheme'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: AppTheme.predefinedColorSchemes.length,
          itemBuilder: (context, index) {
            final colorScheme = AppTheme.predefinedColorSchemes[index];
            return _ColorSchemeOption(
              colorScheme: colorScheme,
              onTap: () {
                // Apply color scheme
                final themeNotifier = ref.read(themeModeProvider.notifier);
                themeNotifier.setCustomColorScheme(colorScheme);
                
                // Close the dialog
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}

class _ColorSchemeOption extends StatelessWidget {
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _ColorSchemeOption({
    Key? key,
    required this.colorScheme,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Preview of primary color
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(
                  Icons.palette,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            // Preview of secondary color
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.secondary,
              ),
              child: Center(
                child: Text(
                  'Preview',
                  style: TextStyle(
                    color: colorScheme.onSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            // Surface color preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Center(
                  child: Text(
                    'Surface',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Accessibility settings provider
final accessibilitySettingsProvider = StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>(
  (ref) => AccessibilitySettingsNotifier(),
);

class AccessibilitySettingsNotifier extends StateNotifier<AccessibilitySettings> {
  AccessibilitySettingsNotifier() : super(const AccessibilitySettings()) {
    _loadAccessibilitySettings();
  }

  static const String _highContrastKey = 'high_contrast';
  static const String _largerTextKey = 'larger_text';
  static const String _boldTextKey = 'bold_text';
  static const String _reduceMotionKey = 'reduce_motion';
  static const String _largerTouchTargetsKey = 'larger_touch_targets';

  Future<void> _loadAccessibilitySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = AccessibilitySettings(
        highContrast: prefs.getBool(_highContrastKey) ?? false,
        largerText: prefs.getBool(_largerTextKey) ?? false,
        boldText: prefs.getBool(_boldTextKey) ?? false,
        reduceMotion: prefs.getBool(_reduceMotionKey) ?? false,
        largerTouchTargets: prefs.getBool(_largerTouchTargetsKey) ?? false,
      );
    } catch (e) {
      print('Error loading accessibility settings: $e');
    }
  }

  Future<void> setHighContrast(bool value) async {
    state = state.copyWith(highContrast: value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_highContrastKey, value);
    } catch (e) {
      print('Error saving high contrast setting: $e');
    }
  }

  Future<void> setLargerText(bool value) async {
    state = state.copyWith(largerText: value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_largerTextKey, value);
    } catch (e) {
      print('Error saving larger text setting: $e');
    }
  }

  Future<void> setBoldText(bool value) async {
    state = state.copyWith(boldText: value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_boldTextKey, value);
    } catch (e) {
      print('Error saving bold text setting: $e');
    }
  }

  Future<void> setReduceMotion(bool value) async {
    state = state.copyWith(reduceMotion: value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reduceMotionKey, value);
    } catch (e) {
      print('Error saving reduce motion setting: $e');
    }
  }

  Future<void> setLargerTouchTargets(bool value) async {
    state = state.copyWith(largerTouchTargets: value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_largerTouchTargetsKey, value);
    } catch (e) {
      print('Error saving larger touch targets setting: $e');
    }
  }
}

class AccessibilitySettings {
  final bool highContrast;
  final bool largerText;
  final bool boldText;
  final bool reduceMotion;
  final bool largerTouchTargets;

  const AccessibilitySettings({
    this.highContrast = false,
    this.largerText = false,
    this.boldText = false,
    this.reduceMotion = false,
    this.largerTouchTargets = false,
  });

  AccessibilitySettings copyWith({
    bool? highContrast,
    bool? largerText,
    bool? boldText,
    bool? reduceMotion,
    bool? largerTouchTargets,
  }) {
    return AccessibilitySettings(
      highContrast: highContrast ?? this.highContrast,
      largerText: largerText ?? this.largerText,
      boldText: boldText ?? this.boldText,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccessibilitySettings &&
        other.highContrast == highContrast &&
        other.largerText == largerText &&
        other.boldText == boldText &&
        other.reduceMotion == reduceMotion &&
        other.largerTouchTargets == largerTouchTargets;
  }

  @override
  int get hashCode {
    return Object.hash(
      highContrast,
      largerText,
      boldText,
      reduceMotion,
      largerTouchTargets,
    );
  }
}

// Accessibility enhanced theme
class AccessibilityTheme {
  static ThemeData getEnhancedTheme(ThemeData baseTheme, AccessibilitySettings settings) {
    var theme = baseTheme;

    // Apply high contrast
    if (settings.highContrast) {
      theme = _applyHighContrast(theme);
    }

    // Apply larger text
    if (settings.largerText) {
      theme = _applyLargerText(theme);
    }

    // Apply bold text
    if (settings.boldText) {
      theme = _applyBoldText(theme);
    }

    return theme;
  }

  static ThemeData _applyHighContrast(ThemeData theme) {
    // Increase contrast ratio for better visibility
    return theme.copyWith(
      textTheme: theme.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      primaryTextTheme: theme.primaryTextTheme.apply(
        bodyColor: _ensureHighContrast(
          theme.primaryTextTheme.bodyMedium?.color ?? Colors.black,
          theme.colorScheme.primary,
        ),
      ),
      colorScheme: theme.colorScheme.copyWith(
        surface: Colors.white,
        onSurface: Colors.black,
        primary: _ensureHighContrast(theme.colorScheme.primary, Colors.white),
        onPrimary: _ensureHighContrast(theme.colorScheme.onPrimary, theme.colorScheme.primary),
      ),
    );
  }

  static ThemeData _applyLargerText(ThemeData theme) {
    // Scale up text sizes
    final textScaleFactor = 1.2;
    return theme.copyWith(
      textTheme: theme.textTheme.apply(
        bodyColor: theme.textTheme.bodyMedium?.color,
        displayColor: theme.textTheme.displayMedium?.color,
        fontSizeFactor: textScaleFactor,
      ),
    );
  }

  static ThemeData _applyBoldText(ThemeData theme) {
    // Make text bold
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        bodyLarge: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        bodyMedium: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        bodySmall: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        titleLarge: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        titleMedium: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        titleSmall: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  static Color _ensureHighContrast(Color foreground, Color background) {
    // Ensure minimum contrast ratio of 4.5:1 (WCAG AA standard)
    final contrastRatio = _calculateContrastRatio(foreground, background);
    if (contrastRatio >= 4.5) return foreground;

    // If contrast is too low, adjust the color
    final isLightBackground = background.computeLuminance() > 0.5;
    return isLightBackground ? Colors.black : Colors.white;
  }

  static double _calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _calculateRelativeLuminance(foreground);
    final bgLuminance = _calculateRelativeLuminance(background);

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _calculateRelativeLuminance(Color color) {
    final r = _linearizeColorChannel(color.red / 255.0);
    final g = _linearizeColorChannel(color.green / 255.0);
    final b = _linearizeColorChannel(color.blue / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearizeColorChannel(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }
}

// Accessible widget mixin
mixin AccessibleWidgetMixin<T extends StatefulWidget> on State<T> {
  AccessibilitySettings get accessibilitySettings {
    final container = ProviderScope.containerOf(context);
    return container.read(accessibilitySettingsProvider);
  }

  // Ensure minimum touch target size (48x48 dp recommended)
  Widget wrapWithMinimumTouchTarget(Widget child, {double? minWidth, double? minHeight}) {
    final settings = accessibilitySettings;
    
    if (!settings.largerTouchTargets) {
      return child;
    }

    return SizedBox(
      width: minWidth != null ? minWidth : 48.0,
      height: minHeight != null ? minHeight : 48.0,
      child: Center(child: child),
    );
  }

  // Add semantic labels for screen readers
  Widget addSemanticLabel(Widget child, String label, {String? hint}) {
    return Semantics(
      label: label,
      hint: hint,
      child: child,
    );
  }

  // Add reduced motion animation
  Widget addReducedMotionAnimation(Widget child, AnimationController controller) {
    final settings = accessibilitySettings;
    
    if (settings.reduceMotion) {
      // Skip animation completely
      controller.duration = Duration.zero;
      controller.forward();
      return child;
    }

    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        return child!;
      },
    );
  }
}

// Accessible button widget
class AccessibleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String? semanticsLabel;
  final EdgeInsets? padding;

  const AccessibleButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.semanticsLabel,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(accessibilitySettingsProvider);
        
        Widget button = ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: padding,
            minimumSize: settings.largerTouchTargets ? const Size(48, 48) : null,
          ),
          child: child,
        );

        // Add semantic label
        if (semanticsLabel != null) {
          button = Semantics(
            button: true,
            label: semanticsLabel,
            child: button,
          );
        }

        return button;
      },
    );
  }
}

// Accessible text widget
class AccessibleText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final String? semanticsLabel;
  final bool? excludeFromSemantics;

  const AccessibleText(
    this.data, {
    Key? key,
    this.style,
    this.textAlign,
    this.semanticsLabel,
    this.excludeFromSemantics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(accessibilitySettingsProvider);
        var textStyle = style;

        // Apply accessibility settings
        if (settings.largerText) {
          textStyle = (textStyle ?? const TextStyle()).copyWith(
            fontSize: (textStyle?.fontSize ?? 16) * 1.2,
          );
        }

        if (settings.boldText) {
          textStyle = (textStyle ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.bold,
          );
        }

        Widget textWidget = Text(
          data,
          style: textStyle,
          textAlign: textAlign,
          excludeFromSemantics: excludeFromSemantics ?? false,
        );

        // Add semantic label
        if (semanticsLabel != null) {
          textWidget = Semantics(
            label: semanticsLabel,
            child: textWidget,
          );
        }

        return textWidget;
      },
    );
  }
}

// Accessibility settings screen
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilitySettingsProvider);
    final notifier = ref.read(accessibilitySettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile.adaptive(
            title: const Text('High Contrast'),
            subtitle: const Text('Increase contrast for better visibility'),
            value: settings.highContrast,
            onChanged: notifier.setHighContrast,
          ),
          SwitchListTile.adaptive(
            title: const Text('Larger Text'),
            subtitle: const Text('Increase font size for better readability'),
            value: settings.largerText,
            onChanged: notifier.setLargerText,
          ),
          SwitchListTile.adaptive(
            title: const Text('Bold Text'),
            subtitle: const Text('Make text thicker for easier reading'),
            value: settings.boldText,
            onChanged: notifier.setBoldText,
          ),
          SwitchListTile.adaptive(
            title: const Text('Reduce Motion'),
            subtitle: const Text('Minimize animations and transitions'),
            value: settings.reduceMotion,
            onChanged: notifier.setReduceMotion,
          ),
          SwitchListTile.adaptive(
            title: const Text('Larger Touch Targets'),
            subtitle: const Text('Increase size of buttons and controls'),
            value: settings.largerTouchTargets,
            onChanged: notifier.setLargerTouchTargets,
          ),
        ],
      ),
    );
  }
}
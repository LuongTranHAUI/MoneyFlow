import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Material 3 Color Scheme - Modern Finance App Colors
  static const Color _primarySeed = Color(0xFF2E7D32); // Dollar green color
  
  // Custom semantic colors for financial app
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE57373);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color incomeColor = Color(0xFF43A047);
  static const Color expenseColor = Color(0xFFEF5350);
  
  // Create Material 3 color schemes with better contrast
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _primarySeed,
    brightness: Brightness.light,
  ).copyWith(
    // Custom adjustments for better visibility
    surface: const Color(0xFFFCFDF9),
    onSurface: const Color(0xFF1A1C19),
    surfaceContainer: const Color(0xFFF0F2ED),
    surfaceContainerHigh: const Color(0xFFEAEDE7),
    surfaceContainerHighest: const Color(0xFFE4E7E1),
  );

  // Enhanced Dark Color Scheme with Better Contrast
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _primarySeed,
    brightness: Brightness.dark,
  ).copyWith(
    // Dark background with green tint for better aesthetics
    surface: const Color(0xFF0D1F0F),
    onSurface: const Color(0xFFE1F5E4),
    
    // Elevated surfaces with green-tinted grays
    surfaceContainer: const Color(0xFF162318),
    surfaceContainerLow: const Color(0xFF0F1A11),
    surfaceContainerHigh: const Color(0xFF1D2F1F),
    surfaceContainerHighest: const Color(0xFF263A28),
    
    // Vibrant primary colors for dark mode
    primary: const Color(0xFF81C784), // Light green for dark mode
    onPrimary: const Color(0xFF003A02),
    primaryContainer: const Color(0xFF005005),
    onPrimaryContainer: const Color(0xFF9CFF9F),
    
    // Secondary colors with good contrast
    secondary: const Color(0xFFA5D6A7),
    onSecondary: const Color(0xFF003A03),
    secondaryContainer: const Color(0xFF1B5E20),
    onSecondaryContainer: const Color(0xFFC8E6C9),
    
    // Tertiary accent colors
    tertiary: const Color(0xFF66BB6A),
    onTertiary: const Color(0xFF003A04),
    tertiaryContainer: const Color(0xFF2E7D32),
    onTertiaryContainer: const Color(0xFFA5D6A7),
    
    // Error colors that pop in dark mode
    error: const Color(0xFFFF6B6B),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    
    // Outline colors for borders with green tint
    outline: const Color(0xFF527A54),
    outlineVariant: const Color(0xFF3A5A3C),
    
    // Inverse colors for special UI elements
    inverseSurface: const Color(0xFFE1F5E4),
    onInverseSurface: const Color(0xFF1D2F1F),
    inversePrimary: const Color(0xFF2E7D32),
    
    // Card and dialog backgrounds
    surfaceTint: const Color(0xFF81C784),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    brightness: Brightness.light,
    
    // System UI Overlay Style
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: _lightColorScheme.surface,
      foregroundColor: _lightColorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 3,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: _lightColorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: _lightColorScheme.surfaceContainer,
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _lightColorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 44),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 44),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightColorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _lightColorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _lightColorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _lightColorScheme.error,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _lightColorScheme.surfaceContainer,
      indicatorColor: _lightColorScheme.secondaryContainer,
      height: 80,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: _lightColorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(
          color: _lightColorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
    ),

    // FAB Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primaryContainer,
      foregroundColor: _lightColorScheme.onPrimaryContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: _lightColorScheme.surfaceContainerHigh,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _lightColorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      dragHandleColor: _lightColorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      dragHandleSize: const Size(32, 4),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: _lightColorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkColorScheme.surface,
    
    // System UI Overlay Style
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: _darkColorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    ),

    // Enhanced Card Theme for Dark Mode
    cardTheme: CardThemeData(
      color: _darkColorScheme.surfaceContainerHigh,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _darkColorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Dark Mode Button Themes with High Contrast
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkColorScheme.primary,
        foregroundColor: _darkColorScheme.onPrimary,
        disabledBackgroundColor: _darkColorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: _darkColorScheme.onSurface.withValues(alpha: 0.38),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 44),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.white.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withValues(alpha: 0.08);
          }
          return null;
        }),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _darkColorScheme.primary,
        foregroundColor: _darkColorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 44),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkColorScheme.primary,
        side: BorderSide(
          color: _darkColorScheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 44),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkColorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    // Dark Mode Input Decoration with Better Contrast
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkColorScheme.surfaceContainerHighest,
      hintStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant.withValues(alpha: 0.9),
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _darkColorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _darkColorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _darkColorScheme.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _darkColorScheme.error,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Dark Mode Navigation Bar with Better Visibility
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _darkColorScheme.surfaceContainer,
      indicatorColor: _darkColorScheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 80,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: _darkColorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(
          color: _darkColorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: _darkColorScheme.onPrimaryContainer,
            size: 24,
          );
        }
        return IconThemeData(
          color: _darkColorScheme.onSurfaceVariant,
          size: 24,
        );
      }),
    ),

    // Dark Mode FAB with Glow Effect
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primaryContainer,
      foregroundColor: _darkColorScheme.onPrimaryContainer,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Dark Mode List Tile
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      selectedTileColor: _darkColorScheme.primaryContainer.withValues(alpha: 0.2),
      selectedColor: _darkColorScheme.primary,
      iconColor: _darkColorScheme.onSurfaceVariant,
      textColor: _darkColorScheme.onSurface,
    ),

    // Dark Mode Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: _darkColorScheme.surfaceContainerHighest,
      selectedColor: _darkColorScheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
      side: BorderSide(
        color: _darkColorScheme.outline.withValues(alpha: 0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: TextStyle(
        color: _darkColorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),

    // Dark Mode Dialog with Better Contrast
    dialogTheme: DialogThemeData(
      backgroundColor: _darkColorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),

    // Dark Mode Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _darkColorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: _darkColorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      dragHandleColor: _darkColorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      dragHandleSize: const Size(32, 4),
    ),

    // Dark Mode Snackbar with High Contrast
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkColorScheme.inverseSurface,
      contentTextStyle: TextStyle(
        color: _darkColorScheme.onInverseSurface,
        fontWeight: FontWeight.w500,
      ),
      actionTextColor: _darkColorScheme.inversePrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Dark Mode Divider
    dividerTheme: DividerThemeData(
      color: _darkColorScheme.outlineVariant.withValues(alpha: 0.3),
      thickness: 1,
      space: 1,
    ),

    // Switch Theme for Dark Mode
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkColorScheme.primary;
        }
        return _darkColorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkColorScheme.primary.withValues(alpha: 0.3);
        }
        return _darkColorScheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkColorScheme.primary.withValues(alpha: 0.5);
        }
        return _darkColorScheme.outline.withValues(alpha: 0.3);
      }),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _darkColorScheme.primary,
      linearTrackColor: _darkColorScheme.surfaceContainerHighest,
      circularTrackColor: _darkColorScheme.surfaceContainerHighest,
    ),

    // Text Theme with Better Readability
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w300,
      ),
      displayMedium: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w300,
      ),
      displaySmall: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: _darkColorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: _darkColorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  // Helper method to get surface color with elevation for dark mode
  static Color getSurfaceColorWithElevation(
    BuildContext context,
    double elevation,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (theme.brightness == Brightness.light) {
      return colorScheme.surface;
    }
    
    // Material 3 dark theme elevation with pure black base
    // Higher elevation = lighter surface
    final double opacity = (elevation * 0.05).clamp(0.0, 1.0);
    return Color.lerp(
      colorScheme.surface,
      colorScheme.surfaceContainerHighest,
      opacity,
    )!;
  }
}
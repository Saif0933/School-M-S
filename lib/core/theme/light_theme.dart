import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Symbosys SMS — Light Theme
/// Clean, professional light theme
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LightTheme {
  LightTheme._();

  static ThemeData get theme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: Colors.white,
        tertiary: AppColors.accentCyan,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        onSurfaceVariant: AppColors.lightTextSecondary,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightDivider,
      ),

      scaffoldBackgroundColor: AppColors.lightBg,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.lightBorder),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.lightTextTertiary,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        prefixIconColor: AppColors.lightTextTertiary,
        suffixIconColor: AppColors.lightTextTertiary,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBg,
        selectedColor: AppColors.primarySurface,
        side: const BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.lightSurface,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.lightTextTertiary,
        indicatorColor: AppColors.primary,
        dividerColor: AppColors.lightDivider,
      ),

      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.lightBg),
        dataRowColor: WidgetStateProperty.all(Colors.transparent),
        headingTextStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.lightTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        dividerThickness: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.lightTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primarySurface;
          return AppColors.lightBorder;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        side: const BorderSide(color: AppColors.lightBorder, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(color: AppColors.lightTextPrimary),
        displayMedium: textTheme.displayMedium?.copyWith(color: AppColors.lightTextPrimary),
        displaySmall: textTheme.displaySmall?.copyWith(color: AppColors.lightTextPrimary),
        headlineLarge: textTheme.headlineLarge?.copyWith(color: AppColors.lightTextPrimary),
        headlineMedium: textTheme.headlineMedium?.copyWith(color: AppColors.lightTextPrimary),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: AppColors.lightTextPrimary),
        titleLarge: textTheme.titleLarge?.copyWith(color: AppColors.lightTextPrimary),
        titleMedium: textTheme.titleMedium?.copyWith(color: AppColors.lightTextPrimary),
        titleSmall: textTheme.titleSmall?.copyWith(color: AppColors.lightTextPrimary),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: AppColors.lightTextPrimary),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: AppColors.lightTextSecondary),
        bodySmall: textTheme.bodySmall?.copyWith(color: AppColors.lightTextTertiary),
        labelLarge: textTheme.labelLarge?.copyWith(color: AppColors.lightTextPrimary),
        labelMedium: textTheme.labelMedium?.copyWith(color: AppColors.lightTextSecondary),
        labelSmall: textTheme.labelSmall?.copyWith(color: AppColors.lightTextTertiary),
      ),
    );
  }
}

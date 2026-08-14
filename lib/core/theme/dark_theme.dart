import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Symbosys SMS — Dark Theme
/// Premium deep-navy glassmorphic dark theme
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class DarkTheme {
  DarkTheme._();

  static ThemeData get theme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.inter().fontFamily,

      // ─── Color Scheme ────────────────────────
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryDark,
        onSecondaryContainer: Colors.white,
        tertiary: AppColors.accentCyan,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkDivider,
      ),

      // ─── Scaffold ────────────────────────────
      scaffoldBackgroundColor: AppColors.darkBg,

      // ─── App Bar ─────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ─── Card ────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ─── Elevated Button ─────────────────────
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

      // ─── Outlined Button ─────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.darkBorder),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─── Text Button ─────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─── Input Decoration ────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
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
          color: AppColors.darkTextTertiary,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        prefixIconColor: AppColors.darkTextTertiary,
        suffixIconColor: AppColors.darkTextTertiary,
      ),

      // ─── Chip ────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        selectedColor: AppColors.primarySurface,
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),

      // ─── Divider ─────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // ─── Dialog ──────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ─── Bottom Sheet ────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // ─── Navigation Rail ─────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: const IconThemeData(color: AppColors.darkTextTertiary),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.darkTextTertiary,
        ),
      ),

      // ─── Drawer ──────────────────────────────
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
      ),

      // ─── Floating Action Button ──────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ─── Snack Bar ───────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── Tab Bar ─────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.darkTextTertiary,
        indicatorColor: AppColors.primary,
        dividerColor: AppColors.darkDivider,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelLarge,
      ),

      // ─── Data Table ──────────────────────────
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.darkCard),
        dataRowColor: WidgetStateProperty.all(Colors.transparent),
        headingTextStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        dividerThickness: 1,
      ),

      // ─── Tooltip ─────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkBorder),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),

      // ─── PopupMenu ───────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),

      // ─── Switch ──────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primarySurface;
          return AppColors.darkBorder;
        }),
      ),

      // ─── Checkbox ────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        side: const BorderSide(color: AppColors.darkBorder, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ─── Text Theme ──────────────────────────
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: textTheme.displayMedium?.copyWith(color: AppColors.darkTextPrimary),
        displaySmall: textTheme.displaySmall?.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge: textTheme.headlineLarge?.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium: textTheme.headlineMedium?.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: textTheme.titleLarge?.copyWith(color: AppColors.darkTextPrimary),
        titleMedium: textTheme.titleMedium?.copyWith(color: AppColors.darkTextPrimary),
        titleSmall: textTheme.titleSmall?.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary),
        bodySmall: textTheme.bodySmall?.copyWith(color: AppColors.darkTextTertiary),
        labelLarge: textTheme.labelLarge?.copyWith(color: AppColors.darkTextPrimary),
        labelMedium: textTheme.labelMedium?.copyWith(color: AppColors.darkTextSecondary),
        labelSmall: textTheme.labelSmall?.copyWith(color: AppColors.darkTextTertiary),
      ),
    );
  }
}

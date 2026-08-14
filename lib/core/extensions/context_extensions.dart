import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// BuildContext Extensions for theme, navigation,
/// responsive layout, and common patterns
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
extension ContextExtensions on BuildContext {
  // ─── Theme shortcuts ─────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ─── Media Query ─────────────────────────────
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  double get bottomPadding => padding.bottom;
  double get topPadding => padding.top;

  // ─── Responsive Breakpoints ──────────────────
  bool get isMobile => screenWidth < AppSpacing.breakpointMobile;
  bool get isTablet => screenWidth >= AppSpacing.breakpointMobile && screenWidth < AppSpacing.breakpointDesktop;
  bool get isDesktop => screenWidth >= AppSpacing.breakpointDesktop;
  bool get isWide => screenWidth >= AppSpacing.breakpointWide;

  /// Returns responsive value based on screen size
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    if (isWide && wide != null) return wide;
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Page padding based on screen size
  double get pagePadding => responsive(
        mobile: AppSpacing.pagePaddingMobile,
        tablet: AppSpacing.pagePaddingTablet,
        desktop: AppSpacing.pagePaddingDesktop,
      );

  // ─── Navigation ──────────────────────────────
  NavigatorState get navigator => Navigator.of(this);

  void pop<T>([T? result]) => navigator.pop(result);

  // ─── Snackbar ────────────────────────────────
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  void showSuccessSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF06D6A0),
      ),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Symbosys SMS — Spacing & Sizing System
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppSpacing {
  AppSpacing._();

  // ─── Base Spacing (4px grid) ─────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // ─── Page Padding ────────────────────────────
  static const double pagePaddingMobile = 16.0;
  static const double pagePaddingTablet = 24.0;
  static const double pagePaddingDesktop = 32.0;

  // ─── Card ────────────────────────────────────
  static const double cardPadding = 20.0;
  static const double cardPaddingLarge = 24.0;
  static const double cardRadius = 16.0;
  static const double cardRadiusSmall = 12.0;
  static const double cardRadiusLarge = 20.0;

  // ─── Button ──────────────────────────────────
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonRadius = 12.0;
  static const double buttonPaddingH = 24.0;

  // ─── Input ───────────────────────────────────
  static const double inputHeight = 52.0;
  static const double inputRadius = 12.0;
  static const double inputPaddingH = 16.0;

  // ─── Sidebar ─────────────────────────────────
  static const double sidebarWidth = 280.0;
  static const double sidebarCollapsedWidth = 72.0;
  static const double sidebarItemHeight = 44.0;
  static const double sidebarPadding = 16.0;

  // ─── Top Bar ─────────────────────────────────
  static const double topBarHeight = 64.0;

  // ─── Avatar ──────────────────────────────────
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 40.0;
  static const double avatarLarge = 56.0;
  static const double avatarXLarge = 80.0;

  // ─── Icon ────────────────────────────────────
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconDefault = 24.0;
  static const double iconLarge = 28.0;

  // ─── Elevation ───────────────────────────────
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationMax = 16.0;

  // ─── Animation Durations ─────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);
  static const Duration animVerySlow = Duration(milliseconds: 600);

  // ─── Responsive Breakpoints ──────────────────
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 900;
  static const double breakpointDesktop = 1200;
  static const double breakpointWide = 1440;
}

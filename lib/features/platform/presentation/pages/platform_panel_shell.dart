import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../domain/entities/platform_organization_entity.dart';
import '../../providers.dart';
import '../widgets/organization_onboarding_modal.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Platform Panel Shell — SaaS Owner Control Center
/// Features Sidebar Navigation with 4 Core Modules:
/// 1. Dashboard (Analytics & Ecosystem Overview)
/// 2. Organization Onboarding (New Tenant Setup)
/// 3. Company (Organizations Directory & Status)
/// 4. Subscription (SaaS Plan Tiers & Billing Matrix)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class PlatformPanelShell extends ConsumerStatefulWidget {
  const PlatformPanelShell({super.key});

  @override
  ConsumerState<PlatformPanelShell> createState() =>
      _PlatformPanelShellState();
}

class _PlatformPanelShellState extends ConsumerState<PlatformPanelShell> {
  String _selectedNavId = 'dashboard';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final currentUser = ref.watch(currentUserProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 950;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      drawer: !isDesktop ? Drawer(child: _buildSidebar(isDark, currentUser?.name ?? 'Platform Admin')) : null,
      body: Row(
        children: [
          // ─── Left Sidebar Navigation (Desktop) ─────────────
          if (isDesktop)
            SizedBox(
              width: 270,
              child: _buildSidebar(isDark, currentUser?.name ?? 'Platform Admin'),
            ),

          // ─── Main Content Area ─────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                _buildTopHeader(
                  context: context,
                  ref: ref,
                  isDark: isDark,
                  isDesktop: isDesktop,
                  adminName: currentUser?.name ?? 'Platform Admin',
                ),

                // Main Page View Body
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppSpacing.animNormal,
                    child: _buildSelectedPage(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SIDEBAR NAVIGATION COMPONENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSidebar(bool isDark, String adminName) {
    final navItems = [
      {
        'id': 'dashboard',
        'label': 'Dashboard',
        'subtitle': 'Platform Analytics & Stats',
        'icon': Icons.space_dashboard_rounded,
        'badge': null,
      },
      {
        'id': 'onboarding',
        'label': 'Organization Onboarding',
        'subtitle': 'Register New School Tenants',
        'icon': Icons.domain_add_rounded,
        'badge': 'NEW',
      },
      {
        'id': 'company',
        'label': 'Company Directory',
        'subtitle': 'Tenants, Admins & Limits',
        'icon': Icons.apartment_rounded,
        'badge': null,
      },
      {
        'id': 'subscription',
        'label': 'Subscription Matrix',
        'subtitle': 'SaaS Plan Tiers & Billing',
        'icon': Icons.stars_rounded,
        'badge': 'PRO',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(4, 0),
          ),
        ],
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        children: [
          // Sidebar Header Brand
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Symbosys SaaS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PLATFORM PANEL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sidebar Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    'MAIN CONTROL MODULES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: isDark
                          ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                          : AppColors.lightTextSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                for (final item in navItems) ...[
                  _buildSidebarNavItem(
                    id: item['id'] as String,
                    label: item['label'] as String,
                    subtitle: item['subtitle'] as String,
                    icon: item['icon'] as IconData,
                    badge: item['badge'] as String?,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),

          // Sidebar Footer Admin Profile & Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : AppColors.lightBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: const Text(
                      'P',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          adminName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'platformadmin@symbosys.com',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.redAccent, size: 20),
                    tooltip: 'Logout Platform Admin',
                    onPressed: () {
                      ref.read(authStateProvider.notifier).logout();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required String id,
    required String label,
    required String subtitle,
    required IconData icon,
    String? badge,
    required bool isDark,
  }) {
    final isSelected = _selectedNavId == id;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedNavId = id;
          });
          if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Navigator.of(context).pop();
          }
        },
        child: AnimatedContainer(
          duration: AppSpacing.animFast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.darkBg
                          : AppColors.lightBg),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary)
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                            : AppColors.lightTextSecondary.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TOP BAR HEADER COMPONENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildTopHeader({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required bool isDesktop,
    required String adminName,
  }) {
    final pageTitles = {
      'dashboard': 'Platform SaaS Dashboard',
      'onboarding': 'Organization Onboarding Hub',
      'company': 'Company & Tenant Directory',
      'subscription': 'SaaS Subscription Matrix',
    };

    final pageSubtitles = {
      'dashboard': 'Ecosystem metrics, MRR revenue & multi-tenant stats',
      'onboarding': 'Onboard new school organizations & provision plans',
      'company': 'Manage all registered tenant organizations & capacity limits',
      'subscription': 'Plan tiers (Basic, Standard, Premium, Enterprise) & billing',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Mobile Menu Toggle Button
            if (!isDesktop) ...[
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              const SizedBox(width: 8),
            ],

            // Active Page Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pageTitles[_selectedNavId] ?? 'Platform Control Panel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    pageSubtitles[_selectedNavId] ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Onboard Quick Action Button
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const OrganizationOnboardingModal(),
                );
              },
              icon: const Icon(Icons.add_business_rounded, size: 16),
              label: const Text(
                'Onboard Org',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Theme Toggle Button
            IconButton(
              onPressed: () =>
                  ref.read(themeModeProvider.notifier).toggleTheme(),
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              tooltip: 'Toggle Theme',
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PAGE ROUTER SWITCHER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSelectedPage(bool isDark) {
    switch (_selectedNavId) {
      case 'onboarding':
        return _buildOnboardingView(isDark);
      case 'company':
        return _buildCompanyView(isDark);
      case 'subscription':
        return _buildSubscriptionView(isDark);
      case 'dashboard':
      default:
        return _buildDashboardView(isDark);
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. DASHBOARD VIEW
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildDashboardView(bool isDark) {
    final orgs = ref.watch(platformOrganizationsProvider);
    final totalMRR = orgs.fold<double>(0, (sum, item) => sum + item.monthlyFee);
    final totalBranches = orgs.fold<int>(0, (sum, item) => sum + item.branchCount);
    final totalStudents = orgs.fold<int>(0, (sum, item) => sum + item.studentCount);

    final basicCount =
        orgs.where((o) => o.subscriptionTier == SubscriptionTier.basic).length;
    final standardCount = orgs
        .where((o) => o.subscriptionTier == SubscriptionTier.standard)
        .length;
    final premiumCount = orgs
        .where((o) => o.subscriptionTier == SubscriptionTier.premium)
        .length;
    final enterpriseCount = orgs
        .where((o) => o.subscriptionTier == SubscriptionTier.enterprise)
        .length;

    return SingleChildScrollView(
      key: const ValueKey('dashboard'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Cards Row
          _buildAnalyticsCards(
            isDark: isDark,
            totalOrgs: orgs.length,
            totalMRR: totalMRR,
            totalBranches: totalBranches,
            totalStudents: totalStudents,
            basicCount: basicCount,
            standardCount: standardCount,
            premiumCount: premiumCount,
            enterpriseCount: enterpriseCount,
          ),
          const SizedBox(height: 24),

          // Dashboard Widgets: Tier Breakdown & Activity Stream
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tier Distribution Card
                  Expanded(
                    flex: isWide ? 6 : 0,
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'SaaS Subscription Plan Distribution',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() => _selectedNavId = 'subscription');
                                },
                                child: const Text('View Pricing Matrix →'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildTierDistributionBar('Basic Plan', basicCount, orgs.length, const Color(0xFF3B82F6), isDark),
                          const SizedBox(height: 12),
                          _buildTierDistributionBar('Standard Plan', standardCount, orgs.length, const Color(0xFF10B981), isDark),
                          const SizedBox(height: 12),
                          _buildTierDistributionBar('Premium Plan', premiumCount, orgs.length, const Color(0xFF8B5CF6), isDark),
                          const SizedBox(height: 12),
                          _buildTierDistributionBar('Enterprise Plan', enterpriseCount, orgs.length, const Color(0xFFF59E0B), isDark),
                        ],
                      ),
                    ),
                  ),
                  if (isWide) const SizedBox(width: 20) else const SizedBox(height: 20),

                  // Recent Activity Log Card
                  Expanded(
                    flex: isWide ? 5 : 0,
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Platform Activities',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildActivityItem('Sunrise Education Trust upgraded to Premium Plan', '2 hours ago', Icons.arrow_upward_rounded, isDark),
                          _buildActivityItem('Zenith Global Schools renewed Annual Enterprise Plan', '1 day ago', Icons.autorenew_rounded, isDark),
                          _buildActivityItem('Harmony Public School Trust started 30-day Trial', '3 days ago', Icons.new_releases_rounded, isDark),
                          _buildActivityItem('Vidya Niketan Academy added 1 new branch', '5 days ago', Icons.add_circle_outline_rounded, isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards({
    required bool isDark,
    required int totalOrgs,
    required double totalMRR,
    required int totalBranches,
    required int totalStudents,
    required int basicCount,
    required int standardCount,
    required int premiumCount,
    required int enterpriseCount,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        final cards = [
          _buildMetricTile(
            title: 'Onboarded Organizations',
            value: '$totalOrgs Tenants',
            subtitle: 'Active SaaS School Trusts',
            icon: Icons.account_balance_rounded,
            gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
            isDark: isDark,
          ),
          _buildMetricTile(
            title: 'Monthly Recurring Revenue',
            value: '\$${totalMRR.toStringAsFixed(0)}/mo',
            subtitle: 'MRR across active plans',
            icon: Icons.monetization_on_rounded,
            gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF047857)]),
            isDark: isDark,
          ),
          _buildMetricTile(
            title: 'Total Multi-Tenant Network',
            value: '$totalBranches Branches',
            subtitle: '$totalStudents active students',
            icon: Icons.hub_rounded,
            gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
            isDark: isDark,
          ),
          _buildMetricTile(
            title: 'Subscription Breakdown',
            value: '$basicCount Basic • $standardCount Std',
            subtitle: '$premiumCount Prem • $enterpriseCount Ent',
            icon: Icons.stars_rounded,
            gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
            isDark: isDark,
          ),
        ];

        if (isDesktop) {
          return Row(
            children: cards
                .map((c) => Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: c,
                    )))
                .toList(),
          );
        } else {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map((c) => SizedBox(width: (constraints.maxWidth - 12) / 2, child: c))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierDistributionBar(
    String label,
    int count,
    int total,
    Color color,
    bool isDark,
  ) {
    final ratio = total == 0 ? 0.0 : (count / total);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            Text(
              '$count (${(ratio * 100).toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. ORGANIZATION ONBOARDING VIEW
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildOnboardingView(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('onboarding'),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: GlassCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.domain_add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Onboard New School Organization',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Provision a brand new tenant organization with custom subscription tiers',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              const OrganizationOnboardingModal(),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Open Wizard Modal'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 20),

                Text(
                  'Quick Onboarding Workspace Instructions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),

                _buildOnboardingStep(
                  step: '1',
                  title: 'Select Subscription Plan Tier',
                  desc: 'Choose from Basic, Standard, Premium, or Enterprise based on branch and student limits.',
                  isDark: isDark,
                ),
                _buildOnboardingStep(
                  step: '2',
                  title: 'Configure Super Admin Credentials',
                  desc: 'Set the primary Organization Admin full name and official email address for initial login.',
                  isDark: isDark,
                ),
                _buildOnboardingStep(
                  step: '3',
                  title: 'Provision Headquarters & Capacity Limits',
                  desc: 'Set max branch limits, max student seats, address, and billing frequency (Yearly/Monthly).',
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const OrganizationOnboardingModal(),
                      );
                    },
                    icon: const Icon(Icons.domain_add_rounded, size: 20),
                    label: const Text(
                      'Launch Onboarding Wizard',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingStep({
    required String step,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Text(
              step,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. COMPANY DIRECTORY VIEW
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildCompanyView(bool isDark) {
    final filteredOrgs = ref.watch(filteredPlatformOrganizationsProvider);
    final activeTierFilter = ref.watch(platformTierFilterProvider);

    return SingleChildScrollView(
      key: const ValueKey('company'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Action Bar
          _buildFilterAndActionBar(context, ref, isDark, activeTierFilter),
          const SizedBox(height: 20),

          // Company Grid
          if (filteredOrgs.isEmpty)
            _buildEmptyState(isDark)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100
                    ? 3
                    : (constraints.maxWidth > 700 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    mainAxisExtent: 310,
                  ),
                  itemCount: filteredOrgs.length,
                  itemBuilder: (context, index) {
                    final org = filteredOrgs[index];
                    return _buildOrganizationCard(context, ref, isDark, org);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. SUBSCRIPTION MATRIX VIEW
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSubscriptionView(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('subscription'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SaaS Subscription Plan Matrix & Pricing Tiers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Manage tier features, branch/student limits, and tenant subscription billing',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pricing Tier Cards Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final tierCards = SubscriptionTier.values.map((tier) {
                return _buildPricingTierCard(tier, isDark);
              }).toList();

              if (isWide) {
                return Row(
                  children: tierCards
                      .map((c) => Expanded(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: c,
                          )))
                      .toList(),
                );
              } else {
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: tierCards
                      .map((c) => SizedBox(
                          width: (constraints.maxWidth - 14) / 2, child: c))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTierCard(SubscriptionTier tier, bool isDark) {
    Color tierColor;
    switch (tier) {
      case SubscriptionTier.basic:
        tierColor = const Color(0xFF3B82F6);
        break;
      case SubscriptionTier.standard:
        tierColor = const Color(0xFF10B981);
        break;
      case SubscriptionTier.premium:
        tierColor = const Color(0xFF8B5CF6);
        break;
      case SubscriptionTier.enterprise:
        tierColor = const Color(0xFFF59E0B);
        break;
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tierColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              tier.label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: tierColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '\$${tier.monthlyPrice.toInt()}/mo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          Text(
            tier.description,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          _buildTierFeatureItem('Up to ${tier.maxBranches} Branch(es)', isDark),
          _buildTierFeatureItem('Up to ${tier.maxStudents} Students', isDark),
          _buildTierFeatureItem('Multi-Role Access Control', isDark),
          _buildTierFeatureItem('Real-Time Analytics & Reports', isDark),
        ],
      ),
    );
  }

  Widget _buildTierFeatureItem(String feature, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 16, color: AppColors.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SHARED FILTER & ACTION BAR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildFilterAndActionBar(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    SubscriptionTier? activeTierFilter,
  ) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          // Filter Chips Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Directory:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  ref: ref,
                  label: 'All Plans',
                  isSelected: activeTierFilter == null,
                  onTap: () =>
                      ref.read(platformTierFilterProvider.notifier).state = null,
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                for (final tier in SubscriptionTier.values) ...[
                  _buildFilterChip(
                    ref: ref,
                    label: tier.label,
                    isSelected: activeTierFilter == tier,
                    onTap: () =>
                        ref.read(platformTierFilterProvider.notifier).state = tier,
                    isDark: isDark,
                    tier: tier,
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),

          // Search Field
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: TextField(
              onChanged: (val) =>
                  ref.read(platformSearchQueryProvider.notifier).state = val,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search org, code, email...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: isDark ? AppColors.darkBg : AppColors.lightBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required WidgetRef ref,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    SubscriptionTier? tier,
  }) {
    Color activeColor = AppColors.primary;
    if (tier != null) {
      switch (tier) {
        case SubscriptionTier.basic:
          activeColor = const Color(0xFF3B82F6);
          break;
        case SubscriptionTier.standard:
          activeColor = const Color(0xFF10B981);
          break;
        case SubscriptionTier.premium:
          activeColor = const Color(0xFF8B5CF6);
          break;
        case SubscriptionTier.enterprise:
          activeColor = const Color(0xFFF59E0B);
          break;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? AppColors.darkBg : AppColors.lightBg),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationCard(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    PlatformOrganizationEntity org,
  ) {
    Color tierColor;
    switch (org.subscriptionTier) {
      case SubscriptionTier.basic:
        tierColor = const Color(0xFF3B82F6);
        break;
      case SubscriptionTier.standard:
        tierColor = const Color(0xFF10B981);
        break;
      case SubscriptionTier.premium:
        tierColor = const Color(0xFF8B5CF6);
        break;
      case SubscriptionTier.enterprise:
        tierColor = const Color(0xFFF59E0B);
        break;
    }

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, Code & Plan Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tierColor.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.school_rounded, color: tierColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      org.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${org.code} • ${org.address}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (val) =>
                    _handleCardAction(context, ref, org, val),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change_plan',
                    child: Row(
                      children: [
                        Icon(Icons.published_with_changes_rounded, size: 18),
                        SizedBox(width: 10),
                        Text('Change Subscription Plan'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'extend_renewal',
                    child: Row(
                      children: [
                        Icon(Icons.event_repeat_rounded, size: 18),
                        SizedBox(width: 10),
                        Text('Extend Renewal Date'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: Row(
                      children: [
                        Icon(
                          org.status == 'suspended'
                              ? Icons.play_circle_outline_rounded
                              : Icons.pause_circle_outline_rounded,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(org.status == 'suspended'
                            ? 'Activate Organization'
                            : 'Suspend Organization'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Plan Badge & Monthly Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tierColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, color: tierColor, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${org.subscriptionTier.label.toUpperCase()} PLAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: tierColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${org.monthlyFee.toInt()}/mo (${org.billingCycle})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Super Admin Details
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org.superAdminName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        org.superAdminEmail,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Usage & Limits Progress Bars
          _buildUsageBar(
            label: 'Branches',
            current: org.branchCount,
            max: org.maxBranches,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _buildUsageBar(
            label: 'Students',
            current: org.studentCount,
            max: org.maxStudents,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Footer: Status & Renewal Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: org.status == 'active'
                          ? Colors.green
                          : (org.status == 'trial'
                              ? Colors.orange
                              : Colors.red),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    org.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: org.status == 'active'
                          ? Colors.green
                          : (org.status == 'trial'
                              ? Colors.orange
                              : Colors.red),
                    ),
                  ),
                ],
              ),
              Text(
                'Renews: ${_formatDate(org.renewalDate)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBar({
    required String label,
    required int current,
    required int max,
    required bool isDark,
  }) {
    final ratio = (max == 0 ? 0.0 : (current / max)).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label Allocation',
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              '$current / $max',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 4,
            backgroundColor:
                isDark ? AppColors.darkBorder : AppColors.lightBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  void _handleCardAction(
    BuildContext context,
    WidgetRef ref,
    PlatformOrganizationEntity org,
    String action,
  ) {
    if (action == 'change_plan') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Change Subscription Plan — ${org.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: SubscriptionTier.values.map((tier) {
              final isCurrent = org.subscriptionTier == tier;
              return ListTile(
                title: Text('${tier.label} Plan (\$${tier.monthlyPrice.toInt()}/mo)'),
                subtitle: Text(
                    'Up to ${tier.maxBranches} Branches, ${tier.maxStudents} Students'),
                trailing: isCurrent
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref
                      .read(platformOrganizationsProvider.notifier)
                      .updateSubscriptionPlan(org.id, tier);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ),
      );
    } else if (action == 'extend_renewal') {
      ref
          .read(platformOrganizationsProvider.notifier)
          .extendSubscriptionValidity(org.id, 12);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Subscription for "${org.name}" extended by 12 months!'),
        ),
      );
    } else if (action == 'toggle_status') {
      final newStatus = org.status == 'suspended' ? 'active' : 'suspended';
      ref
          .read(platformOrganizationsProvider.notifier)
          .updateOrganizationStatus(org.id, newStatus);
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 14),
            Text(
              'No organizations match the selected criteria',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

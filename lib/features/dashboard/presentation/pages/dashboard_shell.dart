import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/enums/enums.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../../shared/widgets/layout/sidebar_navigation.dart';
import '../../../../shared/widgets/layout/responsive_scaffold.dart';
import '../../../auth/providers.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../organization/presentation/pages/organization_management_page.dart';
import '../../../branch/presentation/pages/branch_management_page.dart';
import '../../../subscription/presentation/pages/subscription_management_page.dart';
import '../../../academic/presentation/pages/department_class_section_page.dart';
import '../../../academic/presentation/pages/timetable_management_page.dart';
import '../../../student/presentation/pages/student_management_page.dart';
import '../../../staff/presentation/pages/staff_management_page.dart';
import '../../../academic/presentation/pages/attendance_management_page.dart';
import '../../../academic/presentation/pages/exam_management_page.dart';
import '../../../finance/presentation/pages/fees_management_page.dart';
import '../../../library/presentation/pages/library_management_page.dart';
import '../../../transport/presentation/pages/transport_management_page.dart';
import '../../../hostel/presentation/pages/hostel_management_page.dart';
import '../../../communication/presentation/pages/communication_management_page.dart';
import '../../../parent/presentation/pages/parent_portal_page.dart';
import '../../../student/presentation/pages/admissions_page.dart';
import '../../../staff/presentation/pages/hr_payroll_page.dart';
import '../../../inventory/presentation/pages/inventory_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../mobile/presentation/pages/mobile_page.dart';
import '../../../lms/presentation/pages/lms_page.dart';
import '../../../certificates/presentation/pages/certificates_page.dart';
import '../../../events/presentation/pages/events_page.dart';
import '../../../homework/presentation/pages/homework_page.dart';
import '../../../notices/presentation/pages/notices_page.dart';
import '../../../security/presentation/pages/security_page.dart';
import '../../../leave/presentation/pages/leave_page.dart';
import '../../../academic/providers.dart';
import '../../../organization/providers.dart';
import '../../../library/providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Dashboard Shell — Main app shell after login
/// Contains sidebar navigation and routes to all modules
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  String _selectedNavId = 'dashboard';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    if (user == null) return const SizedBox.shrink();

    return ResponsiveScaffold(
      title: _getTitle(),
      breadcrumbs: _getBreadcrumbs(),
      sidebarItems: _buildSidebarItems(user.role),
      selectedItemId: _selectedNavId,
      onItemSelected: (id) => setState(() => _selectedNavId = id),
      user: user,
      isDarkMode: isDark,
      onThemeToggle: () => ref.read(themeModeProvider.notifier).toggleTheme(),
      onBranchChanged: (branchId) {
        ref.read(authStateProvider.notifier).switchBranch(branchId);
      },
      onLogout: () => ref.read(authStateProvider.notifier).logout(),
      body: AnimatedSwitcher(
        duration: AppSpacing.animNormal,
        child: _buildSelectedPage(user),
      ),
    );
  }

  String _getTitle() {
    final titles = {
      'dashboard': 'Dashboard',
      'organization': 'Organization Management',
      'branches': 'Branch Management',
      'departments': 'Departments & Classes',
      'students': 'Student Management',
      'staff': 'Staff & Teachers',
      'timetable': 'Timetable & Scheduling',
      'attendance': 'Attendance Management',
      'fees': 'Fee & Finance',
      'examinations': 'Examinations & Grading',
      'library': 'Library Management',
      'transport': 'Transport Management',
      'hostel': 'Hostel Management',
      'communication': 'Communication',
      'admissions': 'Online Admissions',
      'hr_payroll': 'HR & Payroll',
      'inventory': 'Inventory & Assets',
      'reports': 'Reports & Analytics',
      'lms': 'Online Classes & LMS',
      'certificates': 'Certificates & ID Cards',
      'events': 'Events & Calendar',
      'homework': 'Homework & Assignments',
      'notice_board': 'Notice Board',
      'visitor_security': 'Visitor & Security',
      'leave': 'Leave & Gate Pass',
      'canteen': 'Canteen Management',
      'alumni': 'Alumni Management',
      'health': 'Health & Medical',
      'subscription': 'Subscription & Billing',
      'settings': 'Settings',
    };
    return titles[_selectedNavId] ?? 'Dashboard';
  }

  List<String> _getBreadcrumbs() {
    final user = ref.read(currentUserProvider);
    return [
      user?.organizationName ?? 'Organization',
      user?.activeBranch?.branchCode ?? 'Branch',
      _getTitle(),
    ];
  }

  Widget _buildSelectedPage(UserEntity user) {
    switch (_selectedNavId) {
      case 'dashboard':
        if (user.role == UserRole.parent) {
          return const ParentPortalPage(key: ValueKey('parent_portal'));
        }
        return _DashboardOverview(key: const ValueKey('dashboard'), user: user);
      case 'parent_portal':
        return const ParentPortalPage(key: ValueKey('parent_portal'));
      case 'organization':
        return const OrganizationManagementPage(key: ValueKey('organization'));
      case 'branches':
        return const BranchManagementPage(key: ValueKey('branches'));
      case 'departments':
        return const DepartmentClassSectionPage(key: ValueKey('departments'));
      case 'students':
        return const StudentManagementPage(key: ValueKey('students'));
      case 'staff':
        return const StaffManagementPage(key: ValueKey('staff'));
      case 'subscription':
        return const SubscriptionManagementPage(key: ValueKey('subscription'));
      case 'timetable':
        return const TimetableManagementPage(key: ValueKey('timetable'));
      case 'attendance':
        return const AttendanceManagementPage(key: ValueKey('attendance'));
      case 'fees':
        return const FeesManagementPage(key: ValueKey('fees'));
      case 'examinations':
        return const ExamManagementPage(key: ValueKey('examinations'));
      case 'library':
        return const LibraryManagementPage(key: ValueKey('library'));
      case 'transport':
        return const TransportManagementPage(key: ValueKey('transport'));
      case 'hostel':
        return const HostelManagementPage(key: ValueKey('hostel'));
      case 'communication':
        return const CommunicationManagementPage(key: ValueKey('communication'));
      case 'admissions':
        return const AdmissionsManagementPage(key: ValueKey('admissions'));
      case 'hr_payroll':
        return const HRPayrollPage(key: ValueKey('hr_payroll'));
      case 'inventory':
        return const InventoryManagementPage(key: ValueKey('inventory'));
      case 'reports':
        return const ReportsAnalyticsPage(key: ValueKey('reports'));
      case 'mobile':
        return const MobileFeaturesPage(key: ValueKey('mobile'));
      case 'lms':
        return const LMSManagementPage(key: ValueKey('lms'));
      case 'certificates':
        return const CertificatesPage(key: ValueKey('certificates'));
      case 'events':
        return const EventsCalendarPage(key: ValueKey('events'));
      case 'homework':
        return const HomeworkManagementPage(key: ValueKey('homework'));
      case 'notices':
        return const NoticeBoardPage(key: ValueKey('notices'));
      case 'security':
        return const VisitorSecurityPage(key: ValueKey('security'));
      case 'leave':
        return const LeaveManagementPage(key: ValueKey('leave'));
      default:
        return _ModulePlaceholder(
          key: ValueKey(_selectedNavId),
          moduleId: _selectedNavId,
          title: _getTitle(),
        );
    }
  }

  List<SidebarItem> _buildSidebarItems(UserRole role) {
    if (role == UserRole.parent) {
      return const [
        SidebarItem(
          id: 'dashboard',
          label: 'Parent Portal',
          icon: Icons.family_restroom_outlined,
          activeIcon: Icons.family_restroom_rounded,
        ),
        SidebarItem(
          id: 'communication',
          label: 'School Chat',
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble_rounded,
          badge: '2',
        ),
      ];
    }

    final items = <SidebarItem>[
      const SidebarItem(
        id: 'dashboard',
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
      ),
    ];

    // Organization-level items (Super Admin only)
    if (role.isOrgLevel) {
      items.addAll([
        const SidebarItem(
          id: 'organization',
          label: 'Organization',
          icon: Icons.business_outlined,
          activeIcon: Icons.business_rounded,
        ),
        const SidebarItem(
          id: 'branches',
          label: 'Branches',
          icon: Icons.account_tree_outlined,
          activeIcon: Icons.account_tree_rounded,
          badge: '3',
        ),
        const SidebarItem(
          id: 'subscription',
          label: 'Subscription',
          icon: Icons.card_membership_outlined,
          activeIcon: Icons.card_membership_rounded,
        ),
      ]);
    }

    // Academic
    items.add(
      SidebarItem(
        id: 'academic_group',
        label: 'Academics',
        icon: Icons.school_outlined,
        children: [
          const SidebarItem(
            id: 'departments',
            label: 'Departments & Classes',
            icon: Icons.category_outlined,
            activeIcon: Icons.category_rounded,
          ),
          const SidebarItem(
            id: 'timetable',
            label: 'Timetable',
            icon: Icons.calendar_view_week_outlined,
            activeIcon: Icons.calendar_view_week_rounded,
          ),
          const SidebarItem(
            id: 'examinations',
            label: 'Examinations',
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
          ),
          const SidebarItem(
            id: 'library',
            label: 'Library Catalog',
            icon: Icons.local_library_outlined,
            activeIcon: Icons.local_library_rounded,
          ),
          const SidebarItem(
            id: 'homework',
            label: 'Homework',
            icon: Icons.edit_note_outlined,
            activeIcon: Icons.edit_note_rounded,
          ),
          const SidebarItem(
            id: 'lms',
            label: 'Online Classes',
            icon: Icons.play_circle_outline,
            activeIcon: Icons.play_circle_rounded,
          ),
        ],
      ),
    );

    // People
    items.add(
      SidebarItem(
        id: 'people_group',
        label: 'People',
        icon: Icons.people_outline,
        children: [
          const SidebarItem(
            id: 'students',
            label: 'Students',
            icon: Icons.person_outlined,
            activeIcon: Icons.person_rounded,
          ),
          const SidebarItem(
            id: 'staff',
            label: 'Staff & Teachers',
            icon: Icons.badge_outlined,
            activeIcon: Icons.badge_rounded,
          ),
          if (role != UserRole.student && role != UserRole.parent)
            const SidebarItem(
              id: 'attendance',
              label: 'Attendance',
              icon: Icons.fact_check_outlined,
              activeIcon: Icons.fact_check_rounded,
            ),
          const SidebarItem(
            id: 'admissions',
            label: 'Admissions',
            icon: Icons.person_add_outlined,
            activeIcon: Icons.person_add_rounded,
          ),
          const SidebarItem(
            id: 'alumni',
            label: 'Alumni',
            icon: Icons.workspace_premium_outlined,
            activeIcon: Icons.workspace_premium_rounded,
          ),
        ],
      ),
    );

    // Finance
    if (role != UserRole.student) {
      items.add(
        SidebarItem(
          id: 'finance_group',
          label: 'Finance',
          icon: Icons.account_balance_wallet_outlined,
          children: [
            const SidebarItem(
              id: 'fees',
              label: 'Fees & Collection',
              icon: Icons.payments_outlined,
              activeIcon: Icons.payments_rounded,
            ),
            if (role.isOrgLevel || role == UserRole.branchAdmin)
              const SidebarItem(
                id: 'hr_payroll',
                label: 'HR & Payroll',
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
              ),
          ],
        ),
      );
    }

    // Facilities
    items.add(
      SidebarItem(
        id: 'facilities_group',
        label: 'Facilities',
        icon: Icons.apartment_outlined,
        children: [
          const SidebarItem(
            id: 'library',
            label: 'Library',
            icon: Icons.local_library_outlined,
            activeIcon: Icons.local_library_rounded,
          ),
          const SidebarItem(
            id: 'transport',
            label: 'Transport',
            icon: Icons.directions_bus_outlined,
            activeIcon: Icons.directions_bus_rounded,
          ),
          const SidebarItem(
            id: 'hostel',
            label: 'Hostel',
            icon: Icons.hotel_outlined,
            activeIcon: Icons.hotel_rounded,
          ),
          const SidebarItem(
            id: 'canteen',
            label: 'Canteen',
            icon: Icons.restaurant_outlined,
            activeIcon: Icons.restaurant_rounded,
          ),
          const SidebarItem(
            id: 'inventory',
            label: 'Inventory',
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
          ),
        ],
      ),
    );

    // Communication
    items.addAll([
      const SidebarItem(
        id: 'communication',
        label: 'Communication',
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble_rounded,
        badge: '5',
      ),
      const SidebarItem(
        id: 'notice_board',
        label: 'Notice Board',
        icon: Icons.campaign_outlined,
        activeIcon: Icons.campaign_rounded,
      ),
      const SidebarItem(
        id: 'events',
        label: 'Events & Calendar',
        icon: Icons.event_outlined,
        activeIcon: Icons.event_rounded,
      ),
    ]);

    // Management
    if (role.isBranchLevel || role.isOrgLevel) {
      items.addAll([
        const SidebarItem(
          id: 'certificates',
          label: 'Certificates',
          icon: Icons.card_membership_outlined,
          activeIcon: Icons.card_membership_rounded,
        ),
        const SidebarItem(
          id: 'visitor_security',
          label: 'Visitor & Security',
          icon: Icons.security_outlined,
          activeIcon: Icons.security_rounded,
        ),
        const SidebarItem(
          id: 'leave',
          label: 'Leave & Gate Pass',
          icon: Icons.exit_to_app_outlined,
          activeIcon: Icons.exit_to_app_rounded,
        ),
        const SidebarItem(
          id: 'health',
          label: 'Health Records',
          icon: Icons.medical_services_outlined,
          activeIcon: Icons.medical_services_rounded,
        ),
      ]);
    }

    // Reports & Settings
    items.addAll([
      const SidebarItem(
        id: 'reports',
        label: 'Reports & Analytics',
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
      ),
      const SidebarItem(
        id: 'mobile',
        label: 'Mobile Apps Simulation',
        icon: Icons.phone_android_outlined,
        activeIcon: Icons.phone_android_rounded,
      ),
      const SidebarItem(
        id: 'settings',
        label: 'Settings',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
      ),
    ]);

    return items;
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Dashboard Overview — The main dashboard content
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _DashboardOverview extends ConsumerWidget {
  final UserEntity user;

  const _DashboardOverview({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final isMobile = context.isMobile;

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Welcome Header ────────────────────
          _buildWelcomeHeader(context, isDark),
          const SizedBox(height: 24),

          // ─── Stat Cards ────────────────────────
          _buildStatCards(context, isMobile),
          const SizedBox(height: 24),

          // ─── Organization Cross-Branch Analytics ───
          if (user.role.isOrgLevel) ...[
            _buildOrgComparisonRow(context, ref, isDark, isMobile),
            const SizedBox(height: 24),
            _buildOrgFinanceRow(context, ref, isDark, isMobile),
            const SizedBox(height: 24),
            _buildOrgLibraryRow(context, ref, isDark, isMobile),
            const SizedBox(height: 24),
          ],

          // ─── Charts Row ────────────────────────
          _buildChartsRow(context, isDark, isMobile),
          const SizedBox(height: 24),

          // ─── Quick Actions + Recent Activity ───
          _buildBottomSection(context, isDark, isMobile),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, bool isDark) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${user.name.split(' ').first}! 👋',
                style: TextStyle(
                  fontSize: context.responsive(mobile: 20.0, desktop: 26.0),
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here\'s what\'s happening at ${user.activeBranch?.branchName ?? 'your school'} today.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        if (!context.isMobile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Academic Year 2026-27',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatCards(BuildContext context, bool isMobile) {
    final cards = [
      StatCard(
        label: 'Total Students',
        value: '2,847',
        subtitle: 'Active enrollments',
        icon: Icons.people_rounded,
        gradient: AppColors.statStudents,
        trend: '+12%',
        trendUp: true,
      ),
      StatCard(
        label: 'Total Staff',
        value: '186',
        subtitle: 'Teaching & non-teaching',
        icon: Icons.badge_rounded,
        gradient: AppColors.statStaff,
        trend: '+3%',
        trendUp: true,
      ),
      StatCard(
        label: 'Revenue (MTD)',
        value: '₹24.5L',
        subtitle: 'Fee collection this month',
        icon: Icons.account_balance_wallet_rounded,
        gradient: AppColors.statRevenue,
        trend: '+8%',
        trendUp: true,
      ),
      StatCard(
        label: 'Attendance Today',
        value: '94.2%',
        subtitle: 'Student attendance rate',
        icon: Icons.fact_check_rounded,
        gradient: AppColors.statAttendance,
        trend: '-1.2%',
        trendUp: false,
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(height: 160, child: card),
                ))
            .toList(),
      );
    }

    return GridView.count(
      crossAxisCount: context.responsive(mobile: 1, tablet: 2, desktop: 4),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: context.responsive(
        mobile: 2.0,
        tablet: 1.6,
        desktop: 1.45,
      ),
      children: cards,
    );
  }

  Widget _buildChartsRow(BuildContext context, bool isDark, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildAttendanceChart(isDark),
          const SizedBox(height: 16),
          _buildFeeCollectionChart(isDark),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildAttendanceChart(isDark)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildFeeCollectionChart(isDark)),
      ],
    );
  }

  Widget _buildOrgComparisonRow(BuildContext context, WidgetRef ref, bool isDark, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildBranchComparisonChart(ref, isDark),
          const SizedBox(height: 16),
          _buildBranchExamComparisonChart(ref, isDark),
          const SizedBox(height: 16),
          _buildBranchAttendanceHeatMap(isDark),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildBranchComparisonChart(ref, isDark)),
        const SizedBox(width: 16),
        Expanded(flex: 3, child: _buildBranchExamComparisonChart(ref, isDark)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildBranchAttendanceHeatMap(isDark)),
      ],
    );
  }

  Widget _buildBranchExamComparisonChart(WidgetRef ref, bool isDark) {
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final allBranches = ref.watch(organizationBranchesProvider);
    final allMarks = ref.watch(studentExamMarksProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cross-Branch Academic Averages',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor),
          ),
          const SizedBox(height: 16),
          if (allBranches.isEmpty)
            const Center(child: Text('No active branches found.', style: TextStyle(fontSize: 12)))
          else
            ...allBranches.map((b) {
              final branchMarks = allMarks.where((m) => m.branchId == b.id).toList();
              final averageScore = branchMarks.isNotEmpty 
                  ? branchMarks.fold(0.0, (sum, m) => sum + m.totalMarks) / branchMarks.length
                  : 0.0;
              final ratio = (averageScore / 100.0).clamp(0.0, 1.0);

              Color barColor = AppColors.primary;
              if (b.id == 'BR-001') barColor = AppColors.secondary;
              if (b.id == 'BR-002') barColor = AppColors.warning;

              return _buildBranchComparisonBar(
                '${b.name} (Avg Score: ${averageScore.toStringAsFixed(1)}%)',
                ratio,
                barColor,
                isDark,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBranchComparisonChart(WidgetRef ref, bool isDark) {
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final allBranches = ref.watch(organizationBranchesProvider);
    final allReceipts = ref.watch(feeReceiptsProvider);

    final targets = {
      'BR-001': 350000.0,
      'BR-002': 200000.0,
    };

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cross-Branch Collections vs Targets',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor),
          ),
          const SizedBox(height: 16),
          if (allBranches.isEmpty)
            const Center(child: Text('No active branches found.', style: TextStyle(fontSize: 12)))
          else
            ...allBranches.map((b) {
              final collectedForBranch = allReceipts.where((r) => r.branchId == b.id && r.status != 'Refunded').fold(0.0, (sum, r) => sum + r.amountPaid);
              final branchTarget = targets[b.id] ?? 150000.0;
              final ratio = branchTarget > 0 ? (collectedForBranch / branchTarget).clamp(0.0, 1.0) : 0.0;

              Color barColor = AppColors.primary;
              if (b.id == 'BR-001') barColor = AppColors.secondary;
              if (b.id == 'BR-002') barColor = AppColors.warning;

              return _buildBranchComparisonBar(
                '${b.name} (Target: ₹${(branchTarget/1000).toStringAsFixed(0)}K)',
                ratio,
                barColor,
                isDark,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBranchComparisonBar(String name, double value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87)),
              Text('${(value * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: color,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchAttendanceHeatMap(bool isDark) {
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Branch Attendance Heat Map',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 80),
              ...['M', 'T', 'W', 'T', 'F'].map((day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSec),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          _buildHeatMapRow('Delhi', [0.95, 0.94, 0.96, 0.93, 0.91], isDark),
          _buildHeatMapRow('Bangalore', [0.92, 0.90, 0.93, 0.92, 0.88], isDark),
          _buildHeatMapRow('Mumbai', [0.89, 0.88, 0.90, 0.87, 0.84], isDark),
        ],
      ),
    );
  }

  Widget _buildHeatMapRow(String branch, List<double> values, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              branch,
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          ...values.map((v) {
            final color = _getHeatMapColor(v);
            return Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${(v * 100).toInt()}',
                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getHeatMapColor(double val) {
    if (val >= 0.94) {
      return const Color(0xFF1E88E5); // High - Blue
    } else if (val >= 0.90) {
      return const Color(0xFF43A047); // Moderate - Green
    } else if (val >= 0.85) {
      return const Color(0xFFFFB300); // Fair - Amber
    } else {
      return const Color(0xFFE53935); // Low - Red
    }
  }

  Widget _buildOrgFinanceRow(BuildContext context, WidgetRef ref, bool isDark, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildOrgConsolidatedFeeDashboard(ref, isDark),
          const SizedBox(height: 16),
          _buildBranchRevenueRanking(ref, isDark),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildOrgConsolidatedFeeDashboard(ref, isDark)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildBranchRevenueRanking(ref, isDark)),
      ],
    );
  }

  Widget _buildOrgConsolidatedFeeDashboard(WidgetRef ref, bool isDark) {
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final allBranches = ref.watch(organizationBranchesProvider);
    final allAssignments = ref.watch(studentFeeAssignmentsProvider);
    final allReceipts = ref.watch(feeReceiptsProvider);

    final totalCollected = allReceipts.where((r) => r.status != 'Refunded').fold(0.0, (sum, r) => sum + r.amountPaid);
    final totalOutstanding = allAssignments.fold(0.0, (sum, fa) => sum + (fa.assignedAmount - fa.discountAmount - fa.paidAmount));
    final efficiency = (totalCollected + totalOutstanding) > 0 ? (totalCollected / (totalCollected + totalOutstanding)) * 100 : 0.0;

    final targets = {
      'BR-001': 350000.0,
      'BR-002': 200000.0,
    };

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consolidated Fee Collection Dashboard',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFinanceKpi('Total Collected', '₹${totalCollected.toStringAsFixed(0)}', AppColors.secondary, isDark),
              _buildFinanceKpi('Total Outstanding', '₹${totalOutstanding.toStringAsFixed(0)}', AppColors.error, isDark),
              _buildFinanceKpi('Collection Efficiency', '${efficiency.toStringAsFixed(1)}%', AppColors.primary, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Collections vs Target (Branch comparison)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSec),
          ),
          const SizedBox(height: 8),
          if (allBranches.isEmpty)
            const Center(child: Text('No branches found.', style: TextStyle(fontSize: 12)))
          else
            ...allBranches.map((b) {
              final collectedForBranch = allReceipts.where((r) => r.branchId == b.id && r.status != 'Refunded').fold(0.0, (sum, r) => sum + r.amountPaid);
              final branchTarget = targets[b.id] ?? 150000.0;
              final ratio = branchTarget > 0 ? (collectedForBranch / branchTarget).clamp(0.0, 1.0) : 0.0;

              Color barColor = AppColors.primary;
              if (b.id == 'BR-001') barColor = AppColors.secondary;
              if (b.id == 'BR-002') barColor = AppColors.warning;

              return _buildBranchComparisonBar(
                '${b.name} (Target: ₹${(branchTarget/1000).toStringAsFixed(0)}K)',
                ratio,
                barColor,
                isDark,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildFinanceKpi(String label, String value, Color color, bool isDark) {
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: textSec)),
      ],
    );
  }

  Widget _buildBranchRevenueRanking(WidgetRef ref, bool isDark) {
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final allBranches = ref.watch(organizationBranchesProvider);
    final allReceipts = ref.watch(feeReceiptsProvider);

    final branchRevenues = allBranches.map((b) {
      final rev = allReceipts.where((r) => r.branchId == b.id && r.status != 'Refunded').fold(0.0, (sum, r) => sum + r.amountPaid);
      return MapEntry(b.name, rev);
    }).toList();

    branchRevenues.sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Branch-wise Revenue Ranking',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor),
          ),
          const SizedBox(height: 16),
          if (branchRevenues.isEmpty)
            const Center(child: Text('No revenue data recorded.', style: TextStyle(fontSize: 12)))
          else
            ...List.generate(branchRevenues.length, (index) {
              final entry = branchRevenues[index];
              final ordinal = (index == 0) ? '1st' : (index == 1) ? '2nd' : (index == 2) ? '3rd' : '${index + 1}th';
              final medalColor = (index == 0) ? Colors.amber : (index == 1) ? const Color(0xFFC0C0C0) : (index == 2) ? const Color(0xFFCD7F32) : Colors.blueGrey;

              return _buildRankTile(
                entry.key,
                '₹${entry.value.toStringAsFixed(0)}',
                ordinal,
                medalColor,
                isDark,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildOrgLibraryRow(BuildContext context, WidgetRef ref, bool isDark, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildOrgConsolidatedLibraryDashboard(ref, isDark),
          const SizedBox(height: 16),
          _buildBranchLibraryRanking(ref, isDark),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildOrgConsolidatedLibraryDashboard(ref, isDark)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildBranchLibraryRanking(ref, isDark)),
      ],
    );
  }

  Widget _buildOrgConsolidatedLibraryDashboard(WidgetRef ref, bool isDark) {
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final allBranches = ref.watch(organizationBranchesProvider);
    final allBooks = ref.watch(bookCatalogProvider);

    final totalBooksCount = allBooks.length;
    final activeIssuedCount = allBooks.where((b) => b.status == 'Issued').length;
    final overallIssueRate = totalBooksCount > 0 ? (activeIssuedCount / totalBooksCount) * 100 : 0.0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consolidated Library Catalog Dashboard',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFinanceKpi('Total Books', '$totalBooksCount items', AppColors.secondary, isDark),
              _buildFinanceKpi('Active Issues', '$activeIssuedCount books', AppColors.warning, isDark),
              _buildFinanceKpi('Overall Issue Rate', '${overallIssueRate.toStringAsFixed(1)}%', AppColors.primary, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Branch Book Stock vs Active Issues',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSec),
          ),
          const SizedBox(height: 8),
          if (allBranches.isEmpty)
            const Center(child: Text('No active branches found.', style: TextStyle(fontSize: 12)))
          else
            ...allBranches.map((b) {
              final branchBooksCount = allBooks.where((bk) => bk.branchId == b.id).length;
              final branchIssuedCount = allBooks.where((bk) => bk.branchId == b.id && bk.status == 'Issued').length;
              final ratio = branchBooksCount > 0 ? (branchIssuedCount / branchBooksCount).clamp(0.0, 1.0) : 0.0;

              Color barColor = AppColors.primary;
              if (b.id == 'BR-001') barColor = AppColors.secondary;
              if (b.id == 'BR-002') barColor = AppColors.warning;

              return _buildBranchComparisonBar(
                '${b.name} ($branchIssuedCount Issued / $branchBooksCount Total)',
                ratio,
                barColor,
                isDark,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBranchLibraryRanking(WidgetRef ref, bool isDark) {
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final allBranches = ref.watch(organizationBranchesProvider);
    final allBooks = ref.watch(bookCatalogProvider);

    final branchBookSizes = allBranches.map((b) {
      final size = allBooks.where((bk) => bk.branchId == b.id).length;
      return MapEntry(b.name, size);
    }).toList();

    branchBookSizes.sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Branch Library Stock Ranking',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor),
          ),
          const SizedBox(height: 16),
          if (branchBookSizes.isEmpty)
            const Center(child: Text('No book data registered.', style: TextStyle(fontSize: 12)))
          else
            ...List.generate(branchBookSizes.length, (index) {
              final entry = branchBookSizes[index];
              final ordinal = (index == 0) ? '1st' : (index == 1) ? '2nd' : (index == 2) ? '3rd' : '${index + 1}th';
              final medalColor = (index == 0) ? Colors.amber : (index == 1) ? const Color(0xFFC0C0C0) : (index == 2) ? const Color(0xFFCD7F32) : Colors.blueGrey;

              return _buildRankTile(
                entry.key,
                '${entry.value} Books',
                ordinal,
                medalColor,
                isDark,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRankTile(String name, String revenue, String rank, Color rankColor, bool isDark) {
    final textPri = isDark ? Colors.white : Colors.black87;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: rankColor,
            radius: 12,
            child: Text(
              rank[0],
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textPri),
            ),
          ),
          Text(
            revenue,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart(bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Attendance Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'This Week',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Simplified chart placeholder with bars
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('Mon', 0.92, isDark),
                _buildBar('Tue', 0.88, isDark),
                _buildBar('Wed', 0.95, isDark),
                _buildBar('Thu', 0.91, isDark),
                _buildBar('Fri', 0.87, isDark),
                _buildBar('Sat', 0.78, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double value, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: AppSpacing.animSlow,
          width: 32,
          height: 140 * value,
          decoration: BoxDecoration(
            gradient: value > 0.9
                ? AppColors.secondaryGradient
                : value > 0.85
                    ? AppColors.cyanGradient
                    : AppColors.accentGradient,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeCollectionChart(bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fee Collection Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 20),
          // Circular progress indicator
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: 0.73,
                      strokeWidth: 12,
                      backgroundColor: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '73%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Collected',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildFeeRow('Collected', '₹18.2L', AppColors.secondary, isDark),
          const SizedBox(height: 8),
          _buildFeeRow('Pending', '₹5.3L', AppColors.warning, isDark),
          const SizedBox(height: 8),
          _buildFeeRow('Overdue', '₹1.5L', AppColors.error, isDark),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context, bool isDark, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildQuickActions(isDark),
          const SizedBox(height: 16),
          _buildRecentActivity(isDark),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildQuickActions(isDark)),
        const SizedBox(width: 16),
        Expanded(flex: 3, child: _buildRecentActivity(isDark)),
      ],
    );
  }

  Widget _buildQuickActions(bool isDark) {
    final actions = [
      _QuickAction(Icons.person_add_rounded, 'New Student', AppColors.primary),
      _QuickAction(Icons.receipt_rounded, 'Collect Fee', AppColors.secondary),
      _QuickAction(Icons.fact_check_rounded, 'Mark Attendance', AppColors.accentCyan),
      _QuickAction(Icons.assignment_rounded, 'Create Exam', AppColors.accentAmber),
      _QuickAction(Icons.campaign_rounded, 'Send Notice', AppColors.accentPink),
      _QuickAction(Icons.event_rounded, 'Add Event', AppColors.accent),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
            children: actions.map((action) {
              return _QuickActionTile(action: action, isDark: isDark);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(bool isDark) {
    final activities = [
      _Activity(
        Icons.person_add_rounded,
        'New student enrolled',
        'Aarav Mehta was enrolled in Class 10-A',
        '2 min ago',
        AppColors.primary,
      ),
      _Activity(
        Icons.payments_rounded,
        'Fee collected',
        '₹25,000 received from Priya Sharma (Class 8-B)',
        '15 min ago',
        AppColors.secondary,
      ),
      _Activity(
        Icons.fact_check_rounded,
        'Attendance marked',
        'Class 9-A attendance marked by Ms. Anita Desai',
        '32 min ago',
        AppColors.accentCyan,
      ),
      _Activity(
        Icons.assignment_rounded,
        'Exam scheduled',
        'Mid-term exams scheduled for Sept 15-22',
        '1 hr ago',
        AppColors.accentAmber,
      ),
      _Activity(
        Icons.campaign_rounded,
        'Notice published',
        'School reopening notice sent to all parents',
        '3 hrs ago',
        AppColors.accentPink,
      ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...activities.map((activity) => _buildActivityItem(activity, isDark)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(_Activity activity, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: activity.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity.icon,
              size: 18,
              color: activity.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
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
          Text(
            activity.time,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Module Placeholder — Shown for modules not yet built
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ModulePlaceholder extends StatelessWidget {
  final String moduleId;
  final String title;

  const _ModulePlaceholder({
    super.key,
    required this.moduleId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.construction_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This module is under development.\nComing soon in the next phase!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Text(
              'Module ID: $moduleId',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Classes ──────────────────────────────

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction(this.icon, this.label, this.color);
}

class _QuickActionTile extends StatefulWidget {
  final _QuickAction action;
  final bool isDark;
  const _QuickActionTile({required this.action, required this.isDark});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: AppSpacing.animFast,
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.action.color.withValues(alpha: 0.12)
                : (widget.isDark ? AppColors.darkCard : AppColors.lightBg),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? widget.action.color.withValues(alpha: 0.3)
                  : (widget.isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.action.icon,
                size: 24,
                color: widget.action.color,
              ),
              const SizedBox(height: 8),
              Text(
                widget.action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Activity {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final Color color;
  const _Activity(this.icon, this.title, this.description, this.time, this.color);
}

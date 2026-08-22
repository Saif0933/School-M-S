import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/enums.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../branch/domain/entities/branch_entity.dart';
import '../../domain/entities/organization_entity.dart';
import '../../providers.dart';
import '../widgets/broadcast_announcement_modal.dart';
import '../widgets/create_org_admin_modal.dart';
import '../widgets/cross_branch_transfer_modal.dart';
import '../widgets/organization_onboarding_wizard_modal.dart';
import '../../../branch/presentation/widgets/branch_detail_management_modal.dart';
import '../widgets/organization_report_export_modal.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Organization (Super Admin) Management Control Center
/// Section 1 Implementation: Level 1 Organization (Super Admin) Hub
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OrganizationManagementPage extends ConsumerStatefulWidget {
  const OrganizationManagementPage({super.key});

  @override
  ConsumerState<OrganizationManagementPage> createState() =>
      _OrganizationManagementPageState();
}

class _OrganizationManagementPageState
    extends ConsumerState<OrganizationManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _newSubjectController = TextEditingController();
  final _newFeeHeadController = TextEditingController();
  final _newDesignationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(organizationProvider.notifier).fetchOrganization();
        ref.read(organizationBranchesProvider.notifier).fetchBranches();
        ref.read(orgAdminsProvider.notifier).fetchAdmins();
        ref.read(crossBranchTransferProvider.notifier).fetchTransfers();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newSubjectController.dispose();
    _newFeeHeadController.dispose();
    _newDesignationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final org = ref.watch(organizationProvider);
    final branches = ref.watch(organizationBranchesProvider);
    final transfers = ref.watch(crossBranchTransferProvider);
    final orgAdmins = ref.watch(orgAdminsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Column(
        children: [
          // Header Banner Card
          _buildTopBanner(isDark, org, branches.length),

          // 6-Tab Navigation Bar
          Container(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(
                  icon: Icon(Icons.analytics_rounded, size: 18),
                  text: '1. Consolidated Overview',
                ),
                Tab(
                  icon: Icon(Icons.account_tree_rounded, size: 18),
                  text: '2. Branch Network & Capacity',
                ),
                Tab(
                  icon: Icon(Icons.admin_panel_settings_rounded, size: 18),
                  text: '3. Organization Admins & RBAC',
                ),
                Tab(
                  icon: Icon(Icons.swap_horizontal_circle_rounded, size: 18),
                  text: '4. Cross-Branch Transfers',
                ),
                Tab(
                  icon: Icon(Icons.rule_folder_rounded, size: 18),
                  text: '5. Master Data & Policies',
                ),
                Tab(
                  icon: Icon(Icons.settings_suggest_rounded, size: 18),
                  text: '6. Master Settings & Audit',
                ),
              ],
            ),
          ),

          // Tab Body Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildConsolidatedOverviewTab(isDark, org, branches),
                _buildBranchNetworkTab(isDark, branches),
                _buildOrgAdminsTab(isDark, orgAdmins),
                _buildCrossBranchTransfersTab(isDark, transfers),
                _buildMasterDataTab(isDark, org),
                _buildBrandingAndAuditTab(isDark, org),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TOP BANNER CARD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildTopBanner(bool isDark, OrganizationEntity org, int branchCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 950;

            final logoAndDetails = Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'SET',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              org.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.secondary),
                            ),
                            child: Text(
                              org.subscriptionPlan.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reg No: ${org.registrationNumber} • Tax ID: ${org.taxRegistrationNumber} • ${org.subdomain}',
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
              ],
            );

            final actionButtons = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          const OrganizationReportExportModal(),
                    );
                  },
                  icon: const Icon(Icons.file_download_rounded,
                      color: AppColors.primary, size: 16),
                  label: const Text('Export Report'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const BroadcastAnnouncementModal(),
                    );
                  },
                  icon: const Icon(Icons.campaign_rounded,
                      color: AppColors.secondary, size: 16),
                  label: const Text('Broadcast'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateOrgAdminModal(),
                    );
                  },
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('+ Create Org Admin'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          const OrganizationOnboardingWizardModal(),
                    );
                  },
                  icon: const Icon(Icons.domain_add_rounded, size: 18),
                  label: const Text(
                    '+ Onboard Branch',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            );

            return isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      logoAndDetails,
                      const SizedBox(height: 16),
                      actionButtons,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: logoAndDetails),
                      const SizedBox(width: 24),
                      actionButtons,
                    ],
                  );
          },
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 1: CONSOLIDATED OVERVIEW
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildConsolidatedOverviewTab(
    bool isDark,
    OrganizationEntity org,
    List<BranchEntity> branches,
  ) {
    final totalStudents =
        branches.fold<int>(0, (sum, b) => sum + b.activeStudentCount);
    final totalStaff =
        branches.fold<int>(0, (sum, b) => sum + b.activeStaffCount);
    final maxCapacity =
        branches.fold<int>(0, (sum, b) => sum + b.maxStudentCapacity);

    // Dynamic Financial Calculations
    const averageMonthlyFee = 2500;
    final totalMrr = totalStudents * averageMonthlyFee;
    final totalGrossRevenue = totalMrr * 12;
    final outstandingDues = (totalGrossRevenue * 0.036).round();
    const collectionRate = 96.4;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4 Metric Tiles
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              final tiles = [
                _buildOverviewTile(
                  title: 'Consolidated MRR Revenue',
                  value: '₹${_formatCurrency(totalMrr)}/mo',
                  subtitle: 'Across ${branches.length} branches',
                  icon: Icons.monetization_on_rounded,
                  gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF047857)]),
                  isDark: isDark,
                ),
                _buildOverviewTile(
                  title: 'Active School Branches',
                  value: '${branches.length} / ${org.maxBranches}',
                  subtitle: 'Multi-Branch Isolation',
                  icon: Icons.account_tree_rounded,
                  gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                  isDark: isDark,
                ),
                _buildOverviewTile(
                  title: 'Total Student Enrolments',
                  value: '$totalStudents Seats',
                  subtitle: 'Capacity: $maxCapacity max',
                  icon: Icons.groups_rounded,
                  gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                  isDark: isDark,
                ),
                _buildOverviewTile(
                  title: 'Total Faculty & Staff',
                  value: '$totalStaff Staff',
                  subtitle: 'Cross-Branch Workforce',
                  icon: Icons.badge_rounded,
                  gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                  isDark: isDark,
                ),
              ];

              if (isDesktop) {
                return Row(
                  children: tiles
                      .map((t) => Expanded(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: t,
                          )))
                      .toList(),
                );
              } else {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: tiles
                      .map((t) => SizedBox(
                          width: (constraints.maxWidth - 12) / 2, child: t))
                      .toList(),
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Organization-Level Financial Dashboard Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organization-Level Financial Dashboard (Consolidated Revenue)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Consolidated fee collections, MRR revenue & outstanding dues across all branches',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.trending_up_rounded,
                              color: Colors.green, size: 16),
                          SizedBox(width: 6),
                          Text(
                            '+14.2% YoY Revenue Growth',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _buildFinancialSummaryBox(
                      title: 'Total Gross Revenue',
                      amount: '₹${_formatCurrency(totalGrossRevenue)}',
                      badgeText: 'Annual Total',
                      badgeColor: AppColors.primary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 14),
                    _buildFinancialSummaryBox(
                      title: 'Fee Collection Rate',
                      amount: '$collectionRate%',
                      badgeText: '${(100 - collectionRate).toStringAsFixed(1)}% Default',
                      badgeColor: Colors.green,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 14),
                    _buildFinancialSummaryBox(
                      title: 'Outstanding Dues',
                      amount: '₹${_formatCurrency(outstandingDues)}',
                      badgeText: 'Pending Collect',
                      badgeColor: Colors.orange,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Branch-Wise Revenue Distribution Breakdown
                Text(
                  'Branch-Wise Fee Revenue Distribution Breakdown:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                Column(
                  children: branches.map((b) {
                    final branchRevenue = b.activeStudentCount * averageMonthlyFee * 12;
                    final sharePercentage = totalGrossRevenue > 0
                        ? (branchRevenue / totalGrossRevenue)
                        : 0.0;
                    final shareText = '${(sharePercentage * 100).toStringAsFixed(1)}%';

                    final colors = [
                      const Color(0xFF6366F1), // Indigo
                      const Color(0xFF10B981), // Emerald
                      const Color(0xFF3B82F6), // Blue
                      const Color(0xFFF59E0B), // Amber
                      const Color(0xFFEC4899), // Pink
                    ];
                    final color = colors[branches.indexOf(b) % colors.length];

                    return _buildBranchRevenueBar(
                      branchName: b.name,
                      revenue: '₹${_formatCurrency(branchRevenue)}',
                      sharePercentage: sharePercentage,
                      shareText: shareText,
                      color: color,
                      isDark: isDark,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Branch Performance Comparison Dashboard Card (Ranking, Growth, Retention)
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Branch Performance & Ranking Comparison Dashboard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Multi-tenant benchmarking across ranking, student growth, retention & academic scores',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              const OrganizationReportExportModal(),
                        );
                      },
                      icon: const Icon(Icons.file_download_rounded, size: 16),
                      label: const Text('Export Excel/PDF Report'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Rank')),
                      DataColumn(label: Text('Branch Name & Code')),
                      DataColumn(label: Text('Board')),
                      DataColumn(label: Text('Growth (+YoY)')),
                      DataColumn(label: Text('Retention Rate')),
                      DataColumn(label: Text('Academic Score')),
                      DataColumn(label: Text('Attendance Avg')),
                      DataColumn(label: Text('Rating')),
                    ],
                    rows: () {
                      final sortedBranches = List<BranchEntity>.from(branches)
                        ..sort((a, b) => b.activeStudentCount.compareTo(a.activeStudentCount));

                      return sortedBranches.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final b = entry.value;

                        String rankEmoji = '${idx + 1}';
                        if (idx == 0) rankEmoji = '#1 🥇';
                        else if (idx == 1) rankEmoji = '#2 🥈';
                        else if (idx == 2) rankEmoji = '#3 🥉';
                        else rankEmoji = '#${idx + 1}';

                        final growth = idx == 0 ? '+18.4%' : (idx == 1 ? '+12.1%' : '+9.5%');
                        final retention = idx == 0 ? '98.2%' : (idx == 1 ? '96.8%' : '95.4%');
                        final academic = idx == 0 ? '92.4%' : (idx == 1 ? '88.6%' : '86.2%');
                        final attendance = idx == 0 ? '96.5%' : (idx == 1 ? '94.8%' : '93.2%');
                        final rating = idx == 0 ? 'Top Performer' : (idx == 1 ? 'Fast Growing' : 'Stable');
                        final ratingColor = idx == 0 ? Colors.green : (idx == 1 ? Colors.blue : Colors.orange);

                        return _buildPerformanceRow(
                          rank: rankEmoji,
                          name: b.name,
                          code: b.code,
                          board: b.affiliationBoard,
                          growth: growth,
                          retention: retention,
                          academicScore: academic,
                          attendance: attendance,
                          rating: rating,
                          ratingColor: ratingColor,
                          isDark: isDark,
                        );
                      }).toList();
                    }(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Master Organization Calendar with All Branch Events Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Master Organization Calendar (All Branch Events & Exams)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Consolidated schedule of examinations, sports meets, holidays & workshops across all branches',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Calendar Event Added!')),
                        );
                      },
                      icon: const Icon(Icons.event_note_rounded, size: 16),
                      label: const Text('+ Add Event'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Column(
                  children: ref.watch(organizationEventsProvider).map((evt) {
                    Color evtColor;
                    IconData evtIcon;

                    switch (evt.eventType) {
                      case 'Exam':
                        evtColor = Colors.redAccent;
                        evtIcon = Icons.assignment_rounded;
                        break;
                      case 'Sports':
                        evtColor = Colors.green;
                        evtIcon = Icons.sports_soccer_rounded;
                        break;
                      case 'Academic':
                        evtColor = Colors.blue;
                        evtIcon = Icons.school_rounded;
                        break;
                      case 'Holiday':
                        evtColor = Colors.purple;
                        evtIcon = Icons.beach_access_rounded;
                        break;
                      case 'Staff':
                      default:
                        evtColor = Colors.orange;
                        evtIcon = Icons.badge_rounded;
                        break;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBg : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: evtColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(evtIcon, color: evtColor, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      evt.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: evtColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        evt.eventType.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: evtColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_formatDate(evt.startDate)} - ${_formatDate(evt.endDate)} • Venue: ${evt.venue}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                Text(
                                  evt.description,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.secondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              evt.branchScope,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTile({
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

  Widget _buildFinancialSummaryBox({
    required String title,
    required String amount,
    required String badgeText,
    required Color badgeColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
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

  Widget _buildBranchRevenueBar({
    required String branchName,
    required String revenue,
    required double sharePercentage,
    required String shareText,
    required Color color,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                branchName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                '$revenue ($shareText)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: sharePercentage,
              minHeight: 6,
              backgroundColor:
                  isDark ? AppColors.darkBorder : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildPerformanceRow({
    required String rank,
    required String name,
    required String code,
    required String board,
    required String growth,
    required String retention,
    required String academicScore,
    required String attendance,
    required String rating,
    required Color ratingColor,
    required bool isDark,
  }) {
    return DataRow(
      cells: [
        DataCell(Text(rank,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12)),
              Text(code,
                  style:
                      const TextStyle(fontSize: 10, color: AppColors.primary)),
            ],
          ),
        ),
        DataCell(Text(board)),
        DataCell(Text(growth,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: Colors.green))),
        DataCell(Text(retention,
            style: const TextStyle(fontWeight: FontWeight.w700))),
        DataCell(Text(academicScore,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.primary))),
        DataCell(Text(attendance)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ratingColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rating,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: ratingColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 2: BRANCH NETWORK & LICENSES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildBranchNetworkTab(bool isDark, List<BranchEntity> branches) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Branch Network & Capacity Allocation (Branch-Isolated)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    'Level 2 Branch Management — Students, Staff & Timetables belong to individual branches',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        const OrganizationOnboardingWizardModal(),
                  );
                },
                icon: const Icon(Icons.add_business_rounded, size: 18),
                label: const Text('+ Provision New Branch'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (branches.isEmpty)
            Container(
              height: 250,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_rounded,
                    size: 64,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Branches Provisioned Yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Click on "+ Provision New Branch" to create your first school branch.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
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
                    mainAxisExtent: 290,
                  ),
                  itemCount: branches.length,
                  itemBuilder: (context, index) {
                    final b = branches[index];
                    return _buildBranchCard(isDark, b);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(bool isDark, BranchEntity branch) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Code: ${branch.code} • ${branch.affiliationBoard}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: branch.status == BranchStatus.active,
                onChanged: (val) {
                  ref
                      .read(organizationBranchesProvider.notifier)
                      .toggleBranchStatus(branch.id);
                },
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 14),

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
                        'Principal: ${branch.principalName}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        '${branch.email} • ${branch.phone}',
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
          // Plan Assignment & Edit License Capacities Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: branch.planType,
                      isDense: true,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Basic',
                            child: Text('Basic Tier Plan')),
                        DropdownMenuItem(
                            value: 'Standard',
                            child: Text('Standard Tier Plan')),
                        DropdownMenuItem(
                            value: 'Premium',
                            child: Text('Premium Enterprise Plan')),
                      ],
                      onChanged: (newPlan) {
                        if (newPlan != null) {
                          ref
                              .read(organizationBranchesProvider.notifier)
                              .updateBranchPlan(
                                  branchId: branch.id, newPlan: newPlan);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Updated plan for "${branch.name}" to $newPlan Plan.'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded,
                    color: AppColors.primary, size: 20),
                tooltip: 'Edit Branch License Limits',
                onPressed: () => _showEditCapacityDialog(context, branch),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Student Capacity Allocation Bar
          _buildAllocationBar(
            label: 'Student Enrolment Capacity',
            current: branch.activeStudentCount,
            max: branch.maxStudentCapacity,
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          // Staff Capacity Allocation Bar
          _buildAllocationBar(
            label: 'Faculty & Staff Capacity',
            current: branch.activeStaffCount,
            max: branch.maxStaffCapacity,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      BranchDetailManagementModal(branch: branch),
                );
              },
              icon: const Icon(Icons.settings_suggest_rounded, size: 16),
              label: const Text('Configure Branch (Section 2)'),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCapacityDialog(BuildContext context, BranchEntity branch) {
    final studentController =
        TextEditingController(text: '${branch.maxStudentCapacity}');
    final staffController =
        TextEditingController(text: '${branch.maxStaffCapacity}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit License Limits (${branch.name})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Student Enrolment Capacity',
                  prefixIcon: Icon(Icons.groups_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: staffController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Faculty & Staff Capacity',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final maxSt =
                    int.tryParse(studentController.text.trim()) ?? branch.maxStudentCapacity;
                final maxTch =
                    int.tryParse(staffController.text.trim()) ?? branch.maxStaffCapacity;

                ref
                    .read(organizationBranchesProvider.notifier)
                    .updateBranchCapacities(
                      branchId: branch.id,
                      maxStudents: maxSt,
                      maxStaff: maxTch,
                    );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Updated user license limits for "${branch.name}".'),
                  ),
                );
              },
              child: const Text('Save Capacities'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllocationBar({
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
              label,
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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 3: ORGANIZATION ADMINS & RBAC MATRIX
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildOrgAdminsTab(bool isDark, List<OrgAdminEntity> admins) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Organization-Level Administrative User Accounts (Level 1 Authority)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    'Manage Super Admins, Billing Admins, Support Admins & Compliance Admins with cross-branch authority',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const CreateOrgAdminModal(),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                label: const Text('+ Create Org Admin Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (admins.isEmpty)
            Container(
              height: 250,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 64,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Organization Admins Created',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Click on "+ Create Org Admin Account" to delegate organization control.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
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
                    mainAxisExtent: 290,
                  ),
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    final admin = admins[index];
                    return _buildOrgAdminCard(isDark, admin);
                  },
                );
              },
            ),
          const SizedBox(height: 24),

          // Role-Based Access Control Matrix Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organization-Level Role-Based Access Control (RBAC) Matrix',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'Governance rules defining who can see and modify data across all branch tenants',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Organization Role')),
                      DataColumn(label: Text('Cross-Branch Visibility')),
                      DataColumn(label: Text('Branch Onboarding')),
                      DataColumn(label: Text('Subscription & Invoices')),
                      DataColumn(label: Text('Cross-Branch Data Migration')),
                      DataColumn(label: Text('Master Data & Templates')),
                      DataColumn(label: Text('System Audit Logs')),
                    ],
                    rows: [
                      _buildRbacRow('Super Admin', true, true, true, true, true, true),
                      _buildRbacRow('Billing Admin', true, false, true, false, false, false),
                      _buildRbacRow('Support Admin', true, false, false, true, false, true),
                      _buildRbacRow('Compliance Admin', true, false, false, false, true, true),
                      _buildRbacRow('Branch Admin (School)', false, false, false, false, false, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRbacRow(
    String role,
    bool visibility,
    bool branchCreation,
    bool billing,
    bool migration,
    bool masterData,
    bool auditLogs,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(role, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
        DataCell(_buildCheckCell(visibility)),
        DataCell(_buildCheckCell(branchCreation)),
        DataCell(_buildCheckCell(billing)),
        DataCell(_buildCheckCell(migration)),
        DataCell(_buildCheckCell(masterData)),
        DataCell(_buildCheckCell(auditLogs)),
      ],
    );
  }

  Widget _buildCheckCell(bool isAllowed) {
    return Icon(
      isAllowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
      size: 18,
      color: isAllowed ? Colors.green : Colors.grey,
    );
  }

  Widget _buildOrgAdminCard(bool isDark, OrgAdminEntity admin) {
    Color roleColor;
    IconData roleIcon;

    switch (admin.role) {
      case 'Super Admin':
        roleColor = const Color(0xFF6366F1);
        roleIcon = Icons.shield_rounded;
        break;
      case 'Billing Admin':
        roleColor = const Color(0xFF10B981);
        roleIcon = Icons.payments_rounded;
        break;
      case 'Support Admin':
        roleColor = const Color(0xFF3B82F6);
        roleIcon = Icons.headset_mic_rounded;
        break;
      case 'Compliance Admin':
      default:
        roleColor = const Color(0xFFF59E0B);
        roleIcon = Icons.gavel_rounded;
        break;
    }

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                ),
                child: Icon(roleIcon, color: roleColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      admin.email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Switch(
                value: admin.isActive,
                onChanged: (val) {
                  ref
                      .read(orgAdminsProvider.notifier)
                      .toggleAdminStatus(admin.id);
                },
                activeThumbColor: roleColor,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Role Badge & Scope Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  admin.role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: roleColor,
                  ),
                ),
              ),
              Text(
                admin.branchScope,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Permission Chips Preview
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: admin.permissions.map((perm) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                    child: Text(
                      perm,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Footer: Last Login & Delete Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                admin.lastLoginAt != null
                    ? 'Active Session'
                    : 'Created: ${_formatDate(admin.createdAt)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 18),
                tooltip: 'Delete Admin Account',
                onPressed: () {
                  ref
                      .read(orgAdminsProvider.notifier)
                      .deleteAdmin(admin.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Admin "${admin.name}" deleted.'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 4: CROSS-BRANCH TRANSFERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildCrossBranchTransfersTab(
    bool isDark,
    List<CrossBranchTransferLog> transfers,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cross-Branch Student & Staff Data Migration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    'Level 1 Super Admin Approval Workflow for transferring records between branch tenants',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const CrossBranchTransferModal(),
                  );
                },
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: const Text('+ Initiate Transfer Request'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (transfers.isEmpty)
            Container(
              height: 250,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 64,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Transfer Requests Found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Click on "+ Initiate Transfer Request" to request inter-branch record migration.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Transfer ID')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Name & Code')),
                    DataColumn(label: Text('Source Branch (From)')),
                    DataColumn(label: Text('Target Branch (To)')),
                    DataColumn(label: Text('Reason & Notes')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: transfers.map((t) {
                    return DataRow(
                      cells: [
                        DataCell(Text(t.id,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: t.entityType == 'student'
                                  ? Colors.blue.withValues(alpha: 0.15)
                                  : Colors.purple.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t.entityType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: t.entityType == 'student'
                                    ? Colors.blue
                                    : Colors.purple,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t.entityName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 13)),
                              Text(t.entityCode,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                        DataCell(Text(t.fromBranchName)),
                        DataCell(Text(t.toBranchName)),
                        DataCell(Text(t.reason)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              t.status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 5: MASTER DATA & POLICIES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildMasterDataTab(bool isDark, OrganizationEntity org) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Master Data Management (Organization-Wide Common Templates)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          Text(
            'Common subjects, fee heads, designations & policy documents shared across all branches',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Master Subjects Section
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Common Master Subjects (${org.masterSubjects.length})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 220,
                          child: TextField(
                            controller: _newSubjectController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Add new master subject...',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_newSubjectController.text.trim().isNotEmpty) {
                              ref
                                  .read(organizationProvider.notifier)
                                  .addMasterSubject(
                                      _newSubjectController.text.trim());
                              _newSubjectController.clear();
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: org.masterSubjects.map((sub) {
                    return Chip(
                      avatar: const Icon(Icons.book_rounded, size: 14),
                      label: Text(sub, style: const TextStyle(fontSize: 12)),
                      onDeleted: () {
                        ref
                            .read(organizationProvider.notifier)
                            .removeMasterSubject(sub);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Master Fee Heads Section
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Common Master Fee Heads (${org.masterFeeHeads.length})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 220,
                          child: TextField(
                            controller: _newFeeHeadController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Add new fee head...',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_newFeeHeadController.text.trim().isNotEmpty) {
                              ref
                                  .read(organizationProvider.notifier)
                                  .addMasterFeeHead(
                                      _newFeeHeadController.text.trim());
                              _newFeeHeadController.clear();
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: org.masterFeeHeads.map((fee) {
                    return Chip(
                      avatar: const Icon(Icons.payments_rounded, size: 14),
                      label: Text(fee, style: const TextStyle(fontSize: 12)),
                      onDeleted: () {
                        ref
                            .read(organizationProvider.notifier)
                            .removeMasterFeeHead(fee);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Master Designations Section
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Common Master Staff Designations (${org.masterDesignations.length})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 220,
                          child: TextField(
                            controller: _newDesignationController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Add new designation...',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_newDesignationController.text.trim().isNotEmpty) {
                              ref
                                  .read(organizationProvider.notifier)
                                  .addMasterDesignation(
                                      _newDesignationController.text.trim());
                              _newDesignationController.clear();
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: org.masterDesignations.map((des) {
                    return Chip(
                      avatar: const Icon(Icons.badge_rounded, size: 14),
                      label: Text(des, style: const TextStyle(fontSize: 12)),
                      onDeleted: () {
                        ref
                            .read(organizationProvider.notifier)
                            .removeMasterDesignation(des);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Policy Document Repository Section
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Organization Policy & Compliance Document Repository',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Policy Document Uploaded!')),
                        );
                      },
                      icon: const Icon(Icons.upload_file_rounded, size: 16),
                      label: const Text('Upload New Policy PDF'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Column(
                  children: [
                    _buildPolicyItem(
                      'Academic Integrity & Code of Ethics Policy 2026.pdf',
                      'v2.4 • Effective April 2026 • Applies to All Branches',
                      isDark,
                    ),
                    _buildPolicyItem(
                      'Fee Refund & Cancellation Rules 2026.pdf',
                      'v1.8 • Effective April 2026 • Financial Compliance',
                      isDark,
                    ),
                    _buildPolicyItem(
                      'Staff Work Conduct & POSH Compliance Manual.pdf',
                      'v3.0 • Effective January 2026 • HR Compliance',
                      isDark,
                    ),
                    _buildPolicyItem(
                      'Student Child Safety & Anti-Bullying Protocol.pdf',
                      'v2.1 • Effective August 2026 • Campus Safety',
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(String title, String subtitle, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_rounded,
              color: Colors.redAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  subtitle,
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
          IconButton(
            icon: const Icon(Icons.file_download_rounded, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading "$title"...')),
              );
            },
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 6: BRANDING, CREDITS, SETTINGS & AUDIT LOGS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildBrandingAndAuditTab(bool isDark, OrganizationEntity org) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SMS & Email Credit Pools',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.sms_rounded,
                                      color: AppColors.primary),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${org.smsCreditPool}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Text('SMS Balance',
                                      style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.email_rounded,
                                      color: AppColors.secondary),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${org.emailCreditPool}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const Text('Email Balance',
                                      style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.read(organizationProvider.notifier).updateCredits(
                                    smsCount: 50000,
                                    emailCount: 200000,
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Credits Recharged Successfully!')),
                              );
                            },
                            icon: const Icon(Icons.add_circle_outline_rounded,
                                size: 16),
                            label: const Text('Recharge Global Credit Pool (+50k SMS)'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 12),

                      Text(
                        'Branch Credit Allocations & Usage Ratios:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Branch Name')),
                            DataColumn(label: Text('Allocated SMS')),
                            DataColumn(label: Text('SMS Used')),
                            DataColumn(label: Text('Allocated Email')),
                            DataColumn(label: Text('Email Used')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: ref
                              .watch(branchCreditAllocationsProvider)
                              .map((alloc) {
                            return DataRow(
                              cells: [
                                DataCell(Text(alloc.branchName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700))),
                                DataCell(Text('${alloc.allocatedSms}')),
                                DataCell(Text('${alloc.usedSms}')),
                                DataCell(Text('${alloc.allocatedEmail}')),
                                DataCell(Text('${alloc.usedEmail}')),
                                DataCell(
                                  OutlinedButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                              branchCreditAllocationsProvider
                                                  .notifier)
                                          .allocateCredits(
                                            branchId: alloc.branchId,
                                            additionalSms: 5000,
                                            additionalEmail: 20000,
                                          );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Allocated +5,000 SMS & +20,000 Email credits to ${alloc.branchName}.'),
                                        ),
                                      );
                                    },
                                    child: const Text('+ Allocate Credits'),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Organization-Wide Master Settings & Configuration Panel
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organization-Wide Settings & Master Configuration Panel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'Global rules, default currency, grading standards & multi-branch data isolation policies',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: org.masterSettings['currency'] ?? 'INR',
                        decoration: InputDecoration(
                          labelText: 'Default Currency Head',
                          prefixIcon:
                              const Icon(Icons.attach_money_rounded, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'INR',
                              child: Text('INR (₹ Indian Rupee)',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'USD',
                              child: Text('USD (\$ US Dollar)',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'EUR',
                              child: Text('EUR (€ Euro)',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'AED',
                              child: Text('AED (د.إ UAE Dirham)',
                                  style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                .read(organizationProvider.notifier)
                                .updateMasterSettings({'currency': val});
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue:
                            org.masterSettings['timezone'] ?? 'Asia/Kolkata',
                        decoration: InputDecoration(
                          labelText: 'Organization Timezone',
                          prefixIcon:
                              const Icon(Icons.access_time_rounded, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Asia/Kolkata',
                              child: Text('Asia/Kolkata (IST +5:30)',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'UTC',
                              child: Text('UTC (Coordinated Universal)',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'America/New_York',
                              child: Text('America/New_York (EST -5:00)',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'Europe/London',
                              child: Text('Europe/London (GMT +0:00)',
                                  style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                .read(organizationProvider.notifier)
                                .updateMasterSettings({'timezone': val});
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue:
                            org.masterSettings['gradingSystem'] ?? 'CBSE',
                        decoration: InputDecoration(
                          labelText: 'Default Grading Standard',
                          prefixIcon:
                              const Icon(Icons.workspace_premium_rounded, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'CBSE',
                              child: Text('CBSE 9-Point Grading Scale',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'ICSE',
                              child: Text('ICSE Percentage & Grade Marks',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'IB',
                              child: Text('IB World 7-Point Criterion',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'US_GPA',
                              child: Text('US GPA 4.0 Standard Scale',
                                  style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                .read(organizationProvider.notifier)
                                .updateMasterSettings({'gradingSystem': val});
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: org.masterSettings['dataSharing'] ??
                            'Isolated',
                        decoration: InputDecoration(
                          labelText: 'Multi-Branch Data Policy',
                          prefixIcon:
                              const Icon(Icons.shield_rounded, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Isolated',
                              child: Text(
                                  'Isolated Tenants (Strict Branch Boundary)',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'Consolidated_ReadOnly',
                              child: Text(
                                  'Organization Consolidated Read-Only',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'Shared_Transfers',
                              child: Text(
                                  'Shared Transfer History Allowed',
                                  style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                .read(organizationProvider.notifier)
                                .updateMasterSettings({'dataSharing': val});
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.secondary,
                            content: Text(
                                'Organization-wide settings & master configurations saved!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: const Text('Save Master Configuration'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Organization API Key & Webhook Management Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organization Developer API Keys & Webhooks Gateway',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Manage REST API integration secret keys, scopes & real-time webhook event subscriptions',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(orgApiKeysProvider.notifier)
                            .generateKey('New Integration Key', 'Read-Only');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('New API Secret Key Generated!')),
                        );
                      },
                      icon: const Icon(Icons.key_rounded, size: 16),
                      label: const Text('+ Generate API Key'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // API Keys Sub-Section
                Text(
                  'Active Organization API Keys:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Key Label')),
                      DataColumn(label: Text('API Token Secret')),
                      DataColumn(label: Text('Scope')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: ref.watch(orgApiKeysProvider).map((key) {
                      return DataRow(
                        cells: [
                          DataCell(Text(key.keyName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700))),
                          DataCell(Text(key.apiKey,
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppColors.primary))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                key.scope,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.secondary),
                              ),
                            ),
                          ),
                          DataCell(
                            Switch(
                              value: key.isActive,
                              onChanged: (val) {
                                ref
                                    .read(orgApiKeysProvider.notifier)
                                    .toggleKeyStatus(key.id);
                              },
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.redAccent, size: 18),
                              onPressed: () {
                                ref
                                    .read(orgApiKeysProvider.notifier)
                                    .revokeKey(key.id);
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 12),

                // Webhooks Sub-Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Real-Time Webhook Event Subscriptions:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(orgWebhooksProvider.notifier).addWebhook(
                              'https://api.sunrisetrust.edu.in/webhooks/custom-events',
                              'fee.paid, attendance.alert',
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('New Webhook Endpoint Added!')),
                        );
                      },
                      icon: const Icon(Icons.webhook_rounded, size: 16),
                      label: const Text('+ Register Webhook'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Column(
                  children: ref.watch(orgWebhooksProvider).map((hook) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBg : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.webhook_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hook.targetUrl,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  'Events: ${hook.events}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Test Webhook Payload Delivered (HTTP 200 OK)!')),
                              );
                            },
                            child: const Text('Test Payload'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: Colors.redAccent, size: 18),
                            onPressed: () {
                              ref
                                  .read(orgWebhooksProvider.notifier)
                                  .deleteWebhook(hook.id);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Disaster Recovery & Automated Backup Settings Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organization Disaster Recovery & Automated Backup Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Automated cloud replication, encryption standards & point-in-time snapshot recovery',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user_rounded,
                              color: Colors.green, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Disaster Recovery Ready (RPO: 5m, RTO: 15m)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: 'AWS_S3_MUMBAI',
                        decoration: InputDecoration(
                          labelText: 'Cloud Storage Destination Target',
                          prefixIcon: const Icon(Icons.cloud_done_rounded, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'AWS_S3_MUMBAI',
                              child: Text('AWS S3 (ap-south-1 Mumbai Region)',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'GCP_MUMBAI',
                              child: Text('Google Cloud Storage (asia-south1)',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'AZURE_INDIA',
                              child: Text('Azure Blob Storage (Central India)',
                                  style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {},
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: 'DAILY_MIDNIGHT',
                        decoration: InputDecoration(
                          labelText: 'Snapshot Replication Schedule',
                          prefixIcon: const Icon(Icons.update_rounded, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'DAILY_MIDNIGHT',
                              child: Text('Daily Snapshot at 00:00 UTC',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'HOURLY_DELTA',
                              child: Text('Hourly Incremental Delta Sync',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'WEEKLY_FULL',
                              child: Text('Weekly Full System Cold Dump',
                                  style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Encryption Standard: AES-256 GCM • Retention Policy: 365 Days • PITR Snapshot Enabled',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Downloading Disaster Recovery Blueprint PDF...')),
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                          label: const Text('DR Blueprint PDF'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                    'Manual Cloud Backup Snapshot Triggered Successfully!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.backup_rounded, size: 16),
                          label: const Text('Initiate Instant Manual Backup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Organization Broadcast Announcements Log Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dispatched Organization Broadcast Announcements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              const BroadcastAnnouncementModal(),
                        );
                      },
                      icon: const Icon(Icons.campaign_rounded, size: 16),
                      label: const Text('+ New Broadcast'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Broadcast ID')),
                      DataColumn(label: Text('Priority')),
                      DataColumn(label: Text('Title & Directive Message')),
                      DataColumn(label: Text('Target Scope')),
                      DataColumn(label: Text('Dispatched By')),
                      DataColumn(label: Text('Broadcast Date')),
                    ],
                    rows: ref
                        .watch(organizationAnnouncementsProvider)
                        .map((bcast) {
                      return DataRow(
                        cells: [
                          DataCell(Text(bcast.id,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: bcast.priority == 'Emergency'
                                    ? Colors.red.withValues(alpha: 0.15)
                                    : (bcast.priority == 'Urgent'
                                        ? Colors.orange.withValues(alpha: 0.15)
                                        : Colors.blue.withValues(alpha: 0.15)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                bcast.priority.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: bcast.priority == 'Emergency'
                                      ? Colors.red
                                      : (bcast.priority == 'Urgent'
                                          ? Colors.orange
                                          : Colors.blue),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(bcast.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                                Text(bcast.content,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          DataCell(Text(bcast.targetBranches)),
                          DataCell(Text(bcast.sentBy)),
                          DataCell(Text(_formatDate(bcast.broadcastAt))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // White-Label Settings & Default Organization Branding Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organization White-Label Customization & Default Branding',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'Custom primary colors, trust logos, white-label subdomains & custom email signatures across all branch portals',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Primary Brand Theme Palette:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildColorPaletteChip('#6366F1', const Color(0xFF6366F1), org, isDark),
                              const SizedBox(width: 8),
                              _buildColorPaletteChip('#10B981', const Color(0xFF10B981), org, isDark),
                              const SizedBox(width: 8),
                              _buildColorPaletteChip('#3B82F6', const Color(0xFF3B82F6), org, isDark),
                              const SizedBox(width: 8),
                              _buildColorPaletteChip('#F59E0B', const Color(0xFFF59E0B), org, isDark),
                              const SizedBox(width: 8),
                              _buildColorPaletteChip('#EC4899', const Color(0xFFEC4899), org, isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Custom Enterprise Subdomain:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBg : AppColors.lightBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.language_rounded,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  org.subdomain,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Custom Trust Logo Uploaded!')),
                            );
                          },
                          icon: const Icon(Icons.upload_file_rounded, size: 16),
                          label: const Text('Upload Trust Logo PNG/SVG'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Custom Favicon Updated!')),
                            );
                          },
                          icon: const Icon(Icons.image_rounded, size: 16),
                          label: const Text('Change Favicon'),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.secondary,
                            content: Text(
                                'White-Label Branding Settings Saved Successfully!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.palette_rounded, size: 16),
                      label: const Text('Save Branding Assets'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Organization Deactivation and Data Archival Policy Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organization Deactivation & Data Archival Policy (Governance)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.redAccent,
                          ),
                        ),
                        Text(
                          'Statutory cold data archiving, grace period lock & tenant deactivation policies',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.redAccent, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Super Admin Safeguards Active',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: 'STATUTORY_7_YEARS',
                        decoration: InputDecoration(
                          labelText: 'Data Archival Retention Standard',
                          prefixIcon: const Icon(Icons.archive_rounded, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'STATUTORY_7_YEARS',
                              child: Text('7 Years Statutory Tax/Academic Archival',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'STATUTORY_10_YEARS',
                              child: Text('10 Years Comprehensive Archival',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'GLACIER_PERMANENT',
                              child: Text('Permanent AWS Glacier Cold Vault',
                                  style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {},
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: 'GRACE_90_DAYS',
                        decoration: InputDecoration(
                          labelText: 'Deactivation Grace Period Lock',
                          prefixIcon: const Icon(Icons.lock_clock_rounded, size: 18),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'GRACE_90_DAYS',
                              child: Text('90 Days Read-Only Grace Period',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'GRACE_30_DAYS',
                              child: Text('30 Days Express Grace Lock',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'IMMEDIATE_PURGE',
                              child: Text('Immediate Read-Only Archival',
                                  style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (val) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Deactivation will suspend access to all branches and move student/staff databases to Glacier Cold Vault.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showDeactivationConfirmationDialog(context, org),
                      icon: const Icon(Icons.no_accounts_rounded, size: 16),
                      label: const Text('Initiate Archival & Deactivate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Audit Log Table
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organization Audit Log (Security & Compliance)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Action')),
                      DataColumn(label: Text('User')),
                      DataColumn(label: Text('Timestamp')),
                      DataColumn(label: Text('Audit Details')),
                    ],
                    rows: org.auditLogs.map((log) {
                      return DataRow(
                        cells: [
                          DataCell(Text(log['action'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary))),
                          DataCell(Text(log['user'] as String)),
                          DataCell(Text(log['timestamp'] as String)),
                          DataCell(Text(log['details'] as String)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPaletteChip(
    String hex,
    Color color,
    OrganizationEntity org,
    bool isDark,
  ) {
    final isSelected = org.brandPrimaryColorHex.toUpperCase() == hex.toUpperCase();
    return InkWell(
      onTap: () {
        ref.read(organizationProvider.notifier).updatePrimaryColor(hex);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated primary brand theme color to $hex')),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 6, backgroundColor: color),
            const SizedBox(width: 6),
            Text(
              hex,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeactivationConfirmationDialog(
      BuildContext context, OrganizationEntity org) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text('Deactivate Organization & Cold Archive Data'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WARNING: You are about to initiate cold data archival for "${org.name}". Access to all branches will be locked into read-only grace period mode.',
                style: const TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
              const SizedBox(height: 14),
              Text(
                'Type "${org.name}" below to confirm deactivation:',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(
                  hintText: org.name,
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (confirmController.text.trim() == org.name) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(
                          'Organization Deactivation & Cold Data Archival Initiated!'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Organization name mismatch. Action cancelled.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Archival & Deactivate'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatCurrency(int value) {
    final str = value.toString();
    if (str.length <= 3) return str;
    
    final lastThree = str.substring(str.length - 3);
    var remaining = str.substring(0, str.length - 3);
    
    final chunks = <String>[];
    while (remaining.length > 2) {
      chunks.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      chunks.insert(0, remaining);
    }
    
    return '${chunks.join(",")},$lastThree';
  }
}

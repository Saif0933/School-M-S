import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../academic/providers.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class ReportsAnalyticsPage extends ConsumerStatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  ConsumerState<ReportsAnalyticsPage> createState() =>
      _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends ConsumerState<ReportsAnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Custom Builder States
  String _selectedReportBranch = 'BR-001';
  String _selectedReportCategory = 'Finance';
  String _selectedExportFormat = 'PDF';

  // Schedule States
  final _scheduleEmailCtrl = TextEditingController(
    text: 'operations.head@school.com',
  );
  String _selectedScheduleFrequency = 'Weekly';
  String _selectedScheduleTemplate = 'Daily Cash Book Collections Ledger';

  // Drill-down State
  String? _drillBranchId;
  String? _drillClassId;
  String? _drillSectionId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scheduleEmailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';

    return Scaffold(
      body: Column(
        children: [
          // Sub Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark
                ? Colors.white10
                : Colors.grey.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports & Consolidated Analytics Desk: ${user?.activeBranch?.branchName ?? "Primary Campus"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Role Access: ${user?.role.label ?? "Manager"} | Analytics Scope: ${user?.role.isOrgLevel == true ? "Organization-Wide" : "Branch-Scoped"}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom TabBar
          Container(
            color: isDark ? Colors.black12 : Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              tabs: [
                const Tab(
                  icon: Icon(Icons.dashboard_rounded, size: 16),
                  text: 'Executive KPIs',
                ),
                if (user?.role.isOrgLevel == true)
                  const Tab(
                    icon: Icon(Icons.business_rounded, size: 16),
                    text: 'Org Consolidated',
                  ),
                const Tab(
                  icon: Icon(Icons.build_circle_rounded, size: 16),
                  text: 'Custom Builder',
                ),
                const Tab(
                  icon: Icon(Icons.star_rounded, size: 16),
                  text: '50+ Pre-built Templates',
                ),
                const Tab(
                  icon: Icon(Icons.schedule_send_rounded, size: 16),
                  text: 'Scheduler & Share',
                ),
                const Tab(
                  icon: Icon(Icons.account_tree_rounded, size: 16),
                  text: 'Drill-Down Browser',
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _KPIsTab(branchId: activeBranchId),
                if (user?.role.isOrgLevel == true)
                  const _OrgConsolidatedTab()
                else
                  const SizedBox.shrink(),
                _CustomBuilderTab(
                  selectedBranch: _selectedReportBranch,
                  selectedCategory: _selectedReportCategory,
                  selectedFormat: _selectedExportFormat,
                  onBranchChanged: (val) =>
                      setState(() => _selectedReportBranch = val ?? 'BR-001'),
                  onCategoryChanged: (val) => setState(
                    () => _selectedReportCategory = val ?? 'Finance',
                  ),
                  onFormatChanged: (val) =>
                      setState(() => _selectedExportFormat = val ?? 'PDF'),
                ),
                const _TemplatesTab(),
                _SchedulerTab(
                  emailCtrl: _scheduleEmailCtrl,
                  selectedFreq: _selectedScheduleFrequency,
                  selectedTemplate: _selectedScheduleTemplate,
                  onFreqChanged: (val) => setState(
                    () => _selectedScheduleFrequency = val ?? 'Weekly',
                  ),
                  onTemplateChanged: (val) => setState(
                    () => _selectedScheduleTemplate =
                        val ?? 'Daily Cash Book Collections Ledger',
                  ),
                ),
                _DrillDownTab(
                  drillBranchId: _drillBranchId,
                  drillClassId: _drillClassId,
                  drillSectionId: _drillSectionId,
                  onBranchSelected: (val) =>
                      setState(() => _drillBranchId = val),
                  onClassSelected: (val) => setState(() => _drillClassId = val),
                  onSectionSelected: (val) =>
                      setState(() => _drillSectionId = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 1 — Branch Executive KPIs & Heatmaps
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _KPIsTab extends ConsumerWidget {
  final String branchId;
  const _KPIsTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref
        .watch(academicStudentsProvider)
        .where((s) => s.branchId == branchId)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Branch Core Performance KPIs',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: MediaQuery.of(context).size.width < 450 ? 1.2 : 1.5,
            children: [
              _kpiCard('Enrollments', '${students.length}', Colors.blue),
              _kpiCard('Attendance Rate', '93.5%', Colors.green),
              _kpiCard('Library Stock', '1,450 Books', Colors.indigo),
              _kpiCard('Outflow Budget', '₹75,000', Colors.orange),
            ],
          ),
          const SizedBox(height: 24),

          // Attendance heatmap simulation
          const Text(
            '🌡️ Class Attendance Heat Map (Visual Audits)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isHeatMobile = constraints.maxWidth < 550;
              final cards = [
                _heatCard('Class 1 Delhi', '96%', Colors.green),
                _heatCard('Class 10 Mumbai', '88%', Colors.orange),
                _heatCard('Class 12 Commerce', '72%', Colors.red),
              ];

              return isHeatMobile
                  ? Column(
                      children: cards
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SizedBox(width: double.infinity, child: c),
                              ))
                          .toList(),
                    )
                  : Row(
                      children: cards
                          .map((c) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: c,
                                ),
                              ))
                          .toList(),
                    );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            '📈 Class-Wise Exam Grade Average Scoring',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: Colors.grey.withValues(alpha: 0.2)),
            children: const [
              TableRow(
                decoration: BoxDecoration(color: Colors.white10),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Academic Class',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Exam Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Subject Average',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Attainment Rank',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Class 10 Science',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Half-Yearly 2026',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      '85.4% (Grade A)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Rank 1', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Class 12 Commerce',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Final Exams 2026',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      '74.2% (Grade B)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Rank 2', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(String label, String value, Color color) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heatCard(String label, String pct, Color heatColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: heatColor.withValues(alpha: 0.15),
        border: Border.all(color: heatColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            pct,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: heatColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 2 — Organization Consolidated Dashboard
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _OrgConsolidatedTab extends ConsumerWidget {
  const _OrgConsolidatedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStudents = ref.watch(academicStudentsProvider);
    final delhiStudents = allStudents
        .where((s) => s.branchId == 'BR-001')
        .toList();
    final mumbaiStudents = allStudents
        .where((s) => s.branchId == 'BR-002')
        .toList();

    // Pred metrics
    final forecasts = ref.watch(predictiveAnalyticsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏢 Organization consolidated revenue & enrollment summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCardsMobile = constraints.maxWidth < 550;
              final enrolledCard = GlassCard(
                child: Column(
                  children: [
                    const Text(
                      'Total Students Enrolled',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '${allStudents.length}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              );

              final revenueCard = GlassCard(
                child: Column(
                  children: [
                    const Text(
                      'Consolidated Revenue Dues',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const Text(
                      '₹5,00,000',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );

              return isCardsMobile
                  ? Column(
                      children: [
                        enrolledCard,
                        const SizedBox(height: 12),
                        revenueCard,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: enrolledCard),
                        const SizedBox(width: 16),
                        Expanded(child: revenueCard),
                      ],
                    );
            },
          ),
          const SizedBox(height: 24),

          // Comparative table
          const Text(
            '⚖️ Side-by-Side Campus Comparison (Delhi vs Mumbai)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: Colors.grey.withValues(alpha: 0.2)),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Colors.white10),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Metrics Detail',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Delhi Campus (BR-001)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Mumbai Campus (BR-002)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Student Count',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '${delhiStudents.length} Students',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '${mumbaiStudents.length} Students',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Attendance Averages',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('94.2%', style: TextStyle(fontSize: 11)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('92.6%', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Academic Ranking',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Rank 1 (Topper center)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Rank 2', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            '🔮 Predictive Enrollment & Revenue Growth Forecasts',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Forecasted values based on admission inquiries, daily leads conversion rate, and fee clearances trends.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ...forecasts.map(
            (f) => Card(
              child: ListTile(
                title: Text(
                  f.branchId == 'BR-001'
                      ? 'Delhi Central SIS'
                      : 'Mumbai South SPS',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  'Proj Enrollment: ${f.projectedEnrollment.toStringAsFixed(0)} (+14%)\nProj Revenue: ₹${f.projectedRevenue.toStringAsFixed(0)} (+12%)',
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: f.growthTrend == 'Strong Growth'
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    f.growthTrend,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: f.growthTrend == 'Strong Growth'
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 3 — Custom Report Builder
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _CustomBuilderTab extends StatelessWidget {
  final String selectedBranch;
  final String selectedCategory;
  final String selectedFormat;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onFormatChanged;

  const _CustomBuilderTab({
    required this.selectedBranch,
    required this.selectedCategory,
    required this.selectedFormat,
    required this.onBranchChanged,
    required this.onCategoryChanged,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🛠️ Report Filter & Custom Builder',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: selectedBranch,
            decoration: const InputDecoration(labelText: 'Target Branch scope'),
            items: const [
              DropdownMenuItem(
                value: 'BR-001',
                child: Text('Delhi Central Campus (BR-001)'),
              ),
              DropdownMenuItem(
                value: 'BR-002',
                child: Text('Mumbai South Campus (BR-002)'),
              ),
            ],
            onChanged: onBranchChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            decoration: const InputDecoration(labelText: 'Report Category'),
            items: const [
              DropdownMenuItem(
                value: 'Finance',
                child: Text('Finance Collections & P&L'),
              ),
              DropdownMenuItem(
                value: 'Academics',
                child: Text('Student Grades & Performance'),
              ),
              DropdownMenuItem(
                value: 'Staff',
                child: Text('Staff Rosters & Substitution'),
              ),
              DropdownMenuItem(
                value: 'Assets',
                child: Text('Inventory stock & Barcode tags'),
              ),
            ],
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedFormat,
            decoration: const InputDecoration(labelText: 'Export Format type'),
            items: const [
              DropdownMenuItem(
                value: 'PDF',
                child: Text('PDF document (.pdf)'),
              ),
              DropdownMenuItem(
                value: 'Excel',
                child: Text('Excel spreadsheet (.xlsx)'),
              ),
              DropdownMenuItem(value: 'CSV', child: Text('CSV text (.csv)')),
              DropdownMenuItem(
                value: 'Word',
                child: Text('Word Document (.docx)'),
              ),
            ],
            onChanged: onFormatChanged,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _triggerCustomReportExport(context),
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: const Text(
                'Generate & Export Report',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerCustomReportExport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ Generating custom $selectedCategory report for $selectedBranch. Downloading as $selectedFormat file...',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 4 — 50+ Pre-built Templates & Bookmarks
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _TemplatesTab extends ConsumerWidget {
  const _TemplatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(reportTemplatesProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final t = templates[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCardMobile = constraints.maxWidth < 450;
                final textColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${t.category}\n${t.description}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                );

                final actionRow = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        t.isBookmarked
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: t.isBookmarked ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () => ref
                          .read(reportTemplatesProvider.notifier)
                          .toggleBookmark(t.id),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(60, 24),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => _runTemplate(context, t.name),
                      child: const Text(
                        'Run',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ],
                );

                return isCardMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textColumn,
                          const SizedBox(height: 8),
                          Align(alignment: Alignment.centerRight, child: actionRow),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: textColumn),
                          const SizedBox(width: 16),
                          actionRow,
                        ],
                      );
              },
            ),
          ),
        );
      },
    );
  }

  void _runTemplate(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✓ Running pre-built template: $name...')),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 5 — Auto-dispatch Scheduler & Share
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _SchedulerTab extends ConsumerWidget {
  final TextEditingController emailCtrl;
  final String selectedFreq;
  final String selectedTemplate;
  final ValueChanged<String?> onFreqChanged;
  final ValueChanged<String?> onTemplateChanged;

  const _SchedulerTab({
    required this.emailCtrl,
    required this.selectedFreq,
    required this.selectedTemplate,
    required this.onFreqChanged,
    required this.onTemplateChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(scheduledReportsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⏰ Schedule Auto-Email Reports',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'Recipient Email'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedFreq,
            decoration: const InputDecoration(
              labelText: 'Email Dispatch Frequency',
            ),
            items: const [
              DropdownMenuItem(value: 'Daily', child: Text('Daily Summary')),
              DropdownMenuItem(value: 'Weekly', child: Text('Weekly Summary')),
              DropdownMenuItem(value: 'Monthly', child: Text('Monthly Audit')),
            ],
            onChanged: onFreqChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedTemplate,
            decoration: const InputDecoration(
              labelText: 'Selected Report Template',
            ),
            items: const [
              DropdownMenuItem(
                value: 'Daily Cash Book Collections Ledger',
                child: Text('Daily Cash Book Collections Ledger'),
              ),
              DropdownMenuItem(
                value: 'Outstanding Overdue Fees & Late Fines',
                child: Text('Outstanding Overdue Fees & Late Fines'),
              ),
              DropdownMenuItem(
                value: 'Student Attendance Summary (Monthly)',
                child: Text('Student Attendance Summary (Monthly)'),
              ),
            ],
            onChanged: onTemplateChanged,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                ref
                    .read(scheduledReportsProvider.notifier)
                    .scheduleReport(
                      ScheduledReportEntity(
                        id: 'SCH-${DateTime.now().millisecondsSinceEpoch}',
                        templateName: selectedTemplate,
                        email: emailCtrl.text,
                        frequency: selectedFreq,
                        status: 'Active',
                      ),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '✓ Report scheduling configured successfully!',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.schedule_rounded, color: Colors.white),
              label: const Text(
                'Add Dispatch Schedule',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '📜 Active Scheduled Reports list:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...schedules.map(
            (sch) => Card(
              child: ListTile(
                title: Text(
                  sch.templateName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                subtitle: Text(
                  'Email: ${sch.email} | Frequency: ${sch.frequency}',
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                  onPressed: () => ref
                      .read(scheduledReportsProvider.notifier)
                      .removeSchedule(sch.id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 6 — Drill-down Interactive Browser
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _DrillDownTab extends ConsumerWidget {
  final String? drillBranchId;
  final String? drillClassId;
  final String? drillSectionId;
  final ValueChanged<String?> onBranchSelected;
  final ValueChanged<String?> onClassSelected;
  final ValueChanged<String?> onSectionSelected;

  const _DrillDownTab({
    required this.drillBranchId,
    required this.drillClassId,
    required this.drillSectionId,
    required this.onBranchSelected,
    required this.onClassSelected,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStudents = ref.watch(academicStudentsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔍 Interactive Multi-Branch Data Drill-Down Browser',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Analyze metrics at each hierarchy level: Organization ➔ Branch ➔ Class ➔ Section ➔ Student list.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Hierarchy Selection Indicators
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _levelChip('Campus Branch', drillBranchId ?? 'Select', () {
                onBranchSelected(null);
                onClassSelected(null);
                onSectionSelected(null);
              }),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 16),
              _levelChip('Class level', drillClassId ?? 'Select', () {
                onClassSelected(null);
                onSectionSelected(null);
              }),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 16),
              _levelChip('Section', drillSectionId ?? 'Select', () {
                onSectionSelected(null);
              }),
            ],
          ),
          const SizedBox(height: 24),

          // Display List content based on hierarchy level
          if (drillBranchId == null) ...[
            const Text(
              'Level 1: Choose Campus Branch:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _drillTile(
              'Delhi Central International SIS Campus (BR-001)',
              () => onBranchSelected('BR-001'),
            ),
            _drillTile(
              'Mumbai South Public SPS Campus (BR-002)',
              () => onBranchSelected('BR-002'),
            ),
          ] else if (drillClassId == null) ...[
            const Text(
              'Level 2: Choose Academic Class:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (drillBranchId == 'BR-001') ...[
              _drillTile('Class 1 Primary', () => onClassSelected('CLS-001')),
              _drillTile(
                'Class 11 Science Secondary',
                () => onClassSelected('CLS-011'),
              ),
            ] else ...[
              _drillTile(
                'Class 10 Secondary board',
                () => onClassSelected('CLS-010'),
              ),
            ],
          ] else if (drillSectionId == null) ...[
            const Text(
              'Level 3: Choose Section division:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _drillTile(
              'Section A division',
              () => onSectionSelected('SEC-A-001'),
            ),
          ] else ...[
            const Text(
              'Level 4: Enrolled Students roster list:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ...allStudents
                .where((s) => s.branchId == drillBranchId)
                .map(
                  (student) => Card(
                    child: ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.person_rounded,
                        color: Colors.grey,
                      ),
                      title: Text(
                        student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      subtitle: Text(
                        'Adm No: ${student.admissionNumber} | Phone: ${student.phone}',
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _levelChip(String title, String val, VoidCallback onClear) {
    final active = val != 'Select';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          '$title: $val',
          style: TextStyle(fontSize: 10, color: active ? Colors.white : null),
        ),
        backgroundColor: active ? AppColors.primary : null,
        onPressed: onClear,
      ),
    );
  }

  Widget _drillTile(String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../../academic/providers.dart'; // Academic providers containing Fees and Accounting providers
import '../../../../shared/widgets/layout/responsive_flex.dart';

class FeesManagementPage extends ConsumerStatefulWidget {
  const FeesManagementPage({super.key});

  @override
  ConsumerState<FeesManagementPage> createState() => _FeesManagementPageState();
}

class _FeesManagementPageState extends ConsumerState<FeesManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Student Assignment form state
  String? _selectedStudentId;
  String? _selectedFeeHeadId;
  String? _selectedInstallmentPlanId;
  String? _selectedConcessionId;

  // Payments filter
  String _paymentStatusFilter = 'All';

  // Toggle for parent portal vs counter collection
  String _collectionViewMode = 'Cashier Counter'; // 'Cashier Counter', 'Parent Portal'

  // Receipts tab filter
  String _receiptsSubView = 'Receipts'; // 'Receipts', 'Daybook', 'Audit Trail'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranch?.branchId ?? 'BR-001';

    return Column(
      children: [
        // ─── Tab Bar ──────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.account_balance_wallet_rounded, size: 16),
                text: 'Fee Structures',
              ),
              Tab(
                icon: Icon(Icons.date_range_rounded, size: 16),
                text: 'Installment Plans',
              ),
              Tab(
                icon: Icon(Icons.assignment_ind_rounded, size: 16),
                text: 'Fee Assignments',
              ),
              Tab(
                icon: Icon(Icons.payments_rounded, size: 16),
                text: 'Collect Fees',
              ),
              Tab(
                icon: Icon(Icons.savings_rounded, size: 16),
                text: 'Student Advances',
              ),
              Tab(
                icon: Icon(Icons.local_offer_rounded, size: 16),
                text: 'Concessions',
              ),
              Tab(
                icon: Icon(Icons.receipt_long_rounded, size: 16),
                text: 'Receipts & Daybook',
              ),
              Tab(
                icon: Icon(Icons.text_snippet_rounded, size: 16),
                text: 'Voucher Ledger',
              ),
              Tab(
                icon: Icon(Icons.account_balance_rounded, size: 16),
                text: 'Bank Reconciliation',
              ),
              Tab(
                icon: Icon(Icons.assessment_rounded, size: 16),
                text: 'Accounting Reports',
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // ─── Tab Views ────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _FeeHeadsTab(branchId: activeBranchId),
              _InstallmentPlansTab(branchId: activeBranchId),
              _StudentFeeAssignmentsTab(
                branchId: activeBranchId,
                selectedStudentId: _selectedStudentId,
                selectedFeeHeadId: _selectedFeeHeadId,
                selectedInstallmentPlanId: _selectedInstallmentPlanId,
                selectedConcessionId: _selectedConcessionId,
                onStudentChanged: (v) => setState(() => _selectedStudentId = v),
                onFeeHeadChanged: (v) => setState(() => _selectedFeeHeadId = v),
                onInstallmentPlanChanged: (v) => setState(() => _selectedInstallmentPlanId = v),
                onConcessionChanged: (v) => setState(() => _selectedConcessionId = v),
              ),
              _CollectFeesTab(
                branchId: activeBranchId,
                statusFilter: _paymentStatusFilter,
                viewMode: _collectionViewMode,
                onStatusFilterChanged: (v) => setState(() => _paymentStatusFilter = v),
                onViewModeChanged: (v) => setState(() => _collectionViewMode = v),
              ),
              _StudentAdvancesTab(branchId: activeBranchId),
              _ConcessionsTab(branchId: activeBranchId),
              _ReceiptsDaybookTab(
                branchId: activeBranchId,
                subView: _receiptsSubView,
                onSubViewChanged: (v) => setState(() => _receiptsSubView = v),
              ),
              _VoucherLedgerTab(branchId: activeBranchId),
              _BankReconciliationTab(branchId: activeBranchId),
              _AccountingReportsTab(branchId: activeBranchId),
            ],
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 1 — Fee Structures (Heads)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _FeeHeadsTab extends ConsumerStatefulWidget {
  final String branchId;
  const _FeeHeadsTab({required this.branchId});

  @override
  ConsumerState<_FeeHeadsTab> createState() => _FeeHeadsTabState();
}

class _FeeHeadsTabState extends ConsumerState<_FeeHeadsTab> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _category = 'Tuition';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final feeHeads = ref.watch(feeHeadsProvider)
        .where((h) => h.branchId == widget.branchId)
        .toList();
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Fee Head Form
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Branch Fee Head', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
                const SizedBox(height: 16),
                ResponsiveRowColumn(
                  children: [
                    Expanded(
                      child: _FormField(controller: _nameCtrl, label: 'Fee Head Name (e.g. Tuition Fee)', isDark: isDark),
                    ),
                    Expanded(
                      child: _FormField(controller: _amountCtrl, label: 'Amount (INR)', isDark: isDark, keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ResponsiveRowColumn(
                  children: [
                    Expanded(
                      child: _FormField(controller: _descCtrl, label: 'Description', isDark: isDark),
                    ),
                    Expanded(
                      child: _DropdownFilter(
                        label: 'Category',
                        value: _category,
                        items: const ['Admission', 'Tuition', 'Exam', 'Transport', 'Hostel', 'Other'],
                        displayItems: const ['Admission', 'Tuition', 'Exam', 'Transport', 'Hostel', 'Other'],
                        onChanged: (v) => setState(() => _category = v),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_nameCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) return;
                    ref.read(feeHeadsProvider.notifier).addFeeHead(
                      FeeHeadEntity(
                        id: 'FH-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: widget.branchId,
                        name: _nameCtrl.text.trim(),
                        description: _descCtrl.text.trim(),
                        amount: double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
                        category: _category,
                      ),
                    );

                    // Audit trail log
                    ref.read(financialAuditTrailProvider.notifier).logAudit(
                      FinancialAuditTrailEntity(
                        id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: widget.branchId,
                        timestamp: DateTime.now(),
                        actionType: 'BudgetUpdated',
                        description: 'New fee structure added: ${_nameCtrl.text.trim()} (Category: $_category, Amount: ₹${_amountCtrl.text.trim()})',
                        performedBy: 'Head Accountant',
                        ipAddress: '192.168.1.15',
                      ),
                    );

                    _nameCtrl.clear();
                    _descCtrl.clear();
                    _amountCtrl.clear();
                    _showSnack(context, 'Fee Head created successfully!');
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Fee Head'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Active Fee Structures', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
          const SizedBox(height: 10),
          if (feeHeads.isEmpty)
            Text('No fee structures defined for this branch.', style: TextStyle(color: textSec))
          else
            ...feeHeads.map((fh) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarySurface,
                        child: Icon(_categoryIcon(fh.category), color: AppColors.primary, size: 18),
                      ),
                      title: Text(fh.name, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                      subtitle: Text('${fh.category} • ${fh.description}', style: TextStyle(color: textSec, fontSize: 11)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('₹${fh.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 14)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                            onPressed: () {
                              ref.read(feeHeadsProvider.notifier).removeFeeHead(fh.id);
                              _showSnack(context, 'Fee structure deleted');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 2 — Installment Plans
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _InstallmentPlansTab extends ConsumerStatefulWidget {
  final String branchId;
  const _InstallmentPlansTab({required this.branchId});

  @override
  ConsumerState<_InstallmentPlansTab> createState() => _InstallmentPlansTabState();
}

class _InstallmentPlansTabState extends ConsumerState<_InstallmentPlansTab> {
  final _nameCtrl = TextEditingController();
  final _countCtrl = TextEditingController();
  final _lateFeePercentageCtrl = TextEditingController();
  final _graceDaysCtrl = TextEditingController();
  String _frequency = 'Monthly';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _countCtrl.dispose();
    _lateFeePercentageCtrl.dispose();
    _graceDaysCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plans = ref.watch(feeInstallmentPlansProvider)
        .where((p) => p.branchId == widget.branchId)
        .toList();
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Installment Plan
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Installment Plan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
                const SizedBox(height: 16),
                ResponsiveRowColumn(
                  children: [
                    Expanded(
                      child: _FormField(controller: _nameCtrl, label: 'Plan Name (e.g. Quarterly Saver)', isDark: isDark),
                    ),
                    Expanded(
                      child: _FormField(controller: _countCtrl, label: 'Installments Count', isDark: isDark, keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DropdownFilter(
                        label: 'Frequency',
                        value: _frequency,
                        items: const ['Monthly', 'Quarterly', 'Half-Yearly', 'Annually'],
                        displayItems: const ['Monthly', 'Quarterly', 'Half-Yearly', 'Annually'],
                        onChanged: (v) => setState(() => _frequency = v),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormField(controller: _lateFeePercentageCtrl, label: 'Late Fee % per month', isDark: isDark, keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormField(controller: _graceDaysCtrl, label: 'Grace Period (Days)', isDark: isDark, keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_nameCtrl.text.trim().isEmpty || _countCtrl.text.trim().isEmpty) return;
                    ref.read(feeInstallmentPlansProvider.notifier).addInstallmentPlan(
                      FeeInstallmentPlanEntity(
                        id: 'IP-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: widget.branchId,
                        name: _nameCtrl.text.trim(),
                        installmentsCount: int.tryParse(_countCtrl.text.trim()) ?? 1,
                        frequency: _frequency,
                        lateFeePercentage: double.tryParse(_lateFeePercentageCtrl.text.trim()) ?? 0.0,
                        graceDays: int.tryParse(_graceDaysCtrl.text.trim()) ?? 0,
                      ),
                    );
                    _nameCtrl.clear();
                    _countCtrl.clear();
                    _lateFeePercentageCtrl.clear();
                    _graceDaysCtrl.clear();
                    _showSnack(context, 'Installment Plan created!');
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Plan'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Active Installment Plans', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
          const SizedBox(height: 10),
          if (plans.isEmpty)
            Text('No installment plans defined for this branch.', style: TextStyle(color: textSec))
          else
            ...plans.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primarySurface,
                        child: Icon(Icons.date_range_rounded, color: AppColors.primary, size: 18),
                      ),
                      title: Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                      subtitle: Text(
                        'Frequency: ${p.frequency} • ${p.installmentsCount} cycles • Late Fee: ${p.lateFeePercentage}% • Grace Period: ${p.graceDays} days',
                        style: TextStyle(color: textSec, fontSize: 11),
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 3 — Student Fee Assignments
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _StudentFeeAssignmentsTab extends ConsumerWidget {
  final String branchId;
  final String? selectedStudentId;
  final String? selectedFeeHeadId;
  final String? selectedInstallmentPlanId;
  final String? selectedConcessionId;
  final ValueChanged<String?> onStudentChanged;
  final ValueChanged<String?> onFeeHeadChanged;
  final ValueChanged<String?> onInstallmentPlanChanged;
  final ValueChanged<String?> onConcessionChanged;

  const _StudentFeeAssignmentsTab({
    required this.branchId,
    required this.selectedStudentId,
    required this.selectedFeeHeadId,
    required this.selectedInstallmentPlanId,
    required this.selectedConcessionId,
    required this.onStudentChanged,
    required this.onFeeHeadChanged,
    required this.onInstallmentPlanChanged,
    required this.onConcessionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final students = ref.watch(academicStudentsProvider).where((s) => s.branchId == branchId).toList();
    final feeHeads = ref.watch(feeHeadsProvider).where((h) => h.branchId == branchId).toList();
    final installmentPlans = ref.watch(feeInstallmentPlansProvider).where((p) => p.branchId == branchId).toList();
    final concessions = ref.watch(feeConcessionsProvider).where((c) => c.branchId == branchId).toList();
    final assignments = ref.watch(studentFeeAssignmentsProvider).where((a) => a.branchId == branchId).toList();

    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assign fee to student card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assign Fee to Student', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (students.isNotEmpty)
                      SizedBox(
                        width: 200,
                        child: _DropdownFilter(
                          label: 'Student',
                          value: selectedStudentId ?? students.first.id,
                          items: students.map((s) => s.id).toList(),
                          displayItems: students.map((s) => s.name).toList(),
                          onChanged: onStudentChanged,
                          isDark: isDark,
                        ),
                      ),
                    if (feeHeads.isNotEmpty)
                      SizedBox(
                        width: 200,
                        child: _DropdownFilter(
                          label: 'Fee Structure',
                          value: selectedFeeHeadId ?? feeHeads.first.id,
                          items: feeHeads.map((h) => h.id).toList(),
                          displayItems: feeHeads.map((h) => '${h.name} (₹${h.amount.toStringAsFixed(0)})').toList(),
                          onChanged: onFeeHeadChanged,
                          isDark: isDark,
                        ),
                      ),
                    if (installmentPlans.isNotEmpty)
                      SizedBox(
                        width: 200,
                        child: _DropdownFilter(
                          label: 'Installment Plan',
                          value: selectedInstallmentPlanId ?? installmentPlans.first.id,
                          items: installmentPlans.map((p) => p.id).toList(),
                          displayItems: installmentPlans.map((p) => p.name).toList(),
                          onChanged: onInstallmentPlanChanged,
                          isDark: isDark,
                        ),
                      ),
                    if (concessions.isNotEmpty)
                      SizedBox(
                        width: 200,
                        child: _DropdownFilter(
                          label: 'Scholarship / Concession',
                          value: selectedConcessionId ?? concessions.first.id,
                          items: concessions.map((c) => c.id).toList(),
                          displayItems: concessions.map((c) => '${c.name} (${c.type == "Percentage" ? "${c.value}%" : "₹${c.value.toStringAsFixed(0)}"})').toList(),
                          onChanged: onConcessionChanged,
                          isDark: isDark,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final stuId = selectedStudentId ?? (students.isNotEmpty ? students.first.id : null);
                    final fhId = selectedFeeHeadId ?? (feeHeads.isNotEmpty ? feeHeads.first.id : null);
                    final planId = selectedInstallmentPlanId ?? (installmentPlans.isNotEmpty ? installmentPlans.first.id : null);
                    final concId = selectedConcessionId ?? (concessions.isNotEmpty ? concessions.first.id : null);

                    if (stuId == null || fhId == null || planId == null) {
                      _showSnack(context, 'Please ensure student, fee structure and plan are selected!');
                      return;
                    }

                    final student = students.firstWhere((s) => s.id == stuId);
                    final feeHead = feeHeads.firstWhere((h) => h.id == fhId);
                    final plan = installmentPlans.firstWhere((p) => p.id == planId);

                    double discount = 0.0;
                    String concReason = 'None';
                    if (concId != null) {
                      final concession = concessions.firstWhere((c) => c.id == concId);
                      concReason = concession.name;
                      if (concession.type == 'Percentage') {
                        discount = (feeHead.amount * concession.value) / 100;
                      } else {
                        discount = concession.value;
                      }
                    }

                    ref.read(studentFeeAssignmentsProvider.notifier).assignFee(
                      StudentFeeAssignmentEntity(
                        id: 'FA-${DateTime.now().millisecondsSinceEpoch}',
                        studentId: stuId,
                        studentName: student.name,
                        branchId: branchId,
                        feeHeadId: fhId,
                        feeHeadName: feeHead.name,
                        installmentPlanId: planId,
                        installmentPlanName: plan.name,
                        assignedAmount: feeHead.amount,
                        discountAmount: discount,
                        concessionReason: concReason,
                        paidAmount: 0.0,
                        dueDate: DateTime.now().add(const Duration(days: 30)),
                        status: 'Unpaid',
                      ),
                    );
                    _showSnack(context, 'Fee assigned to student successfully!');
                  },
                  icon: const Icon(Icons.assignment_turned_in_rounded, size: 16),
                  label: const Text('Assign Fee Structure'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Active Fee Assignments', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
          const SizedBox(height: 10),
          if (assignments.isEmpty)
            Text('No active fee assignments logged.', style: TextStyle(color: textSec))
          else
            ...assignments.map((assignment) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(assignment.studentName, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                      subtitle: Text(
                        'Fee: ${assignment.feeHeadName} • Plan: ${assignment.installmentPlanName}\nWaiver: ${assignment.concessionReason} (₹${assignment.discountAmount.toStringAsFixed(0)})',
                        style: TextStyle(color: textSec, fontSize: 11),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(assignment.status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _statusColor(assignment.status).withOpacity(0.3)),
                        ),
                        child: Text(
                          assignment.status,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(assignment.status)),
                        ),
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 4 — Collect Fees & Online Parent Portal
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _CollectFeesTab extends ConsumerStatefulWidget {
  final String branchId;
  final String statusFilter;
  final String viewMode;
  final ValueChanged<String> onStatusFilterChanged;
  final ValueChanged<String> onViewModeChanged;

  const _CollectFeesTab({
    required this.branchId,
    required this.statusFilter,
    required this.viewMode,
    required this.onStatusFilterChanged,
    required this.onViewModeChanged,
  });

  @override
  ConsumerState<_CollectFeesTab> createState() => _CollectFeesTabState();
}

class _CollectFeesTabState extends ConsumerState<_CollectFeesTab> {
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  String _paymentMode = 'Cash';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assignments = ref.watch(studentFeeAssignmentsProvider)
        .where((a) => a.branchId == widget.branchId)
        .toList();
    final plans = ref.watch(feeInstallmentPlansProvider).where((p) => p.branchId == widget.branchId).toList();
    final receipts = ref.watch(feeReceiptsProvider).where((r) => r.branchId == widget.branchId).toList();
    final advanceBalances = ref.watch(studentAdvanceBalancesProvider).where((a) => a.branchId == widget.branchId).toList();

    final filtered = assignments.where((a) {
      if (widget.statusFilter == 'All') return true;
      return a.status == widget.statusFilter;
    }).toList();

    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    double calculateFine(StudentFeeAssignmentEntity fa) {
      if (fa.dueDate.isBefore(DateTime.now()) && fa.status != 'Paid') {
        try {
          final plan = plans.firstWhere((p) => p.id == fa.installmentPlanId);
          final overdueDate = fa.dueDate.add(Duration(days: plan.graceDays));
          if (DateTime.now().isAfter(overdueDate)) {
            final daysPast = DateTime.now().difference(overdueDate).inDays;
            final monthsPast = (daysPast / 30.0).ceil();
            final netPayable = fa.assignedAmount - fa.discountAmount;
            return netPayable * (plan.lateFeePercentage / 100) * monthsPast;
          }
        } catch (_) {}
      }
      return 0.0;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segments: Cashier collection vs Parent online portal
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Cashier Counter Desk')),
                  selected: widget.viewMode == 'Cashier Counter',
                  onSelected: (val) {
                    if (val) widget.onViewModeChanged('Cashier Counter');
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: widget.viewMode == 'Cashier Counter' ? Colors.white : textSec, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Parent Online Portal')),
                  selected: widget.viewMode == 'Parent Portal',
                  onSelected: (val) {
                    if (val) widget.onViewModeChanged('Parent Portal');
                  },
                  selectedColor: AppColors.secondary,
                  labelStyle: TextStyle(color: widget.viewMode == 'Parent Portal' ? Colors.white : textSec, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Paid', 'PartiallyPaid', 'Unpaid'].map((status) {
                final isSelected = widget.statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) widget.onStatusFilterChanged(status);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textSec,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          if (widget.viewMode == 'Parent Portal') ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_person_rounded, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Parent Secure Login Access: Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textPri)),
                        const Text('Authenticated with Branch token. Pay securely via card/UPI.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (filtered.isEmpty)
            Text('No invoices found matching status ${widget.statusFilter}.', style: TextStyle(color: textSec))
          else
            ...filtered.map((fa) {
              final netPayable = fa.assignedAmount - fa.discountAmount;
              final fine = calculateFine(fa);
              final totalDue = netPayable + fine - fa.paidAmount;

              final studentAdvance = advanceBalances.firstWhere(
                (ab) => ab.studentId == fa.studentId,
                orElse: () => StudentAdvanceBalanceEntity(
                  studentId: fa.studentId,
                  studentName: fa.studentName,
                  branchId: widget.branchId,
                  balance: 0.0,
                  lastUpdated: DateTime.now(),
                ),
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fa.studentName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor(fa.status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _statusColor(fa.status).withOpacity(0.3)),
                            ),
                            child: Text(
                              fa.status,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(fa.status)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Fee Type: ${fa.feeHeadName} • Installment: ${fa.installmentPlanName}', style: TextStyle(color: textSec, fontSize: 11)),
                      Text('Due Date: ${fa.dueDate.day}/${fa.dueDate.month}/${fa.dueDate.year}', style: TextStyle(color: textSec, fontSize: 11)),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Net Structure: ₹${netPayable.toStringAsFixed(0)}', style: TextStyle(color: textSec, fontSize: 11)),
                              if (fine > 0)
                                Text('Fine Calculated: ₹${fine.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('Paid Amount: ₹${fa.paidAmount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Net Due', style: TextStyle(color: textSec, fontSize: 10)),
                              Text('₹${totalDue.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: totalDue > 0 ? AppColors.error : AppColors.secondary)),
                            ],
                          ),
                        ],
                      ),
                      if (totalDue > 0) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (widget.viewMode == 'Cashier Counter' && studentAdvance.balance > 0) ...[
                              ElevatedButton.icon(
                                onPressed: () {
                                  final adjustAmt = studentAdvance.balance > totalDue ? totalDue : studentAdvance.balance;
                                  ref.read(studentFeeAssignmentsProvider.notifier).recordPayment(fa.id, adjustAmt);
                                  ref.read(studentAdvanceBalancesProvider.notifier).deductAdvance(fa.studentId, adjustAmt);

                                  ref.read(feeDaybookProvider.notifier).logEntry(
                                    FeeDaybookEntryEntity(
                                      id: 'DB-ADJ-${DateTime.now().millisecondsSinceEpoch}',
                                      branchId: widget.branchId,
                                      counterName: 'Advance Adjuster Ledger',
                                      date: DateTime.now(),
                                      type: 'Collection',
                                      amount: adjustAmt,
                                      paymentMode: 'Online',
                                      studentName: fa.studentName,
                                      description: 'Adjusted from student advance credits',
                                    ),
                                  );

                                  ref.read(financialAuditTrailProvider.notifier).logAudit(
                                    FinancialAuditTrailEntity(
                                      id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
                                      branchId: widget.branchId,
                                      timestamp: DateTime.now(),
                                      actionType: 'PaymentCollected',
                                      description: 'Advance credit of ₹${adjustAmt.toStringAsFixed(0)} applied to outstanding fee for ${fa.studentName}',
                                      performedBy: 'Counter cashier',
                                      ipAddress: '192.168.1.42',
                                    ),
                                  );

                                  _showSnack(context, 'Adjusted ₹${adjustAmt.toStringAsFixed(0)} from advance credits successfully!');
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 14),
                                label: Text('Apply Advance (₹${studentAdvance.balance.toStringAsFixed(0)})', style: const TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (widget.viewMode == 'Parent Portal')
                              ElevatedButton.icon(
                                onPressed: () => _showOnlinePaymentPortalDialog(context, fa, totalDue, receipts.length),
                                icon: const Icon(Icons.credit_card_rounded, size: 14),
                                label: const Text('Pay Securely Online', style: TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: () => _showRecordPaymentDialog(context, fa, totalDue, receipts.length),
                                icon: const Icon(Icons.payment_rounded, size: 14),
                                label: const Text('Collect Cash/Online', style: TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showOnlinePaymentPortalDialog(BuildContext context, StudentFeeAssignmentEntity fa, double totalDue, int receiptCount) {
    final cardNoCtrl = TextEditingController(text: '4111 2222 3333 4444');
    final cardExpiryCtrl = TextEditingController(text: '12/28');
    final cardCvvCtrl = TextEditingController(text: '321');

    final gateway = ref.read(gatewayConfigsProvider).firstWhere(
      (c) => c.branchId == widget.branchId,
      orElse: () => GatewayConfigEntity(
        branchId: widget.branchId,
        gatewayName: 'Stripe',
        merchantAccountId: 'merch_default',
        publicKey: 'pk_default',
        isActive: true,
      ),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${gateway.gatewayName} Payment Gateway Portal — ${fa.feeHeadName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Secure Online Checkout powered by ${gateway.gatewayName}', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Branch Gateway Account:\nMerchant ID: ${gateway.merchantAccountId}\nAPI Key: ${gateway.publicKey}',
                    style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Total Due: ₹${totalDue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                TextField(
                  controller: cardNoCtrl,
                  decoration: const InputDecoration(labelText: 'Card Number', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cardExpiryCtrl,
                        decoration: const InputDecoration(labelText: 'Expiry MM/YY', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: cardCvvCtrl,
                        decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // simulated payment submission
                ref.read(studentFeeAssignmentsProvider.notifier).recordPayment(fa.id, totalDue);

                final seriesNum = 'REC-${widget.branchId.replaceAll("BR-", "")}-2026-${(receiptCount + 1).toString().padLeft(4, "0")}';
                final newReceiptId = 'R-${DateTime.now().millisecondsSinceEpoch}';

                ref.read(feeReceiptsProvider.notifier).generateReceipt(
                  FeeReceiptEntity(
                    id: newReceiptId,
                    receiptNumber: seriesNum,
                    branchId: widget.branchId,
                    studentId: fa.studentId,
                    studentName: fa.studentName,
                    feeHeadId: fa.feeHeadId,
                    feeHeadName: fa.feeHeadName,
                    amountPaid: totalDue,
                    paymentMode: 'Online',
                    transactionReference: 'PG-TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                    paymentDate: DateTime.now(),
                    status: 'Active',
                  ),
                );

                // Daybook entry
                ref.read(feeDaybookProvider.notifier).logEntry(
                  FeeDaybookEntryEntity(
                    id: 'DB-${DateTime.now().millisecondsSinceEpoch}',
                    branchId: widget.branchId,
                    counterName: 'Online Payment Portal',
                    date: DateTime.now(),
                    type: 'Collection',
                    amount: totalDue,
                    paymentMode: 'Online',
                    studentName: fa.studentName,
                    description: 'Online receipt generated: $seriesNum',
                  ),
                );

                // General Ledger Voucher
                ref.read(financialVouchersProvider.notifier).addVoucher(
                  FinancialVoucherEntity(
                    id: 'VOU-${DateTime.now().millisecondsSinceEpoch}',
                    voucherNumber: 'VOU-${widget.branchId.replaceAll("BR-", "")}-2026-${(receiptCount + 1).toString().padLeft(4, "0")}',
                    branchId: widget.branchId,
                    type: 'Receipt',
                    date: DateTime.now(),
                    debitAccount: 'Cash at Bank',
                    creditAccount: 'Student Tuition Fee Account',
                    amount: totalDue,
                    narration: 'Online receipt generated: $seriesNum',
                    postedBy: 'Parent portal checkout',
                  ),
                );

                // Financial audit trail
                ref.read(financialAuditTrailProvider.notifier).logAudit(
                  FinancialAuditTrailEntity(
                    id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
                    branchId: widget.branchId,
                    timestamp: DateTime.now(),
                    actionType: 'PaymentCollected',
                    description: 'Parent payment checkout successfully cleared via ${gateway.gatewayName} gateway account (Merchant ID: ${gateway.merchantAccountId}) of amount ₹${totalDue.toStringAsFixed(0)}',
                    performedBy: 'Parent (Self Portal)',
                    ipAddress: '192.168.1.199',
                  ),
                );

                Navigator.pop(context);
                _showSnack(context, 'Online Payment Successful! Receipt $seriesNum emailed.');
              },
              child: const Text('Authorize Payment'),
            ),
          ],
        );
      },
    );
  }

  void _showRecordPaymentDialog(BuildContext context, StudentFeeAssignmentEntity fa, double totalDue, int receiptCount) {
    _amountCtrl.text = totalDue.toStringAsFixed(0);
    _refCtrl.text = 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Collect Fee — ${fa.studentName}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choose Mode, Reference and Amount.', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 16),
                    _DropdownFilter(
                      label: 'Payment Mode',
                      value: _paymentMode,
                      items: const ['Cash', 'Cheque', 'DD', 'Online', 'UPI', 'Card'],
                      displayItems: const ['Cash Counter', 'Bank Cheque', 'Demand Draft (DD)', 'Online Gateway', 'UPI / QR Scan', 'Debit/Credit Card'],
                      onChanged: (v) => setDialogState(() => _paymentMode = v),
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _refCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Transaction/Counter Ref No.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Collection Amount (INR)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
                    final refNo = _refCtrl.text.trim().isEmpty ? 'REF-GEN' : _refCtrl.text.trim();
                    if (amt <= 0) return;

                    double advancePaid = 0.0;
                    double collectionAmt = amt;
                    if (amt > totalDue) {
                      advancePaid = amt - totalDue;
                      collectionAmt = totalDue;
                      ref.read(studentAdvanceBalancesProvider.notifier).addAdvance(fa.studentId, fa.studentName, widget.branchId, advancePaid);
                    }

                    // 1. Record payment update
                    ref.read(studentFeeAssignmentsProvider.notifier).recordPayment(fa.id, collectionAmt);

                    // 2. Generate branch-specific receipt number series e.g. DL-2026-0001
                    final seriesNum = 'REC-${widget.branchId.replaceAll("BR-", "")}-2026-${(receiptCount + 1).toString().padLeft(4, "0")}';
                    final newReceiptId = 'R-${DateTime.now().millisecondsSinceEpoch}';

                    ref.read(feeReceiptsProvider.notifier).generateReceipt(
                      FeeReceiptEntity(
                        id: newReceiptId,
                        receiptNumber: seriesNum,
                        branchId: widget.branchId,
                        studentId: fa.studentId,
                        studentName: fa.studentName,
                        feeHeadId: fa.feeHeadId,
                        feeHeadName: fa.feeHeadName,
                        amountPaid: amt,
                        paymentMode: _paymentMode,
                        transactionReference: refNo,
                        paymentDate: DateTime.now(),
                        status: 'Active',
                      ),
                    );

                    // 3. Log counter Daybook entry
                    ref.read(feeDaybookProvider.notifier).logEntry(
                      FeeDaybookEntryEntity(
                        id: 'DB-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: widget.branchId,
                        counterName: _paymentMode == 'Cash' ? 'Cash Counter A' : 'Online Gateway Feed',
                        date: DateTime.now(),
                        type: 'Collection',
                        amount: amt,
                        paymentMode: _paymentMode,
                        studentName: fa.studentName,
                        description: 'Receipt generated: $seriesNum' + (advancePaid > 0 ? ' (₹${advancePaid.toStringAsFixed(0)} excess credited to Advance)' : ''),
                      ),
                    );

                    // 4. Log General Ledger Voucher
                    ref.read(financialVouchersProvider.notifier).addVoucher(
                      FinancialVoucherEntity(
                        id: 'VOU-${DateTime.now().millisecondsSinceEpoch}',
                        voucherNumber: 'VOU-${widget.branchId.replaceAll("BR-", "")}-2026-${(receiptCount + 1).toString().padLeft(4, "0")}',
                        branchId: widget.branchId,
                        type: 'Receipt',
                        date: DateTime.now(),
                        debitAccount: _paymentMode == 'Cash' ? 'Cash in Hand' : 'Cash at Bank',
                        creditAccount: 'Student Tuition Fee Account',
                        amount: amt,
                        narration: 'Fee receipted: $seriesNum',
                        postedBy: 'Counter cashier',
                      ),
                    );

                    // 5. Log audit trail
                    ref.read(financialAuditTrailProvider.notifier).logAudit(
                      FinancialAuditTrailEntity(
                        id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: widget.branchId,
                        timestamp: DateTime.now(),
                        actionType: 'PaymentCollected',
                        description: 'Payment collected by cashier on counter for student ${fa.studentName}. Receipt $seriesNum of amount ₹${amt.toStringAsFixed(0)} generated.',
                        performedBy: 'Counter cashier',
                        ipAddress: '192.168.1.42',
                      ),
                    );

                    Navigator.pop(context);
                    _showSnack(context, 'Receipt $seriesNum generated!');
                  },
                  child: const Text('Collect & Print Receipt'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 5 — Student Advances Tab
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _StudentAdvancesTab extends ConsumerStatefulWidget {
  final String branchId;
  const _StudentAdvancesTab({required this.branchId});

  @override
  ConsumerState<_StudentAdvancesTab> createState() => _StudentAdvancesTabState();
}

class _StudentAdvancesTabState extends ConsumerState<_StudentAdvancesTab> {
  final _amountCtrl = TextEditingController();
  String? _selectedAdvanceStudentId;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final advanceBalances = ref.watch(studentAdvanceBalancesProvider).where((a) => a.branchId == widget.branchId).toList();
    final students = ref.watch(academicStudentsProvider).where((s) => s.branchId == widget.branchId).toList();

    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Advance Deposit Form
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Record Advance Fee Deposit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (students.isNotEmpty)
                      Expanded(
                        child: _DropdownFilter(
                          label: 'Select Student',
                          value: _selectedAdvanceStudentId ?? students.first.id,
                          items: students.map((s) => s.id).toList(),
                          displayItems: students.map((s) => s.name).toList(),
                          onChanged: (v) => setState(() => _selectedAdvanceStudentId = v),
                          isDark: isDark,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormField(controller: _amountCtrl, label: 'Deposit Amount (INR)', isDark: isDark, keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final stuId = _selectedAdvanceStudentId ?? (students.isNotEmpty ? students.first.id : null);
                    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;

                    if (stuId == null || amt <= 0) return;
                    final student = students.firstWhere((s) => s.id == stuId);

                    ref.read(studentAdvanceBalancesProvider.notifier).addAdvance(stuId, student.name, widget.branchId, amt);

                    ref.read(feeDaybookProvider.notifier).logEntry(
                      FeeDaybookEntryEntity(
                        id: 'DB-ADV-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: widget.branchId,
                        counterName: 'Cash Counter A',
                        date: DateTime.now(),
                        type: 'Collection',
                        amount: amt,
                        paymentMode: 'Cash',
                        studentName: student.name,
                        description: 'Advance fee deposit credited',
                      ),
                    );

                    _amountCtrl.clear();
                    _showSnack(context, 'Advance deposit of ₹${amt.toStringAsFixed(0)} logged successfully!');
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Advance Credit'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Student Advance Account Balances', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
          const SizedBox(height: 10),
          ...advanceBalances.map((ab) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primarySurface,
                      child: Icon(Icons.savings_rounded, color: AppColors.primary, size: 18),
                    ),
                    title: Text(ab.studentName, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                    subtitle: Text('Last Updated: ${ab.lastUpdated.day}/${ab.lastUpdated.month}/${ab.lastUpdated.year}', style: TextStyle(color: textSec, fontSize: 11)),
                    trailing: Text('₹${ab.balance.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 14)),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 6 — Concessions & Scholarships
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ConcessionsTab extends ConsumerStatefulWidget {
  final String branchId;
  const _ConcessionsTab({required this.branchId});

  @override
  ConsumerState<_ConcessionsTab> createState() => _ConcessionsTabState();
}

class _ConcessionsTabState extends ConsumerState<_ConcessionsTab> {
  final _nameCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _concessionType = 'Percentage';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final concessions = ref.watch(feeConcessionsProvider)
        .where((c) => c.branchId == widget.branchId)
        .toList();
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Concession
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Scholarship / Concession', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _FormField(controller: _nameCtrl, label: 'Concession Name (e.g. Sports Quota)', isDark: isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormField(controller: _valueCtrl, label: 'Concession Value', isDark: isDark, keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _FormField(controller: _descCtrl, label: 'Waiver Description', isDark: isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DropdownFilter(
                        label: 'Type',
                        value: _concessionType,
                        items: const ['Percentage', 'FixedAmount'],
                        displayItems: const ['Percentage', 'FixedAmount'],
                        onChanged: (v) => setState(() => _concessionType = v),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_nameCtrl.text.trim().isEmpty || _valueCtrl.text.trim().isEmpty) return;
                    ref.read(feeConcessionsProvider.notifier).addConcession(
                      FeeConcessionEntity(
                        id: 'FC-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: widget.branchId,
                        name: _nameCtrl.text.trim(),
                        type: _concessionType,
                        value: double.tryParse(_valueCtrl.text.trim()) ?? 0.0,
                        description: _descCtrl.text.trim(),
                      ),
                    );
                    _nameCtrl.clear();
                    _valueCtrl.clear();
                    _descCtrl.clear();
                    _showSnack(context, 'Scholarship/Concession Added!');
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Waiver'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Active Scholarships & Waivers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
          const SizedBox(height: 10),
          if (concessions.isEmpty)
            Text('No scholarships/concessions defined for this branch.', style: TextStyle(color: textSec))
          else
            ...concessions.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primarySurface,
                        child: Icon(Icons.local_offer_rounded, color: AppColors.primary, size: 18),
                      ),
                      title: Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                      subtitle: Text(c.description, style: TextStyle(color: textSec, fontSize: 11)),
                      trailing: Text(
                        c.type == 'Percentage' ? '${c.value.toStringAsFixed(0)}%' : '₹${c.value.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 14),
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 7 — Receipts, Daybook & Financial Audit Trail
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ReceiptsDaybookTab extends ConsumerWidget {
  final String branchId;
  final String subView;
  final ValueChanged<String> onSubViewChanged;

  const _ReceiptsDaybookTab({
    required this.branchId,
    required this.subView,
    required this.onSubViewChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final receipts = ref.watch(feeReceiptsProvider).where((r) => r.branchId == branchId).toList();
    final daybook = ref.watch(feeDaybookProvider).where((d) => d.branchId == branchId).toList();
    final auditLogs = ref.watch(financialAuditTrailProvider).where((a) => a.branchId == branchId).toList();

    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub tabs for Counter Receipts, Daybook counter summary, and Audit Trail logs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Receipts', 'Daybook', 'Audit Trail'].map((view) {
                final isSelected = subView == view;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(view),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) onSubViewChanged(view);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textSec,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          if (subView == 'Daybook') ...[
            Text('Branch Fee Counter Daybook Logs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _DaybookSummaryCounterCard(
                    title: 'Cash Collections',
                    amount: daybook.where((d) => d.paymentMode == 'Cash' && d.type == 'Collection').fold(0.0, (a, b) => a + b.amount),
                    color: AppColors.secondary,
                    icon: Icons.payments_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DaybookSummaryCounterCard(
                    title: 'Online & Digital',
                    amount: daybook.where((d) => d.paymentMode != 'Cash' && d.type == 'Collection').fold(0.0, (a, b) => a + b.amount),
                    color: AppColors.primary,
                    icon: Icons.qr_code_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DaybookSummaryCounterCard(
                    title: 'Total Refunds',
                    amount: daybook.where((d) => d.type == 'Refund').fold(0.0, (a, b) => a + b.amount),
                    color: AppColors.error,
                    icon: Icons.undo_rounded,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...daybook.map((db) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: GlassCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(db.type == 'Refund' ? Icons.undo_rounded : Icons.add_circle_rounded, color: db.type == 'Refund' ? AppColors.error : AppColors.secondary),
                      title: Text(db.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${db.counterName} • ${db.description}', style: const TextStyle(fontSize: 11)),
                      trailing: Text('₹${db.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: db.type == 'Refund' ? AppColors.error : AppColors.secondary)),
                    ),
                  ),
                )),
          ] else if (subView == 'Audit Trail') ...[
            Text('Financial Operations Audit Trail logs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
            const SizedBox(height: 10),
            ...auditLogs.map((audit) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(audit.actionType, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 12)),
                            Text('${audit.timestamp.day}/${audit.timestamp.month} ${audit.timestamp.hour}:${audit.timestamp.minute}', style: TextStyle(color: textSec, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(audit.description, style: TextStyle(color: textSec, fontSize: 11)),
                        const Divider(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('User: ${audit.performedBy}', style: TextStyle(fontSize: 9, color: textSec)),
                            Text('IP: ${audit.ipAddress}', style: TextStyle(fontSize: 9, color: textSec)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ] else ...[
            Text('Generated Fee Receipts Series', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
            const SizedBox(height: 10),
            ...receipts.map((r) {
              final isRefunded = r.status == 'Refunded';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: isRefunded ? AppColors.error.withOpacity(0.12) : AppColors.secondary.withOpacity(0.12),
                          child: Icon(isRefunded ? Icons.assignment_return_rounded : Icons.receipt_long_rounded, color: isRefunded ? AppColors.error : AppColors.secondary, size: 18),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(r.receiptNumber, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                            Text('₹${r.amountPaid.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: isRefunded ? AppColors.error : AppColors.secondary, fontSize: 13)),
                          ],
                        ),
                        subtitle: Text(
                          'Student: ${r.studentName} • Mode: ${r.paymentMode}\nRef: ${r.transactionReference} • Date: ${r.paymentDate.day}/${r.paymentDate.month}/${r.paymentDate.year}',
                          style: TextStyle(color: textSec, fontSize: 11),
                        ),
                      ),
                      if (!isRefunded) ...[
                        const Divider(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showRefundDialog(context, ref, r),
                              icon: const Icon(Icons.undo_rounded, size: 12, color: AppColors.error),
                              label: const Text('Process Refund', style: TextStyle(color: AppColors.error, fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showReceiptViewer(context, r),
                              icon: const Icon(Icons.print_rounded, size: 12),
                              label: const Text('View Receipt', style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _showRefundDialog(BuildContext context, WidgetRef ref, FeeReceiptEntity r) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Process Refund — ${r.receiptNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Refunding ₹${r.amountPaid.toStringAsFixed(0)} to ${r.studentName} for ${r.feeHeadName}. This cannot be undone.', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Refund Reason',
                  border: OutlineInputBorder(),
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
                if (reasonCtrl.text.trim().isEmpty) return;

                // 1. Mark receipt as refunded
                ref.read(feeReceiptsProvider.notifier).markRefunded(r.id);

                // 2. Add refund log
                ref.read(feeRefundsProvider.notifier).addRefund(
                  FeeRefundEntity(
                    id: 'RF-${DateTime.now().millisecondsSinceEpoch}',
                    branchId: branchId,
                    studentId: r.studentId,
                    studentName: r.studentName,
                    receiptId: r.id,
                    refundAmount: r.amountPaid,
                    reason: reasonCtrl.text.trim(),
                    refundDate: DateTime.now(),
                    refundMode: r.paymentMode,
                    status: 'Approved',
                  ),
                );

                // 3. Log negative counter daybook entry
                ref.read(feeDaybookProvider.notifier).logEntry(
                  FeeDaybookEntryEntity(
                    id: 'DB-REF-${DateTime.now().millisecondsSinceEpoch}',
                    branchId: branchId,
                    counterName: 'Refund Counter A',
                    date: DateTime.now(),
                    type: 'Refund',
                    amount: r.amountPaid,
                    paymentMode: r.paymentMode,
                    studentName: r.studentName,
                    description: 'Refunded Receipt: ${r.receiptNumber}',
                  ),
                );

                // 4. Post Journal refund voucher
                ref.read(financialVouchersProvider.notifier).addVoucher(
                  FinancialVoucherEntity(
                    id: 'VOU-REF-${DateTime.now().millisecondsSinceEpoch}',
                    voucherNumber: 'VOU-REF-${r.receiptNumber}',
                    branchId: branchId,
                    type: 'Journal',
                    date: DateTime.now(),
                    debitAccount: 'Student Tuition Fee Account',
                    creditAccount: r.paymentMode == 'Cash' ? 'Cash in Hand' : 'Cash at Bank',
                    amount: r.amountPaid,
                    narration: 'Refund processed: ${r.receiptNumber}',
                    postedBy: 'Admin Accountant',
                  ),
                );

                // 5. Log Audit Trail
                ref.read(financialAuditTrailProvider.notifier).logAudit(
                  FinancialAuditTrailEntity(
                    id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
                    branchId: branchId,
                    timestamp: DateTime.now(),
                    actionType: 'RefundProcessed',
                    description: 'Refund of amount ₹${r.amountPaid.toStringAsFixed(0)} approved and processed for student ${r.studentName}. Counter balances reversed.',
                    performedBy: 'Senior Auditor',
                    ipAddress: '192.168.1.15',
                  ),
                );

                Navigator.pop(context);
                _showSnack(context, 'Refund of ₹${r.amountPaid.toStringAsFixed(0)} processed successfully!');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Approve Refund'),
            ),
          ],
        );
      },
    );
  }

  void _showReceiptViewer(BuildContext context, FeeReceiptEntity r) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Receipt Print Preview'),
          content: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'SCHOOL ENTERPRISE SYSTEM',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
                  ),
                ),
                Center(
                  child: Text(
                    'Branch Verification ID: ${r.branchId}',
                    style: const TextStyle(color: Colors.black54, fontSize: 10),
                  ),
                ),
                const Divider(color: Colors.black),
                Text('Receipt No: ${r.receiptNumber}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                Text('Date: ${r.paymentDate.day}/${r.paymentDate.month}/${r.paymentDate.year}', style: const TextStyle(color: Colors.black, fontSize: 11)),
                Text('Student: ${r.studentName} (${r.studentId})', style: const TextStyle(color: Colors.black, fontSize: 11)),
                const Divider(color: Colors.black),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.feeHeadName, style: const TextStyle(color: Colors.black, fontSize: 11)),
                    Text('₹${r.amountPaid.toStringAsFixed(0)}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
                const Divider(color: Colors.black),
                Text('Payment Mode: ${r.paymentMode}', style: const TextStyle(color: Colors.black54, fontSize: 10)),
                Text('Ref No: ${r.transactionReference}', style: const TextStyle(color: Colors.black54, fontSize: 10)),
                const SizedBox(height: 12),
                const Center(
                  child: Text('--- Thank You ---', style: TextStyle(color: Colors.black54, fontSize: 10)),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}

class _DaybookSummaryCounterCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _DaybookSummaryCounterCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 8 — Voucher Ledger (General Vouchers)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _VoucherLedgerTab extends ConsumerStatefulWidget {
  final String branchId;
  const _VoucherLedgerTab({required this.branchId});

  @override
  ConsumerState<_VoucherLedgerTab> createState() => _VoucherLedgerTabState();
}

class _VoucherLedgerTabState extends ConsumerState<_VoucherLedgerTab> {
  final _debitAccCtrl = TextEditingController();
  final _creditAccCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _narrationCtrl = TextEditingController();
  String _voucherType = 'Receipt';

  @override
  void dispose() {
    _debitAccCtrl.dispose();
    _creditAccCtrl.dispose();
    _amountCtrl.dispose();
    _narrationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vouchers = ref.watch(financialVouchersProvider).where((v) => v.branchId == widget.branchId).toList();
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Voucher Card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Post Financial Voucher', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DropdownFilter(
                        label: 'Voucher Type',
                        value: _voucherType,
                        items: const ['Receipt', 'Payment', 'Journal', 'Contra'],
                        displayItems: const ['Receipt (Money In)', 'Payment (Money Out)', 'Journal (Adjustments)', 'Contra (Cash-Bank Transfer)'],
                        onChanged: (v) => setState(() => _voucherType = v),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormField(controller: _amountCtrl, label: 'Amount (INR)', isDark: isDark, keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _FormField(controller: _debitAccCtrl, label: 'Debit Account (e.g. Cash in Hand)', isDark: isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormField(controller: _creditAccCtrl, label: 'Credit Account (e.g. School Fees Account)', isDark: isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FormField(controller: _narrationCtrl, label: 'Narration / Description', isDark: isDark),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_amountCtrl.text.trim().isEmpty || _debitAccCtrl.text.trim().isEmpty || _creditAccCtrl.text.trim().isEmpty) return;

                    final newVoucherNo = 'VOU-${widget.branchId.replaceAll("BR-", "")}-2026-${(vouchers.length + 1).toString().padLeft(4, "0")}';

                    ref.read(financialVouchersProvider.notifier).addVoucher(
                      FinancialVoucherEntity(
                        id: 'VOU-${DateTime.now().millisecondsSinceEpoch}',
                        voucherNumber: newVoucherNo,
                        branchId: widget.branchId,
                        type: _voucherType,
                        date: DateTime.now(),
                        debitAccount: _debitAccCtrl.text.trim(),
                        creditAccount: _creditAccCtrl.text.trim(),
                        amount: double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
                        narration: _narrationCtrl.text.trim(),
                        postedBy: 'Senior Accountant',
                      ),
                    );

                    // Log audit trail
                    ref.read(financialAuditTrailProvider.notifier).logAudit(
                      FinancialAuditTrailEntity(
                        id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: widget.branchId,
                        timestamp: DateTime.now(),
                        actionType: 'VoucherPosted',
                        description: 'Voucher $newVoucherNo posted. Debit: ${_debitAccCtrl.text.trim()}, Credit: ${_creditAccCtrl.text.trim()}, Amount: ₹${_amountCtrl.text.trim()}',
                        performedBy: 'Senior Accountant',
                        ipAddress: '192.168.1.15',
                      ),
                    );

                    _debitAccCtrl.clear();
                    _creditAccCtrl.clear();
                    _amountCtrl.clear();
                    _narrationCtrl.clear();
                    _showSnack(context, 'General ledger voucher posted successfully!');
                  },
                  icon: const Icon(Icons.post_add_rounded, size: 16),
                  label: const Text('Post Journal Voucher'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Recent Branch Vouchers Ledger', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
          const SizedBox(height: 10),
          ...vouchers.map((v) {
            Color vColor = AppColors.secondary;
            if (v.type == 'Payment') vColor = AppColors.error;
            if (v.type == 'Journal') vColor = AppColors.warning;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(v.voucherNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPri)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: vColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(v.type, style: TextStyle(fontSize: 9, color: vColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dr: ${v.debitAccount}', style: TextStyle(fontSize: 11, color: textPri, fontWeight: FontWeight.w600)),
                        Text('₹${v.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary)),
                      ],
                    ),
                    Text('Cr: ${v.creditAccount}', style: TextStyle(fontSize: 11, color: textSec)),
                    const SizedBox(height: 4),
                    Text('Narration: ${v.narration}', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: textSec)),
                    const SizedBox(height: 2),
                    Text('Posted by: ${v.postedBy} • ${v.date.day}/${v.date.month}', style: TextStyle(fontSize: 10, color: textSec.withOpacity(0.7))),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 9 — Bank Reconciliation
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _BankReconciliationTab extends ConsumerStatefulWidget {
  final String branchId;
  const _BankReconciliationTab({required this.branchId});

  @override
  ConsumerState<_BankReconciliationTab> createState() => _BankReconciliationTabState();
}

class _BankReconciliationTabState extends ConsumerState<_BankReconciliationTab> {
  final _statementBalCtrl = TextEditingController();
  final _clearedCtrl = TextEditingController();
  final _unclearedCtrl = TextEditingController();

  @override
  void dispose() {
    _statementBalCtrl.dispose();
    _clearedCtrl.dispose();
    _unclearedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recons = ref.watch(bankReconciliationsProvider).where((r) => r.branchId == widget.branchId).toList();
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bank Reconciliation Statement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
          const SizedBox(height: 10),
          ...recons.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.bankName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPri)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: r.isReconciled ? AppColors.secondary.withOpacity(0.12) : AppColors.error.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              r.isReconciled ? 'Reconciled' : 'Discrepancy',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: r.isReconciled ? AppColors.secondary : AppColors.error),
                            ),
                          ),
                        ],
                      ),
                      Text('Account: ${r.accountNumber}', style: TextStyle(color: textSec, fontSize: 11)),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ledger Balance: ₹${r.ledgerBalance.toStringAsFixed(0)}', style: TextStyle(color: textSec, fontSize: 11)),
                              Text('Cleared Ledger: ₹${r.clearedAmount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.secondary, fontSize: 11)),
                              Text('Uncleared Ledger: ₹${r.unclearedAmount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.error, fontSize: 11)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Statement Balance', style: TextStyle(color: textSec, fontSize: 10)),
                              Text('₹${r.statementBalance.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPri)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _showReconcileDialog(context, r),
                          icon: const Icon(Icons.rule_rounded, size: 12),
                          label: const Text('Perform Reconciliation', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showReconcileDialog(BuildContext context, BankReconciliationEntity r) {
    _statementBalCtrl.text = r.statementBalance.toStringAsFixed(0);
    _clearedCtrl.text = r.clearedAmount.toStringAsFixed(0);
    _unclearedCtrl.text = r.unclearedAmount.toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reconcile Account — ${r.bankName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _statementBalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Actual Bank Statement Balance'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _clearedCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Cleared Deposits / Checks'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _unclearedCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Uncleared / Outstanding Checks'),
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
                final statementBal = double.tryParse(_statementBalCtrl.text.trim()) ?? 0.0;
                final clearedAmt = double.tryParse(_clearedCtrl.text.trim()) ?? 0.0;
                final unclearedAmt = double.tryParse(_unclearedCtrl.text.trim()) ?? 0.0;

                ref.read(bankReconciliationsProvider.notifier).reconcile(r.id, statementBal, clearedAmt, unclearedAmt);
                Navigator.pop(context);
                _showSnack(context, 'Bank Reconciliation matching submitted!');
              },
              child: const Text('Submit Reconciliation'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 10 — Accounting Reports (P&L, Balance Sheet, Defaulter list, budget)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AccountingReportsTab extends ConsumerStatefulWidget {
  final String branchId;
  const _AccountingReportsTab({required this.branchId});

  @override
  ConsumerState<_AccountingReportsTab> createState() => _AccountingReportsTabState();
}

class _AccountingReportsTabState extends ConsumerState<_AccountingReportsTab> {
  String _activeReport = 'P&L Statement'; // 'P&L Statement', 'Balance Sheet', 'Trial Balance', 'Defaulter Reminders', 'Budget Plans', 'Financial Years'
  final _yearNameCtrl = TextEditingController();
  final _budgetAmountCtrl = TextEditingController();
  String _budgetCategory = 'Academics';

  @override
  void dispose() {
    _yearNameCtrl.dispose();
    _budgetAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final years = ref.watch(financialYearsProvider).where((y) => y.branchId == widget.branchId).toList();
    final budgets = ref.watch(budgetPlansProvider).where((b) => b.branchId == widget.branchId).toList();
    final vouchers = ref.watch(financialVouchersProvider).where((v) => v.branchId == widget.branchId).toList();
    final advances = ref.watch(studentAdvanceBalancesProvider).where((ab) => ab.branchId == widget.branchId).toList();
    final reminderLogs = ref.watch(feeReminderLogsProvider).where((rem) => rem.branchId == widget.branchId).toList();
    final assignments = ref.watch(studentFeeAssignmentsProvider).where((a) => a.branchId == widget.branchId).toList();
    final plans = ref.watch(feeInstallmentPlansProvider).where((p) => p.branchId == widget.branchId).toList();
    final receipts = ref.watch(feeReceiptsProvider).where((r) => r.branchId == widget.branchId).toList();
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == widget.branchId).toList();
    final studentsList = ref.watch(academicStudentsProvider).where((s) => s.branchId == widget.branchId).toList();

    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Calculations
    final double revenueFees = vouchers.where((v) => v.type == 'Receipt' && v.creditAccount.contains('Fee')).fold(0.0, (a, b) => a + b.amount);
    final double expenses = vouchers.where((v) => v.type == 'Payment').fold(0.0, (a, b) => a + b.amount);
    final double totalAdvanceLiability = advances.fold(0.0, (a, b) => a + b.balance);
    final double bankBalances = vouchers.where((v) => v.debitAccount == 'Cash at Bank').fold(0.0, (a, b) => a + b.amount) -
        vouchers.where((v) => v.creditAccount == 'Cash at Bank').fold(0.0, (a, b) => a + b.amount);

    double calculateFine(StudentFeeAssignmentEntity fa) {
      if (fa.dueDate.isBefore(DateTime.now()) && fa.status != 'Paid') {
        try {
          final plan = plans.firstWhere((p) => p.id == fa.installmentPlanId);
          final overdueDate = fa.dueDate.add(Duration(days: plan.graceDays));
          if (DateTime.now().isAfter(overdueDate)) {
            final daysPast = DateTime.now().difference(overdueDate).inDays;
            final monthsPast = (daysPast / 30.0).ceil();
            final netPayable = fa.assignedAmount - fa.discountAmount;
            return netPayable * (plan.lateFeePercentage / 100) * monthsPast;
          }
        } catch (_) {}
      }
      return 0.0;
    }

    final defaulters = assignments.where((fa) {
      final netPayable = fa.assignedAmount - fa.discountAmount;
      return fa.dueDate.isBefore(DateTime.now()) && fa.paidAmount < netPayable;
    }).toList();

    final todayDate = DateTime.now();
    final todayReceipts = receipts.where((r) =>
        r.paymentDate.day == todayDate.day &&
        r.paymentDate.month == todayDate.month &&
        r.paymentDate.year == todayDate.year).toList();

    final cashCollectedToday = todayReceipts
        .where((r) => r.paymentMode == 'Cash' && r.status != 'Refunded')
        .fold(0.0, (sum, r) => sum + r.amountPaid);
    final onlineCollectedToday = todayReceipts
        .where((r) => r.paymentMode == 'Online' && r.status != 'Refunded')
        .fold(0.0, (sum, r) => sum + r.amountPaid);
    final bankCollectedToday = todayReceipts
        .where((r) => (r.paymentMode == 'Cheque' || r.paymentMode == 'DD' || r.paymentMode == 'UPI' || r.paymentMode == 'Card') && r.status != 'Refunded')
        .fold(0.0, (sum, r) => sum + r.amountPaid);
    final totalCollectedToday = cashCollectedToday + onlineCollectedToday + bankCollectedToday;

    final totalAssignedCount = assignments.length;
    final totalAssignedAmt = assignments.fold(0.0, (sum, item) => sum + item.assignedAmount);
    final totalDiscountAmt = assignments.fold(0.0, (sum, item) => sum + item.discountAmount);
    final totalNetPayable = totalAssignedAmt - totalDiscountAmt;
    final totalCollectedAmt = assignments.fold(0.0, (sum, item) => sum + item.paidAmount);
    final outstandingDuesAmt = totalNetPayable - totalCollectedAmt;
    final totalOutstandingFines = assignments.fold(0.0, (sum, item) => sum + calculateFine(item));
    final grandOutstandingDues = outstandingDuesAmt + totalOutstandingFines;

    // Class-wise dues mapping
    final Map<String, double> classDuesMap = {};
    final Map<String, String> classIdToName = {
      for (final c in classes) c.id: c.name
    };

    for (final fa in assignments) {
      final student = studentsList.firstWhere((s) => s.id == fa.studentId, orElse: () => StudentEntity(id: '', branchId: '', classId: '', sectionId: '', name: '', admissionNumber: '', rollNumber: ''));
      final className = classIdToName[student.classId] ?? 'Other / Unassigned';
      final netPayable = fa.assignedAmount - fa.discountAmount;
      final dues = netPayable + calculateFine(fa) - fa.paidAmount;
      if (dues > 0) {
        classDuesMap[className] = (classDuesMap[className] ?? 0.0) + dues;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub navigation chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Daily Collection Report',
                'Outstanding Dues Report',
                'P&L Statement',
                'Balance Sheet',
                'Trial Balance',
                'Defaulter Reminders',
                'Budget Plans',
                'Financial Years',
              ].map((type) {
                final isSelected = _activeReport == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _activeReport = type);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textSec,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          if (_activeReport == 'Daily Collection Report') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daily Fee Collection Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPri)),
                      Text('${todayDate.day}/${todayDate.month}/${todayDate.year}', style: TextStyle(fontSize: 12, color: textSec, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _DaybookSummaryCounterCard(
                          title: 'Cash Collection',
                          amount: cashCollectedToday,
                          color: AppColors.secondary,
                          icon: Icons.payments_rounded,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DaybookSummaryCounterCard(
                          title: 'Online Gateway',
                          amount: onlineCollectedToday,
                          color: AppColors.primary,
                          icon: Icons.credit_card_rounded,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DaybookSummaryCounterCard(
                          title: 'Bank (Cheque/UPI/Card)',
                          amount: bankCollectedToday,
                          color: AppColors.warning,
                          icon: Icons.qr_code_2_rounded,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 12),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Daily Collection (Net)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPri)),
                      Text('₹${totalCollectedToday.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Daily Transaction Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPri)),
                  const SizedBox(height: 10),
                  if (todayReceipts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('No collection records logged today.', style: TextStyle(color: textSec, fontSize: 12)),
                      ),
                    )
                  else
                    ...todayReceipts.map((r) {
                      final isRefunded = r.status == 'Refunded';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: isRefunded ? AppColors.error.withValues(alpha: 0.12) : AppColors.secondary.withValues(alpha: 0.12),
                              child: Icon(isRefunded ? Icons.assignment_return_rounded : Icons.receipt_long_rounded, color: isRefunded ? AppColors.error : AppColors.secondary, size: 16),
                            ),
                            title: Text('${r.receiptNumber} (${r.studentName})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textPri)),
                            subtitle: Text('Mode: ${r.paymentMode} • Ref: ${r.transactionReference}', style: TextStyle(color: textSec, fontSize: 10)),
                            trailing: Text(
                              '₹${r.amountPaid.toStringAsFixed(0)}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isRefunded ? AppColors.error : AppColors.secondary),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ] else if (_activeReport == 'Outstanding Dues Report') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outstanding Fees & Dues Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPri)),
                  const Divider(height: 20),
                  _buildReportRow('Total Active Students Assigned', totalAssignedCount.toDouble(), textPri),
                  _buildReportRow('Gross Assigned Fee Structure', totalAssignedAmt, textPri),
                  _buildReportRow('Total Concessions & Scholarships', totalDiscountAmt, textPri),
                  _buildReportRow('Net Fee Payable Dues', totalNetPayable, textPri),
                  _buildReportRow('Total Fees Collected', totalCollectedAmt, textPri),
                  _buildReportRow('Overdue Fines/Penalties Calculated', totalOutstandingFines, textPri),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Net Outstanding Dues (Net + Fines)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPri)),
                      Text('₹${grandOutstandingDues.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Class-wise Outstanding Dues Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPri)),
                  const SizedBox(height: 10),
                  if (classDuesMap.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Perfect! No outstanding dues recorded for any class.', style: TextStyle(color: textSec, fontSize: 12)),
                      ),
                    )
                  else
                    ...classDuesMap.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: TextStyle(fontSize: 12, color: textPri, fontWeight: FontWeight.w600)),
                            Text('₹${entry.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ] else if (_activeReport == 'P&L Statement') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profit & Loss Statement (Current Financial Year)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPri)),
                  const Divider(height: 20),
                  Text('Operating Revenue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary)),
                  _buildReportRow('Student Tuition Fee Collections', revenueFees, textPri),
                  const SizedBox(height: 12),
                  Text('Operating Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.error)),
                  _buildReportRow('School Academic & Admin Operations', expenses, textPri),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Net Profit / (Loss)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPri)),
                      Text(
                        '₹${(revenueFees - expenses).toStringAsFixed(0)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: (revenueFees - expenses) >= 0 ? AppColors.secondary : AppColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (_activeReport == 'Balance Sheet') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statement of Assets & Liabilities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPri)),
                  const Divider(height: 20),
                  Text('Current Assets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary)),
                  _buildReportRow('Cash at Bank Accounts', bankBalances < 0 ? 0.0 : bankBalances, textPri),
                  _buildReportRow('Cash in Hand Counter Registry', 35000.0, textPri),
                  const SizedBox(height: 12),
                  Text('Current Liabilities & Capital', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.error)),
                  _buildReportRow('Prepaid Student Advance Credits', totalAdvanceLiability, textPri),
                  const Divider(height: 24),
                  _buildReportRow('Total Assets Balance', (bankBalances < 0 ? 0.0 : bankBalances) + 35000.0, textPri, isBold: true),
                ],
              ),
            ),
          ] else if (_activeReport == 'Trial Balance') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('General Ledger Trial Balance Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPri)),
                  const SizedBox(height: 12),
                  Table(
                    border: TableBorder.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: AppColors.primarySurface),
                        children: const [
                          Padding(padding: EdgeInsets.all(8), child: Text('Ledger Account Head', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Padding(padding: EdgeInsets.all(8), child: Text('Debit (Dr)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Padding(padding: EdgeInsets.all(8), child: Text('Credit (Cr)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(padding: EdgeInsets.all(8), child: Text('Cash at Bank Ledger', style: TextStyle(fontSize: 11))),
                          Padding(padding: const EdgeInsets.all(8), child: Text('₹${(bankBalances < 0 ? 0.0 : bankBalances).toStringAsFixed(0)}', style: const TextStyle(fontSize: 11))),
                          const Padding(padding: EdgeInsets.all(8), child: Text('₹0', style: TextStyle(fontSize: 11))),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(padding: EdgeInsets.all(8), child: Text('Cash in Hand counter', style: TextStyle(fontSize: 11))),
                          const Padding(padding: EdgeInsets.all(8), child: Text('₹35,000', style: TextStyle(fontSize: 11))),
                          const Padding(padding: EdgeInsets.all(8), child: Text('₹0', style: TextStyle(fontSize: 11))),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(padding: EdgeInsets.all(8), child: Text('Tuition Fee Revenue', style: TextStyle(fontSize: 11))),
                          const Padding(padding: EdgeInsets.all(8), child: Text('₹0', style: TextStyle(fontSize: 11))),
                          Padding(padding: const EdgeInsets.all(8), child: Text('₹${revenueFees.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (_activeReport == 'Defaulter Reminders') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Defaulter Alerts & Automatic Reminder Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPri)),
                  const SizedBox(height: 12),
                  if (defaulters.isEmpty)
                    Center(child: Text('No payment defaulters found for this branch!', style: TextStyle(color: textSec)))
                  else
                    ...defaulters.map((fa) {
                      final netPayable = fa.assignedAmount - fa.discountAmount;
                      final fine = calculateFine(fa);
                      final totalDue = netPayable + fine - fa.paidAmount;

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fa.studentName, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 13)),
                                Text('Outstanding Amount: ₹${totalDue.toStringAsFixed(0)}', style: TextStyle(color: textSec, fontSize: 11)),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(feeReminderLogsProvider.notifier).logReminder(
                                      FeeReminderLogEntity(
                                        id: 'REM-${DateTime.now().millisecondsSinceEpoch}',
                                        branchId: widget.branchId,
                                        studentId: fa.studentId,
                                        studentName: fa.studentName,
                                        channel: 'SMS',
                                        amountDue: totalDue,
                                        sentAt: DateTime.now(),
                                        status: 'Sent',
                                      ),
                                    );
                                    _showSnack(context, 'SMS payment reminder sent to parent!');
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                  child: const Text('SMS', style: TextStyle(fontSize: 10)),
                                ),
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(feeReminderLogsProvider.notifier).logReminder(
                                      FeeReminderLogEntity(
                                        id: 'REM-${DateTime.now().millisecondsSinceEpoch}',
                                        branchId: widget.branchId,
                                        studentId: fa.studentId,
                                        studentName: fa.studentName,
                                        channel: 'Email',
                                        amountDue: totalDue,
                                        sentAt: DateTime.now(),
                                        status: 'Sent',
                                      ),
                                    );
                                    _showSnack(context, 'Email payment invoice sent!');
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                  child: const Text('Email', style: TextStyle(fontSize: 10)),
                                ),
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(feeReminderLogsProvider.notifier).logReminder(
                                      FeeReminderLogEntity(
                                        id: 'REM-${DateTime.now().millisecondsSinceEpoch}',
                                        branchId: widget.branchId,
                                        studentId: fa.studentId,
                                        studentName: fa.studentName,
                                        channel: 'WhatsApp',
                                        amountDue: totalDue,
                                        sentAt: DateTime.now(),
                                        status: 'Sent',
                                      ),
                                    );
                                    _showSnack(context, 'WhatsApp notification reminder dispatched!');
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                  child: const Text('WhatsApp', style: TextStyle(fontSize: 10)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 20),
                  Text('Dispatched Reminder Communications Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPri)),
                  const SizedBox(height: 10),
                  if (reminderLogs.isEmpty)
                    Center(child: Text('No payment reminders dispatched yet.', style: TextStyle(color: textSec)))
                  else
                    ...reminderLogs.map((rem) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(rem.channel == 'WhatsApp' ? Icons.message_rounded : (rem.channel == 'SMS' ? Icons.sms_rounded : Icons.email_rounded), color: AppColors.secondary, size: 16),
                          title: Text('Dispatched via ${rem.channel} to ${rem.studentName}', style: TextStyle(color: textPri, fontSize: 12, fontWeight: FontWeight.bold)),
                          subtitle: Text('Due Balance: ₹${rem.amountDue.toStringAsFixed(0)} • Sent: ${rem.sentAt.day}/${rem.sentAt.month} ${rem.sentAt.hour}:${rem.sentAt.minute}', style: TextStyle(color: textSec, fontSize: 11)),
                          trailing: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                        )),
                ],
              ),
            ),
          ] else if (_activeReport == 'Budget Plans') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active Budget Plan Allocations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPri)),
                      ElevatedButton.icon(
                        onPressed: () => _showAddBudgetDialog(context, years),
                        icon: const Icon(Icons.add_rounded, size: 12),
                        label: const Text('Create Budget', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...budgets.map((b) {
                    final percent = b.allocatedAmount > 0 ? (b.spentAmount / b.allocatedAmount) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(b.category, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textPri)),
                              Text('₹${b.spentAmount.toStringAsFixed(0)} / ₹${b.allocatedAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: textSec)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 8,
                              color: percent >= 0.9 ? AppColors.error : AppColors.secondary,
                              backgroundColor: isDark ? Colors.white10 : Colors.black12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ] else if (_activeReport == 'Financial Years') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Financial Year Lock & Cycle Control', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPri)),
                      ElevatedButton.icon(
                        onPressed: () => _showAddFYDialog(context),
                        icon: const Icon(Icons.add_rounded, size: 12),
                        label: const Text('Add FY Period', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...years.map((y) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Text(y.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPri)),
                            if (y.isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                                child: const Text('Current', style: TextStyle(color: AppColors.secondary, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          'Dates: ${y.startDate.day}/${y.startDate.month}/${y.startDate.year} - ${y.endDate.day}/${y.endDate.month}/${y.endDate.year}',
                          style: TextStyle(color: textSec, fontSize: 11),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () {
                            ref.read(financialYearsProvider.notifier).toggleLock(y.id);
                            _showSnack(context, '${y.name} lock state toggled.');
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: y.isLocked ? AppColors.error : AppColors.secondary),
                          child: Text(y.isLocked ? 'Unlock FY' : 'Lock FY', style: const TextStyle(fontSize: 11)),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportRow(String name, double amount, Color textPri, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(fontSize: 12, color: textPri, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('₹${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: textPri, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  void _showAddFYDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Financial Year Period'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _yearNameCtrl,
                decoration: const InputDecoration(labelText: 'Financial Year Name (e.g. FY 2026-27)'),
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
                if (_yearNameCtrl.text.trim().isEmpty) return;
                ref.read(financialYearsProvider.notifier).addFinancialYear(
                  FinancialYearEntity(
                    id: 'FY-${DateTime.now().millisecondsSinceEpoch}',
                    branchId: widget.branchId,
                    name: _yearNameCtrl.text.trim(),
                    startDate: DateTime(2026, 4, 1),
                    endDate: DateTime(2027, 3, 31),
                    isLocked: false,
                    isCurrent: true,
                  ),
                );
                _yearNameCtrl.clear();
                Navigator.pop(context);
                _showSnack(context, 'New Financial Year configured successfully!');
              },
              child: const Text('Create Period'),
            ),
          ],
        );
      },
    );
  }

  void _showAddBudgetDialog(BuildContext context, List<FinancialYearEntity> years) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Category Budget Plan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DropdownFilter(
                    label: 'Category',
                    value: _budgetCategory,
                    items: const ['Academics', 'Administration', 'Infrastructure', 'Staff Salaries', 'Marketing', 'Other'],
                    displayItems: const ['Academics', 'Administration', 'Infrastructure', 'Staff Salaries', 'Marketing', 'Other'],
                    onChanged: (v) => setDialogState(() => _budgetCategory = v),
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _budgetAmountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Allocated Budget Amount (INR)'),
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
                    final amt = double.tryParse(_budgetAmountCtrl.text.trim()) ?? 0.0;
                    if (amt <= 0) return;

                    final currentFY = years.firstWhere((y) => y.isCurrent, orElse: () => years.first);

                    ref.read(budgetPlansProvider.notifier).addBudget(
                      BudgetPlanEntity(
                        id: 'B-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: widget.branchId,
                        financialYearId: currentFY.id,
                        category: _budgetCategory,
                        allocatedAmount: amt,
                        spentAmount: 0.0,
                      ),
                    );

                    _budgetAmountCtrl.clear();
                    Navigator.pop(context);
                    _showSnack(context, 'Budget allocation logged for $_budgetCategory!');
                  },
                  child: const Text('Add Budget allocation'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UTILITIES & SHARED WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Admission': return Icons.app_registration_rounded;
    case 'Tuition': return Icons.menu_book_rounded;
    case 'Exam': return Icons.assignment_rounded;
    case 'Transport': return Icons.directions_bus_rounded;
    case 'Hostel': return Icons.hotel_rounded;
    default: return Icons.payments_rounded;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'Paid': return AppColors.secondary;
    case 'PartiallyPaid': return AppColors.warning;
    case 'Unpaid': return AppColors.error;
    default: return AppColors.error;
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final List<String> displayItems;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.displayItems,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = items.indexOf(value);
    final selectedValue = selectedIndex != -1 ? value : (items.isNotEmpty ? items.first : '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue.isNotEmpty ? selectedValue : null,
          hint: Text(label),
          isDense: true,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: List.generate(items.length, (index) {
            return DropdownMenuItem<String>(
              value: items[index],
              child: Text(displayItems[index]),
            );
          }),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isDark;
  final TextInputType keyboardType;

  const _FormField({
    required this.controller,
    required this.label,
    required this.isDark,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 12,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ),
  );
}

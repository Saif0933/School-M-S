import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';
import '../../payroll_providers.dart';

class HRPayrollPage extends ConsumerStatefulWidget {
  const HRPayrollPage({super.key});

  @override
  ConsumerState<HRPayrollPage> createState() => _HRPayrollPageState();
}

class _HRPayrollPageState extends ConsumerState<HRPayrollPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Selected period for run
  String _selectedPeriod = 'August 2026';

  // Increment parameters
  final _appraisalReviewPeriodCtrl = TextEditingController(text: 'Annual Review 2026');
  final _appraisalPercentCtrl = TextEditingController(text: '10.0');

  // Loan parameters
  final _loanPrincipalCtrl = TextEditingController(text: '40000');
  final _loanEmiCtrl = TextEditingController(text: '4000');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _appraisalReviewPeriodCtrl.dispose();
    _appraisalPercentCtrl.dispose();
    _loanPrincipalCtrl.dispose();
    _loanEmiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';

    // Get staff in active branch
    final allStaff = ref.watch(staffProvider).where((s) => s.branchId == activeBranchId || s.sharedBranchIds.contains(activeBranchId)).toList();

    return Scaffold(
      body: Column(
        children: [
          // Sub Header for payroll stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campus HR & Payroll Desk: ${user?.activeBranch?.branchName ?? "Primary Campus"}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Active Employees Registered: ${allStaff.length} | Branch Code: ${user?.activeBranch?.branchCode ?? "SIS-DEL"}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Active Period: $_selectedPeriod',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: isDark ? Colors.black12 : Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: const [
                Tab(icon: Icon(Icons.settings_suggest_rounded, size: 16), text: 'Salary Structures'),
                Tab(icon: Icon(Icons.run_circle_rounded, size: 16), text: 'Payroll Runs'),
                Tab(icon: Icon(Icons.trending_up_rounded, size: 16), text: 'Appraisals & Increments'),
                Tab(icon: Icon(Icons.monetization_on_rounded, size: 16), text: 'Loans & Advances'),
                Tab(icon: Icon(Icons.description_rounded, size: 16), text: 'Form 16 & PF Reports'),
                Tab(icon: Icon(Icons.analytics_rounded, size: 16), text: 'Cost Analytics'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _StructuresTab(staffList: allStaff, branchId: activeBranchId),
                _RunsTab(
                  staffList: allStaff,
                  branchId: activeBranchId,
                  period: _selectedPeriod,
                  onPeriodChanged: (val) => setState(() => _selectedPeriod = val),
                ),
                _AppraisalsTab(
                  staffList: allStaff,
                  branchId: activeBranchId,
                  reviewPeriodCtrl: _appraisalReviewPeriodCtrl,
                  percentCtrl: _appraisalPercentCtrl,
                ),
                _LoansTab(
                  staffList: allStaff,
                  branchId: activeBranchId,
                  principalCtrl: _loanPrincipalCtrl,
                  emiCtrl: _loanEmiCtrl,
                ),
                _ComplianceTab(branchId: activeBranchId, period: _selectedPeriod),
                _AnalyticsTab(branchId: activeBranchId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 1 — Salary Structures Configuration
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _StructuresTab extends ConsumerWidget {
  final List<StaffEntity> staffList;
  final String branchId;
  const _StructuresTab({required this.staffList, required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final structures = ref.watch(salaryStructuresProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: staffList.length,
      itemBuilder: (context, index) {
        final staff = staffList[index];
        final struct = structures.firstWhere(
          (s) => s.staffId == staff.id,
          orElse: () => SalaryStructureEntity(staffId: staff.id, branchId: branchId),
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(staff.designation, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _breakupText('Basic Pay', struct.basicPay),
                    _breakupText('DA Dues', struct.da),
                    _breakupText('HRA Rent', struct.hra),
                    _breakupText('Gross Monthly', struct.grossEarnings, isBold: true),
                    _breakupText('Net Salary', struct.netSalary, isBold: true, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _editStructureModal(context, ref, struct, staff.name),
                    icon: const Icon(Icons.edit_rounded, size: 14),
                    label: const Text('Update Salary Breakups', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _breakupText(String label, double value, {bool isBold = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  void _editStructureModal(BuildContext context, WidgetRef ref, SalaryStructureEntity struct, String name) {
    final basicCtrl = TextEditingController(text: struct.basicPay.toString());
    final daCtrl = TextEditingController(text: struct.da.toString());
    final hraCtrl = TextEditingController(text: struct.hra.toString());
    final taCtrl = TextEditingController(text: struct.ta.toString());
    final specialCtrl = TextEditingController(text: struct.specialAllowance.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Structure: $name'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: basicCtrl, decoration: const InputDecoration(labelText: 'Basic Salary')),
                TextField(controller: daCtrl, decoration: const InputDecoration(labelText: 'Dearness Allowance (DA)')),
                TextField(controller: hraCtrl, decoration: const InputDecoration(labelText: 'House Rent Allowance (HRA)')),
                TextField(controller: taCtrl, decoration: const InputDecoration(labelText: 'Travel Allowance (TA)')),
                TextField(controller: specialCtrl, decoration: const InputDecoration(labelText: 'Special Allowances')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(salaryStructuresProvider.notifier).updateStructure(
                  struct.staffId,
                  struct.copyWith(
                    basicPay: double.tryParse(basicCtrl.text) ?? struct.basicPay,
                    da: double.tryParse(daCtrl.text) ?? struct.da,
                    hra: double.tryParse(hraCtrl.text) ?? struct.hra,
                    ta: double.tryParse(taCtrl.text) ?? struct.ta,
                    specialAllowance: double.tryParse(specialCtrl.text) ?? struct.specialAllowance,
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Salary components adjusted successfully.')),
                );
              },
              child: const Text('Save components'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 2 — Monthly Payroll processing Runs
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _RunsTab extends ConsumerWidget {
  final List<StaffEntity> staffList;
  final String branchId;
  final String period;
  final ValueChanged<String> onPeriodChanged;

  const _RunsTab({
    required this.staffList,
    required this.branchId,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slips = ref.watch(salarySlipsProvider).where((s) => s.monthYear == period && s.branchId == branchId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: period,
                items: const [
                  DropdownMenuItem(value: 'August 2026', child: Text('August 2026')),
                  DropdownMenuItem(value: 'September 2026', child: Text('September 2026')),
                  DropdownMenuItem(value: 'October 2026', child: Text('October 2026')),
                ],
                onChanged: (val) {
                  if (val != null) onPeriodChanged(val);
                },
              ),
              if (slips.isEmpty)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => _processPayrollRun(context, ref),
                  icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white),
                  label: const Text('Process Run (Draft)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              else if (slips.any((s) => s.status == 'Draft'))
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {
                    ref.read(salarySlipsProvider.notifier).approveSlips(period, branchId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Payroll approved for disbursal.')),
                    );
                  },
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: const Text('Approve Salaries', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              else if (slips.any((s) => s.status == 'Approved'))
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  onPressed: () {
                    ref.read(salarySlipsProvider.notifier).disburseSlips(period, branchId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Salaries disbursed. Disbursal alerts sent to staff accounts.')),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: const Text('Disburse Salaries', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (slips.isNotEmpty)
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
                  onPressed: () => _downloadBankTransferFile(context, slips),
                  icon: const Icon(Icons.text_snippet_rounded, color: Colors.white, size: 16),
                  label: const Text('Download Bank Transfer TXT', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
          const SizedBox(height: 20),
          Text(
            'Slips processed for $period:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (slips.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No salary slips processed for this period.')))
          else
            ...slips.map((slip) => Card(
                  child: ListTile(
                    title: Text(slip.staffName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(
                      'Gross: ₹${slip.grossEarnings.toStringAsFixed(0)} | Deductions: ₹${slip.totalDeductions.toStringAsFixed(0)}\nNet Disbursed: ₹${slip.netDisbursed.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    trailing: Chip(
                      label: Text(slip.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                      backgroundColor: slip.status == 'Disbursed'
                          ? Colors.green
                          : (slip.status == 'Approved' ? Colors.teal : Colors.orange),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _processPayrollRun(BuildContext context, WidgetRef ref) {
    final structures = ref.read(salaryStructuresProvider);
    final activeLoans = ref.read(staffLoansProvider).where((l) => l.branchId == branchId && l.status == 'Active').toList();

    for (final staff in staffList) {
      final struct = structures.firstWhere(
        (s) => s.staffId == staff.id,
        orElse: () => SalaryStructureEntity(staffId: staff.id, branchId: branchId),
      );

      // Check if employee has an active loan EMI to deduct
      final employeeLoan = activeLoans.where((l) => l.staffId == staff.id).firstOrNull;
      final loanEMI = employeeLoan != null ? employeeLoan.monthlyEmi : 0.0;

      ref.read(salarySlipsProvider.notifier).addSalarySlip(
        SalarySlipEntity(
          id: 'SLP-${branchId.replaceAll("BR-", "")}-${period.replaceAll(" ", "")}-${staff.id}',
          staffId: staff.id,
          staffName: staff.name,
          designation: staff.designation,
          branchId: branchId,
          monthYear: period,
          basicPay: struct.basicPay,
          da: struct.da,
          hra: struct.hra,
          ta: struct.ta,
          specialAllowance: struct.specialAllowance,
          pfDeduction: struct.pfDeduction,
          esiDeduction: struct.esiDeduction,
          tdsDeduction: struct.tdsDeduction,
          loanDeduction: loanEMI,
          status: 'Draft',
          processedAt: '2026-08-18',
        ),
      );

      // Pay loan EMI deduction record
      if (employeeLoan != null) {
        ref.read(staffLoansProvider.notifier).payEMI(employeeLoan.id, loanEMI);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ Monthly salary slips processed in Draft mode.')),
    );
  }

  void _downloadBankTransferFile(BuildContext context, List<SalarySlipEntity> slips) {
    String textContent = 'IFS_CODE,ACCOUNT_NO,NET_SALARY,BENEFICIARY_NAME,ROUTING_KEY\n';
    for (final s in slips) {
      textContent += 'SBIN0004321,${s.bankAccountNumber},${s.netDisbursed.toStringAsFixed(2)},${s.staffName},SIS-BRANCH-TRANSFER\n';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bank Transfer file Generated'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Structured CSV format for batch transaction uploads:', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black26,
                child: Text(
                  textContent,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.greenAccent),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 3 — Appraisals & Increments log
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AppraisalsTab extends ConsumerWidget {
  final List<StaffEntity> staffList;
  final String branchId;
  final TextEditingController reviewPeriodCtrl;
  final TextEditingController percentCtrl;

  const _AppraisalsTab({
    required this.staffList,
    required this.branchId,
    required this.reviewPeriodCtrl,
    required this.percentCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appraisals = ref.watch(staffAppraisalsProvider).where((a) => a.branchId == branchId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Record Salary Increment / Appraisal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return Card(
                child: ListTile(
                  dense: true,
                  title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(staff.designation),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () => _showAppraisalModal(context, ref, staff),
                    child: const Text('Log Appraisal', style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text('📜 Past Appraisal History Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          if (appraisals.isEmpty)
            const Text('No past appraisals found.')
          else
            ...appraisals.map((apr) => Card(
                  child: ListTile(
                    title: Text('${apr.staffName} (+${apr.percentageIncrement}%)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    subtitle: Text('Review: ${apr.reviewPeriod} | Effective: ${apr.effectiveDate}'),
                    trailing: Text(
                      '₹${apr.oldBasicPay.toStringAsFixed(0)} ➔ ₹${apr.newBasicPay.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _showAppraisalModal(BuildContext context, WidgetRef ref, StaffEntity staff) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Salary Appraisal: ${staff.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: reviewPeriodCtrl, decoration: const InputDecoration(labelText: 'Review Period Title')),
              TextField(controller: percentCtrl, decoration: const InputDecoration(labelText: 'Percentage Increment (e.g. 10.5)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final pct = double.tryParse(percentCtrl.text) ?? 10.0;
                final structures = ref.read(salaryStructuresProvider);
                final struct = structures.firstWhere((s) => s.staffId == staff.id);

                final oldBasic = struct.basicPay;
                final newBasic = oldBasic * (1 + (pct / 100));

                // 1. Log appraisal record
                ref.read(staffAppraisalsProvider.notifier).logAppraisal(
                  StaffAppraisalEntity(
                    id: 'APR-${DateTime.now().millisecondsSinceEpoch}',
                    staffId: staff.id,
                    staffName: staff.name,
                    branchId: branchId,
                    reviewPeriod: reviewPeriodCtrl.text,
                    oldBasicPay: oldBasic,
                    newBasicPay: newBasic,
                    percentageIncrement: pct,
                    effectiveDate: 'Next Billing Cycle',
                    approvedBy: 'Dr. Principal',
                  ),
                );

                // 2. Adjust salary structure
                ref.read(salaryStructuresProvider.notifier).updateStructure(
                  staff.id,
                  struct.copyWith(basicPay: newBasic),
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✓ Increment recorded! Basic salary changed to ₹${newBasic.toStringAsFixed(0)}')),
                );
              },
              child: const Text('Approve Increment'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 4 — Loans & Advances Tracker
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _LoansTab extends ConsumerWidget {
  final List<StaffEntity> staffList;
  final String branchId;
  final TextEditingController principalCtrl;
  final TextEditingController emiCtrl;

  const _LoansTab({
    required this.staffList,
    required this.branchId,
    required this.principalCtrl,
    required this.emiCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loans = ref.watch(staffLoansProvider).where((l) => l.branchId == branchId).toList();
    final activeStaff = staffList.isNotEmpty ? staffList.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Disburse Employee Loan Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              if (activeStaff != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => _disburseLoanModal(context, ref, activeStaff),
                  child: const Text('Create New Loan', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              return Card(
                child: ListTile(
                  title: Text(loan.staffName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    'Principal: ₹${loan.principalAmount.toStringAsFixed(0)} | Monthly EMI: ₹${loan.monthlyEmi.toStringAsFixed(0)}\nOutstanding: ₹${loan.outstandingAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  trailing: Chip(
                    label: Text(loan.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: loan.status == 'Settled' ? Colors.green : Colors.blue,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _disburseLoanModal(BuildContext context, WidgetRef ref, StaffEntity staff) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Log New Loan: ${staff.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: principalCtrl, decoration: const InputDecoration(labelText: 'Principal Amount (₹)')),
              TextField(controller: emiCtrl, decoration: const InputDecoration(labelText: 'Monthly EMI Deduction (₹)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final p = double.tryParse(principalCtrl.text) ?? 50000.0;
                final emi = double.tryParse(emiCtrl.text) ?? 5000.0;

                ref.read(staffLoansProvider.notifier).logLoanRequest(
                  StaffLoanEntity(
                    id: 'LN-${DateTime.now().millisecondsSinceEpoch}',
                    staffId: staff.id,
                    staffName: staff.name,
                    branchId: branchId,
                    principalAmount: p,
                    monthlyEmi: emi,
                    status: 'Active',
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Loan logged. EMI will auto-deduct in next processing run.')),
                );
              },
              child: const Text('Disburse Loan'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 5 — Form 16 Tax & PF Compliance Reports
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ComplianceTab extends ConsumerWidget {
  final String branchId;
  final String period;
  const _ComplianceTab({required this.branchId, required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final structures = ref.watch(salaryStructuresProvider).where((s) => s.branchId == branchId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Income Tax & Form 16 Projection Desks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ElevatedButton.icon(
                onPressed: () => _simulateForm16Download(context),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download Form 16', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('PF & ESI Compliance Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: Colors.grey.withValues(alpha: 0.2)),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Colors.white10),
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('Staff ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('PF Deduction (12%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('ESI Deduction (0.75%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('TDS flat rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                ],
              ),
              ...structures.map((s) => TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text(s.staffId, style: const TextStyle(fontSize: 11))),
                      Padding(padding: const EdgeInsets.all(8), child: Text('₹${s.pfDeduction.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11))),
                      Padding(padding: const EdgeInsets.all(8), child: Text('₹${s.esiDeduction.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11))),
                      Padding(padding: const EdgeInsets.all(8), child: Text('₹${s.tdsDeduction.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11))),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  void _simulateForm16Download(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚡ Secure Download: Dispatching PDF Form 16 Tax Declarations packet...'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 6 — Organization Payroll Cost Comparison
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AnalyticsTab extends ConsumerWidget {
  final String branchId;
  const _AnalyticsTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final structures = ref.watch(salaryStructuresProvider);
    final delhiCost = structures.where((s) => s.branchId == 'BR-001').fold<double>(0.0, (a, b) => a + b.grossEarnings);
    final mumbaiCost = structures.where((s) => s.branchId == 'BR-002').fold<double>(0.0, (a, b) => a + b.grossEarnings);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏢 Organization consolidated Payroll Cost comparison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gross Monthly Payroll Outflow across branches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 16),
                _outflowBar('Delhi Central SIS Campus (BR-001)', delhiCost, Colors.indigo),
                const SizedBox(height: 16),
                _outflowBar('Mumbai South SPS Campus (BR-002)', mumbaiCost, Colors.teal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _outflowBar(String label, double cost, Color barColor) {
    final maxLimit = 150000.0;
    final pct = cost > 0 ? (cost / maxLimit).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('₹${cost.toStringAsFixed(0)} / Month', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct,
          color: barColor,
          backgroundColor: Colors.white10,
          minHeight: 10,
        ),
      ],
    );
  }
}

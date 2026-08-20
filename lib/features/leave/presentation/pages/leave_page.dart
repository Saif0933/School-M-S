import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class LeaveManagementPage extends ConsumerStatefulWidget {
  const LeaveManagementPage({super.key});

  @override
  ConsumerState<LeaveManagementPage> createState() => _LeaveManagementPageState();
}

class _LeaveManagementPageState extends ConsumerState<LeaveManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Application fields
  final _applicantNameCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController(text: '2026-08-20');
  final _endDateCtrl = TextEditingController(text: '2026-08-21');
  final _attachmentCtrl = TextEditingController();
  String _selectedApplicantType = 'Student';
  String _selectedLeaveType = 'Sick';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _applicantNameCtrl.dispose();
    _reasonCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _attachmentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final allApps = ref.watch(leaveApplicationsProvider).where((l) => l.branchId == activeBranchId).toList();
    final balances = ref.watch(leaveBalancesProvider);

    return Scaffold(
      body: Column(
        children: [
          // Subheader
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;
              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave Policies & Approvals: $branchName',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Text(
                    'Carry Forward Rules: Enabled | Auto Attendance System: Operational',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              );

              final actionButton = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => _tabController.animateTo(0),
                icon: const Icon(Icons.add_task_rounded, color: Colors.white, size: 16),
                label: const Text('Apply for Leave', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              );

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleWidget,
                          const SizedBox(height: 12),
                          actionButton,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: titleWidget),
                          const SizedBox(width: 16),
                          actionButton,
                        ],
                      ),
              );
            },
          ),

          // Tab Bar
          Container(
            color: isDark ? Colors.black12 : Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: const [
                Tab(icon: Icon(Icons.edit_document, size: 16), text: 'Apply Leave & Balances'),
                Tab(icon: Icon(Icons.verified_rounded, size: 16), text: 'Multi-Level Approval Desk'),
                Tab(icon: Icon(Icons.date_range_rounded, size: 16), text: 'Leave Calendars & Reports'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildApplyTab(balances, activeBranchId),
                _buildApprovalsTab(allApps),
                _buildCalendarTab(allApps),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Apply Leave & Balances Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildApplyTab(List<LeaveBalance> balances, String branchId) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final formWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✏️ Submit Leave Application', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedApplicantType,
              decoration: const InputDecoration(labelText: 'Applicant Classification'),
              items: const [
                DropdownMenuItem(value: 'Student', child: Text('Student Application')),
                DropdownMenuItem(value: 'Staff', child: Text('Staff / Teacher Application')),
              ],
              onChanged: (val) => setState(() => _selectedApplicantType = val ?? 'Student'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedLeaveType,
              decoration: const InputDecoration(labelText: 'Leave Type'),
              items: const [
                DropdownMenuItem(value: 'Sick', child: Text('Sick Leave')),
                DropdownMenuItem(value: 'Casual', child: Text('Casual Leave')),
                DropdownMenuItem(value: 'Medical', child: Text('Medical Leave (Syllabus exemption)')),
                DropdownMenuItem(value: 'Emergency', child: Text('Emergency Leave')),
              ],
              onChanged: (val) => setState(() => _selectedLeaveType = val ?? 'Sick'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _applicantNameCtrl, decoration: const InputDecoration(labelText: 'Applicant Name')),
            TextField(controller: _startDateCtrl, decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)')),
            TextField(controller: _endDateCtrl, decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)')),
            TextField(controller: _reasonCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Reason Description')),
            TextField(controller: _attachmentCtrl, decoration: const InputDecoration(labelText: 'Medical Certificate / Doc attachment (Optional)')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  if (_applicantNameCtrl.text.isNotEmpty && _reasonCtrl.text.isNotEmpty) {
                    ref.read(leaveApplicationsProvider.notifier).applyLeave(
                      LeaveApplicationRecord(
                        id: 'LVE-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: branchId,
                        applicantType: _selectedApplicantType,
                        applicantName: _applicantNameCtrl.text,
                        leaveType: _selectedLeaveType,
                        startDate: _startDateCtrl.text,
                        endDate: _endDateCtrl.text,
                        reason: _reasonCtrl.text,
                        attachmentName: _attachmentCtrl.text.isNotEmpty ? _attachmentCtrl.text : null,
                        status: 'Pending',
                      ),
                    );
                    _applicantNameCtrl.clear();
                    _reasonCtrl.clear();
                    _attachmentCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Leave request submitted to department head.')),
                    );
                    _tabController.animateTo(1);
                  }
                },
                child: const Text('Submit Application', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );

        final balancesWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 My Leave Balances (Yearly)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            ...balances.map((b) {
              final remaining = b.total - b.used;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${b.category} Leave', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('$remaining / ${b.total} Remaining', style: const TextStyle(fontSize: 10, color: Colors.indigo)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: remaining / b.total,
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    formWidget,
                    const SizedBox(height: 32),
                    balancesWidget,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: formWidget),
                    const SizedBox(width: 24),
                    Expanded(child: balancesWidget),
                  ],
                ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Approvals Desk (Multi-level check)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildApprovalsTab(List<LeaveApplicationRecord> apps) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final l = apps[index];
        final isPending = l.status == 'Pending';
        final isDeptApproved = l.status == 'Approved (Dept Head)';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('[${l.applicantType}] ${l.applicantName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Chip(
                      label: Text(l.status, style: const TextStyle(fontSize: 8, color: Colors.white)),
                      backgroundColor: l.status == 'Approved' ? Colors.green : (l.status == 'Rejected' ? Colors.red : Colors.orange),
                    ),
                  ],
                ),
                Text('Category: ${l.leaveType} | Dates: ${l.startDate} to ${l.endDate}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                Text('Reason: "${l.reason}"', style: const TextStyle(fontSize: 11)),
                if (l.attachmentName != null) ...[
                  const SizedBox(height: 6),
                  Text('Attachment: ${l.attachmentName}', style: const TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.bold)),
                ],
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isPending) ...[
                      TextButton(
                        onPressed: () => ref.read(leaveApplicationsProvider.notifier).updateApproval(l.id, 'Rejected'),
                        child: const Text('Reject', style: TextStyle(color: Colors.red, fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(leaveApplicationsProvider.notifier).updateApproval(l.id, 'Approved (Dept Head)');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Level 1 Approved (Dept Head). Sent to Principal check.')),
                          );
                        },
                        child: const Text('Approve (Lvl 1)', style: TextStyle(fontSize: 10)),
                      ),
                    ] else if (isDeptApproved) ...[
                      TextButton(
                        onPressed: () => ref.read(leaveApplicationsProvider.notifier).updateApproval(l.id, 'Rejected'),
                        child: const Text('Reject', style: TextStyle(color: Colors.red, fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        onPressed: () {
                          ref.read(leaveApplicationsProvider.notifier).updateApproval(l.id, 'Approved');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Principal Approved. Attendance registers updated automatically!')),
                          );
                        },
                        child: const Text('Final Approve (Principal)', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ] else ...[
                      const Text('Approvals Complete', style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Leave Calendar Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildCalendarTab(List<LeaveApplicationRecord> apps) {
    final activeLeaves = apps.where((a) => a.status == 'Approved').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📅 Active Campus Leave Calendar Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          if (activeLeaves.isEmpty)
            const Text('No members currently on leave today.', style: TextStyle(color: Colors.grey, fontSize: 11))
          else
            ...activeLeaves.map((l) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.airline_seat_flat_rounded, color: Colors.blue),
                    title: Text('${l.applicantName} (${l.applicantType})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    subtitle: Text('Leave category: ${l.leaveType} | Dates: ${l.startDate} to ${l.endDate}'),
                  ),
                )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Compiling leaves data sheet to PDF... Download started.')),
                );
              },
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: const Text('Download Leave Summary Report', style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

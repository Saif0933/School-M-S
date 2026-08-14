import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../../organization/providers.dart';
import '../../../academic/providers.dart';
import '../../providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Staff Management Page (Branch-Scoped & Shared)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffManagementPage extends ConsumerStatefulWidget {
  const StaffManagementPage({super.key});

  @override
  ConsumerState<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends ConsumerState<StaffManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedRole;
  String? _filterBranchId;
  StaffEntity? _selectedStaff;

  // Registration Form Controllers
  final _nameCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _dobCtrl = TextEditingController(text: '1990-01-01');
  final _dojCtrl = TextEditingController(text: '2026-06-01');
  final _qualCtrl = TextEditingController();
  final _specCtrl = TextEditingController();
  final _instCtrl = TextEditingController();
  final _expCtrl = TextEditingController(text: '3');
  final _prevEmpCtrl = TextEditingController();
  String _gender = 'Male';
  final String _bloodGroup = 'O+';
  String _role = 'Teacher';
  String? _selectedDeptId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose(); _designationCtrl.dispose(); _phoneCtrl.dispose();
    _emailCtrl.dispose(); _addressCtrl.dispose(); _dobCtrl.dispose();
    _dojCtrl.dispose(); _qualCtrl.dispose(); _specCtrl.dispose();
    _instCtrl.dispose(); _expCtrl.dispose(); _prevEmpCtrl.dispose();
    super.dispose();
  }

  String _staffName(String id) {
    final all = ref.read(staffProvider);
    final s = all.where((e) => e.id == id);
    return s.isNotEmpty ? s.first.name : id;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranch?.branchId;

    if (activeBranchId == null) {
      return const Center(child: Text('No active branch selected.'));
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            tabs: const [
              Tab(icon: Icon(Icons.badge_rounded, size: 16), text: 'Directory'),
              Tab(icon: Icon(Icons.person_add_alt_1_rounded, size: 16), text: 'Register'),
              Tab(icon: Icon(Icons.article_rounded, size: 16), text: 'Documents'),
              Tab(icon: Icon(Icons.school_rounded, size: 16), text: 'Subjects & Class Teachers'),
              Tab(icon: Icon(Icons.swap_horiz_rounded, size: 16), text: 'Substitutions'),
              Tab(icon: Icon(Icons.event_available_rounded, size: 16), text: 'Leave & Attendance'),
              Tab(icon: Icon(Icons.payments_rounded, size: 16), text: 'Payroll & HR'),
              Tab(icon: Icon(Icons.trending_up_rounded, size: 16), text: 'Performance'),
              Tab(icon: Icon(Icons.exit_to_app_rounded, size: 16), text: 'Offboarding & Exit'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDirectoryTab(isDark, activeBranchId),
              _buildRegistrationTab(isDark, activeBranchId),
              _buildDocumentsTab(isDark, activeBranchId),
              _buildSubjectTeacherTab(isDark, activeBranchId),
              _buildSubstitutionTab(isDark, activeBranchId),
              _buildLeaveAttendanceTab(isDark, activeBranchId),
              _buildPayrollTab(isDark, activeBranchId),
              _buildPerformanceTab(isDark, activeBranchId),
              _buildOffboardingTab(isDark, activeBranchId),
            ],
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 1: STAFF DIRECTORY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildDirectoryTab(bool isDark, String activeBranchId) {
    final user = ref.watch(currentUserProvider);
    final isOrgAdmin = user?.role.isOrgLevel ?? false;
    final branches = ref.watch(organizationBranchesProvider);
    _filterBranchId ??= activeBranchId;

    final allStaff = ref.watch(staffProvider);
    final staffList = allStaff.where((s) {
      if (isOrgAdmin) {
        if (_filterBranchId == 'ALL') return true;
        return s.branchId == _filterBranchId || s.sharedBranchIds.contains(_filterBranchId);
      }
      return s.branchId == activeBranchId || s.sharedBranchIds.contains(activeBranchId);
    }).toList();

    final filteredStaff = staffList.where((s) {
      final matchSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || s.employeeId.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchRole = _selectedRole == null || s.role == _selectedRole;
      return matchSearch && matchRole;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Summary
          Row(
            children: [
              _statCard('Total Staff', '${staffList.length}', Icons.badge_rounded, Colors.blue),
              const SizedBox(width: 12),
              _statCard('Teachers', '${staffList.where((s) => s.role == 'Teacher').length}', Icons.school_rounded, Colors.green),
              const SizedBox(width: 12),
              _statCard('HODs', '${staffList.where((s) => s.role == 'HOD').length}', Icons.star_rounded, Colors.amber),
              const SizedBox(width: 12),
              _statCard('Shared', '${staffList.where((s) => s.sharedBranchIds.isNotEmpty).length}', Icons.share_rounded, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),

          // Consolidated Branch Headcount Comparison Panel
          if (isOrgAdmin) ...[
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🏢 Branch-wise Headcount & Analytics Comparison', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: isDark ? Colors.white12 : Colors.grey.shade200, width: 1, borderRadius: BorderRadius.circular(4)),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.2),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1)),
                        children: const [
                          Padding(padding: EdgeInsets.all(6), child: Text('Campus Name', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(6), child: Text('Total Staff', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(6), child: Text('Teachers', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(6), child: Text('HODs/Admins', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(6), child: Text('Shared Pool', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      ...branches.map((b) {
                        final bStaff = allStaff.where((s) => s.branchId == b.id).toList();
                        final sharedStaff = allStaff.where((s) => s.sharedBranchIds.contains(b.id)).toList();
                        return TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(6), child: Text(b.name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            Padding(padding: const EdgeInsets.all(6), child: Text('${bStaff.length + sharedStaff.length} (Primary: ${bStaff.length})', style: const TextStyle(fontSize: 9))),
                            Padding(padding: const EdgeInsets.all(6), child: Text('${bStaff.where((s) => s.role == 'Teacher').length + sharedStaff.where((s) => s.role == 'Teacher').length}', style: const TextStyle(fontSize: 9))),
                            Padding(padding: const EdgeInsets.all(6), child: Text('${bStaff.where((s) => s.role != 'Teacher').length + sharedStaff.where((s) => s.role != 'Teacher').length}', style: const TextStyle(fontSize: 9))),
                            Padding(padding: const EdgeInsets.all(6), child: Text('${sharedStaff.length} shared', style: const TextStyle(fontSize: 9, color: Colors.purple, fontWeight: FontWeight.bold))),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Filter Panel
          GlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(flex: 2, child: TextField(
                  decoration: const InputDecoration(hintText: 'Search by name or employee ID...', prefixIcon: Icon(Icons.search_rounded, size: 18), isDense: true),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (v) => setState(() => _searchQuery = v),
                )),
                const SizedBox(width: 12),
                if (isOrgAdmin) ...[
                  Expanded(child: DropdownButtonFormField<String>(
                    initialValue: _filterBranchId,
                    decoration: const InputDecoration(labelText: 'Branch', isDense: true),
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: [const DropdownMenuItem(value: 'ALL', child: Text('All Campuses', style: TextStyle(fontSize: 10))), ...branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontSize: 10))))],
                    onChanged: (v) => setState(() => _filterBranchId = v),
                  )),
                  const SizedBox(width: 12),
                ],
                Expanded(child: DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role', isDense: true),
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Roles', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'Teacher', child: Text('Teacher', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'HOD', child: Text('HOD', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'branchAdmin', child: Text('Admin', style: TextStyle(fontSize: 10))),
                  ],
                  onChanged: (v) => setState(() => _selectedRole = v),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: _selectedStaff != null ? 3 : 1,
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Staff Registry (${filteredStaff.length})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Row(children: [
                            IconButton(icon: const Icon(Icons.picture_as_pdf_rounded, size: 16), tooltip: 'Export PDF', onPressed: () => _showExportSnack('PDF')),
                            IconButton(icon: const Icon(Icons.table_chart_rounded, size: 16), tooltip: 'Export Excel', onPressed: () => _showExportSnack('Excel')),
                          ]),
                        ],
                      ),
                      const Divider(),
                      if (filteredStaff.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No staff records found.')))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredStaff.length,
                          separatorBuilder: (_, i) => const Divider(height: 1),
                          itemBuilder: (ctx, idx) {
                            final s = filteredStaff[idx];
                            final isShared = s.branchId != activeBranchId;
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                foregroundColor: AppColors.primary,
                                child: Text(s.name.substring(0, 2).toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              title: Row(children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(width: 6),
                                if (isShared) Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('Shared', style: TextStyle(fontSize: 7, color: Colors.amber, fontWeight: FontWeight.bold)),
                                ),
                              ]),
                              subtitle: Text('${s.employeeId} | ${s.designation} | ${s.qualification}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(s.status, style: TextStyle(color: s.status == 'Active' ? Colors.green : Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text('DOJ: ${s.dateOfJoining}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                ],
                              ),
                              onTap: () => setState(() => _selectedStaff = s),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              if (_selectedStaff != null) ...[
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildProfileSidebar(isDark, activeBranchId)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(child: GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ]),
      ]),
    ));
  }

  void _showExportSnack(String format) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Staff directory exported as $format successfully!')));
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PROFILE SIDEBAR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildProfileSidebar(bool isDark, String activeBranchId) {
    final staff = ref.watch(staffProvider).firstWhere((s) => s.id == _selectedStaff!.id, orElse: () => _selectedStaff!);
    final branches = ref.watch(organizationBranchesProvider);
    final primaryBranchName = branches.any((b) => b.id == staff.branchId) ? branches.firstWhere((b) => b.id == staff.branchId).name : 'Main Campus';
    final depts = ref.watch(academicDepartmentsProvider);
    final deptName = depts.any((d) => d.id == staff.departmentId) ? depts.firstWhere((d) => d.id == staff.departmentId).name : 'Not Assigned';

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Employee Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close_rounded, size: 16), onPressed: () => setState(() => _selectedStaff = null)),
            ]),
            const Divider(),
            Center(child: Column(children: [
              CircleAvatar(radius: 26, backgroundColor: AppColors.secondary.withValues(alpha: 0.15), foregroundColor: AppColors.secondary, child: Text(staff.name.substring(0, 2).toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
              const SizedBox(height: 6),
              Text(staff.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text('${staff.employeeId} | ${staff.designation}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text('Primary: $primaryBranchName', style: const TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.call_rounded, color: Colors.green, size: 18),
                    tooltip: 'Call Staff',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dialing ${staff.name} at ${staff.phone}...'))),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.email_rounded, color: Colors.blue, size: 18),
                    tooltip: 'Email Staff',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening compose mail to ${staff.email}...'))),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.teal, size: 18),
                    tooltip: 'WhatsApp Message',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Simulating WhatsApp chat with ${staff.phone}...'))),
                  ),
                ],
              ),
            ])),
            const SizedBox(height: 12),
            // Personal Info
            _sectionHeader('Personal Details'),
            _profileRow('Phone', staff.phone), _profileRow('Email', staff.email),
            _profileRow('Gender', staff.gender), _profileRow('DOB', staff.dateOfBirth),
            _profileRow('Blood Group', staff.bloodGroup), _profileRow('Address', staff.address),
            const SizedBox(height: 12),
            _sectionHeader('Professional Details'),
            _profileRow('Department', deptName),
            _profileRow('Qualification', staff.qualification), _profileRow('Specialization', staff.specialization),
            _profileRow('Institution', staff.institution), _profileRow('Experience', '${staff.yearsOfExperience} Years'),
            _profileRow('Previous Employer', staff.previousEmployer), _profileRow('Role Access', staff.role),
            const SizedBox(height: 12),
            _sectionHeader('Cross-Branch Assignments'),
            if (staff.sharedBranchIds.isEmpty)
              const Text('Primary branch only', style: TextStyle(fontSize: 9, color: Colors.grey))
            else
              ...staff.sharedBranchIds.map((bId) {
                final bName = branches.any((b) => b.id == bId) ? branches.firstWhere((b) => b.id == bId).name : bId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [const Icon(Icons.share_rounded, size: 10, color: Colors.amber), const SizedBox(width: 6), Text(bName, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))]),
                    IconButton(icon: const Icon(Icons.cancel_outlined, size: 10, color: Colors.red), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () {
                      ref.read(staffProvider.notifier).removeSharedBranch(staff.id, bId);
                    }),
                  ]),
                );
              }),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(isDense: true, labelText: 'Add Shared Campus'),
              style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              items: branches.where((b) => b.id != staff.branchId && !staff.sharedBranchIds.contains(b.id)).map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontSize: 9)))).toList(),
              onChanged: (v) {
                if (v != null) { ref.read(staffProvider.notifier).addSharedBranch(staff.id, v); }
              },
            ),
            const SizedBox(height: 12),
            // ID Card Generation
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
              onPressed: () => _showIDCardDialog(context, staff, branches.firstWhere((b) => b.id == staff.branchId, orElse: () => branches.first)),
              icon: const Icon(Icons.badge_rounded, size: 14),
              label: const Text('Generate Staff ID Card', style: TextStyle(fontSize: 10)),
            )),
            const SizedBox(height: 6),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
              onPressed: () => _showExperienceCertificateDialog(context, staff, branches.firstWhere((b) => b.id == staff.branchId, orElse: () => branches.first)),
              icon: const Icon(Icons.description_rounded, size: 14),
              label: const Text('Experience Certificate', style: TextStyle(fontSize: 10)),
            )),
            const SizedBox(height: 6),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8), foregroundColor: Colors.red),
              onPressed: () => _showRelievingLetterDialog(context, staff, branches.firstWhere((b) => b.id == staff.branchId, orElse: () => branches.first)),
              icon: const Icon(Icons.exit_to_app_rounded, size: 14),
              label: const Text('Relieving Letter & F&F', style: TextStyle(fontSize: 10)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
  );

  Widget _profileRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
    ]),
  );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 2: REGISTER STAFF
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildRegistrationTab(bool isDark, String branchId) {
    final depts = ref.watch(academicDepartmentsProvider).where((d) => d.branchId == branchId).toList();
    final candidates = ref.watch(recruitmentProvider).where((c) => c.branchId == branchId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Direct Enrollment
          Expanded(
            flex: 4,
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Staff Registration & Direct Onboarding', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const Text('Complete the recruitment onboarding form. Employee ID auto-generates with branch prefix.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: TextField(controller: _nameCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Full Name *', isDense: true))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _designationCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Designation *', isDense: true))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(
                    initialValue: _selectedDeptId,
                    decoration: const InputDecoration(labelText: 'Department *', isDense: true),
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: depts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name, style: const TextStyle(fontSize: 10)))).toList(),
                    onChanged: (v) => setState(() => _selectedDeptId = v),
                  )),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(initialValue: _role, decoration: const InputDecoration(labelText: 'System Role *', isDense: true), style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary), items: const [
                    DropdownMenuItem(value: 'Teacher', child: Text('Teacher', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'HOD', child: Text('HOD', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'branchAdmin', child: Text('Branch Admin', style: TextStyle(fontSize: 10))),
                  ], onChanged: (v) { if (v != null) setState(() => _role = v); })),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<String>(initialValue: _gender, decoration: const InputDecoration(labelText: 'Gender', isDense: true), style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary), items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'Other', child: Text('Other', style: TextStyle(fontSize: 10))),
                  ], onChanged: (v) { if (v != null) setState(() => _gender = v); })),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _phoneCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Phone *', isDense: true))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _emailCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Email *', isDense: true))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _dobCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Date of Birth *', isDense: true))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _dojCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Date of Joining *', isDense: true))),
                ]),
                const SizedBox(height: 12),
                TextField(controller: _addressCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Address *', isDense: true)),
                const SizedBox(height: 16),
                const Divider(),
                const Text('Qualifications & Experience', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _qualCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Qualification * (e.g. M.Ed)', isDense: true))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _specCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Specialization', isDense: true))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _instCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'University/College *', isDense: true))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _expCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Years of Experience *', isDense: true))),
                ]),
                const SizedBox(height: 12),
                TextField(controller: _prevEmpCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Previous Employer', isDense: true)),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    if (_nameCtrl.text.trim().isEmpty || _designationCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _qualCtrl.text.trim().isEmpty || _instCtrl.text.trim().isEmpty || _selectedDeptId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all mandatory fields.')));
                      return;
                    }
                    ref.read(staffProvider.notifier).registerStaff(branchId: branchId, name: _nameCtrl.text.trim(), designation: _designationCtrl.text.trim(), role: _role, dateOfJoining: _dojCtrl.text.trim(), gender: _gender, dateOfBirth: _dobCtrl.text.trim(), bloodGroup: _bloodGroup, phone: _phoneCtrl.text.trim(), email: _emailCtrl.text.trim(), address: _addressCtrl.text.trim(), qualification: _qualCtrl.text.trim(), specialization: _specCtrl.text.trim(), institution: _instCtrl.text.trim(), yearsOfExperience: int.tryParse(_expCtrl.text.trim()) ?? 0, previousEmployer: _prevEmpCtrl.text.trim(), departmentId: _selectedDeptId!);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff registered & onboarded successfully!')));
                    _nameCtrl.clear(); _designationCtrl.clear(); _phoneCtrl.clear(); _emailCtrl.clear(); _addressCtrl.clear(); _qualCtrl.clear(); _specCtrl.clear(); _instCtrl.clear(); _prevEmpCtrl.clear();
                    setState(() {
                      _selectedDeptId = null;
                    });
                    _tabController.animateTo(0);
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Complete Enrollment & Generate Employee ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                )),
              ]),
            ),
          ),
          const SizedBox(width: 16),
          // Right: Recruitment Pipeline
          Expanded(
            flex: 5,
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recruitment & Hiring Pipeline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('Manage applicants, interview stages, and onboarding checklists.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_add_rounded, color: Colors.green, size: 20),
                        tooltip: 'Add Candidate to Pipeline',
                        onPressed: () => _showAddCandidateDialog(context, branchId),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (candidates.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No active candidates in the pipeline.')))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: candidates.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final c = candidates[index];
                        final isHired = c.stage == 'Hired';
                        Color stageColor = Colors.blue;
                        if (c.stage == 'Interviewing') stageColor = Colors.orange;
                        if (c.stage == 'Offered') stageColor = Colors.purple;
                        if (c.stage == 'Onboarding') stageColor = Colors.teal;
                        if (isHired) stageColor = Colors.green;

                        return Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: isDark ? Colors.white10 : Colors.grey.shade50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(c.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: stageColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                      child: Text(c.stage, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: stageColor)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('${c.designation} | ${c.qualification} | ${c.yearsOfExperience} Yrs Exp', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                if (c.interviewNotes.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text('Notes: ${c.interviewNotes}', style: const TextStyle(fontSize: 8, fontStyle: FontStyle.italic, color: Colors.black54)),
                                ],
                                if (c.stage == 'Onboarding') ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: c.onboardingProgress,
                                            minHeight: 4,
                                            backgroundColor: Colors.grey.shade300,
                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('${(c.onboardingProgress * 100).toStringAsFixed(0)}% Onboarded', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.teal)),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (c.stage == 'Applied') ...[
                                      TextButton(
                                        onPressed: () => ref.read(recruitmentProvider.notifier).advanceCandidateStage(c.id, 'Interviewing'),
                                        child: const Text('Schedule Interview', style: TextStyle(fontSize: 9, color: Colors.orange)),
                                      ),
                                    ],
                                    if (c.stage == 'Interviewing') ...[
                                      TextButton(
                                        onPressed: () => ref.read(recruitmentProvider.notifier).advanceCandidateStage(c.id, 'Offered'),
                                        child: const Text('Release Offer', style: TextStyle(fontSize: 9, color: Colors.purple)),
                                      ),
                                    ],
                                    if (c.stage == 'Offered') ...[
                                      TextButton(
                                        onPressed: () => ref.read(recruitmentProvider.notifier).advanceCandidateStage(c.id, 'Onboarding'),
                                        child: const Text('Start Induction', style: TextStyle(fontSize: 9, color: Colors.teal)),
                                      ),
                                    ],
                                    if (c.stage == 'Onboarding') ...[
                                      TextButton(
                                        onPressed: () => _showOnboardingProgressDialog(context, c),
                                        child: const Text('Track Checklist', style: TextStyle(fontSize: 9, color: Colors.teal)),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), minimumSize: Size.zero),
                                        onPressed: () {
                                          ref.read(recruitmentProvider.notifier).hireCandidate(c.id);
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${c.name} has been hired and employee ID generated!')));
                                        },
                                        child: const Text('Finalize Hire', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                    if (isHired) ...[
                                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                                      const SizedBox(width: 4),
                                      const Text('Employment Confirmed', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 3: DOCUMENT MANAGEMENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildDocumentsTab(bool isDark, String branchId) {
    final branchStaff = ref.watch(staffProvider).where((s) => s.branchId == branchId || s.sharedBranchIds.contains(branchId)).toList();
    final docTypes = ['Degree Certificate', 'B.Ed / M.Ed Diploma', 'Identity Proof (Aadhar)', 'PAN Card', 'Passport Photo', 'Resume/CV', 'Experience Letter', 'Police Verification', 'Medical Fitness Certificate', 'CTET/TET Certificate'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Document Management Vault (Branch-Scoped)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const Text('Manage degrees, certificates, and identity proofs for all branch staff.', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 16),
        ...branchStaff.map((staff) => GlassCard(
          padding: const EdgeInsets.all(12),
          child: ExpansionTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              child: Text(staff.name.substring(0, 2).toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            ),
            title: Text(staff.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            subtitle: Text('${staff.employeeId} | ${staff.uploadedDocuments.length} documents uploaded', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            children: [
              const Divider(),
              ...staff.uploadedDocuments.map((doc) => ListTile(
                dense: true,
                leading: const Icon(Icons.article_rounded, size: 14, color: Colors.blue),
                title: Text(doc, style: const TextStyle(fontSize: 10)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle, size: 12, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text('Verified', style: TextStyle(fontSize: 8, color: Colors.green)),
                ]),
              )),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(isDense: true, labelText: 'Upload New Document'),
                  style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  items: docTypes.where((d) => !staff.uploadedDocuments.contains(d)).map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 9)))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(staffProvider.notifier).uploadDocument(staff.id, v);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$v uploaded & encrypted for ${staff.name}!')));
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        )),
      ]),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 4: SUBJECT ASSIGNMENT & CLASS TEACHERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSubjectTeacherTab(bool isDark, String branchId) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == branchId).toList();
    final sections = ref.watch(academicSectionsProvider);
    final assignments = ref.watch(subjectAssignmentsProvider).where((a) => a.branchId == branchId).toList();
    final branchStaff = ref.watch(staffProvider).where((s) => (s.branchId == branchId || s.sharedBranchIds.contains(branchId)) && s.role == 'Teacher' || s.role == 'HOD').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Class Teacher Allocation
        const Text('Class Teacher Allocation (Per Section)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const Text('Assign class teachers to each section within branch.', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 12),
        ...classes.map((cls) {
          final classSections = sections.where((s) => s.classId == cls.id).toList();
          if (classSections.isEmpty) return const SizedBox.shrink();
          return GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${cls.name} (${cls.code})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...classSections.map((sec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  SizedBox(width: 80, child: Text('Section ${sec.name}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<String>(
                    initialValue: branchStaff.any((s) => s.name == sec.classTeacher) ? sec.classTeacher : null,
                    decoration: InputDecoration(isDense: true, labelText: 'Class Teacher: ${sec.classTeacher}'),
                    style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: branchStaff.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name, style: const TextStyle(fontSize: 9)))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(academicSectionsProvider.notifier).updateClassTeacher(sec.id, v);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$v assigned as class teacher for ${cls.name} Section ${sec.name}')));
                      }
                    },
                  )),
                  const SizedBox(width: 8),
                  Text('Room: ${sec.roomNumber}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                ]),
              )),
            ]),
          );
        }),
        const SizedBox(height: 24),
        const Divider(),
        // Subject Assignments
        const Text('Subject-Teacher Assignments (Per Branch)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const Text('Map subjects to teachers for each class and section.', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 12),
        if (assignments.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No subject assignments yet.', style: TextStyle(color: Colors.grey))))
        else
          ...assignments.map((a) {
            final clsName = classes.any((c) => c.id == a.classId) ? classes.firstWhere((c) => c.id == a.classId).name : a.classId;
            final secName = sections.any((s) => s.id == a.sectionId) ? sections.firstWhere((s) => s.id == a.sectionId).name : a.sectionId;
            return ListTile(
              dense: true,
              leading: const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.primary),
              title: Text(a.subjectName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              subtitle: Text('$clsName | Section $secName | Teacher: ${a.assignedTeacher}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
              trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.red), onPressed: () => ref.read(subjectAssignmentsProvider.notifier).removeAssignment(a.id)),
            );
          }),
        const SizedBox(height: 12),
        // Add New Assignment
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: _SubjectAssignmentForm(branchId: branchId, isDark: isDark),
        ),
      ]),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 5: SUBSTITUTION MANAGEMENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSubstitutionTab(bool isDark, String branchId) {
    final subs = ref.watch(substitutionProvider).where((s) => s.branchId == branchId).toList();
    final branchStaff = ref.watch(staffProvider).where((s) => s.branchId == branchId || s.sharedBranchIds.contains(branchId)).toList();
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == branchId).toList();
    final sections = ref.watch(academicSectionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Teacher Substitution Management', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const Text('Manage teacher substitutions within branch. Auto-suggests available staff.', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 16),
        // Active Substitutions
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Active Substitutions (${subs.where((s) => s.status == 'Active').length})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const Divider(),
            if (subs.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No substitution records.'))),
            ...subs.map((sub) {
              final origName = _staffName(sub.originalTeacherId);
              final subName = _staffName(sub.substituteTeacherId);
              final clsName = classes.any((c) => c.id == sub.classId) ? classes.firstWhere((c) => c.id == sub.classId).name : sub.classId;
              final secName = sections.any((s) => s.id == sub.sectionId) ? sections.firstWhere((s) => s.id == sub.sectionId).name : sub.sectionId;
              return ListTile(
                dense: true,
                leading: Icon(Icons.swap_horiz_rounded, size: 16, color: sub.status == 'Active' ? Colors.orange : Colors.grey),
                title: Text('$origName → $subName', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                subtitle: Text('$clsName Sec $secName | ${sub.date} | ${sub.reason}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: sub.status == 'Active' ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(sub.status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: sub.status == 'Active' ? Colors.orange : Colors.grey)),
                  ),
                  if (sub.status == 'Active') ...[
                    const SizedBox(width: 4),
                    IconButton(icon: const Icon(Icons.cancel_rounded, size: 14, color: Colors.red), onPressed: () {
                      ref.read(substitutionProvider.notifier).cancelSubstitution(sub.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Substitution cancelled.')));
                    }),
                  ],
                ]),
              );
            }),
          ]),
        ),
        const SizedBox(height: 16),
        // Create New Substitution
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: _SubstitutionForm(branchId: branchId, branchStaff: branchStaff, classes: classes, sections: sections, isDark: isDark),
        ),
      ]),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 6: LEAVE & ATTENDANCE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildLeaveAttendanceTab(bool isDark, String branchId) {
    final leaves = ref.watch(staffLeaveProvider).where((l) => l.branchId == branchId).toList();
    final attendance = ref.watch(staffAttendanceProvider).where((a) => a.branchId == branchId).toList();
    final duties = ref.watch(dutyRosterProvider).where((d) => d.branchId == branchId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Today's Attendance Summary
        Row(children: [
          _statCard('Present', '${attendance.where((a) => a.status == 'Present').length}', Icons.check_circle_rounded, Colors.green),
          const SizedBox(width: 12),
          _statCard('Absent', '${attendance.where((a) => a.status == 'Absent').length}', Icons.cancel_rounded, Colors.red),
          const SizedBox(width: 12),
          _statCard('On Leave', '${attendance.where((a) => a.status == 'OnLeave').length}', Icons.event_busy_rounded, Colors.orange),
          const SizedBox(width: 12),
          _statCard('Late', '${attendance.where((a) => a.status == 'Late').length}', Icons.access_time_rounded, Colors.amber),
        ]),
        const SizedBox(height: 16),

        // Attendance Records
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Staff Attendance", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.green),
                  tooltip: 'Mark Attendance',
                  onPressed: () => _showMarkAttendanceDialog(context, branchId),
                ),
              ],
            ),
            const Divider(),
            ...attendance.map((a) => ListTile(
              dense: true,
              leading: Icon(
                a.status == 'Present' ? Icons.check_circle_rounded : a.status == 'OnLeave' ? Icons.event_busy_rounded : Icons.cancel_rounded,
                size: 16, color: a.status == 'Present' ? Colors.green : a.status == 'OnLeave' ? Colors.orange : Colors.red,
              ),
              title: Text(_staffName(a.staffId), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              subtitle: Text('Check-in: ${a.checkInTime} | Check-out: ${a.checkOutTime}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: (a.status == 'Present' ? Colors.green : Colors.orange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(a.status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: a.status == 'Present' ? Colors.green : a.status == 'OnLeave' ? Colors.orange : Colors.red)),
              ),
            )),
          ]),
        ),
        const SizedBox(height: 16),

        // Leave Applications
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Leave Applications (CL, EL, ML, Casual, Medical)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.green),
                  tooltip: 'Apply Leave',
                  onPressed: () => _showApplyLeaveDialog(context, branchId),
                ),
              ],
            ),
            const Divider(),
            ...leaves.map((l) => ListTile(
              dense: true,
              leading: Icon(
                l.status == 'Approved' ? Icons.check_circle_rounded : l.status == 'Rejected' ? Icons.cancel_rounded : Icons.hourglass_top_rounded,
                size: 16, color: l.status == 'Approved' ? Colors.green : l.status == 'Rejected' ? Colors.red : Colors.orange,
              ),
              title: Text('${_staffName(l.staffId)} — ${l.leaveType} (${l.days} days)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              subtitle: Text('${l.fromDate} to ${l.toDate} | ${l.reason}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
              trailing: l.status == 'Pending' ? Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.check_rounded, size: 16, color: Colors.green), onPressed: () => ref.read(staffLeaveProvider.notifier).approveLeave(l.id)),
                IconButton(icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red), onPressed: () => ref.read(staffLeaveProvider.notifier).rejectLeave(l.id)),
              ]) : Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: (l.status == 'Approved' ? Colors.green : Colors.red).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(l.status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: l.status == 'Approved' ? Colors.green : Colors.red)),
              ),
            )),
          ]),
        ),
        const SizedBox(height: 16),

        // Duty Roster
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Duty Roster & Shift Schedule", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.green),
                  tooltip: 'Assign Shift Duty',
                  onPressed: () => _showAssignDutyDialog(context, branchId),
                ),
              ],
            ),
            const Divider(),
            ...duties.map((d) => ListTile(
              dense: true,
              leading: const Icon(Icons.assignment_ind_rounded, size: 16, color: AppColors.primary),
              title: Text(_staffName(d.staffId), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              subtitle: Text('${d.shift} Shift | ${d.dutyType}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
              trailing: Text(d.date, style: const TextStyle(fontSize: 8, color: Colors.grey)),
            )),
          ]),
        ),
      ]),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 7: PAYROLL & HR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPayrollTab(bool isDark, String branchId) {
    final payrolls = ref.watch(staffPayrollProvider).where((p) => p.branchId == branchId).toList();
    final trainings = ref.watch(staffTrainingProvider).where((t) => t.branchId == branchId).toList();
    final transfers = ref.watch(staffTransferProvider);

    final totalPay = payrolls.fold<double>(0, (sum, p) => sum + p.netPay);
    final pendingCount = payrolls.where((p) => p.status == 'Pending').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _statCard('Total Payroll', '₹${totalPay.toStringAsFixed(0)}', Icons.account_balance_wallet_rounded, Colors.green),
          const SizedBox(width: 12),
          _statCard('Pending', '$pendingCount', Icons.hourglass_top_rounded, Colors.orange),
          const SizedBox(width: 12),
          _statCard('Trainings', '${trainings.length}', Icons.school_rounded, Colors.blue),
          const SizedBox(width: 12),
          _statCard('Transfers', '${transfers.length}', Icons.swap_horiz_rounded, Colors.purple),
        ]),
        const SizedBox(height: 16),

        // Payroll Records
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payroll Processing (Branch-Scoped)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.green),
                      tooltip: 'Process New Payroll',
                      onPressed: () => _showProcessPayrollDialog(context, branchId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.receipt_long_rounded, size: 16),
                      tooltip: 'Generate Salary Slips',
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salary slips generated with branch header for all staff!'))),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            ...payrolls.map((p) => ListTile(
              dense: true,
              onTap: () => _showSalarySlipDialog(context, p),
              leading: Icon(Icons.payments_rounded, size: 16, color: p.status == 'Paid' ? Colors.green : p.status == 'Processed' ? Colors.blue : Colors.orange),
              title: Text('${_staffName(p.staffId)} — ${p.month}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Basic: ₹${p.basicSalary.toStringAsFixed(0)} | DA: ₹${p.da.toStringAsFixed(0)} | HRA: ₹${p.hra.toStringAsFixed(0)} | PF: -₹${p.pfDeduction.toStringAsFixed(0)} | TDS: -₹${p.tdsDeduction.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 8, color: Colors.grey),
              ),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('₹${p.netPay.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: (p.status == 'Paid' ? Colors.green : Colors.orange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(p.status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: p.status == 'Paid' ? Colors.green : Colors.orange)),
                ),
                if (p.status == 'Pending') ...[
                  const SizedBox(width: 4),
                  IconButton(icon: const Icon(Icons.check_circle_rounded, size: 14, color: Colors.green), onPressed: () => ref.read(staffPayrollProvider.notifier).markPaid(p.id)),
                ],
              ]),
            )),
          ]),
        ),
        const SizedBox(height: 16),

        // Training & Workshops
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Training & Workshop Tracking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.green),
                  tooltip: 'Schedule Training/Workshop',
                  onPressed: () => _showScheduleTrainingDialog(context, branchId),
                ),
              ],
            ),
            const Divider(),
            ...trainings.map((t) => ListTile(
              dense: true,
              leading: Icon(Icons.workspace_premium_rounded, size: 16, color: t.status == 'Completed' ? Colors.green : Colors.blue),
              title: Text(t.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              subtitle: Text('${t.date} | Trainer: ${t.trainer} | Participants: ${t.participantStaffIds.length}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: (t.status == 'Completed' ? Colors.green : Colors.blue).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(t.status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: t.status == 'Completed' ? Colors.green : Colors.blue)),
              ),
            )),
          ]),
        ),
        const SizedBox(height: 16),

        // Inter-Branch Transfers
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Inter-Branch Staff Transfer Requests', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.green),
                  tooltip: 'Request Staff Transfer',
                  onPressed: () => _showRequestTransferDialog(context, branchId),
                ),
              ],
            ),
            const Divider(),
            if (transfers.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No transfer requests.', style: TextStyle(color: Colors.grey, fontSize: 10))))
            else
              ...transfers.map((t) => ListTile(
                dense: true,
                leading: const Icon(Icons.swap_horiz_rounded, size: 16, color: Colors.purple),
                title: Text(_staffName(t.staffId), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                subtitle: Text('From: ${t.fromBranchId} → To: ${t.toBranchId} | ${t.reason}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                trailing: t.status == 'Pending' ? Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.check_rounded, size: 14, color: Colors.green), onPressed: () => ref.read(staffTransferProvider.notifier).approveTransfer(t.id)),
                  IconButton(icon: const Icon(Icons.close_rounded, size: 14, color: Colors.red), onPressed: () => ref.read(staffTransferProvider.notifier).rejectTransfer(t.id)),
                ]) : Text(t.status, style: TextStyle(fontSize: 9, color: t.status == 'Approved' ? Colors.green : Colors.red)),
              )),
          ]),
        ),
      ]),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 8: PERFORMANCE EVALUATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPerformanceTab(bool isDark, String branchId) {
    final reviews = ref.watch(performanceReviewProvider).where((r) => r.branchId == branchId).toList();
    final branchStaff = ref.watch(staffProvider).where((s) => s.branchId == branchId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Staff Performance Evaluation (Branch-Scoped)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const Text('Annual appraisal scores, teaching quality metrics, and review remarks.', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 16),

        // Branch Staff Analytics
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Branch Staff Metrics', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const Divider(),
            Row(children: [
              _statCard('Total Staff', '${branchStaff.length}', Icons.people_rounded, Colors.blue),
              const SizedBox(width: 12),
              _statCard('Avg Experience', '${branchStaff.isEmpty ? 0 : (branchStaff.fold<int>(0, (s, e) => s + e.yearsOfExperience) / branchStaff.length).round()} yrs', Icons.timeline_rounded, Colors.green),
              const SizedBox(width: 12),
              _statCard('Reviews', '${reviews.length}', Icons.rate_review_rounded, Colors.amber),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // Performance Reviews
        ...reviews.map((r) {
          final avgScore = (r.teachingScore + r.disciplineScore + r.attendanceScore + r.parentFeedbackScore) / 4;
          return GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_staffName(r.staffId), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: avgScore >= 8 ? Colors.green.withValues(alpha: 0.1) : avgScore >= 6 ? Colors.amber.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('${avgScore.toStringAsFixed(1)}/10', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: avgScore >= 8 ? Colors.green : avgScore >= 6 ? Colors.amber : Colors.red)),
                ),
              ]),
              Text('Review Period: ${r.reviewPeriod}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(children: [
                _scoreChip('Teaching', r.teachingScore),
                const SizedBox(width: 8),
                _scoreChip('Discipline', r.disciplineScore),
                const SizedBox(width: 8),
                _scoreChip('Attendance', r.attendanceScore),
                const SizedBox(width: 8),
                _scoreChip('Parent Feedback', r.parentFeedbackScore),
              ]),
              if (r.remarks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Remarks: ${r.remarks}', style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.grey)),
                Text('Reviewed by: ${r.reviewerName}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
              ],
            ]),
          );
        }),

        const SizedBox(height: 16),
        // Birthday & Anniversary Reminders
        Builder(
          builder: (context) {
            final currentMonth = DateTime.now().month.toString().padLeft(2, '0');
            final upcomingEvents = branchStaff.where((s) {
              final dobMonth = s.dateOfBirth.contains('-') ? s.dateOfBirth.split('-')[1] : '';
              final dojMonth = s.dateOfJoining.contains('-') ? s.dateOfJoining.split('-')[1] : '';
              return dobMonth == currentMonth || dojMonth == currentMonth;
            }).toList();

            return GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🎂 Birthdays & Anniversaries This Month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const Divider(),
                if (upcomingEvents.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No birthdays or work anniversaries this month.', style: TextStyle(fontSize: 10, color: Colors.grey))))
                else
                  ...upcomingEvents.map((s) {
                    final isBirthday = s.dateOfBirth.split('-')[1] == currentMonth;
                    final isAnniversary = s.dateOfJoining.split('-')[1] == currentMonth;
                    String subtitle = '';
                    if (isBirthday && isAnniversary) {
                      subtitle = 'Birthday: ${s.dateOfBirth} & Work Anniversary (Joined: ${s.dateOfJoining})';
                    } else if (isBirthday) {
                      subtitle = 'Birthday: ${s.dateOfBirth}';
                    } else {
                      subtitle = 'Work Anniversary (Joined: ${s.dateOfJoining})';
                    }
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isBirthday ? Icons.cake_rounded : Icons.workspace_premium_rounded,
                        size: 16,
                        color: isBirthday ? Colors.pink : Colors.amber,
                      ),
                      title: Text(s.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      subtitle: Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    );
                  }),
              ]),
            );
          }
        ),
      ]),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 9: OFFBOARDING & EXIT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildOffboardingTab(bool isDark, String branchId) {
    final branchStaff = ref.watch(staffProvider).where((s) => (s.branchId == branchId || s.sharedBranchIds.contains(branchId)) && s.status == 'Active').toList();
    final offboardings = ref.watch(staffOffboardingProvider).where((o) => o.branchId == branchId).toList();

    String? selectedResignerId = branchStaff.isNotEmpty ? branchStaff.first.id : null;
    final resignationDateCtrl = TextEditingController(text: DateTime.now().toString().substring(0, 10));
    final lastWorkingDayCtrl = TextEditingController(text: DateTime.now().add(const Duration(days: 30)).toString().substring(0, 10));
    final reasonCtrl = TextEditingController();

    return StatefulBuilder(
      builder: (context, setStateTab) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Submit Resignation
            Expanded(
              flex: 3,
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Submit Staff Resignation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const Text('Initiate exit workflow and clearance processing.', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedResignerId,
                      decoration: const InputDecoration(labelText: 'Resigning Staff Member', isDense: true),
                      style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      items: branchStaff.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontSize: 9)))).toList(),
                      onChanged: (v) => selectedResignerId = v,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: resignationDateCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Resignation Date', isDense: true))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: lastWorkingDayCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Last Working Day', isDense: true))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: reasonCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Reason for Leaving', isDense: true), maxLines: 2),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          if (selectedResignerId == null || reasonCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select staff and enter reason.')));
                            return;
                          }
                          ref.read(staffOffboardingProvider.notifier).submitResignation(
                            staffId: selectedResignerId!,
                            branchId: branchId,
                            resignationDate: resignationDateCtrl.text.trim(),
                            lastWorkingDay: lastWorkingDayCtrl.text.trim(),
                            reason: reasonCtrl.text.trim(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resignation submitted successfully! Clearance initiated.')));
                          reasonCtrl.clear();
                        },
                        icon: const Icon(Icons.exit_to_app_rounded, size: 14),
                        label: const Text('Initiate Exit Process', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Right: Offboarding Pipeline
            Expanded(
              flex: 4,
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Offboarding & Clearance Checklist', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const Text('Track clearances and process Full & Final (F&F) settlements.', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    const SizedBox(height: 12),
                    if (offboardings.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No staff members in exit processing.')))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: offboardings.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final o = offboardings[index];
                          final isSettled = o.status == 'Settled';
                          Color statusColor = Colors.orange;
                          if (o.status == 'ClearanceInProgress') statusColor = Colors.blue;
                          if (isSettled) statusColor = Colors.green;

                          final settlementAmountCtrl = TextEditingController(text: o.settlementAmount > 0 ? o.settlementAmount.toStringAsFixed(0) : '25000');

                          return Card(
                            margin: EdgeInsets.zero,
                            elevation: 0,
                            color: isDark ? Colors.white10 : Colors.grey.shade50,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_staffName(o.staffId), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                        child: Text(o.status, style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: statusColor)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('LWD: ${o.lastWorkingDay} | Initiated: ${o.resignationDate}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                  Text('Reason: ${o.reason}', style: const TextStyle(fontSize: 8, color: Colors.black54)),
                                  if (o.exitFeedback.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text('Exit Interview Feedback: ${o.exitFeedback}', style: const TextStyle(fontSize: 8, fontStyle: FontStyle.italic, color: Colors.indigo)),
                                  ],
                                  const SizedBox(height: 10),
                                  const Text('Department Clearance checklist:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      FilterChip(
                                        label: const Text('IT Clearance', style: TextStyle(fontSize: 7)),
                                        selected: o.clearanceIt,
                                        selectedColor: Colors.green.withValues(alpha: 0.2),
                                        onSelected: isSettled ? null : (val) {
                                          ref.read(staffOffboardingProvider.notifier).updateClearances(o.id, it: val);
                                        },
                                      ),
                                      FilterChip(
                                        label: const Text('Library Clearance', style: TextStyle(fontSize: 7)),
                                        selected: o.clearanceLibrary,
                                        selectedColor: Colors.green.withValues(alpha: 0.2),
                                        onSelected: isSettled ? null : (val) {
                                          ref.read(staffOffboardingProvider.notifier).updateClearances(o.id, lib: val);
                                        },
                                      ),
                                      FilterChip(
                                        label: const Text('Accounts Clearance', style: TextStyle(fontSize: 7)),
                                        selected: o.clearanceAccounts,
                                        selectedColor: Colors.green.withValues(alpha: 0.2),
                                        onSelected: isSettled ? null : (val) {
                                          ref.read(staffOffboardingProvider.notifier).updateClearances(o.id, acc: val);
                                        },
                                      ),
                                      FilterChip(
                                        label: const Text('HR Clearance', style: TextStyle(fontSize: 7)),
                                        selected: o.clearanceHr,
                                        selectedColor: Colors.green.withValues(alpha: 0.2),
                                        onSelected: isSettled ? null : (val) {
                                          ref.read(staffOffboardingProvider.notifier).updateClearances(o.id, hr: val);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (o.exitFeedback.isEmpty)
                                        TextButton.icon(
                                          onPressed: () => _showExitInterviewDialog(context, o),
                                          icon: const Icon(Icons.rate_review_rounded, size: 10),
                                          label: const Text('Exit Interview', style: TextStyle(fontSize: 8)),
                                        ),
                                      if (!isSettled) ...[
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 80,
                                          height: 24,
                                          child: TextField(
                                            controller: settlementAmountCtrl,
                                            style: const TextStyle(fontSize: 8),
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(labelText: 'F&F Amount', isDense: true),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), minimumSize: Size.zero),
                                          onPressed: () {
                                            if (!o.clearanceIt || !o.clearanceLibrary || !o.clearanceAccounts || !o.clearanceHr) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All department clearances are required before settlement!')));
                                              return;
                                            }
                                            ref.read(staffOffboardingProvider.notifier).settleOffboarding(o.id, double.tryParse(settlementAmountCtrl.text) ?? 0);
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Full & Final Settlement processed for ${_staffName(o.staffId)}. Account deactivated.')));
                                          },
                                          child: const Text('Process F&F', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                      if (isSettled) ...[
                                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                                        const SizedBox(width: 4),
                                        Text('F&F Completed (₹${o.settlementAmount.toStringAsFixed(0)})', style: const TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitInterviewDialog(BuildContext context, StaffOffboardingEntity offboarding) {
    final feedbackCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Exit Interview Notes - ${_staffName(offboarding.staffId)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter remarks regarding work environment, reasons for leaving, and suggestions for improvement.', style: TextStyle(fontSize: 9, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(controller: feedbackCtrl, maxLines: 3, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Feedback Notes', isDense: true)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              ref.read(staffOffboardingProvider.notifier).completeExitInterview(offboarding.id, feedbackCtrl.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exit interview notes saved!')));
            },
            child: const Text('Save Exit Interview', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddCandidateDialog(BuildContext context, String branchId) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final designationCtrl = TextEditingController();
    final qualCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final instCtrl = TextEditingController();
    final expCtrl = TextEditingController(text: '1');
    final prevEmpCtrl = TextEditingController();
    String role = 'Teacher';
    String? deptId;

    final depts = ref.read(academicDepartmentsProvider).where((d) => d.branchId == branchId).toList();
    if (depts.isNotEmpty) {
      deptId = depts.first.id;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add Candidate to Recruitment Pipeline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Candidate Name *', isDense: true)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: designationCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Designation', isDense: true))),
                  const SizedBox(width: 8),
                  Expanded(child: DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Role', isDense: true),
                    style: const TextStyle(fontSize: 10, color: Colors.black87),
                    items: const [
                      DropdownMenuItem(value: 'Teacher', child: Text('Teacher', style: TextStyle(fontSize: 9))),
                      DropdownMenuItem(value: 'HOD', child: Text('HOD', style: TextStyle(fontSize: 9))),
                      DropdownMenuItem(value: 'branchAdmin', child: Text('Admin', style: TextStyle(fontSize: 9))),
                    ],
                    onChanged: (v) => setDialogState(() => role = v ?? 'Teacher'),
                  )),
                ]),
                const SizedBox(height: 8),
                if (depts.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: deptId,
                    decoration: const InputDecoration(labelText: 'Department *', isDense: true),
                    style: const TextStyle(fontSize: 10, color: Colors.black87),
                    items: depts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name, style: const TextStyle(fontSize: 9)))).toList(),
                    onChanged: (v) => setDialogState(() => deptId = v),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(children: [
                  Expanded(child: TextField(controller: emailCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Email *', isDense: true))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: phoneCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Phone *', isDense: true))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: qualCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Qualification', isDense: true))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: specCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Specialization', isDense: true))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: instCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Institution', isDense: true))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: expCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Years Exp', isDense: true), keyboardType: TextInputType.number)),
                ]),
                const SizedBox(height: 8),
                TextField(controller: prevEmpCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Previous Employer', isDense: true)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || phoneCtrl.text.isEmpty || deptId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all mandatory fields.')));
                  return;
                }
                ref.read(recruitmentProvider.notifier).addCandidate(
                  branchId: branchId,
                  name: nameCtrl.text.trim(),
                  designation: designationCtrl.text.trim(),
                  role: role,
                  departmentId: deptId!,
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  qualification: qualCtrl.text.trim(),
                  specialization: specCtrl.text.trim(),
                  institution: instCtrl.text.trim(),
                  yearsOfExperience: int.tryParse(expCtrl.text.trim()) ?? 1,
                  previousEmployer: prevEmpCtrl.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Candidate added to recruitment pipeline!')));
              },
              child: const Text('Add Candidate', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showOnboardingProgressDialog(BuildContext context, RecruitmentCandidateEntity candidate) {
    double progress = candidate.onboardingProgress;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Onboarding Progress - ${candidate.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Progress: ${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10)),
              Slider(
                value: progress,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                activeColor: AppColors.primary,
                label: '${(progress * 100).toStringAsFixed(0)}%',
                onChanged: (v) => setDialogState(() => progress = v),
              ),
              const Text('Update the progress of induction, IT provisioning, workspace setup, and training.', style: TextStyle(fontSize: 8, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                ref.read(recruitmentProvider.notifier).updateOnboardingProgress(candidate.id, progress);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Onboarding progress updated!')));
              },
              child: const Text('Update', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleTrainingDialog(BuildContext context, String branchId) {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toString().substring(0, 10));
    final trainerCtrl = TextEditingController();

    final branchStaff = ref.read(staffProvider).where((s) => s.branchId == branchId || s.sharedBranchIds.contains(branchId)).toList();
    final List<String> selectedStaffIds = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Schedule Training or Workshop', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: titleCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Workshop/Training Title', isDense: true)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: dateCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Scheduled Date', isDense: true))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: trainerCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Trainer Name', isDense: true))),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Select Staff Participants', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const Divider(),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                    child: ListView.builder(
                      itemCount: branchStaff.length,
                      itemBuilder: (context, idx) {
                        final s = branchStaff[idx];
                        final isChecked = selectedStaffIds.contains(s.id);
                        return CheckboxListTile(
                          dense: true,
                          title: Text(s.name, style: const TextStyle(fontSize: 9)),
                          subtitle: Text(s.designation, style: const TextStyle(fontSize: 7, color: Colors.grey)),
                          value: isChecked,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                selectedStaffIds.add(s.id);
                              } else {
                                selectedStaffIds.remove(s.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (titleCtrl.text.isEmpty || trainerCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all mandatory fields.')));
                  return;
                }
                ref.read(staffTrainingProvider.notifier).addTraining(
                  branchId: branchId,
                  title: titleCtrl.text.trim(),
                  date: dateCtrl.text.trim(),
                  trainer: trainerCtrl.text.trim(),
                  participants: selectedStaffIds,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Training Workshop scheduled successfully!')));
              },
              child: const Text('Schedule', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestTransferDialog(BuildContext context, String branchId) {
    final reasonCtrl = TextEditingController();
    final branchStaff = ref.read(staffProvider).where((s) => s.branchId == branchId && s.status == 'Active').toList();
    final branches = ref.read(organizationBranchesProvider).where((b) => b.id != branchId).toList();

    String? selectedStaffId = branchStaff.isNotEmpty ? branchStaff.first.id : null;
    String? selectedTargetBranchId = branches.isNotEmpty ? branches.first.id : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Request Inter-Branch Transfer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (branchStaff.isEmpty)
                const Text('No active staff available in this branch.', style: TextStyle(fontSize: 10, color: Colors.red))
              else ...[
                DropdownButtonFormField<String>(
                  initialValue: selectedStaffId,
                  decoration: const InputDecoration(labelText: 'Staff Member', isDense: true),
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                  items: branchStaff.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontSize: 9)))).toList(),
                  onChanged: (v) => selectedStaffId = v,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedTargetBranchId,
                  decoration: const InputDecoration(labelText: 'Target Branch (Destination)', isDense: true),
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                  items: branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontSize: 9)))).toList(),
                  onChanged: (v) => selectedTargetBranchId = v,
                ),
                const SizedBox(height: 8),
                TextField(controller: reasonCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Reason for Transfer', isDense: true), maxLines: 2),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: (branchStaff.isEmpty || selectedTargetBranchId == null) ? null : () {
                if (selectedStaffId == null || reasonCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select staff and enter reason.')));
                  return;
                }
                ref.read(staffTransferProvider.notifier).requestTransfer(
                  staffId: selectedStaffId!,
                  fromBranchId: branchId,
                  toBranchId: selectedTargetBranchId!,
                  reason: reasonCtrl.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inter-branch transfer request submitted successfully!')));
              },
              child: const Text('Submit Request', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showIDCardDialog(BuildContext context, StaffEntity staff, dynamic branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Staff ID Card - ${branch.name}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Front side of card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(branch.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                              const Text('SYMBIOSYS GLOBAL SCHOOL', style: TextStyle(color: Colors.white70, fontSize: 7, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white30, height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(staff.name.substring(0, 2).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(staff.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(staff.designation, style: const TextStyle(color: Colors.white70, fontSize: 9)),
                              const SizedBox(height: 6),
                              Text('ID: ${staff.employeeId}', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              Text('Blood: ${staff.bloodGroup}', style: const TextStyle(color: Colors.white70, fontSize: 8)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                      child: const Center(child: Text('STAFF IDENTIFICATION', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Back side of card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TERMS & CONDITIONS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    const Text(
                      '1. This card is the property of Symbosys Global School.\n'
                      '2. Card holder must display it while on the campus.\n'
                      '3. Loss of card must be reported to school administration immediately.',
                      style: TextStyle(fontSize: 7, color: Colors.black54),
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Address:', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.black54)),
                            Text(branch.address, style: const TextStyle(fontSize: 7, color: Colors.black54)),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 16,
                              width: 60,
                              color: Colors.black12,
                              child: const Center(child: Text('BARCODE', style: TextStyle(fontSize: 6, color: Colors.black54))),
                            ),
                            const SizedBox(height: 2),
                            const Text('Authorized Signatory', style: TextStyle(fontSize: 6, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showExperienceCertificateDialog(BuildContext context, StaffEntity staff, dynamic branch) {
    final depts = ref.read(academicDepartmentsProvider);
    final deptName = depts.any((d) => d.id == staff.departmentId)
        ? depts.firstWhere((d) => d.id == staff.departmentId).name
        : 'Academic Department';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber.shade800, width: 4),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.school, size: 36, color: AppColors.primary),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(branch.name.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                        const Text('SYMBIOSYS GLOBAL SCHOOLS GROUP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.black54)),
                        Text(branch.address, style: const TextStyle(fontSize: 7, color: Colors.black54)),
                        Text('Phone: ${branch.phone} | Email: ${branch.email}', style: const TextStyle(fontSize: 7, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const Divider(thickness: 2, color: AppColors.primary),
                const SizedBox(height: 24),
                const Text(
                  'EXPERIENCE CERTIFICATE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2, decoration: TextDecoration.underline, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Text(
                  'Date: ${DateTime.now().toString().substring(0, 10)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.6),
                    children: [
                      const TextSpan(text: 'This is to certify that '),
                      TextSpan(text: staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' has served as a '),
                      TextSpan(text: staff.designation, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' in the '),
                      TextSpan(text: deptName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' at Symbosys Global School ('),
                      TextSpan(text: branch.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ') from '),
                      TextSpan(text: staff.dateOfJoining, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' to '),
                      const TextSpan(text: 'Present', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: '.\n\nDuring this period, their conduct, performance, and dedication to their duties have been exemplary. They possess excellent pedagogical skills and have contributed significantly to academic excellence.\n\nWe wish them the best in all their future endeavors.'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Place: Delhi/Mumbai', style: TextStyle(fontSize: 9, color: Colors.black54)),
                        Text('Date: ${DateTime.now().toString().substring(0, 10)}', style: const TextStyle(fontSize: 9, color: Colors.black54)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue.shade800),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(child: Text('OFFICIAL SEAL', style: TextStyle(fontSize: 7, color: Colors.black38))),
                        ),
                        const SizedBox(height: 4),
                        const Text('Principal Signature', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showRelievingLetterDialog(BuildContext context, StaffEntity staff, dynamic branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade800, width: 4),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.school, size: 36, color: AppColors.primary),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(branch.name.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                        const Text('SYMBIOSYS GLOBAL SCHOOLS GROUP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.black54)),
                        Text(branch.address, style: const TextStyle(fontSize: 7, color: Colors.black54)),
                        Text('Phone: ${branch.phone} | Email: ${branch.email}', style: const TextStyle(fontSize: 7, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const Divider(thickness: 2, color: AppColors.primary),
                const SizedBox(height: 24),
                const Text(
                  'RELIEVING LETTER & FULL & FINAL SETTLEMENT',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1, decoration: TextDecoration.underline, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Date: ${DateTime.now().toString().substring(0, 10)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.6),
                    children: [
                      const TextSpan(text: 'This relieving letter is formally issued to '),
                      TextSpan(text: staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' (Employee ID: '),
                      TextSpan(text: staff.employeeId, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: '), who was employed as a '),
                      TextSpan(text: staff.designation, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' at Symbosys Global School ('),
                      TextSpan(text: branch.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ').\n\nWe hereby confirm that they have been relieved from the services of the school at the close of working hours on '),
                      TextSpan(text: DateTime.now().toString().substring(0, 10), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: '.\n\nAll accounts, dues, benefits, and salary have been computed as part of the Full & Final (F&F) settlement and transferred to their registered bank account. No further liabilities or obligations remain between the employee and the school.\n\nWe appreciate their contributions to our institution and wish them success in their future endeavors.'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Place: Delhi/Mumbai', style: TextStyle(fontSize: 9, color: Colors.black54)),
                        Text('Date: ${DateTime.now().toString().substring(0, 10)}', style: const TextStyle(fontSize: 9, color: Colors.black54)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red.shade800),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(child: Text('HR CLEARANCE', style: TextStyle(fontSize: 7, color: Colors.red))),
                        ),
                        const SizedBox(height: 4),
                        const Text('Manager (HR & Accounts)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showSalarySlipDialog(BuildContext context, StaffPayrollEntity p) {
    final staffList = ref.read(staffProvider);
    final staff = staffList.firstWhere((s) => s.id == p.staffId, orElse: () => StaffEntity(id: '', branchId: '', employeeId: '', name: 'Staff Member', designation: 'Employee', role: 'Teacher', dateOfJoining: ''));
    final branches = ref.read(organizationBranchesProvider);
    final branch = branches.firstWhere((b) => b.id == p.branchId, orElse: () => branches.first);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: Container(
          width: 450,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.receipt_long, size: 28, color: Colors.green),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(branch.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                        const Text('SALARY DISBURSEMENT SLIP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Employee Name: ${staff.name}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text('Designation: ${staff.designation}', style: const TextStyle(fontSize: 8, color: Colors.black54)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('ID: ${staff.employeeId}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text('Pay Month: ${p.month}', style: const TextStyle(fontSize: 8, color: Colors.black54)),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('SALARY DETAILS & BREAKDOWN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
                const Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('EARNINGS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black54)),
                          const Divider(),
                          _slipRow('Basic Salary', '₹${p.basicSalary.toStringAsFixed(0)}'),
                          _slipRow('Dearness Allowance (DA)', '₹${p.da.toStringAsFixed(0)}'),
                          _slipRow('House Rent Allowance (HRA)', '₹${p.hra.toStringAsFixed(0)}'),
                          _slipRow('Transport Allowance (TA)', '₹${p.ta.toStringAsFixed(0)}'),
                          _slipRow('Other Allowances', '₹${p.allowances.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DEDUCTIONS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          const Divider(),
                          _slipRow('Provident Fund (PF)', '₹${p.pfDeduction.toStringAsFixed(0)}'),
                          _slipRow('ESI Contribution', '₹${p.esiDeduction.toStringAsFixed(0)}'),
                          _slipRow('TDS (Income Tax)', '₹${p.tdsDeduction.toStringAsFixed(0)}'),
                          _slipRow('Loan / Advance Deduct', '₹${p.loanDeduction.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('NET DISBURSED AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                    Text('₹${p.netPay.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Employee Signature', style: TextStyle(fontSize: 7, fontStyle: FontStyle.italic, color: Colors.black54)),
                    Text('Finance Officer Stamp', style: TextStyle(fontSize: 7, fontStyle: FontStyle.italic, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _slipRow(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.black87)),
        Text(val, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    ),
  );

  void _showMarkAttendanceDialog(BuildContext context, String branchId) {
    final branchStaff = ref.read(staffProvider).where((s) => s.branchId == branchId || s.sharedBranchIds.contains(branchId)).toList();
    String? selectedStaffId = branchStaff.isNotEmpty ? branchStaff.first.id : null;
    String status = 'Present';
    final checkInCtrl = TextEditingController(text: '08:00 AM');
    final checkOutCtrl = TextEditingController(text: '02:30 PM');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Mark Daily Staff Attendance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedStaffId,
                decoration: const InputDecoration(labelText: 'Select Staff Member', isDense: true),
                style: const TextStyle(fontSize: 11, color: Colors.black87),
                items: branchStaff.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontSize: 10)))).toList(),
                onChanged: (v) => setDialogState(() => selectedStaffId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Attendance Status', isDense: true),
                style: const TextStyle(fontSize: 11, color: Colors.black87),
                items: const [
                  DropdownMenuItem(value: 'Present', child: Text('Present', style: TextStyle(fontSize: 10))),
                  DropdownMenuItem(value: 'Absent', child: Text('Absent', style: TextStyle(fontSize: 10))),
                  DropdownMenuItem(value: 'Late', child: Text('Late Arrival', style: TextStyle(fontSize: 10))),
                  DropdownMenuItem(value: 'HalfDay', child: Text('Half Day', style: TextStyle(fontSize: 10))),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setDialogState(() => status = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: checkInCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Check-in Time', isDense: true))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: checkOutCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Check-out Time', isDense: true))),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (selectedStaffId == null) return;
                ref.read(staffAttendanceProvider.notifier).markAttendance(
                  staffId: selectedStaffId!,
                  branchId: branchId,
                  date: DateTime.now().toString().substring(0, 10),
                  status: status,
                  checkIn: checkInCtrl.text,
                  checkOut: checkOutCtrl.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance recorded successfully!')));
              },
              child: const Text('Record Attendance', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showApplyLeaveDialog(BuildContext context, String branchId) {
    final branchStaff = ref.read(staffProvider).where((s) => s.branchId == branchId || s.sharedBranchIds.contains(branchId)).toList();
    String? selectedStaffId = branchStaff.isNotEmpty ? branchStaff.first.id : null;
    String leaveType = 'CL';
    final fromDateCtrl = TextEditingController(text: '2026-08-15');
    final toDateCtrl = TextEditingController(text: '2026-08-16');
    final daysCtrl = TextEditingController(text: '2');
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Apply Staff Leave (CL, EL, ML, Casual, Medical)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedStaffId,
                  decoration: const InputDecoration(labelText: 'Select Staff Member', isDense: true),
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  items: branchStaff.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontSize: 10)))).toList(),
                  onChanged: (v) => setDialogState(() => selectedStaffId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: leaveType,
                  decoration: const InputDecoration(labelText: 'Leave Type', isDense: true),
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  items: const [
                    DropdownMenuItem(value: 'CL', child: Text('Casual Leave (CL)', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'EL', child: Text('Earned Leave (EL)', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'ML', child: Text('Medical Leave (ML)', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'Casual', child: Text('Casual (Other)', style: TextStyle(fontSize: 10))),
                    DropdownMenuItem(value: 'Medical', child: Text('Medical (Other)', style: TextStyle(fontSize: 10))),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => leaveType = v);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: fromDateCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'From Date', isDense: true))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: toDateCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'To Date', isDense: true))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: daysCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Total Leave Days', isDense: true), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: reasonCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Reason / Remarks', isDense: true)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (selectedStaffId == null || reasonCtrl.text.trim().isEmpty) return;
                ref.read(staffLeaveProvider.notifier).applyLeave(
                  staffId: selectedStaffId!,
                  branchId: branchId,
                  leaveType: leaveType,
                  fromDate: fromDateCtrl.text,
                  toDate: toDateCtrl.text,
                  days: int.tryParse(daysCtrl.text) ?? 1,
                  reason: reasonCtrl.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave application submitted successfully!')));
              },
              child: const Text('Submit Application', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDutyDialog(BuildContext context, String branchId) {
    final branchStaff = ref.read(staffProvider).where((s) => s.branchId == branchId || s.sharedBranchIds.contains(branchId)).toList();
    String? selectedStaffId = branchStaff.isNotEmpty ? branchStaff.first.id : null;
    String shift = 'Morning';
    String dutyType = 'Teaching';
    final dateCtrl = TextEditingController(text: '2026-08-13');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Assign Duty Roster & Shift Schedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedStaffId,
                decoration: const InputDecoration(labelText: 'Select Staff Member', isDense: true),
                style: const TextStyle(fontSize: 11, color: Colors.black87),
                items: branchStaff.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontSize: 10)))).toList(),
                onChanged: (v) => setDialogState(() => selectedStaffId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: shift,
                decoration: const InputDecoration(labelText: 'Shift Allocation', isDense: true),
                style: const TextStyle(fontSize: 11, color: Colors.black87),
                items: const [
                  DropdownMenuItem(value: 'Morning', child: Text('Morning Shift (08:00 AM - 02:30 PM)', style: TextStyle(fontSize: 10))),
                  DropdownMenuItem(value: 'Evening', child: Text('Evening Shift (02:30 PM - 08:30 PM)', style: TextStyle(fontSize: 10))),
                  DropdownMenuItem(value: 'Full Day', child: Text('Full Day Shift', style: TextStyle(fontSize: 10))),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setDialogState(() => shift = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: dutyType,
                decoration: const InputDecoration(labelText: 'Duty Assignment', isDense: true),
                style: const TextStyle(fontSize: 11, color: Colors.black87),
                items: const [
                  DropdownMenuItem(value: 'Teaching', child: Text('Teaching Duty', style: TextStyle(fontSize: 10))),
                  DropdownMenuItem(value: 'Invigilation', child: Text('Exam Invigilation', style: TextStyle(fontSize: 10))),
                  DropdownMenuItem(value: 'Admin', child: Text('Administrative Duty', style: TextStyle(fontSize: 10))),
                  DropdownMenuItem(value: 'Ground Duty', child: Text('Ground / Assembly Supervision', style: TextStyle(fontSize: 10))),
                  DropdownMenuItem(value: 'Lab Duty', child: Text('Lab & Practical Assistance', style: TextStyle(fontSize: 10))),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setDialogState(() => dutyType = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(controller: dateCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Allocation Date', isDense: true)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (selectedStaffId == null) return;
                ref.read(dutyRosterProvider.notifier).assignDuty(
                  staffId: selectedStaffId!,
                  branchId: branchId,
                  date: dateCtrl.text,
                  shift: shift,
                  dutyType: dutyType,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Duty Roster updated successfully!')));
              },
              child: const Text('Assign Shift', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showProcessPayrollDialog(BuildContext context, String branchId) {
    final branchStaff = ref.read(staffProvider).where((s) => s.branchId == branchId || s.sharedBranchIds.contains(branchId)).toList();
    String? selectedStaffId = branchStaff.isNotEmpty ? branchStaff.first.id : null;
    final monthCtrl = TextEditingController(text: 'August 2026');
    final basicCtrl = TextEditingController(text: '30000');
    final daCtrl = TextEditingController(text: '3000');
    final hraCtrl = TextEditingController(text: '6000');
    final taCtrl = TextEditingController(text: '1500');
    final allowancesCtrl = TextEditingController(text: '1000');
    final pfCtrl = TextEditingController(text: '3600');
    final esiCtrl = TextEditingController(text: '225');
    final tdsCtrl = TextEditingController(text: '1000');
    final loanCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Process Monthly Payroll & Deductions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedStaffId,
                  decoration: const InputDecoration(labelText: 'Select Staff Member', isDense: true),
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  items: branchStaff.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontSize: 10)))).toList(),
                  onChanged: (v) => setDialogState(() => selectedStaffId = v),
                ),
                const SizedBox(height: 12),
                TextField(controller: monthCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Pay Month (e.g. August 2026)', isDense: true)),
                const SizedBox(height: 12),
                const Text('Gross Earnings (Allowances)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
                const Divider(),
                Row(
                  children: [
                    Expanded(child: TextField(controller: basicCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Basic Salary', isDense: true), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: daCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'DA', isDense: true), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: hraCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'HRA', isDense: true), keyboardType: TextInputType.number)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: TextField(controller: taCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'TA', isDense: true), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: allowancesCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Other Allowances', isDense: true), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Deductions & Compliance', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                const Divider(),
                Row(
                  children: [
                    Expanded(child: TextField(controller: pfCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'PF Deduction', isDense: true), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: esiCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'ESI Deduction', isDense: true), keyboardType: TextInputType.number)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: TextField(controller: tdsCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'TDS Deduction', isDense: true), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: loanCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Loan Recovery', isDense: true), keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                if (selectedStaffId == null) return;
                ref.read(staffPayrollProvider.notifier).processPayroll(
                  staffId: selectedStaffId!,
                  branchId: branchId,
                  month: monthCtrl.text,
                  basicSalary: double.tryParse(basicCtrl.text) ?? 0,
                  da: double.tryParse(daCtrl.text) ?? 0,
                  hra: double.tryParse(hraCtrl.text) ?? 0,
                  ta: double.tryParse(taCtrl.text) ?? 0,
                  allowances: double.tryParse(allowancesCtrl.text) ?? 0,
                  pfDeduction: double.tryParse(pfCtrl.text) ?? 0,
                  esiDeduction: double.tryParse(esiCtrl.text) ?? 0,
                  tdsDeduction: double.tryParse(tdsCtrl.text) ?? 0,
                  loanDeduction: double.tryParse(loanCtrl.text) ?? 0,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payroll processed & Net pay calculated!')));
              },
              child: const Text('Process Salary', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreChip(String label, int score) {
    final color = score >= 8 ? Colors.green : score >= 6 ? Colors.amber : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Column(children: [
        Text('$score/10', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 7, color: Colors.grey)),
      ]),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Subject Assignment Form Widget
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _SubjectAssignmentForm extends ConsumerStatefulWidget {
  final String branchId;
  final bool isDark;
  const _SubjectAssignmentForm({required this.branchId, required this.isDark});

  @override
  ConsumerState<_SubjectAssignmentForm> createState() => _SubjectAssignmentFormState();
}

class _SubjectAssignmentFormState extends ConsumerState<_SubjectAssignmentForm> {
  String? _selClassId;
  String? _selSectionId;
  final _subjectCtrl = TextEditingController();
  String? _selTeacher;

  @override
  void dispose() { _subjectCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == widget.branchId).toList();
    final sections = ref.watch(academicSectionsProvider);
    final classSections = _selClassId != null ? sections.where((s) => s.classId == _selClassId).toList() : <dynamic>[];
    final teachers = ref.watch(staffProvider).where((s) => (s.branchId == widget.branchId || s.sharedBranchIds.contains(widget.branchId)) && (s.role == 'Teacher' || s.role == 'HOD')).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Assign New Subject to Teacher', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(
          initialValue: _selClassId,
          decoration: const InputDecoration(labelText: 'Class', isDense: true),
          style: TextStyle(fontSize: 10, color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 9)))).toList(),
          onChanged: (v) => setState(() { _selClassId = v; _selSectionId = null; }),
        )),
        const SizedBox(width: 12),
        Expanded(child: DropdownButtonFormField<String>(
          initialValue: _selSectionId,
          decoration: const InputDecoration(labelText: 'Section', isDense: true),
          style: TextStyle(fontSize: 10, color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          items: classSections.map((s) => DropdownMenuItem(value: s.id as String, child: Text('Section ${s.name}', style: const TextStyle(fontSize: 9)))).toList(),
          onChanged: (v) => setState(() => _selSectionId = v),
        )),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: TextField(controller: _subjectCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Subject Name', isDense: true))),
        const SizedBox(width: 12),
        Expanded(child: DropdownButtonFormField<String>(
          initialValue: _selTeacher,
          decoration: const InputDecoration(labelText: 'Teacher', isDense: true),
          style: TextStyle(fontSize: 10, color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          items: teachers.map((t) => DropdownMenuItem(value: t.name, child: Text(t.name, style: const TextStyle(fontSize: 9)))).toList(),
          onChanged: (v) => setState(() => _selTeacher = v),
        )),
      ]),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 10)),
        onPressed: () {
          if (_selClassId == null || _selSectionId == null || _subjectCtrl.text.trim().isEmpty || _selTeacher == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
            return;
          }
          ref.read(subjectAssignmentsProvider.notifier).assignSubject(branchId: widget.branchId, classId: _selClassId!, sectionId: _selSectionId!, subjectName: _subjectCtrl.text.trim(), assignedTeacher: _selTeacher!);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subject assigned to teacher successfully!')));
          _subjectCtrl.clear();
          setState(() { _selTeacher = null; });
        },
        icon: const Icon(Icons.add_rounded, size: 16),
        label: const Text('Assign Subject', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      )),
    ]);
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Substitution Form Widget
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _SubstitutionForm extends ConsumerStatefulWidget {
  final String branchId;
  final List<StaffEntity> branchStaff;
  final List<dynamic> classes;
  final List<dynamic> sections;
  final bool isDark;
  const _SubstitutionForm({required this.branchId, required this.branchStaff, required this.classes, required this.sections, required this.isDark});

  @override
  ConsumerState<_SubstitutionForm> createState() => _SubstitutionFormState();
}

class _SubstitutionFormState extends ConsumerState<_SubstitutionForm> {
  String? _origTeacher;
  String? _subTeacher;
  String? _classId;
  String? _sectionId;
  final _reasonCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: '2026-08-13');

  @override
  void dispose() { _reasonCtrl.dispose(); _dateCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toString().substring(0, 10);
    final attendanceList = ref.watch(staffAttendanceProvider);
    final leaveList = ref.watch(staffLeaveProvider);

    final teachers = widget.branchStaff.where((s) => s.role == 'Teacher' || s.role == 'HOD').toList();

    bool isUnavailable(String staffId) {
      final isOnLeave = leaveList.any((l) =>
          l.staffId == staffId &&
          l.status == 'Approved' &&
          l.fromDate.compareTo(today) <= 0 &&
          l.toDate.compareTo(today) >= 0);
      final isAbsent = attendanceList.any((a) =>
          a.staffId == staffId &&
          a.date == today &&
          (a.status == 'Absent' || a.status == 'OnLeave'));
      return isOnLeave || isAbsent;
    }

    final availableSubs = teachers.where((t) => t.id != _origTeacher && !isUnavailable(t.id)).toList();

    String? absentDeptId;
    if (_origTeacher != null) {
      final absentTeacher = teachers.firstWhere((t) => t.id == _origTeacher, orElse: () => teachers.first);
      absentDeptId = absentTeacher.departmentId;
    }

    if (absentDeptId != null) {
      availableSubs.sort((a, b) {
        final aSame = a.departmentId == absentDeptId ? 1 : 0;
        final bSame = b.departmentId == absentDeptId ? 1 : 0;
        return bSame.compareTo(aSame);
      });
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Create New Substitution', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      const Text('Auto-suggests available teachers from branch staff pool.', style: TextStyle(fontSize: 9, color: Colors.grey)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(
          initialValue: _origTeacher,
          decoration: const InputDecoration(labelText: 'Absent Teacher', isDense: true),
          style: TextStyle(fontSize: 10, color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          items: teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name, style: const TextStyle(fontSize: 9)))).toList(),
          onChanged: (v) => setState(() { _origTeacher = v; _subTeacher = null; }),
        )),
        const SizedBox(width: 12),
        Expanded(child: DropdownButtonFormField<String>(
          initialValue: _subTeacher,
          decoration: const InputDecoration(labelText: 'Substitute Teacher (Auto-Suggest)', isDense: true),
          style: TextStyle(fontSize: 10, color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          items: availableSubs.map((t) {
            final isSameDept = absentDeptId != null && t.departmentId == absentDeptId;
            final label = isSameDept ? '${t.name} (Recommended - Same Dept)' : t.name;
            return DropdownMenuItem(value: t.id, child: Text('$label (${t.specialization})', style: const TextStyle(fontSize: 9)));
          }).toList(),
          onChanged: (v) => setState(() => _subTeacher = v),
        )),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: TextField(controller: _dateCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Date', isDense: true))),
        const SizedBox(width: 12),
        Expanded(child: TextField(controller: _reasonCtrl, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(labelText: 'Reason for Substitution', isDense: true))),
      ]),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 10)),
        onPressed: () {
          if (_origTeacher == null || _subTeacher == null || _reasonCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
            return;
          }
          ref.read(substitutionProvider.notifier).createSubstitution(branchId: widget.branchId, date: _dateCtrl.text.trim(), originalTeacherId: _origTeacher!, substituteTeacherId: _subTeacher!, classId: _classId ?? 'CLS-001', sectionId: _sectionId ?? 'SEC-A-001', reason: _reasonCtrl.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Substitution created successfully!')));
          _reasonCtrl.clear();
          setState(() { _origTeacher = null; _subTeacher = null; });
        },
        icon: const Icon(Icons.swap_horiz_rounded, size: 16),
        label: const Text('Create Substitution', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      )),
    ]);
  }
}

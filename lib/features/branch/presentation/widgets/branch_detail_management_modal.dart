import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/enums.dart';
import '../../domain/entities/branch_entity.dart';
import '../../../organization/providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch (School) Detailed Management Control Modal
/// Comprehensive Section 2 Implementation with all advanced features
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BranchDetailManagementModal extends ConsumerStatefulWidget {
  final BranchEntity branch;

  const BranchDetailManagementModal({super.key, required this.branch});

  @override
  ConsumerState<BranchDetailManagementModal> createState() =>
      _BranchDetailManagementModalState();
}

class _BranchDetailManagementModalState
    extends ConsumerState<BranchDetailManagementModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Basic Controllers
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _principalController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _recognitionController;
  late TextEditingController _academicYearController;
  late TextEditingController _customDomainController;
  late TextEditingController _workingHoursController;

  // Contact Directory
  late List<Map<String, String>> _contactDirectory;

  // Advanced States
  late String _status; // Active, Inactive, Trial, Suspended
  late String _gradingScale; // CBSE, ICSE, IB, GPA
  late String _examPattern; // Term-based, Semester-based, Annual

  // Capacity & Structure
  late int _maxStudents;
  late int _maxStaff;
  late List<Map<String, dynamic>> _classStructure; // name, sections, maxSections
  late List<String> _departments;
  late TextEditingController _newDeptController;

  // Compliance
  late Map<String, bool> _complianceChecklist;

  // Fees Structure
  late List<Map<String, dynamic>> _feeStructure; // feeHead, amount, frequency

  // Storage Quota
  late double _storageQuotaGb;
  late double _storageUsedGb;

  // Support Tickets
  late List<Map<String, dynamic>> _supportTickets;

  // Notifications Templates
  late Map<String, String> _notificationTemplates;
  late Map<String, bool> _notificationTriggers;

  // Migration settings
  late String _migrationTargetOrgId;
  late String _migrationStatus; // None, Pending Approval, Approved

  // Custom fields
  late Map<String, bool> _customFields;
  late List<String> _holidays;

  // Temp text controllers
  final _newClassController = TextEditingController();
  final _newFeeHeadController = TextEditingController();
  final _newFeeAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    _nameController = TextEditingController(text: widget.branch.name);
    _codeController = TextEditingController(text: widget.branch.code);
    _principalController =
        TextEditingController(text: widget.branch.principalName);
    _emailController = TextEditingController(text: widget.branch.email);
    _phoneController = TextEditingController(text: widget.branch.phone);
    _addressController = TextEditingController(text: widget.branch.address);
    _recognitionController =
        TextEditingController(text: widget.branch.recognitionNumber);
    _academicYearController =
        TextEditingController(text: widget.branch.academicYearConfig);
    _customDomainController = TextEditingController(
        text: widget.branch.brandingOverride['customDomain'] ?? '');
    _workingHoursController = TextEditingController(
        text: widget.branch.workingDaysAndHours['workingHours'] ??
            '08:00 AM - 02:30 PM');

    _newDeptController = TextEditingController();

    // Default Contact Directory
    _contactDirectory = [
      {'title': 'Reception Helpdesk', 'phone': '+91 11 2612 0001', 'email': 'reception@delhi.sunrisetrust.edu.in'},
      {'title': 'Admissions Office', 'phone': '+91 11 2612 0002', 'email': 'admissions@delhi.sunrisetrust.edu.in'},
      {'title': 'Principal Secretariat', 'phone': '+91 11 2612 0003', 'email': 'principal.sec@delhi.sunrisetrust.edu.in'},
      {'title': 'Administrative Office', 'phone': '+91 11 2612 0004', 'email': 'admin@delhi.sunrisetrust.edu.in'},
    ];

    // Status Tracking
    _status = widget.branch.status == BranchStatus.active ? 'Active' : 'Inactive';

    // Compliance & Grading Scale
    _gradingScale = widget.branch.affiliationBoard == 'CBSE'
        ? 'CBSE 9-Point Scale'
        : (widget.branch.affiliationBoard == 'ICSE'
            ? 'ICSE Percentage Scale'
            : 'IB 7-Point Scale');
    _examPattern = 'Term-based Semester Exam';

    // Capacity & Structure
    _maxStudents = widget.branch.maxStudentCapacity;
    _maxStaff = widget.branch.maxStaffCapacity;

    _classStructure = [
      {'className': 'Class I', 'sections': ['A', 'B'], 'maxSections': 4},
      {'className': 'Class II', 'sections': ['A', 'B', 'C'], 'maxSections': 4},
      {'className': 'Class III', 'sections': ['A', 'B'], 'maxSections': 3},
      {'className': 'Class IV', 'sections': ['A', 'B', 'C'], 'maxSections': 4},
      {'className': 'Class IX', 'sections': ['A', 'B', 'C', 'D'], 'maxSections': 5},
      {'className': 'Class X', 'sections': ['A', 'B', 'C'], 'maxSections': 5},
    ];

    _departments = ['Science & Technology', 'Commerce & Finance', 'Humanities & Fine Arts', 'Physical Education'];

    // Compliance Settings Checklist
    _complianceChecklist = {
      'Affiliation Certificate Validated': true,
      'Fire & Safety NOC Filed': true,
      'Drinking Water Quality Cert verified': true,
      'Staff Qualification Verification (NCTE)': true,
      'Biometric Integration Approved': false,
    };

    // Fee structure independent per branch
    _feeStructure = [
      {'feeHead': 'Tuition & Development Fee', 'amount': '₹8,500', 'frequency': 'Quarterly'},
      {'feeHead': 'Laboratory & Computer Lab Fee', 'amount': '₹1,500', 'frequency': 'Quarterly'},
      {'feeHead': 'Activity & Sports Fund', 'amount': '₹2,000', 'frequency': 'Annually'},
      {'feeHead': 'Transport Security Cover', 'amount': '₹3,000', 'frequency': 'Monthly'},
    ];

    // Storage Quota
    _storageQuotaGb = 100.0;
    _storageUsedGb = 34.6;

    // Escalated Support Tickets
    _supportTickets = [
      {'ticketId': 'ST-8291', 'subject': 'Biometric Machine Sync Failure', 'priority': 'High', 'status': 'Under Review'},
      {'ticketId': 'ST-8302', 'subject': 'CBSE Board Exam Registration Portal API Error', 'priority': 'Critical', 'status': 'Escalated to Dev'},
      {'ticketId': 'ST-8409', 'subject': 'Glacier Archive Retrieval Request', 'priority': 'Medium', 'status': 'Completed'},
    ];

    // Notification Settings
    _notificationTriggers = {
      'Student Attendance Alerts (SMS)': true,
      'Staff Clock-In Alerts': false,
      'Fee Outstanding Reminders (Email)': true,
      'Exam Result Announcements (Push)': true,
    };

    _notificationTemplates = {
      'attendance_template': 'Dear Parent, your ward [StudentName] was marked absent on [Date].',
      'fee_reminder_template': 'Dear Parent, fee dues of [Amount] for [Term] are outstanding.',
      'exam_result_template': 'Results for [ExamName] are published. Log in to [Subdomain] to view.',
    };

    _migrationTargetOrgId = '';
    _migrationStatus = 'None';

    _customFields = Map.from(widget.branch.customFields);
    _holidays = List.from(widget.branch.branchHolidays);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    _principalController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _recognitionController.dispose();
    _academicYearController.dispose();
    _customDomainController.dispose();
    _workingHoursController.dispose();
    _newDeptController.dispose();
    _newClassController.dispose();
    _newFeeHeadController.dispose();
    _newFeeAmountController.dispose();
    super.dispose();
  }

  void _saveBranchSettings() {
    final updatedBranch = widget.branch.copyWith(
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      principalName: _principalController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      recognitionNumber: _recognitionController.text.trim(),
      academicYearConfig: _academicYearController.text.trim(),
      status: _status == 'Active'
          ? BranchStatus.active
          : (_status == 'Suspended' ? BranchStatus.suspended : BranchStatus.inactive),
      customFields: _customFields,
      branchHolidays: _holidays,
      brandingOverride: {
        ...widget.branch.brandingOverride,
        'customDomain': _customDomainController.text.trim(),
      },
      workingDaysAndHours: {
        ...widget.branch.workingDaysAndHours,
        'workingHours': _workingHoursController.text.trim(),
      },
    );

    ref
        .read(organizationBranchesProvider.notifier)
        .updateBranchProfile(updatedBranch);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
            'Branch configuration settings for "${updatedBranch.name}" saved!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.domain_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.branch.name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.branch.code,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Advanced Multi-Tenant Branch Controls & Independent Systems Configuration',
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
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Navigation Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(icon: Icon(Icons.badge_rounded, size: 16), text: 'Profile & Contacts'),
                  Tab(icon: Icon(Icons.school_rounded, size: 16), text: 'Academics & Compliance'),
                  Tab(icon: Icon(Icons.class_rounded, size: 16), text: 'Classes & Departments'),
                  Tab(icon: Icon(Icons.payments_rounded, size: 16), text: 'Fees, Quota & Archival'),
                  Tab(icon: Icon(Icons.palette_rounded, size: 16), text: 'Branding & Migration'),
                  Tab(icon: Icon(Icons.notifications_active_rounded, size: 16), text: 'Notifications & Tickets'),
                ],
              ),
              const SizedBox(height: 14),

              // Tab Views Body
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProfileTab(isDark),
                    _buildAcademicsTab(isDark),
                    _buildClassesTab(isDark),
                    _buildFeesTab(isDark),
                    _buildBrandingTab(isDark),
                    _buildNotificationsTab(isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _saveBranchSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text(
                      'Save Configuration',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 1: Profile & Contacts (Status, Basic Info, Contact Directory)
  Widget _buildProfileTab(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Branch Lifecycle Status Tracking',
                    prefixIcon: Icon(Icons.track_changes_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active (Fully Functional)')),
                    DropdownMenuItem(value: 'Inactive', child: Text('Inactive (Hold)')),
                    DropdownMenuItem(value: 'Trial', child: Text('Trial Sandbox Mode')),
                    DropdownMenuItem(value: 'Suspended', child: Text('Suspended (Compliance Hold)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _principalController,
                  decoration: const InputDecoration(
                    labelText: 'Principal / Branch Admin Principal',
                    prefixIcon: Icon(Icons.person_pin_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Branch Name',
                    prefixIcon: Icon(Icons.school_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Unique Branch Code',
                    prefixIcon: Icon(Icons.qr_code_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Capacity allocation display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Branch Allocated Capacities: Max Students Limit: $_maxStudents  |  Max Staff Limit: $_maxStaff',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Branch Contact Directory:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _contactDirectory.length,
            itemBuilder: (context, idx) {
              final item = _contactDirectory[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBg : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.contact_phone_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title']!,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          Text('Phone: ${item['phone']} • Email: ${item['email']}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // TAB 2: Academics & Compliance (Grading Scale, Exam Pattern, Compliance checklist)
  Widget _buildAcademicsTab(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _gradingScale,
                  decoration: const InputDecoration(
                    labelText: 'Branch-Wise Grading Scale',
                    prefixIcon: Icon(Icons.grid_goldenratio_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CBSE 9-Point Scale', child: Text('CBSE 9-Point Scale')),
                    DropdownMenuItem(value: 'ICSE Percentage Scale', child: Text('ICSE Percentage Scale')),
                    DropdownMenuItem(value: 'IB 7-Point Scale', child: Text('IB 7-Point Standard Scale')),
                    DropdownMenuItem(value: 'US GPA 4.0 Standard', child: Text('US GPA 4.0 Standard')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _gradingScale = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _examPattern,
                  decoration: const InputDecoration(
                    labelText: 'Branch Exam & Marksheet Pattern',
                    prefixIcon: Icon(Icons.menu_book_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Term-based Semester Exam', child: Text('Term-based Semester Exam')),
                    DropdownMenuItem(value: 'Continuous and Comprehensive Evaluation', child: Text('CCE Comprehensive Pattern')),
                    DropdownMenuItem(value: 'Annual Examination Only', child: Text('Annual Examination Only')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _examPattern = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Branch Compliance & Affiliation Settings Checklist:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 10),

          Column(
            children: _complianceChecklist.entries.map((entry) {
              return CheckboxListTile(
                value: entry.value,
                title: Text(entry.key, style: const TextStyle(fontSize: 12)),
                activeColor: AppColors.primary,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _complianceChecklist[entry.key] = val;
                    });
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // TAB 3: Classes, Sections & Departments (Classes table, custom departments, class max capacities)
  Widget _buildClassesTab(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Branch Class and Section Structure:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_newClassController.text.trim().isNotEmpty) {
                    setState(() {
                      _classStructure.add({
                        'className': _newClassController.text.trim(),
                        'sections': ['A'],
                        'maxSections': 4,
                      });
                      _newClassController.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Add Class'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newClassController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Class Name (e.g. Class XI)',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Class')),
                DataColumn(label: Text('Sections')),
                DataColumn(label: Text('Max Sections Capacity')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _classStructure.map((cls) {
                return DataRow(
                  cells: [
                    DataCell(Text(cls['className'])),
                    DataCell(Text(cls['sections'].join(', '))),
                    DataCell(Text('${cls['maxSections']} Max Sections')),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_box_rounded, color: AppColors.primary, size: 18),
                            onPressed: () {
                              setState(() {
                                final currentSections = List<String>.from(cls['sections']);
                                if (currentSections.length < cls['maxSections']) {
                                  final nextChar = String.fromCharCode(65 + currentSections.length);
                                  cls['sections'] = [...currentSections, nextChar];
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 18),
                            onPressed: () {
                              setState(() {
                                final currentSections = List<String>.from(cls['sections']);
                                if (currentSections.length > 1) {
                                  cls['sections'] = currentSections.sublist(0, currentSections.length - 1);
                                }
                              });
                            },
                          ),
                        ],
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

          // Department Creation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Branch-Wise Custom Departments:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_newDeptController.text.trim().isNotEmpty) {
                    setState(() {
                      _departments.add(_newDeptController.text.trim());
                      _newDeptController.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Create Department'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newDeptController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Department Name (e.g. Science)',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _departments.map((dept) {
              return Chip(
                label: Text(dept, style: const TextStyle(fontSize: 11)),
                onDeleted: () {
                  setState(() {
                    _departments.remove(dept);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // TAB 4: Fees, Quota & Archival (Branch Fee Structure, Storage Quota progress, Deactivate Archival policy)
  Widget _buildFeesTab(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Independent Branch Fee Structure:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_newFeeHeadController.text.trim().isNotEmpty &&
                      _newFeeAmountController.text.trim().isNotEmpty) {
                    setState(() {
                      _feeStructure.add({
                        'feeHead': _newFeeHeadController.text.trim(),
                        'amount': '₹${_newFeeAmountController.text.trim()}',
                        'frequency': 'Quarterly',
                      });
                      _newFeeHeadController.clear();
                      _newFeeAmountController.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Add Fee Head'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newFeeHeadController,
                  decoration: const InputDecoration(
                    hintText: 'Fee Head Name',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _newFeeAmountController,
                  decoration: const InputDecoration(
                    hintText: 'Amount (e.g. 5000)',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Fee Component')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Frequency')),
                DataColumn(label: Text('Action')),
              ],
              rows: _feeStructure.map((fee) {
                return DataRow(
                  cells: [
                    DataCell(Text(fee['feeHead'])),
                    DataCell(Text(fee['amount'], style: const TextStyle(fontWeight: FontWeight.w800))),
                    DataCell(Text(fee['frequency'])),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                        onPressed: () {
                          setState(() {
                            _feeStructure.remove(fee);
                          });
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

          // Storage Quota
          Text(
            'Branch Data Storage Quota & Monitoring:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Storage Used: $_storageUsedGb GB / $_storageQuotaGb GB',
                  style: const TextStyle(fontSize: 11)),
              const Text('Usage: 34.6%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: _storageUsedGb / _storageQuotaGb,
            backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            color: AppColors.primary,
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),

          // Archival / Restore Actions
          Text(
            'Deactivation with Student Data Archival:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('Branch suspended and all student data successfully archived to AWS Glacier!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                icon: const Icon(Icons.archive_rounded, size: 16),
                label: const Text('Deactivate & Archive Branch'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Branch reactivated and all archived databases restored!'),
                    ),
                  );
                },
                icon: const Icon(Icons.unarchive_rounded, size: 16),
                label: const Text('Reactivate & Restore Data'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 5: Branding Override, Custom Fields & Migration Settings
  Widget _buildBrandingTab(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _customDomainController,
            decoration: const InputDecoration(
              labelText: 'Branch White-Labeled Custom Subdomain URL',
              hintText: 'e.g. delhi.sunrisetrust.edu.in',
              prefixIcon: Icon(Icons.language_rounded, size: 18),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Branch branding Override Color',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(int.parse(
                                widget.branch.brandingOverride['primaryColor']
                                        ?.replaceAll('#', '0xFF') ??
                                    '0xFF6366F1')),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.branch.brandingOverride['primaryColor'] ??
                                '#6366F1',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Custom Branch Logo Updated!')),
                    );
                  },
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: const Text('Override Branch Logo'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),

          // Inter-Organization Branch Migration
          Text(
            'Branch Migration Between Organizations:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Target Parent Organization ID',
                    hintText: 'e.g. ORG-9929-TRUST',
                  ),
                  onChanged: (val) => _migrationTargetOrgId = val,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (_migrationTargetOrgId.isNotEmpty) {
                    setState(() {
                      _migrationStatus = 'Pending Approval';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Branch Migration request submitted to Parent Trust Super Admin for approval!'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Initiate Migration'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Migration Status: ', style: TextStyle(fontSize: 11)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _migrationStatus == 'Pending Approval'
                      ? Colors.orange.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _migrationStatus,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _migrationStatus == 'Pending Approval' ? Colors.orange : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 6: Notifications, Escalations & Support Tickets
  Widget _buildNotificationsTab(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Event Settings & System Toggles:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Column(
            children: _notificationTriggers.entries.map((entry) {
              return SwitchListTile(
                value: entry.value,
                title: Text(entry.key, style: const TextStyle(fontSize: 12)),
                activeThumbColor: AppColors.primary,
                dense: true,
                onChanged: (val) {
                  setState(() {
                    _notificationTriggers[entry.key] = val;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          Text(
            'Branch-Specific Notification Templates:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Column(
            children: _notificationTemplates.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBg : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: entry.value,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(isDense: true),
                      onChanged: (val) {
                        _notificationTemplates[entry.key] = val;
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),

          // Support Tickets Escalated to Parent Trust
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Support Ticket Escalation to Organization Super Admin:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _supportTickets.add({
                      'ticketId': 'ST-850${_supportTickets.length + 1}',
                      'subject': 'Request extra SMS credit allocation',
                      'priority': 'Medium',
                      'status': 'Submitted',
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support ticket escalated to Trust Super Admin!')),
                  );
                },
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Escalate Ticket'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _supportTickets.length,
            itemBuilder: (context, idx) {
              final ticket = _supportTickets[idx];
              Color priorityColor = ticket['priority'] == 'Critical'
                  ? Colors.red
                  : (ticket['priority'] == 'High' ? Colors.orange : Colors.blue);
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBg : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.report_problem_rounded, color: Colors.orange, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(ticket['ticketId']!,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.primary)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: priorityColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ticket['priority']!,
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: priorityColor),
                                ),
                              ),
                            ],
                          ),
                          Text(ticket['subject']!,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                      ticket['status']!,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

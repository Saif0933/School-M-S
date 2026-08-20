import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../academic/providers.dart';
import '../../../auth/providers.dart';
import '../../../organization/providers.dart';
import '../../../branch/domain/entities/branch_entity.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Management Page (Branch-Scoped)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StudentManagementPage extends ConsumerStatefulWidget {
  const StudentManagementPage({super.key});

  @override
  ConsumerState<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends ConsumerState<StudentManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search & Filters
  String _searchQuery = '';
  String? _selectedClassId;
  String? _selectedSectionId;
  bool? _selectedStatus; // true = Active, false = Inactive, null = All
  String? _filterBranchId;
  bool _isExporting = false;

  // Selected student for detailed profile modal/drawer
  StudentEntity? _selectedStudent;
  String? _uploadingDocLabel;

  // Sidebar profile tab index
  int _profileTabIdx = 0;

  // Enrollment Form Controllers
  final _nameController = TextEditingController();
  final _guardianController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController(text: '2015-05-10');
  final _rollNumberController = TextEditingController();
  final _admissionDateController = TextEditingController(text: '2026-04-01');
  
  // Behavioral & Medical controllers
  final _remarksController = TextEditingController(text: 'Excellent participation and behaviour.');
  final _allergiesController = TextEditingController(text: 'None');
  final _conditionsController = TextEditingController(text: 'None');
  final _emergencyContactController = TextEditingController();

  String _gender = 'Male';
  String _bloodGroup = 'O+';
  String? _enrollClassId;
  String? _enrollSectionId;

  // Bulk CSV Import Controllers
  final _csvImportController = TextEditingController();
  List<Map<String, dynamic>> _csvValidationResults = [];
  bool _csvValidated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _csvImportController.dispose();
    _nameController.dispose();
    _guardianController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _rollNumberController.dispose();
    _admissionDateController.dispose();
    _remarksController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranch?.branchId;

    if (activeBranchId == null) {
      return const Center(child: Text('No active branch selected. Please select a branch first.'));
    }

    return Column(
      children: [
        // TabBar Header - Scrollable to prevent horizontal overflow on mobile
        Container(
          color: isDark ? Colors.black12 : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(icon: Icon(Icons.people_rounded, size: 18), text: 'Directory & Profiles'),
              Tab(icon: Icon(Icons.person_add_rounded, size: 18), text: 'Enroll Student'),
              Tab(icon: Icon(Icons.swap_horiz_rounded, size: 18), text: 'Transfers'),
              Tab(icon: Icon(Icons.photo_library_rounded, size: 18), text: 'Photo Gallery'),
              Tab(icon: Icon(Icons.upload_file_rounded, size: 18), text: 'Bulk Import CSV'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDirectoryTab(isDark, activeBranchId),
              _buildEnrollmentTab(isDark, activeBranchId),
              _buildTransfersTab(isDark, activeBranchId),
              _buildPhotoGalleryTab(isDark, activeBranchId),
              _buildBulkImportTab(isDark, activeBranchId),
            ],
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 1: STUDENT DIRECTORY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildDirectoryTab(bool isDark, String activeBranchId) {
    final user = ref.watch(currentUserProvider);
    final isOrgAdmin = user?.role.isOrgLevel ?? false;
    final branches = ref.watch(organizationBranchesProvider);

    // Default branch filter to active campus branch
    _filterBranchId ??= activeBranchId;

    final allStudents = ref.watch(academicStudentsProvider);
    final students = isOrgAdmin
        ? (_filterBranchId == 'ALL' ? allStudents : allStudents.where((s) => s.branchId == _filterBranchId).toList())
        : allStudents.where((s) => s.branchId == activeBranchId).toList();

    final classes = ref.watch(academicClassesProvider).where((c) {
      if (isOrgAdmin) {
        return _filterBranchId == 'ALL' || c.branchId == _filterBranchId;
      }
      return c.branchId == activeBranchId;
    }).toList();

    final sections = ref.watch(academicSectionsProvider);
    final filteredSections = sections.where((s) => s.classId == _selectedClassId).toList();

    // Filter logic
    final filteredStudents = students.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.admissionNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesClass = _selectedClassId == null || s.classId == _selectedClassId;
      final matchesSection = _selectedSectionId == null || s.sectionId == _selectedSectionId;
      final matchesStatus = _selectedStatus == null || s.isActive == _selectedStatus;
      return matchesSearch && matchesClass && matchesSection && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Panel
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (layoutContext, constraints) {
                final isMobileFilter = constraints.maxWidth < 900;
                
                final searchField = TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by Name or Student ID...',
                    prefixIcon: Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (val) => setState(() => _searchQuery = val),
                );

                final branchFilter = isOrgAdmin
                    ? DropdownButtonFormField<String>(
                        initialValue: _filterBranchId,
                        decoration: const InputDecoration(labelText: 'Campus Branch', isDense: true),
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        items: [
                          const DropdownMenuItem(value: 'ALL', child: Text('All Campuses', style: TextStyle(fontSize: 11))),
                          ...branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontSize: 11)))),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _filterBranchId = val;
                            _selectedClassId = null;
                            _selectedSectionId = null;
                          });
                        },
                      )
                    : const SizedBox.shrink();

                final classFilter = DropdownButtonFormField<String>(
                  initialValue: _selectedClassId,
                  decoration: const InputDecoration(labelText: 'Class', isDense: true),
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Classes', style: TextStyle(fontSize: 11))),
                    ...classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)))),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedClassId = val;
                      _selectedSectionId = null;
                    });
                  },
                );

                final sectionFilter = DropdownButtonFormField<String>(
                  initialValue: _selectedSectionId,
                  decoration: const InputDecoration(labelText: 'Section', isDense: true),
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Sections', style: TextStyle(fontSize: 11))),
                    ...filteredSections.map((s) => DropdownMenuItem(value: s.id, child: Text('Section ${s.name}', style: const TextStyle(fontSize: 11)))),
                  ],
                  onChanged: (val) => setState(() => _selectedSectionId = val),
                );

                final statusFilter = DropdownButtonFormField<bool?>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status', isDense: true),
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Status', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: true, child: Text('Active Only', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: false, child: Text('Inactive Only', style: TextStyle(fontSize: 11))),
                  ],
                  onChanged: (val) => setState(() => _selectedStatus = val),
                );

                final exportAction = _isExporting
                    ? const SizedBox(width: 32, height: 32, child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)))
                    : PopupMenuButton<String>(
                        icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                        tooltip: 'Export Student Records',
                        onSelected: (format) async {
                          setState(() => _isExporting = true);
                          await Future.delayed(const Duration(milliseconds: 1500));
                          setState(() => _isExporting = false);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Student directory successfully exported as $format format for this branch!')),
                          );
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'PDF', child: Text('Export as PDF Document', style: TextStyle(fontSize: 11))),
                          PopupMenuItem(value: 'Excel', child: Text('Export as Microsoft Excel', style: TextStyle(fontSize: 11))),
                          PopupMenuItem(value: 'CSV', child: Text('Export as raw CSV data', style: TextStyle(fontSize: 11))),
                        ],
                      );

                if (isMobileFilter) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: searchField),
                          const SizedBox(width: 8),
                          exportAction,
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (isOrgAdmin) ...[
                            Expanded(child: branchFilter),
                            const SizedBox(width: 12),
                          ],
                          Expanded(child: classFilter),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: sectionFilter),
                          const SizedBox(width: 12),
                          Expanded(child: statusFilter),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(flex: 2, child: searchField),
                    const SizedBox(width: 12),
                    if (isOrgAdmin) ...[
                      Expanded(child: branchFilter),
                      const SizedBox(width: 12),
                    ],
                    Expanded(child: classFilter),
                    const SizedBox(width: 12),
                    Expanded(child: sectionFilter),
                    const SizedBox(width: 12),
                    Expanded(child: statusFilter),
                    const SizedBox(width: 12),
                    exportAction,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Main Directory Content
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              final mainListWidget = GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Directory (${filteredStudents.length} Students)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                    const SizedBox(height: 12),
                    if (filteredStudents.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No students match search filters.', style: TextStyle(fontSize: 12, color: Colors.grey))))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, idx) {
                          final s = filteredStudents[idx];
                          final clsName = classes.firstWhere((c) => c.id == s.classId, orElse: () => ClassEntity(id: '', branchId: '', departmentId: '', name: 'Unknown Class', code: '', maxStudentsCapacity: 0)).name;
                          final secName = sections.firstWhere((sec) => sec.id == s.sectionId, orElse: () => SectionEntity(id: '', classId: '', name: 'Unknown Sec', roomNumber: '', classTeacher: '', maxStudentsCapacity: 0)).name;
                          final isSelected = _selectedStudent?.id == s.id;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : (isDark ? AppColors.darkBg : AppColors.lightBg),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: s.isActive ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                                radius: 16,
                                child: Text(s.name[0], style: TextStyle(color: s.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              subtitle: Text('ID: ${s.admissionNumber}  |  Class: $clsName ($secName)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: s.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      s.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(color: s.isActive ? Colors.green : Colors.red, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
                                ],
                              ),
                              onTap: () {
                                setState(() => _selectedStudent = s);
                                if (!isWide) {
                                  _showStudentProfileBottomSheet(context, s, classes, sections);
                                }
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: mainListWidget,
                    ),
                    if (_selectedStudent != null) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildStudentProfileSidebar(isDark, _selectedStudent!, classes, sections),
                      ),
                    ],
                  ],
                );
              }

              return mainListWidget;
            },
          ),
        ],
      ),
    );
  }

  void _showStudentProfileBottomSheet(
    BuildContext context,
    StudentEntity student,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildStudentProfileSidebar(isDark, student, classes, sections, isBottomSheet: true),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentProfileSidebar(
    bool isDark,
    StudentEntity student,
    List<ClassEntity> classes,
    List<SectionEntity> sections, {
    bool isBottomSheet = false,
  }) {
    // Watches the global provider to automatically fetch the fresh profile upon updates
    final freshStudent = ref.watch(academicStudentsProvider).firstWhere(
      (s) => s.id == student.id,
      orElse: () => student,
    );

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Student Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (isBottomSheet) {
                    Navigator.pop(context);
                  } else {
                    setState(() => _selectedStudent = null);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(freshStudent.name[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                const SizedBox(height: 10),
                Text(freshStudent.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Unique ID: ${freshStudent.admissionNumber}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: freshStudent.categorization,
                  decoration: const InputDecoration(labelText: 'Categorization Status', isDense: true),
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'Inactive', child: Text('Inactive', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'Transferred', child: Text('Transferred', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'Graduated', child: Text('Graduated', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'Expelled', child: Text('Expelled', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'TC Issued', child: Text('TC Issued', style: TextStyle(fontSize: 11))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                            freshStudent.id,
                            freshStudent.copyWith(
                              categorization: val,
                              isActive: val == 'Active',
                            ),
                          );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),

          // Redesigned responsive Tab System (No hardcoded height TabBarView)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _profileTabHeader(0, 'Personal'),
                const SizedBox(width: 8),
                _profileTabHeader(1, 'Academic'),
                const SizedBox(width: 8),
                _profileTabHeader(2, 'Behavioral'),
                const SizedBox(width: 8),
                _profileTabHeader(3, 'Medical'),
                const SizedBox(width: 8),
                _profileTabHeader(4, 'Docs'),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Render active tab contents natively to prevent vertical scroll constraints
          if (_profileTabIdx == 0) _buildPersonalTab(freshStudent),
          if (_profileTabIdx == 1) _buildAcademicTab(freshStudent, classes, sections),
          if (_profileTabIdx == 2) _buildBehavioralTab(freshStudent),
          if (_profileTabIdx == 3) _buildMedicalTab(freshStudent),
          if (_profileTabIdx == 4) _buildDocsTab(freshStudent),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Quick Actions & Certificate Generation', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.withValues(alpha: 0.15),
                    foregroundColor: Colors.purple,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _showTransferRequestDialog(context, freshStudent),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 12),
                  label: const Text('Request Transfer', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.withValues(alpha: 0.15),
                    foregroundColor: Colors.teal,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _showCertificateGenerationModal(context, freshStudent, classes, sections),
                  icon: const Icon(Icons.card_membership_rounded, size: 12),
                  label: const Text('Generate Cards / Certs', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileTabHeader(int index, String label) {
    final isSelected = _profileTabIdx == index;
    return InkWell(
      onTap: () => setState(() => _profileTabIdx = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.secondary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.secondary : Colors.grey,
          ),
        ),
      ),
    );
  }

  // Personal profile tab contents
  Widget _buildPersonalTab(StudentEntity student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileRow('Guardian', student.guardianName),
        _buildProfileRow('Gender', student.gender),
        _buildProfileRow('DOB', student.dateOfBirth),
        _buildProfileRow('Blood Group', student.bloodGroup),
        _buildProfileRow('Phone', student.phone),
        _buildProfileRow('Email', student.email),
        _buildProfileRow('Address', student.address),
        const Divider(),
        const Text('Linked Siblings:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        if (student.siblingIds.isEmpty)
          const Text('No siblings linked in records.', style: TextStyle(fontSize: 9, color: Colors.grey))
        else
          ...student.siblingIds.map((sibId) {
            final sib = ref.read(academicStudentsProvider).firstWhere((s) => s.id == sibId, orElse: () => StudentEntity(id: '', branchId: '', classId: '', sectionId: '', name: 'Sibling Deleted', admissionNumber: '', rollNumber: ''));
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• ${sib.name} (ID: ${sib.admissionNumber})', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            );
          }),
        const SizedBox(height: 4),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            minimumSize: const Size(60, 24),
            elevation: 0,
          ),
          onPressed: () {
            final allStudents = ref.read(academicStudentsProvider);
            final otherStudents = allStudents.where((s) => s.id != student.id).toList();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Link Sibling Relation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                content: SizedBox(
                  width: 300,
                  height: 200,
                  child: ListView.builder(
                    itemCount: otherStudents.length,
                    itemBuilder: (context, idx) {
                      final other = otherStudents[idx];
                      return ListTile(
                        dense: true,
                        title: Text(other.name, style: const TextStyle(fontSize: 11)),
                        subtitle: Text('ID: ${other.admissionNumber}', style: const TextStyle(fontSize: 9)),
                        onTap: () {
                          ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                                student.id,
                                student.copyWith(siblingIds: [...student.siblingIds, other.id]),
                              );
                          ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                                other.id,
                                other.copyWith(siblingIds: [...other.siblingIds, student.id]),
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sibling relationship linked successfully!')));
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
          icon: const Icon(Icons.link_rounded, size: 10),
          label: const Text('Link Sibling', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
        ),
        const Divider(),
        const Text('Custom Branch Fields:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        if (student.customFields.isEmpty)
          const Text('No custom fields registered.', style: TextStyle(fontSize: 9, color: Colors.grey))
        else
          ...student.customFields.entries.map((entry) => _buildProfileRow(entry.key, entry.value)),
        const SizedBox(height: 4),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            minimumSize: const Size(60, 24),
            elevation: 0,
          ),
          onPressed: () {
            final keyCtrl = TextEditingController();
            final valCtrl = TextEditingController();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Add Custom Branch Data Field', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: keyCtrl,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Field Label (e.g. Locker Code, Bus Stop)', isDense: true),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: valCtrl,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Field Value', isDense: true),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      if (keyCtrl.text.trim().isNotEmpty) {
                        final updatedFields = Map<String, String>.from(student.customFields);
                        updatedFields[keyCtrl.text.trim()] = valCtrl.text.trim();
                        ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                              student.id,
                              student.copyWith(customFields: updatedFields),
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom field added for this student!')));
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.add_circle_outline_rounded, size: 10),
          label: const Text('Add Custom Field', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Academic profile tab contents
  Widget _buildAcademicTab(StudentEntity student, List<ClassEntity> classes, List<SectionEntity> sections) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: student.classId,
          decoration: const InputDecoration(labelText: 'Change Class', isDense: true),
          style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 10)))).toList(),
          onChanged: (newClsId) {
            if (newClsId != null) {
              ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                    student.id,
                    student.copyWith(classId: newClsId),
                  );
            }
          },
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: student.sectionId,
          decoration: const InputDecoration(labelText: 'Change Section', isDense: true),
          style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          items: sections.where((sec) => sec.classId == student.classId).map((s) => DropdownMenuItem(value: s.id, child: Text('Section ${s.name}', style: const TextStyle(fontSize: 10)))).toList(),
          onChanged: (newSecId) {
            if (newSecId != null) {
              ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                    student.id,
                    student.copyWith(sectionId: newSecId),
                  );
            }
          },
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text('Roll Number: ${student.rollNumber.isNotEmpty ? student.rollNumber : "Not Assigned"}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 24)),
              onPressed: () {
                final ctrl = TextEditingController(text: student.rollNumber);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Update Roll Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    content: TextField(controller: ctrl, decoration: const InputDecoration(isDense: true)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                                student.id,
                                student.copyWith(rollNumber: ctrl.text.trim()),
                              );
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.edit_rounded, size: 10),
              label: const Text('Edit', style: TextStyle(fontSize: 9)),
            ),
          ],
        ),
        _buildProfileRow('Repeat Year Status', student.isRepeatingYear ? 'Repeating Year' : 'Normal Year'),
        const Divider(),
        const SizedBox(height: 6),
        const Text('Academic Year Actions:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withValues(alpha: 0.15),
                foregroundColor: Colors.blue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(60, 24),
              ),
              onPressed: () {
                final currentClsIndex = classes.indexWhere((c) => c.id == student.classId);
                if (currentClsIndex < classes.length - 1) {
                  final nextCls = classes[currentClsIndex + 1];
                  final defaultSec = sections.firstWhere((sec) => sec.classId == nextCls.id);
                  ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                        student.id,
                        student.copyWith(classId: nextCls.id, sectionId: defaultSec.id, rollNumber: '', isRepeatingYear: false),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student promoted to next class grade!')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student is already in highest class grade.')));
                }
              },
              child: const Text('Promote', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.15),
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(60, 24),
              ),
              onPressed: () {
                final currentClsIndex = classes.indexWhere((c) => c.id == student.classId);
                if (currentClsIndex > 0) {
                  final prevCls = classes[currentClsIndex - 1];
                  final defaultSec = sections.firstWhere((sec) => sec.classId == prevCls.id);
                  ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                        student.id,
                        student.copyWith(classId: prevCls.id, sectionId: defaultSec.id, rollNumber: '', isRepeatingYear: false),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student demoted to previous class grade.')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student is in lowest class grade.')));
                }
              },
              child: const Text('Demote', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.withValues(alpha: 0.15),
                foregroundColor: Colors.amber[800],
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(60, 24),
              ),
              onPressed: () {
                ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                      student.id,
                      student.copyWith(isRepeatingYear: true, rollNumber: ''),
                    );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student registered to Repeat current Academic Year.')));
              },
              child: const Text('Repeat Year', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.withValues(alpha: 0.15),
                foregroundColor: Colors.purple,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(60, 24),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Convert to Alumni', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    content: const Text('Are you sure you want to graduate this student to Alumni status? They will be marked as inactive and registered in the Alumni cohort.', style: TextStyle(fontSize: 11)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                                student.id,
                                student.copyWith(
                                  categorization: 'Graduated',
                                  isActive: false,
                                ),
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student graduated to Alumni status!')));
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Graduate / Alumni', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const Divider(),
        const Text('Achievements & Portfolio:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        ...student.achievements.map((ach) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 12),
                  const SizedBox(width: 4),
                  Expanded(child: Text(ach, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                ],
              ),
            )),
        const SizedBox(height: 4),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.withValues(alpha: 0.15),
            foregroundColor: Colors.amber[800],
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            minimumSize: const Size(60, 24),
            elevation: 0,
          ),
          onPressed: () {
            final ctrl = TextEditingController();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Log Achievement / Portfolio Item', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                content: TextField(
                  controller: ctrl,
                  style: const TextStyle(fontSize: 11),
                  decoration: const InputDecoration(isDense: true, hintText: 'e.g. Best Student MUN 2026'),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      if (ctrl.text.trim().isNotEmpty) {
                        ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                              student.id,
                              student.copyWith(achievements: [...student.achievements, ctrl.text.trim()]),
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Achievement logged to portfolio!')));
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.add_rounded, size: 10),
          label: const Text('Add Achievement', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
        ),
        const Divider(),
        const Text('RFID & Biometric Registry:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: student.rfidCardNumber.isEmpty ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                student.rfidCardNumber.isEmpty ? 'Not Registered' : student.rfidCardNumber,
                style: TextStyle(color: student.rfidCardNumber.isEmpty ? Colors.red : Colors.green, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(60, 24),
                elevation: 0,
              ),
              onPressed: () {
                bool isScanning = true;
                showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(
                    builder: (context, setState) {
                      if (isScanning) {
                        Future.delayed(const Duration(milliseconds: 1800), () {
                          if (context.mounted) {
                            final newRfid = 'RFID-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}-${student.name.substring(0, 2).toUpperCase()}';
                            ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                                  student.id,
                                  student.copyWith(rfidCardNumber: newRfid),
                                );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('RFID Card registered successfully! Card ID: $newRfid')));
                          }
                        });
                      }

                      return AlertDialog(
                        title: const Text('Scanning RFID Badge / Biometric...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Place student RFID badge on the USB scanner or press finger on the biometric reader...',
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              isScanning = false;
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
              icon: const Icon(Icons.nfc_rounded, size: 10),
              label: Text(student.rfidCardNumber.isEmpty ? 'Register' : 'Update', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  // Behavioral profile tab contents
  Widget _buildBehavioralTab(StudentEntity student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileRow('Attendance Rate', '${student.attendanceRate}%'),
        const SizedBox(height: 6),
        const Text('Behavioral Remarks / Flags:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Text(student.behavioralRemarks, style: const TextStyle(fontSize: 9, color: Colors.brown)),
        ),
        const Divider(),
        const Text('Disciplinary Log (Branch Scoped):', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        ...student.disciplinaryRecords.map((disc) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.gavel_rounded, color: Colors.red, size: 12),
                  const SizedBox(width: 4),
                  Expanded(child: Text(disc, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                ],
              ),
            )),
        const SizedBox(height: 6),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withValues(alpha: 0.15),
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            minimumSize: const Size(60, 24),
            elevation: 0,
          ),
          onPressed: () {
            final ctrl = TextEditingController();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Log Disciplinary Incident', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                content: TextField(
                  controller: ctrl,
                  style: const TextStyle(fontSize: 11),
                  decoration: const InputDecoration(isDense: true, hintText: 'Enter incident details...'),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      if (ctrl.text.trim().isNotEmpty) {
                        ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                              student.id,
                              student.copyWith(disciplinaryRecords: [...student.disciplinaryRecords, ctrl.text.trim()]),
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disciplinary infraction logged.')));
                      }
                    },
                    child: const Text('Log'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.add_moderator_rounded, size: 10),
          label: const Text('Log Disciplinary Action', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Medical profile tab contents
  Widget _buildMedicalTab(StudentEntity student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileRow('Known Allergies', student.allergies),
        _buildProfileRow('Medical Conditions', student.medicalConditions),
        _buildProfileRow('Emergency Contact', student.emergencyContact),
      ],
    );
  }

  // Documents profile tab contents
  Widget _buildDocsTab(StudentEntity student) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Branch-Scoped Certificate Vault', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        ...['Birth Certificate', 'Student Photos', 'Aadhar Card', 'Caste Certificate'].map((doc) {
          final isUploaded = student.uploadedDocuments.contains(doc);
          final isCurrentlyUploading = _uploadingDocLabel == doc;

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(doc, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                if (isUploaded)
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 12),
                      const SizedBox(width: 4),
                      const Text('Uploaded', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye_outlined, size: 10, color: AppColors.primary),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Simulated opening of file: $doc')));
                        },
                      ),
                    ],
                  )
                else if (isCurrentlyUploading)
                  const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      minimumSize: const Size(50, 20),
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () async {
                      setState(() => _uploadingDocLabel = doc);
                      await Future.delayed(const Duration(seconds: 1));
                      ref.read(academicStudentsProvider.notifier).updateStudentProfile(
                            student.id,
                            student.copyWith(uploadedDocuments: [...student.uploadedDocuments, doc]),
                          );
                      setState(() {
                        _uploadingDocLabel = null;
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$doc uploaded successfully to branch vault!')));
                    },
                    icon: const Icon(Icons.upload_file_rounded, size: 8),
                    label: const Text('Upload', style: TextStyle(fontSize: 8)),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // INTER-BRANCH STUDENT TRANSFERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  void _showTransferRequestDialog(BuildContext context, StudentEntity student) {
    final branches = ref.read(organizationBranchesProvider);
    final targetBranches = branches.where((b) => b.id != student.branchId).toList();
    String? destBranchId = targetBranches.isNotEmpty ? targetBranches.first.id : null;
    final reasonCtrl = TextEditingController(text: 'Academic relocation requested.');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Initiate Inter-Branch Transfer: ${student.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Target Campus Branch *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                if (targetBranches.isEmpty)
                  const Text('No other branches exist inside organization to transfer to.', style: TextStyle(fontSize: 11, color: Colors.red))
                else
                  DropdownButtonFormField<String>(
                    initialValue: destBranchId,
                    style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: targetBranches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontSize: 11)))).toList(),
                    onChanged: (val) => setState(() => destBranchId = val),
                    decoration: const InputDecoration(isDense: true),
                  ),
                const SizedBox(height: 12),
                const Text('Reason for Transfer Request *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: reasonCtrl,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 3,
                  decoration: const InputDecoration(isDense: true, hintText: 'Enter relocation rationale...'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: targetBranches.isEmpty || destBranchId == null
                  ? null
                  : () {
                      ref.read(interBranchTransfersProvider.notifier).createRequest(
                            studentId: student.id,
                            studentName: student.name,
                            sourceBranchId: student.branchId,
                            destBranchId: destBranchId!,
                            reason: reasonCtrl.text.trim(),
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inter-branch student transfer request submitted successfully! Pending Organization Admin Approval.')),
                      );
                    },
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PREMIUM CERTIFICATE & ID GENERATION PREVIEW
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  void _showCertificateGenerationModal(
    BuildContext context,
    StudentEntity student,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    final branches = ref.read(organizationBranchesProvider);
    final branch = branches.firstWhere((b) => b.id == student.branchId);
    final cls = classes.firstWhere((c) => c.id == student.classId, orElse: () => ClassEntity(id: '', branchId: '', departmentId: '', name: 'Grade Class', code: '', maxStudentsCapacity: 0));
    final sec = sections.firstWhere((s) => s.id == student.sectionId, orElse: () => SectionEntity(id: '', classId: '', name: 'Sec', roomNumber: '', classTeacher: '', maxStudentsCapacity: 0));

    String certType = 'Bonafide'; // Bonafide, Character, TC, Student ID Card
    bool isGenerating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Branch Certificate & ID Generator', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close_rounded, size: 16), onPressed: () => Navigator.pop(context)),
              ],
            ),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selector wrapped in Wrap for small screens
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Bonafide', style: TextStyle(fontSize: 10)),
                        selected: certType == 'Bonafide',
                        onSelected: (val) => setState(() => certType = 'Bonafide'),
                      ),
                      ChoiceChip(
                        label: const Text('Character', style: TextStyle(fontSize: 10)),
                        selected: certType == 'Character',
                        onSelected: (val) => setState(() => certType = 'Character'),
                      ),
                      ChoiceChip(
                        label: const Text('Transfer Cert (TC)', style: TextStyle(fontSize: 10)),
                        selected: certType == 'TC',
                        onSelected: (val) => setState(() => certType = 'TC'),
                      ),
                      ChoiceChip(
                        label: const Text('Migration', style: TextStyle(fontSize: 10)),
                        selected: certType == 'Migration',
                        onSelected: (val) => setState(() => certType = 'Migration'),
                      ),
                      ChoiceChip(
                        label: const Text('Student ID Card', style: TextStyle(fontSize: 10)),
                        selected: certType == 'Student ID Card',
                        onSelected: (val) => setState(() => certType = 'Student ID Card'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // High-fidelity Preview Canvas
                  Container(
                    width: double.infinity,
                    height: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300, width: 3), // Classic certificate border
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: certType == 'Student ID Card'
                          ? _buildIDCardPreviewWidget(student, cls, sec, branch, isDark)
                          : _buildLetterheadCertificatePreviewWidget(certType, student, cls, sec, branch, isDark),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                icon: isGenerating
                    ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.print_rounded, size: 14),
                label: Text(isGenerating ? 'Generating PDF...' : 'Print & Download PDF'),
                onPressed: isGenerating
                    ? null
                    : () async {
                        setState(() => isGenerating = true);
                        await Future.delayed(const Duration(milliseconds: 1500));
                        setState(() => isGenerating = false);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloaded ${student.name} - $certType Certificate to your system files!')),
                        );
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIDCardPreviewWidget(
    StudentEntity student,
    ClassEntity cls,
    SectionEntity sec,
    dynamic branch,
    bool isDark,
  ) {
    return Center(
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                Text(
                  branch.name.substring(0, branch.name.indexOf(' ') != -1 ? branch.name.indexOf(' ') : branch.name.length),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const Divider(color: AppColors.primary, thickness: 0.5),
            const SizedBox(height: 6),

            // Photo
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
              child: Text(student.name[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary)),
            ),
            const SizedBox(height: 8),

            // Details
            Text(student.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            Text('ID: ${student.admissionNumber}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
            const SizedBox(height: 6),

            _buildIDRow('Grade/Sec', '${cls.name} (${sec.name})'),
            _buildIDRow('Roll No', student.rollNumber.isNotEmpty ? student.rollNumber : 'N/A'),
            _buildIDRow('Blood Grp', student.bloodGroup),
            _buildIDRow('Emergency', student.emergencyContact),
            const SizedBox(height: 8),

            // Barcode preview
            Container(
              height: 14,
              width: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/e/e9/UPC-A-barcode.svg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIDRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 7.5, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(val, style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLetterheadCertificatePreviewWidget(
    String type,
    StudentEntity student,
    ClassEntity cls,
    SectionEntity sec,
    dynamic branch,
    bool isDark,
  ) {
    String certificateTitle = '';
    String contentText = '';

    if (type == 'Bonafide') {
      certificateTitle = 'BONAFIDE CERTIFICATE';
      contentText = 'This is to certify that Master/Miss ${student.name}, Son/Daughter of ${student.guardianName}, is a bonafide student of our school studying in ${cls.name}, Section ${sec.name} during the academic term. According to our registers, his/her date of birth is ${student.dateOfBirth}. He/she bears a good moral character.';
    } else if (type == 'Character') {
      certificateTitle = 'CHARACTER CERTIFICATE';
      contentText = 'This is to certify that Master/Miss ${student.name} has been studying in this institution in ${cls.name} for the current academic session. During his/her stay in this branch, his/her conduct, behaviour, and overall moral character have been found to be exemplary, and he/she actively participated in campus initiatives.';
    } else if (type == 'Migration') {
      certificateTitle = 'MIGRATION CERTIFICATE';
      contentText = 'This is to certify that Master/Miss ${student.name}, registration ID ${student.admissionNumber}, has been a student of ${branch.name}. He/she has successfully completed his/her course of study and board examinations. This institution has no objection to his/her admission to any other college, school, or university. We certify his/her migration clearance.';
    } else {
      certificateTitle = 'TRANSFER CERTIFICATE';
      contentText = 'This Transfer Certificate is officially issued to Master/Miss ${student.name}, registration ID ${student.admissionNumber}. Class last attended: ${cls.name}. Section: ${sec.name}. Roll: ${student.rollNumber}. Reason for leaving branch: Academic relocation. All school dues are cleared, and his/her status is hereby updated to TC Issued.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Letterhead
        Text(branch.name.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(branch.address, style: const TextStyle(fontSize: 8, color: Colors.grey)),
        Text('Affiliation Board: ${branch.affiliationBoard} | Rec. No: ${branch.recognitionNumber}', style: const TextStyle(fontSize: 7, color: Colors.grey)),
        const Divider(thickness: 1.5),
        const SizedBox(height: 12),

        // Title
        Text(
          certificateTitle,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
        ),
        const SizedBox(height: 14),

        // Body
        Text(
          contentText,
          style: const TextStyle(fontSize: 9, height: 1.4),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 30),

        // Signatures wrapped in Wrap to prevent horizontal overflow
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            Column(
              children: [
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('SCHOOL SEAL', style: TextStyle(fontSize: 6, color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Column(
              children: [
                Text('Class Teacher Sign', style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic)),
                SizedBox(height: 12),
                Text('________________', style: TextStyle(fontSize: 8)),
              ],
            ),
            Column(
              children: [
                Text(branch.principalName, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                const Text('Principal Stamp & Signature', style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic)),
                const SizedBox(height: 6),
                const Text('____________________', style: TextStyle(fontSize: 8)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 3: INTER-BRANCH TRANSFERS (ORGANIZATION PANELS)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildTransfersTab(bool isDark, String branchId) {
    final requests = ref.watch(interBranchTransfersProvider);
    final branches = ref.watch(organizationBranchesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inter-Branch Relocation Requests (${requests.length} Requests)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
            const Text(
              'View relocations across all branch systems inside the organization. Approved transfers update the student active branch registry.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            if (requests.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No inter-branch relocation requests found.', style: TextStyle(fontSize: 12, color: Colors.grey))))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (context, idx) {
                  final req = requests[idx];
                  final srcName = branches.firstWhere((b) => b.id == req.sourceBranchId, orElse: () => BranchEntity(id: '', organizationId: '', code: '', name: 'Unknown', affiliationBoard: '', recognitionNumber: '', principalName: '', email: '', phone: '', address: '', city: '', state: '', pincode: '', maxStudentCapacity: 0, maxStaffCapacity: 0, activeStudentCount: 0, activeStaffCount: 0, currentAcademicYear: '', planType: '', enabledModules: const {}, createdAt: DateTime.now())).name;
                  final destName = branches.firstWhere((b) => b.id == req.destBranchId, orElse: () => BranchEntity(id: '', organizationId: '', code: '', name: 'Unknown', affiliationBoard: '', recognitionNumber: '', principalName: '', email: '', phone: '', address: '', city: '', state: '', pincode: '', maxStudentCapacity: 0, maxStaffCapacity: 0, activeStudentCount: 0, activeStaffCount: 0, currentAcademicYear: '', planType: '', enabledModules: const {}, createdAt: DateTime.now())).name;

                  Color statusColor = Colors.amber;
                  if (req.status == 'Approved') statusColor = Colors.green;
                  if (req.status == 'Rejected') statusColor = Colors.red;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(req.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                req.status,
                                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Transfer: $srcName ➔ $destName', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text('Reason: "${req.reason}"', style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 10),
                        if (req.status == 'Pending')
                          LayoutBuilder(
                            builder: (context, innerConstraints) {
                              final isCardMobile = innerConstraints.maxWidth < 450;
                              final rejectBtn = ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.withValues(alpha: 0.15),
                                  foregroundColor: Colors.red,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                onPressed: () {
                                  ref.read(interBranchTransfersProvider.notifier).processRequest(
                                        requestId: req.id,
                                        newStatus: 'Rejected',
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Relocation request rejected.')));
                                },
                                child: const Text('Reject', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              );

                              final approveBtn = ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.withValues(alpha: 0.15),
                                  foregroundColor: Colors.green,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                onPressed: () {
                                  ref.read(interBranchTransfersProvider.notifier).processRequest(
                                        requestId: req.id,
                                        newStatus: 'Approved',
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Relocation request approved! Student shifted branches.')));
                                },
                                child: const Text('Approve & Shift Branch', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              );

                              if (isCardMobile) {
                                return Column(
                                  children: [
                                    SizedBox(width: double.infinity, child: approveBtn),
                                    const SizedBox(height: 8),
                                    SizedBox(width: double.infinity, child: rejectBtn),
                                  ],
                                );
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  rejectBtn,
                                  const SizedBox(width: 8),
                                  approveBtn,
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 2: ENROLL NEW STUDENT (FORM WIZARD)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildEnrollmentTab(bool isDark, String branchId) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == branchId).toList();
    final sections = ref.watch(academicSectionsProvider);
    final branch = ref.watch(organizationBranchesProvider).firstWhere((b) => b.id == branchId);

    final classSections = sections.where((s) => s.classId == _enrollClassId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobileForm = constraints.maxWidth < 600;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enrolling New Student to ${branch.name}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
                const Text(
                  'Fill out the multi-step profile fields. The enrollment system automatically attaches the branch ID and prefix code to generate a unique Student ID.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 12),

                // Step 1: Personal Details
                const Text('1. Personal Profile Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                const SizedBox(height: 8),
                _responsiveFormRow(
                  isMobile: isMobileForm,
                  left: TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Full Student Name *', isDense: true),
                  ),
                  right: DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender', isDense: true),
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: 'Other', child: Text('Other', style: TextStyle(fontSize: 11))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _gender = val);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _responsiveFormRow(
                  isMobile: isMobileForm,
                  left: TextField(
                    controller: _dobController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)', isDense: true),
                  ),
                  right: DropdownButtonFormField<String>(
                    initialValue: _bloodGroup,
                    decoration: const InputDecoration(labelText: 'Blood Group', isDense: true),
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: const [
                      DropdownMenuItem(value: 'O+', child: Text('O+', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: 'A+', child: Text('A+', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: 'B+', child: Text('B+', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: 'AB+', child: Text('AB+', style: TextStyle(fontSize: 11))),
                      DropdownMenuItem(value: 'O-', child: Text('O-', style: TextStyle(fontSize: 11))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _bloodGroup = val);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _responsiveFormRow(
                  isMobile: isMobileForm,
                  left: TextField(
                    controller: _guardianController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Guardian Full Name *', isDense: true),
                  ),
                  right: TextField(
                    controller: _phoneController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Contact Phone Number', isDense: true),
                  ),
                ),
                const SizedBox(height: 12),
                _responsiveFormRow(
                  isMobile: isMobileForm,
                  left: TextField(
                    controller: _emailController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Guardian Email', isDense: true),
                  ),
                  right: TextField(
                    controller: _addressController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Residential Address', isDense: true),
                  ),
                ),
                const SizedBox(height: 20),

                // Step 2: Academic Details
                const Text('2. Academic Enrollment Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                const SizedBox(height: 8),
                _responsiveFormRow(
                  isMobile: isMobileForm,
                  left: DropdownButtonFormField<String>(
                    initialValue: _enrollClassId,
                    decoration: const InputDecoration(labelText: 'Assign Class *', isDense: true),
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: classes.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _enrollClassId = val;
                        _enrollSectionId = null;
                      });
                    },
                  ),
                  right: DropdownButtonFormField<String>(
                    initialValue: _enrollSectionId,
                    decoration: const InputDecoration(labelText: 'Assign Section *', isDense: true),
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: classSections.map((s) {
                      return DropdownMenuItem(value: s.id, child: Text('Section ${s.name}', style: const TextStyle(fontSize: 11)));
                    }).toList(),
                    onChanged: (val) => setState(() => _enrollSectionId = val),
                  ),
                ),
                const SizedBox(height: 12),
                _responsiveFormRow(
                  isMobile: isMobileForm,
                  left: TextField(
                    controller: _rollNumberController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Roll Number (Leave blank to auto-generate)', isDense: true),
                  ),
                  right: TextField(
                    controller: _admissionDateController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Admission Date (YYYY-MM-DD)', isDense: true),
                  ),
                ),
                const SizedBox(height: 20),

                // Step 3: Medical & Behavioral Details
                const Text('3. Behavioral & Medical Profiles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                const SizedBox(height: 8),
                _responsiveFormRow(
                  isMobile: isMobileForm,
                  left: TextField(
                    controller: _allergiesController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Allergies (e.g. Peanuts)', isDense: true),
                  ),
                  right: TextField(
                    controller: _conditionsController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Medical Conditions (e.g. Asthma)', isDense: true),
                  ),
                ),
                const SizedBox(height: 12),
                _responsiveFormRow(
                  isMobile: isMobileForm,
                  left: TextField(
                    controller: _emergencyContactController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Emergency Medical Contact Phone', isDense: true),
                  ),
                  right: TextField(
                    controller: _remarksController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Behavioral Entry Remarks', isDense: true),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () {
                      if (_nameController.text.trim().isEmpty ||
                          _guardianController.text.trim().isEmpty ||
                          _enrollClassId == null ||
                          _enrollSectionId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all mandatory (*) profile fields!')),
                        );
                        return;
                      }

                      // Auto generate unique Student ID with Branch prefix
                      final branchPrefix = branch.code.toUpperCase();
                      final uniqueStudentId = '$branchPrefix-STU-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

                      ref.read(academicStudentsProvider.notifier).addStudent(
                            branchId: branchId,
                            classId: _enrollClassId!,
                            sectionId: _enrollSectionId!,
                            name: _nameController.text.trim(),
                            admissionNumber: uniqueStudentId,
                            rollNumber: _rollNumberController.text.trim(),
                            gender: _gender,
                            dateOfBirth: _dobController.text.trim(),
                            bloodGroup: _bloodGroup,
                            guardianName: _guardianController.text.trim(),
                            phone: _phoneController.text.trim(),
                            email: _emailController.text.trim(),
                            address: _addressController.text.trim(),
                            admissionDate: _admissionDateController.text.trim(),
                            behavioralRemarks: _remarksController.text.trim(),
                            allergies: _allergiesController.text.trim(),
                            medicalConditions: _conditionsController.text.trim(),
                            emergencyContact: _emergencyContactController.text.trim().isNotEmpty
                                ? _emergencyContactController.text.trim()
                                : _phoneController.text.trim(),
                          );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Student successfully enrolled! Unique ID Generated: $uniqueStudentId')),
                      );

                      // Clear form
                      _nameController.clear();
                      _guardianController.clear();
                      _phoneController.clear();
                      _emailController.clear();
                      _addressController.clear();
                      _rollNumberController.clear();
                      _emergencyContactController.clear();
                      setState(() {
                        _enrollClassId = null;
                        _enrollSectionId = null;
                      });

                      // Go to directory tab
                      _tabController.animateTo(0);
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Complete Student Enrollment & Generate ID', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _responsiveFormRow({
    required bool isMobile,
    required Widget left,
    required Widget right,
  }) {
    if (isMobile) {
      return Column(
        children: [
          left,
          const SizedBox(height: 12),
          right,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 4: STUDENT PHOTO GALLERY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPhotoGalleryTab(bool isDark, String branchId) {
    final students = ref.watch(academicStudentsProvider).where((s) => s.branchId == branchId).toList();
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == branchId).toList();

    final filteredStudents = students.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesClass = _selectedClassId == null || s.classId == _selectedClassId;
      return matchesSearch && matchesClass;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gallery Filters
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, filterConstraints) {
                final isMobileFilter = filterConstraints.maxWidth < 600;
                
                final searchField = TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search gallery by student name...',
                    prefixIcon: Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (val) => setState(() => _searchQuery = val),
                );

                final classDropdown = DropdownButtonFormField<String>(
                  initialValue: _selectedClassId,
                  decoration: const InputDecoration(labelText: 'Filter Class', isDense: true),
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Classes', style: TextStyle(fontSize: 11))),
                    ...classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)))),
                  ],
                  onChanged: (val) => setState(() => _selectedClassId = val),
                );

                if (isMobileFilter) {
                  return Column(
                    children: [
                      searchField,
                      const SizedBox(height: 12),
                      classDropdown,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: 12),
                    Expanded(child: classDropdown),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Photos Grid
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Branch Student Gallery (${filteredStudents.length} photos)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (filteredStudents.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No student photos found.', style: TextStyle(fontSize: 11, color: Colors.grey))))
                else
                  LayoutBuilder(
                    builder: (context, gridConstraints) {
                      final isMobileGrid = gridConstraints.maxWidth < 900;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: isMobileGrid ? 0.75 : 0.8, // Set dynamic ratio to prevent overflow
                        ),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, idx) {
                          final s = filteredStudents[idx];
                          final clsName = classes.firstWhere((c) => c.id == s.classId, orElse: () => ClassEntity(id: '', branchId: '', departmentId: '', name: 'Grade Class', code: '', maxStudentsCapacity: 0)).name;

                          return Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBg : AppColors.lightBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(s.photoUrl),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.name,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  clsName,
                                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                TextButton(
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 20)),
                                  onPressed: () {
                                    setState(() {
                                      _selectedStudent = s;
                                    });
                                    _tabController.animateTo(0);
                                    if (isMobileGrid) {
                                      // Wait a brief moment to ensure tab changes before showing sheet
                                      Future.delayed(const Duration(milliseconds: 100), () {
                                        if (!context.mounted) return;
                                        _showStudentProfileBottomSheet(context, s, classes, ref.read(academicSectionsProvider));
                                      });
                                    }
                                  },
                                  child: const Text('View Profile', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 5: BULK STUDENT IMPORT VIA CSV
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildBulkImportTab(bool isDark, String branchId) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == branchId).toList();
    final sections = ref.watch(academicSectionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bulk Student Enrollment via CSV',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Import multiple students at once. Paste your CSV string. We will perform branch safety and metadata checks on ClassCodes & Sections.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Text(
                'Expected CSV Header Format:\nName,ClassCode,SectionName,GuardianName,Phone,RollNumber,DOB\n\nExample Rows:\nRahul Khanna,CLS-001,A,Vikram Khanna,+91 9882910283,115,2015-05-12\nSneha Patil,CLS-005,A,Sunita Patil,+91 8872910392,204,2011-03-24',
                style: TextStyle(fontSize: 9, fontFamily: 'monospace', height: 1.3),
              ),
            ),
            const SizedBox(height: 12),

            // Pasted Input
            TextField(
              controller: _csvImportController,
              maxLines: 6,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              decoration: const InputDecoration(
                hintText: 'Paste CSV rows here...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                  onPressed: () {
                    final pastedText = _csvImportController.text.trim();
                    if (pastedText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please paste some CSV data first!')));
                      return;
                    }

                    // Parse CSV lines
                    final lines = pastedText.split('\n');
                    final results = <Map<String, dynamic>>[];

                    for (var i = 0; i < lines.length; i++) {
                      final line = lines[i].trim();
                      if (line.isEmpty || line.toLowerCase().startsWith('name,')) continue;

                      final parts = line.split(',');
                      if (parts.length < 5) {
                        results.add({
                          'rowNumber': i + 1,
                          'name': parts.isNotEmpty ? parts[0] : 'Unknown Row',
                          'status': 'FAIL',
                          'remark': 'Malformed row. Expected at least 5 columns.',
                        });
                        continue;
                      }

                      final name = parts[0].trim();
                      final classCode = parts[1].trim();
                      final sectionName = parts[2].trim();
                      final guardian = parts[3].trim();
                      final phone = parts[4].trim();
                      final roll = parts.length > 5 ? parts[5].trim() : '';
                      final dob = parts.length > 6 ? parts[6].trim() : '2015-05-10';

                      // Validation check: ClassCode exists in branch
                      final matchedCls = classes.firstWhere((c) => c.code == classCode, orElse: () => ClassEntity(id: '', branchId: '', departmentId: '', name: '', code: '', maxStudentsCapacity: 0));
                      if (matchedCls.id.isEmpty) {
                        results.add({
                          'rowNumber': i + 1,
                          'name': name,
                          'status': 'FAIL',
                          'remark': 'Class code "$classCode" not found in active branch.',
                        });
                        continue;
                      }

                      // Validation check: SectionName exists in that class
                      final classSecs = sections.where((s) => s.classId == matchedCls.id).toList();
                      final matchedSec = classSecs.firstWhere((s) => s.name.toUpperCase() == sectionName.toUpperCase(), orElse: () => SectionEntity(id: '', classId: '', name: '', roomNumber: '', classTeacher: '', maxStudentsCapacity: 0));
                      if (matchedSec.id.isEmpty) {
                        results.add({
                          'rowNumber': i + 1,
                          'name': name,
                          'status': 'FAIL',
                          'remark': 'Section "$sectionName" not found inside Class $classCode.',
                        });
                        continue;
                      }

                      // Row valid
                      results.add({
                        'rowNumber': i + 1,
                        'name': name,
                        'status': 'PASS',
                        'remark': 'Valid config (Class: ${matchedCls.name}, Sec: $sectionName)',
                        'student': StudentEntity(
                          id: 'STU-${DateTime.now().millisecondsSinceEpoch}-$i',
                          branchId: branchId,
                          classId: matchedCls.id,
                          sectionId: matchedSec.id,
                          name: name,
                          admissionNumber: '${branchId.toUpperCase().substring(0,3)}-STU-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}-$i',
                          rollNumber: roll,
                          guardianName: guardian,
                          phone: phone,
                          dateOfBirth: dob,
                        ),
                      });
                    }

                    setState(() {
                      _csvValidationResults = results;
                      _csvValidated = true;
                    });
                  },
                  icon: const Icon(Icons.fact_check_rounded, size: 14),
                  label: const Text('Validate CSV Safety & Config'),
                ),
                if (_csvValidated)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: _csvValidationResults.any((r) => r['status'] == 'PASS')
                        ? () {
                            int count = 0;
                            for (final res in _csvValidationResults) {
                              if (res['status'] == 'PASS') {
                                final s = res['student'] as StudentEntity;
                                ref.read(academicStudentsProvider.notifier).addStudent(
                                      branchId: s.branchId,
                                      classId: s.classId,
                                      sectionId: s.sectionId,
                                      name: s.name,
                                      admissionNumber: s.admissionNumber,
                                      rollNumber: s.rollNumber,
                                      guardianName: s.guardianName,
                                      phone: s.phone,
                                      dateOfBirth: s.dateOfBirth,
                                    );
                                count++;
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully imported $count student records!')));
                            _csvImportController.clear();
                            setState(() {
                              _csvValidationResults = [];
                              _csvValidated = false;
                            });
                            _tabController.animateTo(0);
                          }
                        : null,
                    icon: const Icon(Icons.done_all_rounded, size: 14),
                    label: const Text('Execute Safe Bulk Import'),
                  ),
              ],
            ),

            if (_csvValidated) ...[
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Import Validation Results:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _csvValidationResults.length,
                itemBuilder: (context, idx) {
                  final res = _csvValidationResults[idx];
                  final isPass = res['status'] == 'PASS';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPass ? Colors.green.withValues(alpha: 0.05) : Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isPass ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPass ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: isPass ? Colors.green : Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Row ${res['rowNumber']}: ${res['name']}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            res['remark'],
                            style: TextStyle(fontSize: 9, color: isPass ? Colors.green[800] : Colors.red[800]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

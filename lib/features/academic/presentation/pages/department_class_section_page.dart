import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../../organization/providers.dart';
import '../../providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Department, Class & Section Management Page
/// Section 3 Implementation: Branch-Scoped Academic Structure
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class DepartmentClassSectionPage extends ConsumerStatefulWidget {
  const DepartmentClassSectionPage({super.key});

  @override
  ConsumerState<DepartmentClassSectionPage> createState() =>
      _DepartmentClassSectionPageState();
}

class _DepartmentClassSectionPageState
    extends ConsumerState<DepartmentClassSectionPage> {
  String? _selectedBranchId;

  // Controllers for Adding Department
  final _deptNameController = TextEditingController();
  final _deptCodeController = TextEditingController();
  final _deptHeadController = TextEditingController();
  final _deptDescController = TextEditingController();

  // Controllers for Adding Class
  final _classNameController = TextEditingController();
  final _classCodeController = TextEditingController();
  final _classCapacityController = TextEditingController(text: '40');
  String? _classDeptId;

  // Controllers for Adding Section
  final _secNameController = TextEditingController();
  final _secRoomController = TextEditingController();
  final _secTeacherController = TextEditingController();
  final _secCapacityController = TextEditingController(text: '40');
  String? _secClassId;

  // Controllers for Subject Assignment
  final _subjectNameController = TextEditingController();
  final _subjectTeacherController = TextEditingController();
  String? _subAssignClassId;
  String? _subAssignSectionId = 'ALL';

  // Controllers for Streams
  final _streamNameController = TextEditingController();

  // Controllers for Batches
  final _batchNameController = TextEditingController();

  // Controllers for Elective Groups
  final _electiveNameController = TextEditingController();
  final _electiveSubjectsController = TextEditingController(); // Comma-separated list of elective subjects

  // Controllers/State for Student Directory & transfers
  String? _dirClassId;
  String? _dirSectionId;

  // Controllers/State for Promotion
  String? _promoFromClassId;
  String? _promoToClassId;
  String? _promoToSectionId;

  // Controllers/State for Timetable Slots
  String? _ttClassId;
  String? _ttSectionId = 'ALL';
  String _ttDay = 'Monday';
  final _ttPeriodNameController = TextEditingController();
  final _ttStartTimeController = TextEditingController(text: '08:30 AM');
  final _ttEndTimeController = TextEditingController(text: '09:15 AM');
  final _ttSubjectController = TextEditingController();
  final _ttTeacherController = TextEditingController();

  // Controllers/State for Class Fee Plans
  final _feePlanNameController = TextEditingController();
  final _feeAmountController = TextEditingController();
  String? _feeClassId;

  // Controllers/State for Exam Schedules
  final _examNameController = TextEditingController();
  final _examSubjectController = TextEditingController();
  final _examDateController = TextEditingController(text: '2026-09-15');
  final _examStartController = TextEditingController(text: '09:00 AM');
  final _examEndController = TextEditingController(text: '12:00 PM');
  String? _examClassId;

  // Controllers/State for Attendance Register
  String? _attClassId;
  String? _attSectionId;
  final _attDateController = TextEditingController(text: '2026-08-13');
  final Map<String, String> _tempAttendanceMap = {};

  // Controllers/State for Parent-Teacher Meetings
  final _ptmTitleController = TextEditingController();
  final _ptmDateController = TextEditingController(text: '2026-08-20');
  final _ptmStartController = TextEditingController(text: '10:00 AM');
  final _ptmEndController = TextEditingController(text: '01:00 PM');
  String? _ptmClassId;
  String? _ptmSectionId;

  @override
  void dispose() {
    _deptNameController.dispose();
    _deptCodeController.dispose();
    _deptHeadController.dispose();
    _deptDescController.dispose();
    _classNameController.dispose();
    _classCodeController.dispose();
    _classCapacityController.dispose();
    _secNameController.dispose();
    _secRoomController.dispose();
    _secTeacherController.dispose();
    _secCapacityController.dispose();
    _subjectNameController.dispose();
    _subjectTeacherController.dispose();
    _streamNameController.dispose();
    _batchNameController.dispose();
    _electiveNameController.dispose();
    _electiveSubjectsController.dispose();
    _ttPeriodNameController.dispose();
    _ttStartTimeController.dispose();
    _ttEndTimeController.dispose();
    _ttSubjectController.dispose();
    _ttTeacherController.dispose();
    _feePlanNameController.dispose();
    _feeAmountController.dispose();
    _examNameController.dispose();
    _examSubjectController.dispose();
    _examDateController.dispose();
    _examStartController.dispose();
    _examEndController.dispose();
    _attDateController.dispose();
    _ptmTitleController.dispose();
    _ptmDateController.dispose();
    _ptmStartController.dispose();
    _ptmEndController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final branches = ref.watch(organizationBranchesProvider);

    // Initialize selected branch
    if (_selectedBranchId == null && branches.isNotEmpty) {
      _selectedBranchId = user?.activeBranch?.branchId ?? branches.first.id;
    }

    final activeBranch = branches.firstWhere(
      (b) => b.id == _selectedBranchId,
      orElse: () => branches.first,
    );

    return DefaultTabController(
      length: 11,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(115),
          child: Container(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Branch Switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Academic Structure & Course Allocations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Configure departments, classes, subjects, electives, batches, promotions, fee plans, exams, attendance, and PTMs for ${activeBranch.name}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (user != null && user.role.isOrgLevel)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBranchId,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            items: branches.map((b) {
                              return DropdownMenuItem(
                                value: b.id,
                                child: Text(b.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedBranchId = val;
                                  _classDeptId = null;
                                  _secClassId = null;
                                  _subAssignClassId = null;
                                  _subAssignSectionId = 'ALL';
                                  _dirClassId = null;
                                  _dirSectionId = null;
                                  _promoFromClassId = null;
                                  _promoToClassId = null;
                                  _promoToSectionId = null;
                                  _ttClassId = null;
                                  _ttSectionId = 'ALL';
                                  _feeClassId = null;
                                  _examClassId = null;
                                  _attClassId = null;
                                  _attSectionId = null;
                                  _tempAttendanceMap.clear();
                                  _ptmClassId = null;
                                  _ptmSectionId = null;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  tabs: const [
                    Tab(icon: Icon(Icons.account_tree_rounded, size: 16), text: 'Academic Tree'),
                    Tab(icon: Icon(Icons.menu_book_rounded, size: 16), text: 'Subject Assignments'),
                    Tab(icon: Icon(Icons.ballot_rounded, size: 16), text: 'Electives & Streams'),
                    Tab(icon: Icon(Icons.history_toggle_off_rounded, size: 16), text: 'Batches & Years'),
                    Tab(icon: Icon(Icons.badge_rounded, size: 16), text: 'Student Directory'),
                    Tab(icon: Icon(Icons.trending_up_rounded, size: 16), text: 'Promotion Workflow'),
                    Tab(icon: Icon(Icons.calendar_today_rounded, size: 16), text: 'Timetable Slots'),
                    Tab(icon: Icon(Icons.monetization_on_rounded, size: 16), text: 'Class Fee Plans'),
                    Tab(icon: Icon(Icons.percent_rounded, size: 16), text: 'Exam Schedules'),
                    Tab(icon: Icon(Icons.rule_rounded, size: 16), text: 'Attendance Register'),
                    Tab(icon: Icon(Icons.people_alt_rounded, size: 16), text: 'PTM Scheduler'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildAcademicTreeTab(isDark),
            _buildSubjectAssignmentTab(isDark),
            _buildElectivesStreamsTab(isDark),
            _buildBatchesTab(isDark),
            _buildStudentDirectoryTab(isDark),
            _buildPromotionTab(isDark),
            _buildTimetableSlotsTab(isDark),
            _buildClassFeePlansTab(isDark),
            _buildExamSchedulesTab(isDark),
            _buildAttendanceRegisterTab(isDark),
            _buildParentTeacherMeetingsTab(isDark),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 1: ACADEMIC TREE (DEPT, CLASS & SECTION)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildAcademicTreeTab(bool isDark) {
    final depts = ref.watch(academicDepartmentsProvider).where((d) => d.branchId == _selectedBranchId).toList();
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == _selectedBranchId).toList();
    final sections = ref.watch(academicSectionsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 950;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildAcademicTreeList(isDark, depts, classes, sections)),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: _buildAcademicTreeActions(isDark, depts, classes)),
                  ],
                )
              : Column(
                  children: [
                    _buildAcademicTreeList(isDark, depts, classes, sections),
                    const SizedBox(height: 16),
                    _buildAcademicTreeActions(isDark, depts, classes),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildAcademicTreeList(
    bool isDark,
    List<DepartmentEntity> depts,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    if (depts.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.category_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'No Academic Departments Registered',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const Text('Add departments on the right panel to begin.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: depts.map((dept) {
        final deptClasses = classes.where((c) => c.departmentId == dept.id).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.lan_rounded, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dept.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Code: ${dept.code}  |  HoD: ${dept.headOfDepartment}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                      tooltip: 'Remove Department',
                      onPressed: () {
                        ref.read(academicDepartmentsProvider.notifier).removeDepartment(dept.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  dept.description,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                if (deptClasses.isEmpty)
                  const Text(
                    'No classes created under this department yet.',
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                  )
                else
                  Column(
                    children: deptClasses.map((cls) {
                      final clsSections = sections.where((s) => s.classId == cls.id).toList();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBg : AppColors.lightBg,
                          borderRadius: BorderRadius.circular(8),
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
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.class_rounded, color: cls.isActive ? AppColors.secondary : Colors.grey, size: 14),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${cls.name} (${cls.code})',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: cls.isActive
                                                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                                    : Colors.grey,
                                                decoration: cls.isActive ? null : TextDecoration.lineThrough,
                                              ),
                                            ),
                                            Text(
                                              'Template: ${cls.reportCardTemplate}',
                                              style: const TextStyle(fontSize: 8, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: cls.isActive ? Colors.blue.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          cls.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: cls.isActive ? Colors.blue : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Template Selector
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.summarize_outlined, size: 14, color: AppColors.primary),
                                      tooltip: 'Select Report Card Template',
                                      onSelected: (template) {
                                        ref.read(academicClassesProvider.notifier).updateClassTemplate(cls.id, template);
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(value: 'CBSE Standard 9-Point Template', child: Text('CBSE Standard 9-Point', style: TextStyle(fontSize: 10))),
                                        PopupMenuItem(value: 'ICSE Comprehensive Template', child: Text('ICSE Comprehensive', style: TextStyle(fontSize: 10))),
                                        PopupMenuItem(value: 'State Board Grade Template', child: Text('State Board Grade', style: TextStyle(fontSize: 10))),
                                        PopupMenuItem(value: 'IB PYP/MYP Criteria Template', child: Text('IB Criteria Template', style: TextStyle(fontSize: 10))),
                                      ],
                                    ),
                                    // Activation switch
                                    IconButton(
                                      icon: Icon(
                                        cls.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_outlined,
                                        color: cls.isActive ? Colors.green : Colors.grey,
                                        size: 18,
                                      ),
                                      tooltip: cls.isActive ? 'Deactivate Class' : 'Activate Class',
                                      onPressed: () {
                                        ref.read(academicClassesProvider.notifier).toggleClassStatus(cls.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 14),
                                      onPressed: () {
                                        ref.read(academicClassesProvider.notifier).removeClass(cls.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (clsSections.isEmpty)
                              const Text(
                                'No sections. Add sections to manage class allocations.',
                                style: TextStyle(fontSize: 9, color: Colors.grey, fontStyle: FontStyle.italic),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: clsSections.map((sec) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: sec.isActive
                                            ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                                            : Colors.redAccent.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Section ${sec.name}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: sec.isActive
                                                        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                                        : Colors.grey,
                                                    decoration: sec.isActive ? null : TextDecoration.lineThrough,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '(${sec.isActive ? "Active" : "Inactive"})',
                                                  style: TextStyle(
                                                    fontSize: 7,
                                                    color: sec.isActive ? Colors.green : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              'Room: ${sec.roomNumber} | Teacher: ${sec.classTeacher}',
                                              style: const TextStyle(fontSize: 8, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(
                                            sec.isActive ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                            color: sec.isActive ? Colors.green : Colors.grey,
                                            size: 11,
                                          ),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          tooltip: sec.isActive ? 'Deactivate Section' : 'Activate Section',
                                          onPressed: () {
                                            ref.read(academicSectionsProvider.notifier).toggleSectionStatus(sec.id);
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 10),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            ref.read(academicSectionsProvider.notifier).removeSection(sec.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAcademicTreeActions(
    bool isDark,
    List<DepartmentEntity> depts,
    List<ClassEntity> classes,
  ) {
    return Column(
      children: [
        // 1. ADD DEPARTMENT
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Branch Department',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _deptNameController,
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(labelText: 'Department Name (e.g. Primary)', isDense: true),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _deptCodeController,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Dept Code', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _deptHeadController,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'HoD (Branch Staff)', isDense: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _deptDescController,
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(labelText: 'Description', isDense: true),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_deptNameController.text.trim().isNotEmpty && _deptCodeController.text.trim().isNotEmpty) {
                      ref.read(academicDepartmentsProvider.notifier).addDepartment(
                            branchId: _selectedBranchId!,
                            name: _deptNameController.text.trim(),
                            code: _deptCodeController.text.trim().toUpperCase(),
                            headOfDepartment: _deptHeadController.text.trim(),
                            description: _deptDescController.text.trim(),
                          );
                      _deptNameController.clear();
                      _deptCodeController.clear();
                      _deptHeadController.clear();
                      _deptDescController.clear();
                    }
                  },
                  child: const Text('Save Department', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. ADD CLASS
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Class / Grade',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _classDeptId,
                decoration: const InputDecoration(labelText: 'Department Link', isDense: true),
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                items: depts.map((d) {
                  return DropdownMenuItem(value: d.id, child: Text(d.name, style: const TextStyle(fontSize: 11)));
                }).toList(),
                onChanged: (val) => setState(() => _classDeptId = val),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _classNameController,
                style: const TextStyle(fontSize: 11),
                decoration: const InputDecoration(labelText: 'Class Name (e.g. Class 10)', isDense: true),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _classCodeController,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Class Code', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _classCapacityController,
                      style: const TextStyle(fontSize: 11),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Capacity Limit', isDense: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_classDeptId != null && _classNameController.text.trim().isNotEmpty && _classCodeController.text.trim().isNotEmpty) {
                      ref.read(academicClassesProvider.notifier).addClass(
                            branchId: _selectedBranchId!,
                            departmentId: _classDeptId!,
                            name: _classNameController.text.trim(),
                            code: _classCodeController.text.trim().toUpperCase(),
                            maxStudentsCapacity: int.tryParse(_classCapacityController.text.trim()) ?? 40,
                          );
                      _classNameController.clear();
                      _classCodeController.clear();
                    }
                  },
                  child: const Text('Save Class', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. ADD SECTION WITH CLASS TEACHER & CAPACITY
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Section & Assign Class Teacher',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _secClassId,
                decoration: const InputDecoration(labelText: 'Class Link', isDense: true),
                style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                items: classes.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
                }).toList(),
                onChanged: (val) => setState(() => _secClassId = val),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _secNameController,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Section Name (e.g. A)', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _secCapacityController,
                      style: const TextStyle(fontSize: 11),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Capacity Limit', isDense: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _secRoomController,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Room Number', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _secTeacherController,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Class Teacher Name', isDense: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_secClassId != null && _secNameController.text.trim().isNotEmpty) {
                      ref.read(academicSectionsProvider.notifier).addSection(
                            classId: _secClassId!,
                            name: _secNameController.text.trim(),
                            roomNumber: _secRoomController.text.trim(),
                            classTeacher: _secTeacherController.text.trim(),
                            maxStudentsCapacity: int.tryParse(_secCapacityController.text.trim()) ?? 40,
                          );
                      _secNameController.clear();
                      _secRoomController.clear();
                      _secTeacherController.clear();
                    }
                  },
                  child: const Text('Save Section', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 2: SUBJECT ASSIGNMENTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSubjectAssignmentTab(bool isDark) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == _selectedBranchId).toList();
    final sections = ref.watch(academicSectionsProvider);
    final assignments = ref.watch(subjectAssignmentsProvider).where((a) => a.branchId == _selectedBranchId).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 950;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildSubjectAssignmentsList(isDark, assignments, classes, sections)),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: _buildSubjectAssignmentForm(isDark, classes, sections)),
                  ],
                )
              : Column(
                  children: [
                    _buildSubjectAssignmentsList(isDark, assignments, classes, sections),
                    const SizedBox(height: 16),
                    _buildSubjectAssignmentForm(isDark, classes, sections),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSubjectAssignmentsList(
    bool isDark,
    List<SubjectAssignmentEntity> assignments,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assigned Subjects & Teachers',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (assignments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No subjects assigned yet.', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assignments.length,
              itemBuilder: (context, idx) {
                final a = assignments[idx];
                final cls = classes.firstWhere((c) => c.id == a.classId, orElse: () => ClassEntity(id: '', branchId: '', departmentId: '', name: 'Unknown', code: '', maxStudentsCapacity: 0));
                final sec = a.sectionId == 'ALL'
                    ? null
                    : sections.firstWhere((s) => s.id == a.sectionId, orElse: () => SectionEntity(id: '', classId: '', name: 'Unknown', roomNumber: '', classTeacher: '', maxStudentsCapacity: 0));

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${a.subjectName} — ${cls.name}${sec != null ? " (Sec ${sec.name})" : " (All Sections)"}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            Text('Teacher: ${a.assignedTeacher}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 14),
                        onPressed: () {
                          ref.read(subjectAssignmentsProvider.notifier).removeAssignment(a.id);
                        },
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

  Widget _buildSubjectAssignmentForm(
    bool isDark,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    final filteredSections = sections.where((s) => s.classId == _subAssignClassId).toList();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assign Subject to Class/Section',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _subAssignClassId,
            decoration: const InputDecoration(labelText: 'Select Class', isDense: true),
            style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            items: classes.map((c) {
              return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _subAssignClassId = val;
                _subAssignSectionId = 'ALL';
              });
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _subAssignSectionId,
            decoration: const InputDecoration(labelText: 'Select Section scope', isDense: true),
            style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            items: [
              const DropdownMenuItem(value: 'ALL', child: Text('All Sections', style: TextStyle(fontSize: 11))),
              ...filteredSections.map((s) => DropdownMenuItem(value: s.id, child: Text('Section ${s.name}', style: const TextStyle(fontSize: 11)))),
            ],
            onChanged: (val) => setState(() => _subAssignSectionId = val),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _subjectNameController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(labelText: 'Subject Name (e.g. Mathematics)', isDense: true),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _subjectTeacherController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(labelText: 'Assigned Teacher', isDense: true),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_subAssignClassId != null &&
                    _subAssignSectionId != null &&
                    _subjectNameController.text.trim().isNotEmpty &&
                    _subjectTeacherController.text.trim().isNotEmpty) {
                  ref.read(subjectAssignmentsProvider.notifier).assignSubject(
                        branchId: _selectedBranchId!,
                        classId: _subAssignClassId!,
                        sectionId: _subAssignSectionId!,
                        subjectName: _subjectNameController.text.trim(),
                        assignedTeacher: _subjectTeacherController.text.trim(),
                      );
                  _subjectNameController.clear();
                  _subjectTeacherController.clear();
                }
              },
              child: const Text('Assign Subject', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 3: ELECTIVES & STREAMS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildElectivesStreamsTab(bool isDark) {
    final streams = ref.watch(academicStreamsProvider).where((s) => s.branchId == _selectedBranchId).toList();
    final electives = ref.watch(academicElectivesProvider).where((e) => e.branchId == _selectedBranchId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STREAMS MANAGEMENT
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Branch Streams (Science/Commerce/Arts)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _streamNameController,
                              style: const TextStyle(fontSize: 11),
                              decoration: const InputDecoration(labelText: 'New Stream Name', isDense: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_streamNameController.text.trim().isNotEmpty) {
                                ref.read(academicStreamsProvider.notifier).addStream(_selectedBranchId!, _streamNameController.text.trim());
                                _streamNameController.clear();
                              }
                            },
                            child: const Icon(Icons.add, size: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (streams.isEmpty)
                        const Text('No streams configured.', style: TextStyle(fontSize: 10, color: Colors.grey))
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: streams.map((s) {
                            return Chip(
                              label: Text(s.name, style: const TextStyle(fontSize: 10)),
                              deleteIcon: const Icon(Icons.close_rounded, size: 12),
                              onDeleted: () {
                                ref.read(academicStreamsProvider.notifier).removeStream(s.id);
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ELECTIVE GROUPS
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Elective Subject Groups',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _electiveNameController,
                        style: const TextStyle(fontSize: 11),
                        decoration: const InputDecoration(labelText: 'Group Name (e.g. Elective Group A)', isDense: true),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _electiveSubjectsController,
                        style: const TextStyle(fontSize: 11),
                        decoration: const InputDecoration(labelText: 'Subjects (comma-separated)', isDense: true),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_electiveNameController.text.trim().isNotEmpty && _electiveSubjectsController.text.trim().isNotEmpty) {
                              final subjs = _electiveSubjectsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                              ref.read(academicElectivesProvider.notifier).addElectiveGroup(_selectedBranchId!, _electiveNameController.text.trim(), subjs);
                              _electiveNameController.clear();
                              _electiveSubjectsController.clear();
                            }
                          },
                          child: const Text('Add Elective Group', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ELECTIVE GROUPS DISPLAY LIST
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configured Elective Groups',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (electives.isEmpty)
                  const Text('No elective groups registered.', style: TextStyle(fontSize: 11, color: Colors.grey))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: electives.length,
                    itemBuilder: (context, idx) {
                      final e = electives[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBg : AppColors.lightBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    children: e.subjects.map((s) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(s, style: const TextStyle(fontSize: 8, color: Colors.blue)),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 14),
                              onPressed: () {
                                ref.read(academicElectivesProvider.notifier).removeElectiveGroup(e.id);
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
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 4: BATCH / YEAR MANAGEMENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildBatchesTab(bool isDark) {
    final batches = ref.watch(academicBatchesProvider).where((b) => b.branchId == _selectedBranchId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BATCH LIST
              Expanded(
                flex: 4,
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'School Academic Batches / Session Years',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (batches.isEmpty)
                        const Text('No batches registered.', style: TextStyle(fontSize: 11, color: Colors.grey))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: batches.length,
                          itemBuilder: (context, idx) {
                            final b = batches[idx];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkBg : AppColors.lightBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        b.isActive ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                        color: b.isActive ? Colors.green : Colors.grey,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        b.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (b.isActive)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('Active Session', style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          ref.read(academicBatchesProvider.notifier).toggleBatch(b.id);
                                        },
                                        child: Text(b.isActive ? 'Deactivate' : 'Activate', style: const TextStyle(fontSize: 10)),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 14),
                                        onPressed: () {
                                          ref.read(academicBatchesProvider.notifier).removeBatch(b.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ADD BATCH
              Expanded(
                flex: 3,
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Academic Batch / Year',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _batchNameController,
                        style: const TextStyle(fontSize: 11),
                        decoration: const InputDecoration(labelText: 'Batch Name (e.g. Batch 2026 - 2027)', isDense: true),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_batchNameController.text.trim().isNotEmpty) {
                              ref.read(academicBatchesProvider.notifier).addBatch(_selectedBranchId!, _batchNameController.text.trim());
                              _batchNameController.clear();
                            }
                          },
                          child: const Text('Save Batch', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 5: STUDENT DIRECTORY & SECTION ACTIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildStudentDirectoryTab(bool isDark) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == _selectedBranchId).toList();
    final sections = ref.watch(academicSectionsProvider);
    final allStudents = ref.watch(academicStudentsProvider).where((s) => s.branchId == _selectedBranchId).toList();

    final classSections = sections.where((s) => s.classId == _dirClassId).toList();
    final filteredStudents = allStudents.where((s) => s.classId == _dirClassId && s.sectionId == _dirSectionId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Row
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _dirClassId,
                    decoration: const InputDecoration(labelText: 'Filter by Class', isDense: true),
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: classes.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _dirClassId = val;
                        _dirSectionId = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _dirSectionId,
                    decoration: const InputDecoration(labelText: 'Filter by Section', isDense: true),
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: classSections.map((s) {
                      return DropdownMenuItem(value: s.id, child: Text('Section ${s.name}', style: const TextStyle(fontSize: 11)));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _dirSectionId = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_dirClassId == null || _dirSectionId == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('Select Class and Section to view Student Directory.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            )
          else ...[
            // Auto roll-number generator banner
            GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Auto-Generate Roll Numbers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Regenerate roll numbers alphabetically based on student names.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.withValues(alpha: 0.2),
                      foregroundColor: Colors.amber[800],
                      elevation: 0,
                    ),
                    onPressed: () {
                      ref.read(academicStudentsProvider.notifier).autoGenerateRollNumbers(_dirClassId!, _dirSectionId!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Alphabetical Roll Numbers successfully assigned!')),
                      );
                    },
                    icon: const Icon(Icons.flash_on_rounded, size: 14),
                    label: const Text('Generate Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Student Directory List
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student List (${filteredStudents.length} Students)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                  const SizedBox(height: 12),
                  if (filteredStudents.isEmpty)
                    const Center(child: Text('No students currently assigned to this section.', style: TextStyle(fontSize: 11, color: Colors.grey)))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, idx) {
                        final s = filteredStudents[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBg : AppColors.lightBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                    child: Text(s.rollNumber.isNotEmpty ? s.rollNumber : '-', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text('Adm No: ${s.admissionNumber}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Section Transfer Dropdown Menu
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.secondary, size: 18),
                                    tooltip: 'Transfer Section',
                                    onSelected: (newSecId) {
                                      ref.read(academicStudentsProvider.notifier).transferSection(s.id, newSecId);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Student successfully transferred to new section!')),
                                      );
                                    },
                                    itemBuilder: (context) {
                                      return classSections
                                          .where((sec) => sec.id != s.sectionId)
                                          .map((sec) => PopupMenuItem(value: sec.id, child: Text('Move to Section ${sec.name}', style: const TextStyle(fontSize: 11))))
                                          .toList();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 6: PROMOTION WORKFLOW
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPromotionTab(bool isDark) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == _selectedBranchId).toList();
    final sections = ref.watch(academicSectionsProvider);
    final students = ref.watch(academicStudentsProvider).where((s) => s.branchId == _selectedBranchId).toList();

    final targetSections = sections.where((s) => s.classId == _promoToClassId).toList();
    final eligibleStudents = students.where((s) => s.classId == _promoFromClassId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'End-Of-Term Student Promotion Workflow',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Promote all students registered in a source class to the next academic grade within this branch.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 14),

            // Source Class
            DropdownButtonFormField<String>(
              initialValue: _promoFromClassId,
              decoration: const InputDecoration(labelText: 'Source Grade (From Class)', isDense: true),
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              items: classes.map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
              }).toList(),
              onChanged: (val) => setState(() => _promoFromClassId = val),
            ),
            const SizedBox(height: 12),

            // Target Class
            DropdownButtonFormField<String>(
              initialValue: _promoToClassId,
              decoration: const InputDecoration(labelText: 'Destination Grade (To Class)', isDense: true),
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              items: classes.map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _promoToClassId = val;
                  _promoToSectionId = null;
                });
              },
            ),
            const SizedBox(height: 12),

            // Target Default Section
            DropdownButtonFormField<String>(
              initialValue: _promoToSectionId,
              decoration: const InputDecoration(labelText: 'Default Allocation Section', isDense: true),
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              items: targetSections.map((s) {
                return DropdownMenuItem(value: s.id, child: Text('Section ${s.name}', style: const TextStyle(fontSize: 11)));
              }).toList(),
              onChanged: (val) => setState(() => _promoToSectionId = val),
            ),
            const SizedBox(height: 24),

            // Promotion Preview
            if (_promoFromClassId != null && eligibleStudents.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Found ${eligibleStudents.length} students eligible for promotion.',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  if (_promoFromClassId != null && _promoToClassId != null && _promoToSectionId != null) {
                    if (eligibleStudents.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No students found in the source class to promote!')),
                      );
                      return;
                    }
                    ref.read(academicStudentsProvider.notifier).promoteStudents(
                          branchId: _selectedBranchId!,
                          fromClassId: _promoFromClassId!,
                          toClassId: _promoToClassId!,
                          defaultToSectionId: _promoToSectionId!,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Promotion workflow completed successfully!')),
                    );
                    setState(() {
                      _promoFromClassId = null;
                      _promoToClassId = null;
                      _promoToSectionId = null;
                    });
                  }
                },
                icon: const Icon(Icons.upgrade_rounded, size: 18),
                label: const Text('Execute Bulk Class Promotion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 7: TIMETABLE SLOT CONFIGURATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildTimetableSlotsTab(bool isDark) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == _selectedBranchId).toList();
    final sections = ref.watch(academicSectionsProvider);
    final slots = ref.watch(timetableSlotsProvider).where((s) => s.branchId == _selectedBranchId).toList();

    final filteredSections = sections.where((s) => s.classId == _ttClassId).toList();
    final displayedSlots = slots.where((s) => s.classId == _ttClassId && (s.sectionId == 'ALL' || s.sectionId == _ttSectionId)).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 950;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildTimetableSlotsList(isDark, displayedSlots, classes, sections)),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: _buildTimetableSlotForm(isDark, classes, filteredSections)),
                  ],
                )
              : Column(
                  children: [
                    _buildTimetableSlotsList(isDark, displayedSlots, classes, sections),
                    const SizedBox(height: 16),
                    _buildTimetableSlotForm(isDark, classes, filteredSections),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTimetableSlotsList(
    bool isDark,
    List<TimetableSlotEntity> displayedSlots,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _ttClassId,
                  decoration: const InputDecoration(labelText: 'Filter Class', isDense: true),
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  items: classes.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _ttClassId = val;
                      _ttSectionId = 'ALL';
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _ttSectionId,
                  decoration: const InputDecoration(labelText: 'Filter Section scope', isDense: true),
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('All Sections', style: TextStyle(fontSize: 11))),
                    ...sections.where((s) => s.classId == _ttClassId).map((s) => DropdownMenuItem(value: s.id, child: Text('Section ${s.name}', style: const TextStyle(fontSize: 11)))),
                  ],
                  onChanged: (val) => setState(() => _ttSectionId = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Timetable Period Slots',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
          const SizedBox(height: 12),

          if (_ttClassId == null)
            const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('Select a class to view timetable slots.', style: TextStyle(fontSize: 12, color: Colors.grey))))
          else if (displayedSlots.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('No timetable slots configured for selection.', style: TextStyle(fontSize: 11, color: Colors.grey))))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedSlots.length,
              itemBuilder: (context, idx) {
                final s = displayedSlots[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${s.periodName} (${s.startTime} - ${s.endTime}) — ${s.dayOfWeek}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            Text('Subject: ${s.subjectName} | Teacher: ${s.teacherName}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 14),
                        onPressed: () {
                          ref.read(timetableSlotsProvider.notifier).removeSlot(s.id);
                        },
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

  Widget _buildTimetableSlotForm(
    bool isDark,
    List<ClassEntity> classes,
    List<SectionEntity> filteredSections,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Period Slot',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
          const SizedBox(height: 12),

          // Class link
          DropdownButtonFormField<String>(
            initialValue: _ttClassId,
            decoration: const InputDecoration(labelText: 'Select Class', isDense: true),
            style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            items: classes.map((c) {
              return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _ttClassId = val;
                _ttSectionId = 'ALL';
              });
            },
          ),
          const SizedBox(height: 8),

          // Section scope link
          DropdownButtonFormField<String>(
            initialValue: _ttSectionId,
            decoration: const InputDecoration(labelText: 'Select Section Scope', isDense: true),
            style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            items: [
              const DropdownMenuItem(value: 'ALL', child: Text('All Sections', style: TextStyle(fontSize: 11))),
              ...filteredSections.map((s) => DropdownMenuItem(value: s.id, child: Text('Section ${s.name}', style: const TextStyle(fontSize: 11)))),
            ],
            onChanged: (val) => setState(() => _ttSectionId = val),
          ),
          const SizedBox(height: 8),

          // Day of week
          DropdownButtonFormField<String>(
            initialValue: _ttDay,
            decoration: const InputDecoration(labelText: 'Day of Week', isDense: true),
            style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            items: const [
              DropdownMenuItem(value: 'Monday', child: Text('Monday', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(value: 'Tuesday', child: Text('Tuesday', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(value: 'Wednesday', child: Text('Wednesday', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(value: 'Thursday', child: Text('Thursday', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(value: 'Friday', child: Text('Friday', style: TextStyle(fontSize: 11))),
              DropdownMenuItem(value: 'Saturday', child: Text('Saturday', style: TextStyle(fontSize: 11))),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _ttDay = val);
            },
          ),
          const SizedBox(height: 8),

          // Period Name
          TextField(
            controller: _ttPeriodNameController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(labelText: 'Period Name (e.g. Period 1)', isDense: true),
          ),
          const SizedBox(height: 8),

          // Start & End Time
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ttStartTimeController,
                  style: const TextStyle(fontSize: 11),
                  decoration: const InputDecoration(labelText: 'Start Time (e.g. 08:30 AM)', isDense: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ttEndTimeController,
                  style: const TextStyle(fontSize: 11),
                  decoration: const InputDecoration(labelText: 'End Time (e.g. 09:15 AM)', isDense: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Subject Name
          TextField(
            controller: _ttSubjectController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(labelText: 'Subject Name', isDense: true),
          ),
          const SizedBox(height: 8),

          // Teacher Name
          TextField(
            controller: _ttTeacherController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(labelText: 'Teacher Name', isDense: true),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_ttClassId != null &&
                    _ttSectionId != null &&
                    _ttPeriodNameController.text.trim().isNotEmpty &&
                    _ttSubjectController.text.trim().isNotEmpty) {
                  ref.read(timetableSlotsProvider.notifier).addSlot(
                        branchId: _selectedBranchId!,
                        classId: _ttClassId!,
                        sectionId: _ttSectionId!,
                        dayOfWeek: _ttDay,
                        periodName: _ttPeriodNameController.text.trim(),
                        startTime: _ttStartTimeController.text.trim(),
                        endTime: _ttEndTimeController.text.trim(),
                        subjectName: _ttSubjectController.text.trim(),
                        teacherName: _ttTeacherController.text.trim(),
                      );
                  _ttPeriodNameController.clear();
                  _ttSubjectController.clear();
                  _ttTeacherController.clear();
                }
              },
              child: const Text('Add Period Slot', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 8: CLASS-WISE FEE PLAN ASSIGNMENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildClassFeePlansTab(bool isDark) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == _selectedBranchId).toList();
    final feePlans = ref.watch(classFeePlansProvider).where((f) => f.branchId == _selectedBranchId).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 950;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildClassFeePlansList(isDark, feePlans, classes)),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: _buildClassFeePlanForm(isDark, classes)),
                  ],
                )
              : Column(
                  children: [
                    _buildClassFeePlansList(isDark, feePlans, classes),
                    const SizedBox(height: 16),
                    _buildClassFeePlanForm(isDark, classes),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildClassFeePlansList(bool isDark, List<ClassFeePlanEntity> feePlans, List<ClassEntity> classes) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assigned Class Fee Plans',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
          const SizedBox(height: 12),
          if (feePlans.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No fee plans assigned to classes yet.', style: TextStyle(fontSize: 11, color: Colors.grey))),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: feePlans.length,
              itemBuilder: (context, idx) {
                final fp = feePlans[idx];
                final cls = classes.firstWhere((c) => c.id == fp.classId, orElse: () => ClassEntity(id: '', branchId: '', departmentId: '', name: 'Unknown', code: '', maxStudentsCapacity: 0));
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: AppColors.primary, size: 16),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${fp.feePlanName} (${cls.name})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              Text('Total Plan Amount: ₹${fp.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 14),
                        onPressed: () {
                          ref.read(classFeePlansProvider.notifier).removeFeePlan(fp.id);
                        },
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

  Widget _buildClassFeePlanForm(bool isDark, List<ClassEntity> classes) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assign Class Fee Plan',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _feeClassId,
            decoration: const InputDecoration(labelText: 'Select Class', isDense: true),
            style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            items: classes.map((c) {
              return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
            }).toList(),
            onChanged: (val) => setState(() => _feeClassId = val),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _feePlanNameController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(labelText: 'Fee Plan Label / Title', isDense: true),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _feeAmountController,
            style: const TextStyle(fontSize: 11),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Total Academic Year Fee Amount', isDense: true),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_feeClassId != null &&
                    _feePlanNameController.text.trim().isNotEmpty &&
                    _feeAmountController.text.trim().isNotEmpty) {
                  ref.read(classFeePlansProvider.notifier).assignFeePlan(
                        branchId: _selectedBranchId!,
                        classId: _feeClassId!,
                        feePlanName: _feePlanNameController.text.trim(),
                        totalAmount: double.tryParse(_feeAmountController.text.trim()) ?? 0.0,
                      );
                  _feePlanNameController.clear();
                  _feeAmountController.clear();
                }
              },
              child: const Text('Assign Fee Plan', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 9: CLASS-WISE EXAM SCHEDULE SETUP
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildExamSchedulesTab(bool isDark) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == _selectedBranchId).toList();
    final examSchedules = ref.watch(examSchedulesProvider).where((e) => e.branchId == _selectedBranchId).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 950;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildExamSchedulesList(isDark, examSchedules, classes)),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: _buildExamScheduleForm(isDark, classes)),
                  ],
                )
              : Column(
                  children: [
                    _buildExamSchedulesList(isDark, examSchedules, classes),
                    const SizedBox(height: 16),
                    _buildExamScheduleForm(isDark, classes),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildExamSchedulesList(bool isDark, List<ExamScheduleEntity> schedules, List<ClassEntity> classes) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduled Exams & Timetables',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
          const SizedBox(height: 12),
          if (schedules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No exams scheduled yet.', style: TextStyle(fontSize: 11, color: Colors.grey))),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              itemBuilder: (context, idx) {
                final s = schedules[idx];
                final cls = classes.firstWhere((c) => c.id == s.classId, orElse: () => ClassEntity(id: '', branchId: '', departmentId: '', name: 'Unknown', code: '', maxStudentsCapacity: 0));
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.percent_rounded, color: AppColors.primary, size: 16),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${s.examName} — ${cls.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              Text('Subject: ${s.subjectName} | Date: ${s.examDate}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                              Text('Time Slot: ${s.startTime} - ${s.endTime}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 14),
                        onPressed: () {
                          ref.read(examSchedulesProvider.notifier).removeExam(s.id);
                        },
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

  Widget _buildExamScheduleForm(bool isDark, List<ClassEntity> classes) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Class Exam',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _examClassId,
            decoration: const InputDecoration(labelText: 'Select Class', isDense: true),
            style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            items: classes.map((c) {
              return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
            }).toList(),
            onChanged: (val) => setState(() => _examClassId = val),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _examNameController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(labelText: 'Exam Name (e.g. Mid-Term Mock)', isDense: true),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _examSubjectController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(labelText: 'Subject Name', isDense: true),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _examDateController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', isDense: true),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _examStartController,
                  style: const TextStyle(fontSize: 11),
                  decoration: const InputDecoration(labelText: 'Start Time', isDense: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _examEndController,
                  style: const TextStyle(fontSize: 11),
                  decoration: const InputDecoration(labelText: 'End Time', isDense: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_examClassId != null &&
                    _examNameController.text.trim().isNotEmpty &&
                    _examSubjectController.text.trim().isNotEmpty) {
                  ref.read(examSchedulesProvider.notifier).scheduleExam(
                        branchId: _selectedBranchId!,
                        classId: _examClassId!,
                        examName: _examNameController.text.trim(),
                        subjectName: _examSubjectController.text.trim(),
                        examDate: _examDateController.text.trim(),
                        startTime: _examStartController.text.trim(),
                        endTime: _examEndController.text.trim(),
                      );
                  _examNameController.clear();
                  _examSubjectController.clear();
                }
              },
              child: const Text('Schedule Exam', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 10: ATTENDANCE REGISTER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildAttendanceRegisterTab(bool isDark) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == _selectedBranchId).toList();
    final sections = ref.watch(academicSectionsProvider);
    final students = ref.watch(academicStudentsProvider).where((s) => s.branchId == _selectedBranchId).toList();
    final attendanceRecords = ref.watch(attendanceRecordsProvider).where((r) => r.branchId == _selectedBranchId).toList();

    final classSections = sections.where((s) => s.classId == _attClassId).toList();
    final filteredStudents = students.where((s) => s.classId == _attClassId && s.sectionId == _attSectionId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _attClassId,
                    decoration: const InputDecoration(labelText: 'Class', isDense: true),
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: classes.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _attClassId = val;
                        _attSectionId = null;
                        _tempAttendanceMap.clear();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _attSectionId,
                    decoration: const InputDecoration(labelText: 'Section Scope', isDense: true),
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    items: classSections.map((s) {
                      return DropdownMenuItem(value: s.id, child: Text('Section ${s.name}', style: const TextStyle(fontSize: 11)));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _attSectionId = val;
                        _tempAttendanceMap.clear();
                        // Populate temp mapping from saved register if any
                        for (final s in filteredStudents) {
                          final saved = attendanceRecords.firstWhere(
                            (r) => r.studentId == s.id && r.date == _attDateController.text.trim(),
                            orElse: () => const AttendanceRecordEntity(id: '', branchId: '', studentId: '', date: '', status: 'Present'),
                          );
                          _tempAttendanceMap[s.id] = saved.status;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _attDateController,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', isDense: true),
                    onChanged: (val) {
                      setState(() {
                        _tempAttendanceMap.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_attClassId == null || _attSectionId == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('Select Class, Section and Date to open register.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            )
          else ...[
            // Attendance Roll Call list
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Roll Call Register (${filteredStudents.length} Students)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: () {
                          // Fill missing records with Present
                          for (final s in filteredStudents) {
                            _tempAttendanceMap.putIfAbsent(s.id, () => 'Present');
                          }
                          ref.read(attendanceRecordsProvider.notifier).saveAttendance(
                                branchId: _selectedBranchId!,
                                date: _attDateController.text.trim(),
                                studentStatusMap: Map<String, String>.from(_tempAttendanceMap),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Attendance Register successfully saved!')),
                          );
                        },
                        icon: const Icon(Icons.save_rounded, size: 14),
                        label: const Text('Save Register', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (filteredStudents.isEmpty)
                    const Center(child: Text('No students registered in this section.', style: TextStyle(fontSize: 11, color: Colors.grey)))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, idx) {
                        final s = filteredStudents[idx];
                        final currentStatus = _tempAttendanceMap[s.id] ?? 'Present';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBg : AppColors.lightBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text('Roll No: ${s.rollNumber.isNotEmpty ? s.rollNumber : "-"}  |  Adm: ${s.admissionNumber}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                ],
                              ),
                              Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('Present', style: TextStyle(fontSize: 10)),
                                    selected: currentStatus == 'Present',
                                    selectedColor: Colors.green.withValues(alpha: 0.2),
                                    labelStyle: TextStyle(color: currentStatus == 'Present' ? Colors.green : Colors.grey, fontWeight: FontWeight.bold),
                                    onSelected: (val) {
                                      if (val) {
                                        setState(() {
                                          _tempAttendanceMap[s.id] = 'Present';
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('Absent', style: TextStyle(fontSize: 10)),
                                    selected: currentStatus == 'Absent',
                                    selectedColor: Colors.red.withValues(alpha: 0.2),
                                    labelStyle: TextStyle(color: currentStatus == 'Absent' ? Colors.red : Colors.grey, fontWeight: FontWeight.bold),
                                    onSelected: (val) {
                                      if (val) {
                                        setState(() {
                                          _tempAttendanceMap[s.id] = 'Absent';
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 11: PARENT-TEACHER MEETING (PTM) SCHEDULER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildParentTeacherMeetingsTab(bool isDark) {
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == _selectedBranchId).toList();
    final sections = ref.watch(academicSectionsProvider);
    final meetings = ref.watch(parentTeacherMeetingsProvider).where((m) => m.branchId == _selectedBranchId).toList();

    final classSections = sections.where((s) => s.classId == _ptmClassId).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 950;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildPTMList(isDark, meetings, classes, sections)),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: _buildPTMForm(isDark, classes, classSections)),
                  ],
                )
              : Column(
                  children: [
                    _buildPTMList(isDark, meetings, classes, sections),
                    const SizedBox(height: 16),
                    _buildPTMForm(isDark, classes, classSections),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPTMList(
    bool isDark,
    List<ParentTeacherMeetingEntity> meetings,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduled Parent-Teacher Meetings',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
          const SizedBox(height: 12),
          if (meetings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No PTM sessions scheduled yet.', style: TextStyle(fontSize: 11, color: Colors.grey))),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meetings.length,
              itemBuilder: (context, idx) {
                final m = meetings[idx];
                final cls = classes.firstWhere((c) => c.id == m.classId, orElse: () => ClassEntity(id: '', branchId: '', departmentId: '', name: 'Unknown Class', code: '', maxStudentsCapacity: 0));
                final sec = sections.firstWhere((s) => s.id == m.sectionId, orElse: () => SectionEntity(id: '', classId: '', name: 'Unknown Section', roomNumber: '', classTeacher: '', maxStudentsCapacity: 0));
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 16),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              Text('Grade: ${cls.name} (Section ${sec.name})', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                              Text('Date: ${m.meetingDate} | ${m.startTime} - ${m.endTime}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 14),
                        onPressed: () {
                          ref.read(parentTeacherMeetingsProvider.notifier).removeMeeting(m.id);
                        },
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

  Widget _buildPTMForm(bool isDark, List<ClassEntity> classes, List<SectionEntity> classSections) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Section PTM Session',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _ptmClassId,
            decoration: const InputDecoration(labelText: 'Select Class', isDense: true),
            style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            items: classes.map((c) {
              return DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 11)));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _ptmClassId = val;
                _ptmSectionId = null;
              });
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _ptmSectionId,
            decoration: const InputDecoration(labelText: 'Select Target Section', isDense: true),
            style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            items: classSections.map((s) {
              return DropdownMenuItem(value: s.id, child: Text('Section ${s.name}', style: const TextStyle(fontSize: 11)));
            }).toList(),
            onChanged: (val) => setState(() => _ptmSectionId = val),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ptmTitleController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(labelText: 'Meeting Title (e.g. End of Term PTM)', isDense: true),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ptmDateController,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', isDense: true),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ptmStartController,
                  style: const TextStyle(fontSize: 11),
                  decoration: const InputDecoration(labelText: 'Start Time', isDense: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ptmEndController,
                  style: const TextStyle(fontSize: 11),
                  decoration: const InputDecoration(labelText: 'End Time', isDense: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_ptmClassId != null &&
                    _ptmSectionId != null &&
                    _ptmTitleController.text.trim().isNotEmpty) {
                  ref.read(parentTeacherMeetingsProvider.notifier).scheduleMeeting(
                        branchId: _selectedBranchId!,
                        classId: _ptmClassId!,
                        sectionId: _ptmSectionId!,
                        title: _ptmTitleController.text.trim(),
                        meetingDate: _ptmDateController.text.trim(),
                        startTime: _ptmStartController.text.trim(),
                        endTime: _ptmEndController.text.trim(),
                      );
                  _ptmTitleController.clear();
                }
              },
              child: const Text('Schedule Meeting', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}




import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../../academic/providers.dart';
import '../../../staff/providers.dart'
    as staff_prov; // Import staff pool for invigilator matching
import '../../../../shared/widgets/layout/responsive_flex.dart';

class ExamManagementPage extends ConsumerStatefulWidget {
  const ExamManagementPage({super.key});

  @override
  ConsumerState<ExamManagementPage> createState() => _ExamManagementPageState();
}

class _ExamManagementPageState extends ConsumerState<ExamManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
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
        // Tab Bar
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
                icon: Icon(Icons.assignment_rounded, size: 16),
                text: 'Exam Cycles',
              ),
              Tab(
                icon: Icon(Icons.calendar_month_rounded, size: 16),
                text: 'Timetable',
              ),
              Tab(
                icon: Icon(Icons.edit_note_rounded, size: 16),
                text: 'Marks Ledger',
              ),
              Tab(
                icon: Icon(Icons.analytics_rounded, size: 16),
                text: 'Result Analytics',
              ),
              Tab(
                icon: Icon(Icons.badge_rounded, size: 16),
                text: 'Admit Cards & Seating',
              ),
              Tab(
                icon: Icon(Icons.online_prediction_rounded, size: 16),
                text: 'Papers & Online Exams',
              ),
              Tab(
                icon: Icon(Icons.rate_review_rounded, size: 16),
                text: 'Recheck & Supplementary',
              ),
              Tab(
                icon: Icon(Icons.workspace_premium_rounded, size: 16),
                text: 'Certificates & CCE',
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ExamCyclesTab(branchId: activeBranchId),
              _ExamSchedulesTab(branchId: activeBranchId),
              _MarksEntryTab(branchId: activeBranchId),
              _ResultAnalyticsTab(branchId: activeBranchId),
              _AdmitCardsSeatingTab(branchId: activeBranchId),
              _PapersOnlineExamsTab(branchId: activeBranchId),
              _RecheckSupplementaryTab(branchId: activeBranchId),
              _CertificatesCCETab(branchId: activeBranchId),
            ],
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 1 — Exam Cycles (Types & Patterns)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ExamCyclesTab extends ConsumerStatefulWidget {
  final String branchId;
  const _ExamCyclesTab({required this.branchId});

  @override
  ConsumerState<_ExamCyclesTab> createState() => _ExamCyclesTabState();
}

class _ExamCyclesTabState extends ConsumerState<_ExamCyclesTab> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _patternNameCtrl = TextEditingController();
  final _theoryCtrl = TextEditingController(text: '70');
  final _practicalCtrl = TextEditingController(text: '30');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _patternNameCtrl.dispose();
    _theoryCtrl.dispose();
    _practicalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final examTypes = ref
        .watch(examTypesProvider)
        .where((t) => t.branchId == widget.branchId)
        .toList();
    final patterns = ref
        .watch(examPatternsProvider)
        .where((p) => p.branchId == widget.branchId)
        .toList();
    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRowColumn(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Exam Cycle',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _FormField(
                            controller: _nameCtrl,
                            label: 'Exam Name (e.g. Unit Test I)',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 8),
                          _FormField(
                            controller: _descCtrl,
                            label: 'Description',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_nameCtrl.text.trim().isEmpty) return;
                              ref
                                  .read(examTypesProvider.notifier)
                                  .addExamType(
                                    ExamTypeEntity(
                                      id: 'ET-${DateTime.now().millisecondsSinceEpoch}',
                                      branchId: widget.branchId,
                                      name: _nameCtrl.text.trim(),
                                      description: _descCtrl.text.trim(),
                                    ),
                                  );
                              _nameCtrl.clear();
                              _descCtrl.clear();
                              _showSnack(
                                context,
                                'Exam cycle assessment created!',
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 14),
                            label: const Text('Add Exam Cycle'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...examTypes.map(
                      (et) => Card(
                        child: ListTile(
                          title: Text(
                            et.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                          ),
                          subtitle: Text(
                            et.description,
                            style: TextStyle(color: textSec, fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configure Grading Split Patterns',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _FormField(
                            controller: _patternNameCtrl,
                            label: 'Pattern Name (e.g. Theory + Lab)',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _FormField(
                                  controller: _theoryCtrl,
                                  label: 'Theory %',
                                  isDark: isDark,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _FormField(
                                  controller: _practicalCtrl,
                                  label: 'Practical %',
                                  isDark: isDark,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              final name = _patternNameCtrl.text.trim();
                              final theory =
                                  double.tryParse(_theoryCtrl.text.trim()) ??
                                  0.0;
                              final practical =
                                  double.tryParse(_practicalCtrl.text.trim()) ??
                                  0.0;
                              if (name.isEmpty) return;
                              if ((theory + practical) != 100.0) {
                                _showSnack(
                                  context,
                                  'Error: Combined weight splits must equal 100%!',
                                );
                                return;
                              }
                              ref
                                  .read(examPatternsProvider.notifier)
                                  .addExamPattern(
                                    ExamPatternEntity(
                                      id: 'EP-${DateTime.now().millisecondsSinceEpoch}',
                                      branchId: widget.branchId,
                                      name: name,
                                      theoryWeight: theory,
                                      practicalWeight: practical,
                                      oralWeight: 0.0,
                                      projectWeight: 0.0,
                                    ),
                                  );
                              _patternNameCtrl.clear();
                              _showSnack(
                                context,
                                'Subject evaluation pattern registered!',
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 14),
                            label: const Text('Add Pattern Weight'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...patterns.map(
                      (p) => Card(
                        child: ListTile(
                          title: Text(
                            p.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                          ),
                          subtitle: Text(
                            'Theory: ${p.theoryWeight.toStringAsFixed(0)}% • Practical: ${p.practicalWeight.toStringAsFixed(0)}%',
                            style: TextStyle(color: textSec, fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 2 — Exam Timetable / Schedule Creation
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ExamSchedulesTab extends ConsumerStatefulWidget {
  final String branchId;
  const _ExamSchedulesTab({required this.branchId});

  @override
  ConsumerState<_ExamSchedulesTab> createState() => _ExamSchedulesTabState();
}

class _ExamSchedulesTabState extends ConsumerState<_ExamSchedulesTab> {
  String? _selectedExamTypeId;
  String? _selectedClassId;
  String? _selectedSubjectId;
  String? _selectedPatternId;

  final _startTimeCtrl = TextEditingController(text: '09:00 AM');
  final _endTimeCtrl = TextEditingController(text: '12:00 PM');
  final _roomCtrl = TextEditingController(text: 'Room 101');
  final _maxMarksCtrl = TextEditingController(text: '100');
  final _passMarksCtrl = TextEditingController(text: '35');

  @override
  void dispose() {
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _roomCtrl.dispose();
    _maxMarksCtrl.dispose();
    _passMarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final examTypes = ref
        .watch(examTypesProvider)
        .where((t) => t.branchId == widget.branchId)
        .toList();
    final classes = ref
        .watch(academicClassesProvider)
        .where((c) => c.branchId == widget.branchId)
        .toList();
    final subjectAssignments = ref
        .watch(subjectAssignmentsProvider)
        .where((s) => s.branchId == widget.branchId)
        .toList();
    final subjects = subjectAssignments
        .map((s) => s.subjectName)
        .toSet()
        .toList();
    final patterns = ref
        .watch(examPatternsProvider)
        .where((p) => p.branchId == widget.branchId)
        .toList();
    final schedules = ref
        .watch(branchExamSchedulesProvider)
        .where((s) => s.branchId == widget.branchId)
        .toList();

    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Exam Schedule Form
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Exam Timetable Entry',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (examTypes.isNotEmpty)
                      SizedBox(
                        width: 200,
                        child: _DropdownFilter(
                          label: 'Exam Assessment',
                          value: _selectedExamTypeId ?? examTypes.first.id,
                          items: examTypes.map((t) => t.id).toList(),
                          displayItems: examTypes.map((t) => t.name).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedExamTypeId = v),
                          isDark: isDark,
                        ),
                      ),
                    if (classes.isNotEmpty)
                      SizedBox(
                        width: 200,
                        child: _DropdownFilter(
                          label: 'Class/Grade',
                          value: _selectedClassId ?? classes.first.id,
                          items: classes.map((c) => c.id).toList(),
                          displayItems: classes.map((c) => c.name).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedClassId = v),
                          isDark: isDark,
                        ),
                      ),
                    if (subjects.isNotEmpty)
                      SizedBox(
                        width: 200,
                        child: _DropdownFilter(
                          label: 'Subject',
                          value: _selectedSubjectId ?? subjects.first,
                          items: subjects,
                          displayItems: subjects,
                          onChanged: (v) =>
                              setState(() => _selectedSubjectId = v),
                          isDark: isDark,
                        ),
                      ),
                    if (patterns.isNotEmpty)
                      SizedBox(
                        width: 200,
                        child: _DropdownFilter(
                          label: 'Grading Pattern',
                          value: _selectedPatternId ?? patterns.first.id,
                          items: patterns.map((p) => p.id).toList(),
                          displayItems: patterns.map((p) => p.name).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedPatternId = v),
                          isDark: isDark,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 550;

                    final startTimeField = _FormField(
                      controller: _startTimeCtrl,
                      label: 'Start Time',
                      isDark: isDark,
                    );

                    final endTimeField = _FormField(
                      controller: _endTimeCtrl,
                      label: 'End Time',
                      isDark: isDark,
                    );

                    final roomField = _FormField(
                      controller: _roomCtrl,
                      label: 'Room/Lab No.',
                      isDark: isDark,
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          startTimeField,
                          const SizedBox(height: 8),
                          endTimeField,
                          const SizedBox(height: 8),
                          roomField,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: startTimeField),
                        const SizedBox(width: 8),
                        Expanded(child: endTimeField),
                        const SizedBox(width: 8),
                        Expanded(child: roomField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 550;

                    final maxMarksField = _FormField(
                      controller: _maxMarksCtrl,
                      label: 'Max Marks',
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                    );

                    final passMarksField = _FormField(
                      controller: _passMarksCtrl,
                      label: 'Passing Marks',
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          maxMarksField,
                          const SizedBox(height: 8),
                          passMarksField,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: maxMarksField),
                        const SizedBox(width: 8),
                        Expanded(child: passMarksField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final etId =
                        _selectedExamTypeId ??
                        (examTypes.isNotEmpty ? examTypes.first.id : null);
                    final clId =
                        _selectedClassId ??
                        (classes.isNotEmpty ? classes.first.id : null);
                    final subName =
                        _selectedSubjectId ??
                        (subjects.isNotEmpty ? subjects.first : null);
                    final patId =
                        _selectedPatternId ??
                        (patterns.isNotEmpty ? patterns.first.id : null);

                    if (etId == null ||
                        clId == null ||
                        subName == null ||
                        patId == null) {
                      _showSnack(
                        context,
                        'Please ensure all parameters are configured!',
                      );
                      return;
                    }

                    final eType = examTypes.firstWhere((t) => t.id == etId);
                    final cl = classes.firstWhere((c) => c.id == clId);
                    final pat = patterns.firstWhere((p) => p.id == patId);

                    ref
                        .read(branchExamSchedulesProvider.notifier)
                        .addExamSchedule(
                          BranchExamScheduleEntity(
                            id: 'ES-${DateTime.now().millisecondsSinceEpoch}',
                            branchId: widget.branchId,
                            examTypeId: etId,
                            examTypeName: eType.name,
                            classId: clId,
                            className: cl.name,
                            subjectId: 'SUB-GEN',
                            subjectName: subName,
                            patternId: patId,
                            patternName: pat.name,
                            date: DateTime.now().add(const Duration(days: 10)),
                            startTime: _startTimeCtrl.text.trim(),
                            endTime: _endTimeCtrl.text.trim(),
                            maxMarks:
                                double.tryParse(_maxMarksCtrl.text.trim()) ??
                                100.0,
                            passingMarks:
                                double.tryParse(_passMarksCtrl.text.trim()) ??
                                35.0,
                            roomNo: _roomCtrl.text.trim(),
                          ),
                        );

                    _showSnack(
                      context,
                      'Exam Timetable entry successfully added!',
                    );
                  },
                  icon: const Icon(Icons.calendar_month_rounded, size: 16),
                  label: const Text('Add to Exam Timetable'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Active Branch Exam Timetable schedules',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textPri,
            ),
          ),
          const SizedBox(height: 10),
          if (schedules.isEmpty)
            Text(
              'No scheduled exam timetables logged.',
              style: TextStyle(color: textSec),
            )
          else
            ...schedules.map(
              (sch) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${sch.subjectName} (${sch.className})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textPri,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${sch.maxMarks.toStringAsFixed(0)} Max',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Cycle: ${sch.examTypeName}\nGrading: ${sch.patternName}\nRoom: ${sch.roomNo} • Pass Marks: ${sch.passingMarks.toStringAsFixed(0)}',
                          style: TextStyle(color: textSec, fontSize: 11),
                        ),
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date: ${sch.date.day}/${sch.date.month}/${sch.date.year}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                          ),
                          Text(
                            'Time: ${sch.startTime} - ${sch.endTime}',
                            style: TextStyle(fontSize: 11, color: textSec),
                          ),
                        ],
                      ),
                    ],
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
// TAB 3 — Marks Entry & Moderation Ledger
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _MarksEntryTab extends ConsumerStatefulWidget {
  final String branchId;
  const _MarksEntryTab({required this.branchId});

  @override
  ConsumerState<_MarksEntryTab> createState() => _MarksEntryTabState();
}

class _MarksEntryTabState extends ConsumerState<_MarksEntryTab> {
  String? _selectedScheduleId;
  final _modScaleCtrl = TextEditingController(text: '5.0');

  @override
  void dispose() {
    _modScaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final schedules = ref
        .watch(branchExamSchedulesProvider)
        .where((s) => s.branchId == widget.branchId)
        .toList();
    final students = ref
        .watch(academicStudentsProvider)
        .where((s) => s.branchId == widget.branchId)
        .toList();
    final marks = ref
        .watch(studentExamMarksProvider)
        .where((m) => m.branchId == widget.branchId)
        .toList();

    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final activeScheduleId =
        _selectedScheduleId ??
        (schedules.isNotEmpty ? schedules.first.id : null);
    final activeSchedule = schedules.firstWhere(
      (s) => s.id == activeScheduleId,
      orElse: () => schedules.first,
    );

    final List<StudentExamMarksEntity> activeMarks = [];
    if (activeScheduleId != null) {
      for (final student in students) {
        final existing = marks.firstWhere(
          (m) => m.scheduleId == activeScheduleId && m.studentId == student.id,
          orElse: () => StudentExamMarksEntity(
            id: 'SM-${DateTime.now().millisecondsSinceEpoch}-${student.id}',
            branchId: widget.branchId,
            scheduleId: activeScheduleId,
            studentId: student.id,
            studentName: student.name,
            theoryMarks: 0.0,
            practicalMarks: 0.0,
            oralMarks: 0.0,
            projectMarks: 0.0,
            totalMarks: 0.0,
            moderatedMarks: 0.0,
            isApproved: false,
            grade: 'F',
            status: 'Failed',
            remarks: 'Default entry',
          ),
        );
        activeMarks.add(existing);
      }
    }

    final isAllApproved =
        activeMarks.isNotEmpty && activeMarks.every((m) => m.isApproved);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (schedules.isNotEmpty)
            _DropdownFilter(
              label: 'Select Timetable Entry',
              value: activeScheduleId ?? schedules.first.id,
              items: schedules.map((s) => s.id).toList(),
              displayItems: schedules
                  .map(
                    (s) =>
                        '${s.subjectName} (${s.className}) - ${s.examTypeName}',
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedScheduleId = v),
              isDark: isDark,
            ),
          const SizedBox(height: 16),

          if (activeScheduleId == null)
            Text(
              'Configure a timetable first to enter student marks.',
              style: TextStyle(color: textSec),
            )
          else ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions & Control Panel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isAllApproved
                            ? null
                            : () {
                                // Simulated Excel Bulk Marks import
                                final List<StudentExamMarksEntity> imported =
                                    [];
                                final randomMarks = [
                                  92.0,
                                  84.0,
                                  76.0,
                                  68.0,
                                  42.0,
                                  28.0,
                                ];
                                int index = 0;
                                for (final m in activeMarks) {
                                  final score =
                                      randomMarks[index % randomMarks.length];
                                  final isPassed =
                                      score >= activeSchedule.passingMarks;
                                  imported.add(
                                    m.copyWith(
                                      theoryMarks: score,
                                      totalMarks: score,
                                      moderatedMarks: score,
                                      grade: score >= 90
                                          ? 'A+'
                                          : (score >= 80
                                                ? 'A'
                                                : (score >= 60 ? 'B' : 'C')),
                                      status: isPassed ? 'Passed' : 'Failed',
                                      remarks:
                                          'Bulk Excel uploaded successfully',
                                    ),
                                  );
                                  index++;
                                }
                                ref
                                    .read(studentExamMarksProvider.notifier)
                                    .importBulkMarks(imported);
                                _showSnack(
                                  context,
                                  'Excel bulk marks imported!',
                                );
                              },
                        icon: const Icon(Icons.upload_file_rounded, size: 14),
                        label: const Text('Simulate Excel Marks Import'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                      ),
                      if (!isAllApproved) ...[
                        SizedBox(
                          width: 250,
                          child: Row(
                            children: [
                              Expanded(
                                child: _FormField(
                                  controller: _modScaleCtrl,
                                  label: 'Moderation Offset',
                                  isDark: isDark,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  final offset =
                                      double.tryParse(
                                        _modScaleCtrl.text.trim(),
                                      ) ??
                                      0.0;
                                  ref
                                      .read(studentExamMarksProvider.notifier)
                                      .applyModeration(
                                        activeScheduleId,
                                        offset,
                                      );
                                  _showSnack(
                                    context,
                                    'Moderation scaling factor applied to all unapproved student scores!',
                                  );
                                },
                                child: const Text('Apply Moderation'),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(studentExamMarksProvider.notifier)
                                .approveMarks(activeScheduleId);
                            _showSnack(
                              context,
                              'Timetable marks approved & locked for reports!',
                            );
                          },
                          icon: const Icon(Icons.lock_rounded, size: 14),
                          label: const Text('Approve & Lock Marks'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Student Score Sheet Ledger',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
            const SizedBox(height: 10),
            ...activeMarks.map(
              (m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              m.studentName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: textPri,
                              ),
                            ),
                            if (m.isApproved)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Approved',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Draft',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          'ID: ${m.studentId} • Status: ${m.status}',
                          style: TextStyle(color: textSec, fontSize: 11),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Total: ${m.totalMarks.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: textPri,
                              ),
                            ),
                            Text(
                              'Moderated: ${m.moderatedMarks.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 4 — Result Analytics & Comparison
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ResultAnalyticsTab extends ConsumerWidget {
  final String branchId;
  const _ResultAnalyticsTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final marks = ref
        .watch(studentExamMarksProvider)
        .where((m) => m.branchId == branchId)
        .toList();
    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final double classAverage = marks.isEmpty
        ? 0.0
        : (marks.fold(0.0, (a, b) => a + b.moderatedMarks) / marks.length);
    final double passPercent = marks.isEmpty
        ? 0.0
        : (marks.where((m) => m.status == 'Passed').length / marks.length) *
              100.0;

    final sorted = List<StudentExamMarksEntity>.from(marks);
    sorted.sort((a, b) => b.moderatedMarks.compareTo(a.moderatedMarks));
    final toppers = sorted.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  child: Column(
                    children: [
                      Text(
                        'Class Average Score',
                        style: TextStyle(color: textSec, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${classAverage.toStringAsFixed(1)} / 100',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  child: Column(
                    children: [
                      Text(
                        'Passing Rate',
                        style: TextStyle(color: textSec, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${passPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Graphical Bar chart simulation
          Text(
            'Subject Average Performance Analytics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textPri,
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(
              children: [
                _buildAnalysisProgressBar(
                  'Mathematics (Avg: 72)',
                  0.72,
                  AppColors.secondary,
                  isDark,
                ),
                _buildAnalysisProgressBar(
                  'Science (Avg: 65)',
                  0.65,
                  AppColors.primary,
                  isDark,
                ),
                _buildAnalysisProgressBar(
                  'English Literature (Avg: 81)',
                  0.81,
                  AppColors.warning,
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Toppers List
          Text(
            'Branch Topper List 🏆',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textPri,
            ),
          ),
          const SizedBox(height: 10),
          ...toppers.map(
            (t) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                title: Text(
                  t.studentName,
                  style: TextStyle(fontWeight: FontWeight.bold, color: textPri),
                ),
                subtitle: Text(
                  'ID: ${t.studentId} • Status: ${t.status}',
                  style: TextStyle(color: textSec, fontSize: 11),
                ),
                trailing: Text(
                  '${t.moderatedMarks.toStringAsFixed(0)} Marks',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Organization Wide Comparison
          Text(
            'Organization-level Consolidated exam comparison',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textPri,
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(
              children: [
                _buildAnalysisProgressBar(
                  'Delhi Branch (BR-001) - Avg: 76.5%',
                  0.765,
                  AppColors.secondary,
                  isDark,
                ),
                _buildAnalysisProgressBar(
                  'Bangalore Branch (BR-002) - Avg: 78.1%',
                  0.781,
                  AppColors.primary,
                  isDark,
                ),
                _buildAnalysisProgressBar(
                  'Mumbai Branch (BR-003) - Avg: 69.4%',
                  0.694,
                  AppColors.error,
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisProgressBar(
    String label,
    double val,
    Color color,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(val * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: val,
              minHeight: 8,
              color: color,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 5 — Admit Cards & Seating Configurations
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AdmitCardsSeatingTab extends ConsumerStatefulWidget {
  final String branchId;
  const _AdmitCardsSeatingTab({required this.branchId});

  @override
  ConsumerState<_AdmitCardsSeatingTab> createState() =>
      _AdmitCardsSeatingTabState();
}

class _AdmitCardsSeatingTabState extends ConsumerState<_AdmitCardsSeatingTab> {
  String? _selectedAdmitStudentId;
  String? _selectedSeatingScheduleId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final students = ref
        .watch(academicStudentsProvider)
        .where((s) => s.branchId == widget.branchId)
        .toList();
    final staff = ref
        .watch(staff_prov.staffProvider)
        .where((st) => st.branchId == widget.branchId)
        .toList();
    final schedules = ref
        .watch(branchExamSchedulesProvider)
        .where((s) => s.branchId == widget.branchId)
        .toList();
    final seating = ref
        .watch(seatingArrangementsProvider)
        .where((s) => s.branchId == widget.branchId)
        .toList();

    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final activeStudentId =
        _selectedAdmitStudentId ??
        (students.isNotEmpty ? students.first.id : null);
    final activeStudent = students.firstWhere(
      (s) => s.id == activeStudentId,
      orElse: () => students.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admit card section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admit Card / Hall Ticket with Branch Header',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textPri,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (students.isNotEmpty) ...[
                      _DropdownFilter(
                        label: 'Select Student',
                        value: activeStudentId ?? students.first.id,
                        items: students.map((s) => s.id).toList(),
                        displayItems: students.map((s) => s.name).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedAdmitStudentId = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'BRANCH ID: ${widget.branchId} • ADMIT CARD',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Divider(color: Colors.black),
                            Text(
                              'Name: ${activeStudent.name}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Roll Number: ${activeStudent.rollNumber}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'Class: Grade 10 - A',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                              ),
                            ),
                            const Divider(color: Colors.black),
                            const Text(
                              'Authorized Exam Invigilator Sign',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showSnack(
                          context,
                          'Hall ticket printed successfully!',
                        ),
                        icon: const Icon(Icons.print_rounded, size: 14),
                        label: const Text('Print Hall Ticket'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Seating configuration section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exam Seating & Invigilator Generation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textPri,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (schedules.isNotEmpty) ...[
                      _DropdownFilter(
                        label: 'Select Exam Schedule',
                        value: _selectedSeatingScheduleId ?? schedules.first.id,
                        items: schedules.map((s) => s.id).toList(),
                        displayItems: schedules
                            .map((s) => '${s.subjectName} (${s.className})')
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedSeatingScheduleId = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Generate arrangement
                          final activeSchId =
                              _selectedSeatingScheduleId ?? schedules.first.id;
                          final List<SeatingArrangementEntity> generatedList =
                              [];
                          int desk = 1;
                          for (final student in students) {
                            final staffName = staff.isNotEmpty
                                ? staff[desk % staff.length].name
                                : 'Mr. Harish Sen';
                            generatedList.add(
                              SeatingArrangementEntity(
                                id: 'SEAT-${DateTime.now().millisecondsSinceEpoch}-${student.id}',
                                branchId: widget.branchId,
                                scheduleId: activeSchId,
                                studentId: student.id,
                                studentName: student.name,
                                roomNo: 'Room ${300 + desk} (Block A)',
                                deskNo: 'Desk-${10 + desk}',
                                invigilatorName: staffName,
                              ),
                            );
                            desk++;
                          }
                          ref
                              .read(seatingArrangementsProvider.notifier)
                              .generateArrangement(generatedList);
                          _showSnack(
                            context,
                            'Exam Seating desk arrangements generated with invigilator assignments!',
                          );
                        },
                        icon: const Icon(
                          Icons.settings_suggest_rounded,
                          size: 14,
                        ),
                        label: const Text('Auto-Generate Seating arrangements'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ...seating.map(
                      (seat) => Card(
                        child: ListTile(
                          title: Text(
                            '${seat.studentName} - Room: ${seat.roomNo} (Desk: ${seat.deskNo})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPri,
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Text(
                            'Invigilator: ${seat.invigilatorName}',
                            style: TextStyle(color: textSec, fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 6 — Papers & Online Exams Configs
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _PapersOnlineExamsTab extends ConsumerStatefulWidget {
  final String branchId;
  const _PapersOnlineExamsTab({required this.branchId});

  @override
  ConsumerState<_PapersOnlineExamsTab> createState() =>
      _PapersOnlineExamsTabState();
}

class _PapersOnlineExamsTabState extends ConsumerState<_PapersOnlineExamsTab> {
  final _paperTitleCtrl = TextEditingController();
  final _paperSubjectCtrl = TextEditingController(text: 'Mathematics');

  final _onlineTitleCtrl = TextEditingController();
  final _onlineSubjectCtrl = TextEditingController(text: 'Science');
  final _onlineDurationCtrl = TextEditingController(text: '60');
  final _onlineQuestionsCtrl = TextEditingController(text: '30');

  @override
  void dispose() {
    _paperTitleCtrl.dispose();
    _paperSubjectCtrl.dispose();
    _onlineTitleCtrl.dispose();
    _onlineSubjectCtrl.dispose();
    _onlineDurationCtrl.dispose();
    _onlineQuestionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final papers = ref
        .watch(questionPapersProvider)
        .where((p) => p.branchId == widget.branchId)
        .toList();
    final onlineExams = ref
        .watch(onlineExamConfigsProvider)
        .where((o) => o.branchId == widget.branchId)
        .toList();

    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question paper uploads
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question Paper Repository',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _FormField(
                            controller: _paperTitleCtrl,
                            label: 'Paper Title (e.g. Unit Test I)',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 8),
                          _FormField(
                            controller: _paperSubjectCtrl,
                            label: 'Subject',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_paperTitleCtrl.text.trim().isEmpty) return;
                              ref
                                  .read(questionPapersProvider.notifier)
                                  .uploadPaper(
                                    QuestionPaperEntity(
                                      id: 'QP-${DateTime.now().millisecondsSinceEpoch}',
                                      branchId: widget.branchId,
                                      title: _paperTitleCtrl.text.trim(),
                                      subjectName: _paperSubjectCtrl.text
                                          .trim(),
                                      status: 'Draft',
                                      uploadedBy: 'Mrs. Kavita Verma',
                                    ),
                                  );
                              _paperTitleCtrl.clear();
                              _showSnack(
                                context,
                                'Draft Question Paper uploaded!',
                              );
                            },
                            icon: const Icon(
                              Icons.upload_file_rounded,
                              size: 14,
                            ),
                            label: const Text('Upload Paper Draft'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...papers.map(
                      (p) => Card(
                        child: ListTile(
                          title: Text(
                            p.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPri,
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Text(
                            'Subject: ${p.subjectName} • Status: ${p.status}',
                            style: TextStyle(color: textSec, fontSize: 11),
                          ),
                          trailing: p.status == 'Draft'
                              ? OutlinedButton(
                                  onPressed: () {
                                    ref
                                        .read(questionPapersProvider.notifier)
                                        .approvePaper(p.id);
                                    _showSnack(
                                      context,
                                      'Question paper approved and locked!',
                                    );
                                  },
                                  child: const Text(
                                    'Approve',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                )
                              : const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                  size: 18,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Online exams configurator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Online Exam Integrations',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _FormField(
                            controller: _onlineTitleCtrl,
                            label: 'Exam Title (e.g. Algebra Quiz)',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 8),
                          _FormField(
                            controller: _onlineSubjectCtrl,
                            label: 'Subject',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _FormField(
                                  controller: _onlineDurationCtrl,
                                  label: 'Duration (Mins)',
                                  isDark: isDark,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _FormField(
                                  controller: _onlineQuestionsCtrl,
                                  label: 'Questions',
                                  isDark: isDark,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_onlineTitleCtrl.text.trim().isEmpty) return;
                              ref
                                  .read(onlineExamConfigsProvider.notifier)
                                  .addOnlineExam(
                                    OnlineExamConfigEntity(
                                      id: 'ON-${DateTime.now().millisecondsSinceEpoch}',
                                      branchId: widget.branchId,
                                      title: _onlineTitleCtrl.text.trim(),
                                      subjectName: _onlineSubjectCtrl.text
                                          .trim(),
                                      durationMinutes:
                                          int.tryParse(
                                            _onlineDurationCtrl.text.trim(),
                                          ) ??
                                          60,
                                      totalQuestions:
                                          int.tryParse(
                                            _onlineQuestionsCtrl.text.trim(),
                                          ) ??
                                          30,
                                      isActive: true,
                                    ),
                                  );
                              _onlineTitleCtrl.clear();
                              _showSnack(
                                context,
                                'Online exam configuration published live!',
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 14),
                            label: const Text('Publish Online exam'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...onlineExams.map(
                      (o) => Card(
                        child: ListTile(
                          title: Text(
                            o.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPri,
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Text(
                            'Subject: ${o.subjectName} • Duration: ${o.durationMinutes} mins • Questions: ${o.totalQuestions}',
                            style: TextStyle(color: textSec, fontSize: 11),
                          ),
                          trailing: Switch(
                            value: o.isActive,
                            onChanged: (val) {
                              ref
                                  .read(onlineExamConfigsProvider.notifier)
                                  .toggleStatus(o.id);
                              _showSnack(
                                context,
                                'Online Exam active status changed.',
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 7 — Recheck & Supplementary Exams
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _RecheckSupplementaryTab extends ConsumerStatefulWidget {
  final String branchId;
  const _RecheckSupplementaryTab({required this.branchId});

  @override
  ConsumerState<_RecheckSupplementaryTab> createState() =>
      _RecheckSupplementaryTabState();
}

class _RecheckSupplementaryTabState
    extends ConsumerState<_RecheckSupplementaryTab> {
  final _suplStudentNameCtrl = TextEditingController();
  final _suplSubjectCtrl = TextEditingController(text: 'Mathematics');

  @override
  void dispose() {
    _suplStudentNameCtrl.dispose();
    _suplSubjectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requests = ref
        .watch(recheckRequestsProvider)
        .where((r) => r.branchId == widget.branchId)
        .toList();
    final supplementary = ref
        .watch(supplementaryExamsProvider)
        .where((s) => s.branchId == widget.branchId)
        .toList();

    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rechecking Requests Ledger
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rechecking & Re-evaluation Requests Registry',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textPri,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...requests.map(
                      (req) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    req.studentName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textPri,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: req.status == 'Pending'
                                          ? AppColors.warning.withValues(alpha: 0.12)
                                          : Colors.green.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      req.status,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: req.status == 'Pending'
                                            ? AppColors.warning
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Subject: ${req.subjectName} • Type: ${req.requestType}',
                                style: TextStyle(color: textSec, fontSize: 11),
                              ),
                              Text(
                                'Reason: ${req.reason}',
                                style: TextStyle(
                                  color: textSec,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              if (req.status == 'Pending') ...[
                                const Divider(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        ref
                                            .read(
                                              recheckRequestsProvider.notifier,
                                            )
                                            .updateStatus(req.id, 'Rejected');
                                        _showSnack(
                                          context,
                                          'Rechecking request rejected',
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                      ),
                                      child: const Text(
                                        'Reject',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        ref
                                            .read(
                                              recheckRequestsProvider.notifier,
                                            )
                                            .updateStatus(req.id, 'Approved');
                                        // Update student marks
                                        ref
                                            .read(
                                              studentExamMarksProvider.notifier,
                                            )
                                            .enterMarks(
                                              StudentExamMarksEntity(
                                                id: req.marksId,
                                                branchId: widget.branchId,
                                                scheduleId: 'ES-001',
                                                studentId: 'STU-002',
                                                studentName: 'Bhumika Gowda',
                                                theoryMarks: 62.0,
                                                practicalMarks: 0.0,
                                                oralMarks: 0.0,
                                                projectMarks: 0.0,
                                                totalMarks: 62.0,
                                                moderatedMarks: 62.0,
                                                isApproved: true,
                                                grade: 'B',
                                                status: 'Passed',
                                                remarks:
                                                    'Re-evaluation result updated successfully',
                                              ),
                                            );
                                        _showSnack(
                                          context,
                                          'Request approved! Moderated marks updated in Ledger.',
                                        );
                                      },
                                      child: const Text(
                                        'Approve & Revise Marks',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Supplementary Exam bookings
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Book Supplementary Compartment Exam',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _FormField(
                            controller: _suplStudentNameCtrl,
                            label: 'Student Name',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 8),
                          _FormField(
                            controller: _suplSubjectCtrl,
                            label: 'Failed Subject Name',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_suplStudentNameCtrl.text.trim().isEmpty) {
                                return;
                              }
                              ref
                                  .read(supplementaryExamsProvider.notifier)
                                  .addSupplementary(
                                    SupplementaryExamEntity(
                                      id: 'SUP-${DateTime.now().millisecondsSinceEpoch}',
                                      branchId: widget.branchId,
                                      studentId: 'STU-SUP',
                                      studentName: _suplStudentNameCtrl.text
                                          .trim(),
                                      subjectName: _suplSubjectCtrl.text.trim(),
                                      examDate: DateTime.now().add(
                                        const Duration(days: 15),
                                      ),
                                      status: 'Scheduled',
                                    ),
                                  );
                              _suplStudentNameCtrl.clear();
                              _showSnack(
                                context,
                                'Supplementary compart exam successfully scheduled!',
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 14),
                            label: const Text('Book Supplementary Exam'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...supplementary.map(
                      (sup) => Card(
                        child: ListTile(
                          title: Text(
                            sup.studentName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPri,
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Text(
                            'Subject: ${sup.subjectName} • Date: ${sup.examDate.day}/${sup.examDate.month}',
                            style: TextStyle(color: textSec, fontSize: 11),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              sup.status,
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 8 — Certificates, Marksheets & CCE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _CertificatesCCETab extends ConsumerStatefulWidget {
  final String branchId;
  const _CertificatesCCETab({required this.branchId});

  @override
  ConsumerState<_CertificatesCCETab> createState() =>
      _CertificatesCCETabState();
}

class _CertificatesCCETabState extends ConsumerState<_CertificatesCCETab> {
  String? _selectedCertStudentId;
  String _certType = 'Consolidated Marksheet';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final students = ref
        .watch(academicStudentsProvider)
        .where((s) => s.branchId == widget.branchId)
        .toList();
    final certificateRequests = ref
        .watch(certificateRequestsProvider)
        .where((c) => c.branchId == widget.branchId)
        .toList();

    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Generate certificate form
              Expanded(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate Official Certificates & marksheets',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textPri,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (students.isNotEmpty) ...[
                        _DropdownFilter(
                          label: 'Select Student',
                          value: _selectedCertStudentId ?? students.first.id,
                          items: students.map((s) => s.id).toList(),
                          displayItems: students.map((s) => s.name).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCertStudentId = v),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _DropdownFilter(
                          label: 'Certificate Type',
                          value: _certType,
                          items: const [
                            'Consolidated Marksheet',
                            'Migration Certificate',
                            'CCE Report',
                          ],
                          displayItems: const [
                            'Consolidated Marksheet (All Terms)',
                            'Migration Certificate',
                            'CCE Comprehensive Report Card',
                          ],
                          onChanged: (v) => setState(() => _certType = v),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            final stuId =
                                _selectedCertStudentId ?? students.first.id;
                            final student = students.firstWhere(
                              (s) => s.id == stuId,
                            );
                            ref
                                .read(certificateRequestsProvider.notifier)
                                .addRequest(
                                  CertificateRequestEntity(
                                    id: 'CERT-${DateTime.now().millisecondsSinceEpoch}',
                                    branchId: widget.branchId,
                                    studentId: stuId,
                                    studentName: student.name,
                                    type: _certType,
                                    dateGenerated: DateTime.now(),
                                    status: 'Generated',
                                  ),
                                );
                            _showSnack(
                              context,
                              '$_certType generated successfully and saved to student records database.',
                            );
                          },
                          icon: const Icon(
                            Icons.workspace_premium_rounded,
                            size: 14,
                          ),
                          label: const Text('Generate & Sign Document'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Generated registry
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official branch Generated Registry',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textPri,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...certificateRequests.map(
                      (cert) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: GlassCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.workspace_premium_rounded,
                              color: AppColors.secondary,
                            ),
                            title: Text(
                              cert.studentName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textPri,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              '${cert.type}\nGenerated: ${cert.dateGenerated.day}/${cert.dateGenerated.month}/${cert.dateGenerated.year}',
                              style: TextStyle(color: textSec, fontSize: 11),
                            ),
                            trailing: cert.status == 'Generated'
                                ? OutlinedButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                            certificateRequestsProvider
                                                .notifier,
                                          )
                                          .updateStatus(cert.id, 'Shared');
                                      _showSnack(
                                        context,
                                        '${cert.type} digitally shared with parent WhatsApp / email dashboard portal.',
                                      );
                                    },
                                    child: const Text(
                                      'Share Digitally',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Shared',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UTILITIES & SHARED WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
    final selectedValue = selectedIndex != -1
        ? value
        : (items.isNotEmpty ? items.first : '');

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
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
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
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
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

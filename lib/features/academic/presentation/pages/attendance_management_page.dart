import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../providers.dart'; // Academic providers
import '../../../staff/providers.dart' as staff_prov; // Staff providers
// import '../../../../shared/widgets/layout/responsive_flex.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Attendance Management Page (Branch-Scoped)
/// 6 tabs: Student Attendance, Staff Attendance,
/// Reports, Biometric Devices, Configuration, Corrections
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AttendanceManagementPage extends ConsumerStatefulWidget {
  const AttendanceManagementPage({super.key});

  @override
  ConsumerState<AttendanceManagementPage> createState() =>
      _AttendanceManagementPageState();
}

class _AttendanceManagementPageState
    extends ConsumerState<AttendanceManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Student Attendance tab state
  DateTime _selectedStudentDate = DateTime.now();
  String _selectedClassId = 'CLS-001';
  String _selectedSectionId = 'SEC-A-001';
  String _selectedPeriod = 'All Day';

  // Staff Attendance tab state
  DateTime _selectedStaffDate = DateTime.now();

  // Reports tab state
  String _reportClassFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
                icon: Icon(Icons.person_pin_circle_rounded, size: 16),
                text: 'Student Attendance',
              ),
              Tab(
                icon: Icon(Icons.badge_rounded, size: 16),
                text: 'Staff Attendance',
              ),
              Tab(
                icon: Icon(Icons.bar_chart_rounded, size: 16),
                text: 'Reports & Analytics',
              ),
              Tab(
                icon: Icon(Icons.fingerprint_rounded, size: 16),
                text: 'Biometric Devices',
              ),
              Tab(
                icon: Icon(Icons.settings_rounded, size: 16),
                text: 'Configuration',
              ),
              Tab(
                icon: Icon(Icons.rule_folder_rounded, size: 16),
                text: 'Corrections Workflow',
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
              _StudentAttendanceTab(
                branchId: activeBranchId,
                selectedDate: _selectedStudentDate,
                selectedClassId: _selectedClassId,
                selectedSectionId: _selectedSectionId,
                selectedPeriod: _selectedPeriod,
                onDateChanged: (d) => setState(() => _selectedStudentDate = d),
                onClassChanged: (c) => setState(() => _selectedClassId = c),
                onSectionChanged: (s) => setState(() => _selectedSectionId = s),
                onPeriodChanged: (p) => setState(() => _selectedPeriod = p),
              ),
              _StaffAttendanceTab(
                branchId: activeBranchId,
                selectedDate: _selectedStaffDate,
                onDateChanged: (d) => setState(() => _selectedStaffDate = d),
              ),
              _AttendanceReportsTab(
                branchId: activeBranchId,
                classFilter: _reportClassFilter,
                onClassFilterChanged: (v) =>
                    setState(() => _reportClassFilter = v),
              ),
              _BiometricDevicesTab(branchId: activeBranchId),
              _AttendanceConfigTab(branchId: activeBranchId),
              _CorrectionsWorkflowTab(branchId: activeBranchId),
            ],
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 1 — Daily Student Attendance
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _StudentAttendanceTab extends ConsumerWidget {
  final String branchId;
  final DateTime selectedDate;
  final String selectedClassId;
  final String selectedSectionId;
  final String selectedPeriod;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onClassChanged;
  final ValueChanged<String> onSectionChanged;
  final ValueChanged<String> onPeriodChanged;

  const _StudentAttendanceTab({
    required this.branchId,
    required this.selectedDate,
    required this.selectedClassId,
    required this.selectedSectionId,
    required this.selectedPeriod,
    required this.onDateChanged,
    required this.onClassChanged,
    required this.onSectionChanged,
    required this.onPeriodChanged,
  });

  int _minutesFromMidnight(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final parts = clean.split(' ');
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);
      final isPm = parts[1] == 'PM';
      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return hour * 60 + minute;
    } catch (_) {
      return 0;
    }
  }

  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return 'Sunday';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final students = ref.watch(academicStudentsProvider);
    final attendance = ref.watch(studentAttendanceProvider);
    final studentLeaves = ref.watch(studentLeavesProvider);
    final timetableSlots = ref.watch(timetableSlotsProvider);

    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final branchRoster = students
        .where(
          (s) =>
              s.branchId == branchId &&
              s.classId == selectedClassId &&
              s.sectionId == selectedSectionId,
        )
        .toList();

    // Filter attendance for current selection
    final dayRecords = attendance
        .where(
          (r) =>
              r.branchId == branchId &&
              r.date.year == selectedDate.year &&
              r.date.month == selectedDate.month &&
              r.date.day == selectedDate.day &&
              r.period == selectedPeriod,
        )
        .toList();

    String getStatus(String studentId) {
      final hasLeave = studentLeaves.any(
        (l) =>
            l.studentId == studentId &&
            l.status == 'Approved' &&
            (selectedDate.isAfter(
                  l.fromDate.subtract(const Duration(seconds: 1)),
                ) &&
                selectedDate.isBefore(l.toDate.add(const Duration(days: 1)))),
      );
      if (hasLeave) return 'OnLeave';

      final rec = dayRecords.where((r) => r.studentId == studentId);
      return rec.isNotEmpty ? rec.first.status : 'Absent';
    }

    final classesList = ref
        .watch(academicClassesProvider)
        .where((c) => c.branchId == branchId)
        .toList();
    final sectionsList = ref
        .watch(academicSectionsProvider)
        .where((s) => s.classId == selectedClassId)
        .toList();

    // ─── Automatic Period Detection ──────────────────
    final currentMin = DateTime.now().hour * 60 + DateTime.now().minute;
    final currentDay = _getDayOfWeek(DateTime.now());

    TimetableSlotEntity? activeSlot;
    try {
      activeSlot = timetableSlots.firstWhere(
        (s) =>
            s.branchId == branchId &&
            s.classId == selectedClassId &&
            (s.sectionId == selectedSectionId || s.sectionId == 'ALL') &&
            s.dayOfWeek.toLowerCase() == currentDay.toLowerCase() &&
            currentMin >= _minutesFromMidnight(s.startTime) &&
            currentMin <= _minutesFromMidnight(s.endTime),
      );
    } catch (_) {
      activeSlot = null;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Filters Row ───────────────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Date Picker
                    _FilterChipButton(
                      label:
                          'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      icon: Icons.calendar_today_rounded,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2026, 1, 1),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) onDateChanged(picked);
                      },
                    ),

                    // Class Selector
                    if (classesList.isNotEmpty)
                      SizedBox(
                        width: 150,
                        child: _DropdownFilter(
                          label: 'Class',
                          value: selectedClassId,
                          items: classesList.map((c) => c.id).toList(),
                          displayItems: classesList.map((c) => c.name).toList(),
                          onChanged: onClassChanged,
                          isDark: isDark,
                        ),
                      ),

                    // Section Selector
                    if (sectionsList.isNotEmpty)
                      SizedBox(
                        width: 120,
                        child: _DropdownFilter(
                          label: 'Section',
                          value: selectedSectionId,
                          items: sectionsList.map((s) => s.id).toList(),
                          displayItems: sectionsList
                              .map((s) => s.name)
                              .toList(),
                          onChanged: onSectionChanged,
                          isDark: isDark,
                        ),
                      ),

                    // Period Selector
                    SizedBox(
                      width: 120,
                      child: _DropdownFilter(
                        label: 'Period',
                        value: selectedPeriod,
                        items: const [
                          'All Day',
                          'Period 1',
                          'Period 2',
                          'Period 3',
                          'Period 4',
                          'Period 5',
                          'Period 6',
                          'Period 7',
                          'Period 8',
                        ],
                        displayItems: const [
                          'All Day',
                          'Period 1',
                          'Period 2',
                          'Period 3',
                          'Period 4',
                          'Period 5',
                          'Period 6',
                          'Period 7',
                          'Period 8',
                        ],
                        onChanged: onPeriodChanged,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ─── Timetable Banner Alert ────────────────
          if (activeSlot != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Timetable Slot Detected',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${activeSlot.periodName} (${activeSlot.subjectName} by ${activeSlot.teacherName})',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onPeriodChanged(activeSlot!.periodName);
                      _showSnack(
                        context,
                        'Period filter updated to ${activeSlot.periodName}',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Quick Filter'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ─── Summary Stats ─────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AttendanceSummaryChip(
                label: 'Present',
                count: dayRecords
                    .where(
                      (r) =>
                          r.status == 'Present' ||
                          r.status == 'Late' ||
                          r.status == 'HalfDay',
                    )
                    .length,
                color: AppColors.secondary,
              ),
              _AttendanceSummaryChip(
                label: 'Absent',
                count: dayRecords.where((r) => r.status == 'Absent').length,
                color: AppColors.error,
              ),
              _AttendanceSummaryChip(
                label: 'Late',
                count: dayRecords.where((r) => r.status == 'Late').length,
                color: AppColors.warning,
              ),
              _AttendanceSummaryChip(
                label: 'Total Roster',
                count: branchRoster.length,
                color: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ─── Bulk Actions ──────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                label: 'Mark All Present',
                icon: Icons.check_circle_rounded,
                color: AppColors.secondary,
                onTap: () {
                  final notifier = ref.read(studentAttendanceProvider.notifier);
                  final records = branchRoster.map((s) {
                    return StudentAttendanceRecordEntity(
                      id: 'ATT-${s.id}-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: s.branchId,
                      classId: s.classId,
                      sectionId: s.sectionId,
                      studentId: s.id,
                      studentName: s.name,
                      rollNumber: s.rollNumber,
                      date: selectedDate,
                      period: selectedPeriod,
                      subjectName: 'General',
                      status: 'Present',
                      arrivalTime: '08:00 AM',
                      departureTime: '03:30 PM',
                      inputMethod: 'Manual',
                      markedBy: 'Teacher',
                    );
                  }).toList();
                  notifier.markBulk(records);
                  _showSnack(context, 'All students marked Present');
                },
              ),
              _ActionButton(
                label: 'Mark All Absent',
                icon: Icons.cancel_rounded,
                color: AppColors.error,
                onTap: () {
                  final notifier = ref.read(studentAttendanceProvider.notifier);
                  final records = branchRoster.map((s) {
                    return StudentAttendanceRecordEntity(
                      id: 'ATT-${s.id}-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: s.branchId,
                      classId: s.classId,
                      sectionId: s.sectionId,
                      studentId: s.id,
                      studentName: s.name,
                      rollNumber: s.rollNumber,
                      date: selectedDate,
                      period: selectedPeriod,
                      subjectName: 'General',
                      status: 'Absent',
                      arrivalTime: '',
                      departureTime: '',
                      inputMethod: 'Manual',
                      markedBy: 'Teacher',
                    );
                  }).toList();
                  notifier.markBulk(records);
                  _showSnack(context, 'All students marked Absent');
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ─── Student List ──────────────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Roster',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 12),
                if (branchRoster.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No students found in this class & section.',
                        style: TextStyle(color: textSec, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ...branchRoster.map((student) {
                    final status = getStatus(student.id);
                    final dayRec = dayRecords.where(
                      (r) => r.studentId == student.id,
                    );
                    final recordId = dayRec.isNotEmpty ? dayRec.first.id : '';

                    return _StudentAttendanceRow(
                      student: student,
                      status: status,
                      isDark: isDark,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textPri: textPri,
                      textSec: textSec,
                      onRequestCorrection: () {
                        _showCorrectionDialog(
                          context,
                          ref,
                          branchId: branchId,
                          recordId: recordId,
                          personId: student.id,
                          personName: student.name,
                          role: 'Student',
                          date: selectedDate,
                          period: selectedPeriod,
                        );
                      },
                      onStatusChanged: (newStatus) {
                        final notifier = ref.read(
                          studentAttendanceProvider.notifier,
                        );
                        notifier.markAttendance(
                          StudentAttendanceRecordEntity(
                            id: recordId.isNotEmpty
                                ? recordId
                                : 'ATT-${student.id}-${DateTime.now().millisecondsSinceEpoch}',
                            branchId: student.branchId,
                            classId: student.classId,
                            sectionId: student.sectionId,
                            studentId: student.id,
                            studentName: student.name,
                            rollNumber: student.rollNumber,
                            date: selectedDate,
                            period: selectedPeriod,
                            subjectName: 'General',
                            status: newStatus,
                            arrivalTime: newStatus == 'Late'
                                ? '08:45 AM'
                                : (newStatus == 'Absent' ? '' : '08:00 AM'),
                            departureTime: newStatus == 'Absent'
                                ? ''
                                : '03:30 PM',
                            inputMethod: 'Manual',
                            markedBy: 'Teacher',
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Save Button ───────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showSnack(context, 'Attendance saved!'),
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save Attendance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
// TAB 2 — Staff Attendance
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _StaffAttendanceTab extends ConsumerWidget {
  final String branchId;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _StaffAttendanceTab({
    required this.branchId,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final staffList = ref.watch(staff_prov.staffProvider);
    final staffAttendance = ref.watch(staffAttendanceProvider);
    final staffLeaves = ref.watch(staff_prov.staffLeaveProvider);

    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final branchStaff = staffList
        .where(
          (s) => s.branchId == branchId || s.sharedBranchIds.contains(branchId),
        )
        .toList();

    List<StaffAttendanceRecordEntity> dayRecords = staffAttendance
        .where(
          (r) =>
              r.branchId == branchId &&
              r.date.year == selectedDate.year &&
              r.date.month == selectedDate.month &&
              r.date.day == selectedDate.day,
        )
        .toList();

    String getStaffStatus(String staffId) {
      final hasLeave = staffLeaves.any(
        (l) =>
            l.staffId == staffId &&
            l.status == 'Approved' &&
            (selectedDate.isAfter(
                  DateTime.parse(
                    l.fromDate,
                  ).subtract(const Duration(seconds: 1)),
                ) &&
                selectedDate.isBefore(
                  DateTime.parse(l.toDate).add(const Duration(days: 1)),
                )),
      );
      if (hasLeave) return 'OnLeave';

      final rec = dayRecords.where((r) => r.staffId == staffId);
      return rec.isNotEmpty ? rec.first.status : 'Absent';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Date Picker ───────────────────────────
          GlassCard(
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2026, 1, 1),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) onDateChanged(picked);
                  },
                  icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                  label: const Text('Change'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ─── Summary Chips ─────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AttendanceSummaryChip(
                label: 'Present',
                count: dayRecords
                    .where((r) => r.status == 'Present' || r.status == 'Late')
                    .length,
                color: AppColors.secondary,
              ),
              _AttendanceSummaryChip(
                label: 'Absent',
                count: dayRecords.where((r) => r.status == 'Absent').length,
                color: AppColors.error,
              ),
              _AttendanceSummaryChip(
                label: 'On Leave',
                count: dayRecords.where((r) => r.status == 'OnLeave').length,
                color: AppColors.accentAmber,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ─── Bulk Actions ──────────────────────────
          Row(
            children: [
              _ActionButton(
                label: 'Mark All Present',
                icon: Icons.check_circle_rounded,
                color: AppColors.secondary,
                onTap: () {
                  final notifier = ref.read(staffAttendanceProvider.notifier);
                  final records = branchStaff.map((s) {
                    return StaffAttendanceRecordEntity(
                      id: 'SAT-${s.id}-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: branchId,
                      staffId: s.id,
                      staffName: s.name,
                      designation: s.designation,
                      date: selectedDate,
                      status: 'Present',
                      arrivalTime: '07:45 AM',
                      departureTime: '04:00 PM',
                      inputMethod: 'Manual',
                      markedBy: 'Admin',
                    );
                  }).toList();
                  notifier.markBulk(records);
                  _showSnack(context, 'All staff marked Present');
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ─── Staff List ────────────────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Staff Roster',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 12),
                if (branchStaff.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No staff members found for this branch.',
                        style: TextStyle(color: textSec, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ...branchStaff.map((s) {
                    final status = getStaffStatus(s.id);
                    final dayRec = dayRecords.where((r) => r.staffId == s.id);
                    final recordId = dayRec.isNotEmpty ? dayRec.first.id : '';
                    final arrivalTime = dayRec.isNotEmpty
                        ? dayRec.first.arrivalTime
                        : '';
                    final departureTime = dayRec.isNotEmpty
                        ? dayRec.first.departureTime
                        : '';
                    final inputMethod = dayRec.isNotEmpty
                        ? dayRec.first.inputMethod
                        : 'Manual';

                    return _StaffAttendanceRow(
                      staffId: s.id,
                      staffName: s.name,
                      designation: s.designation,
                      status: status,
                      arrivalTime: arrivalTime,
                      departureTime: departureTime,
                      inputMethod: inputMethod,
                      isDark: isDark,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textPri: textPri,
                      textSec: textSec,
                      onRequestCorrection: () {
                        _showCorrectionDialog(
                          context,
                          ref,
                          branchId: branchId,
                          recordId: recordId,
                          personId: s.id,
                          personName: s.name,
                          role: 'Staff',
                          date: selectedDate,
                          period: 'All Day',
                        );
                      },
                      onStatusChanged: (newStatus) {
                        final notifier = ref.read(
                          staffAttendanceProvider.notifier,
                        );
                        notifier.markAttendance(
                          StaffAttendanceRecordEntity(
                            id: recordId.isNotEmpty
                                ? recordId
                                : 'SAT-${s.id}-${DateTime.now().millisecondsSinceEpoch}',
                            branchId: branchId,
                            staffId: s.id,
                            staffName: s.name,
                            designation: s.designation,
                            date: selectedDate,
                            status: newStatus,
                            arrivalTime: newStatus == 'Late'
                                ? '09:15 AM'
                                : (newStatus == 'Absent' ||
                                          newStatus == 'OnLeave'
                                      ? ''
                                      : '07:45 AM'),
                            departureTime:
                                (newStatus == 'Absent' ||
                                    newStatus == 'OnLeave')
                                ? ''
                                : '04:00 PM',
                            inputMethod: 'Manual',
                            markedBy: 'Admin',
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showSnack(context, 'Staff attendance saved!'),
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save Attendance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
// TAB 3 — Attendance Reports & Analytics
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AttendanceReportsTab extends ConsumerStatefulWidget {
  final String branchId;
  final String classFilter;
  final ValueChanged<String> onClassFilterChanged;

  const _AttendanceReportsTab({
    required this.branchId,
    required this.classFilter,
    required this.onClassFilterChanged,
  });

  @override
  ConsumerState<_AttendanceReportsTab> createState() =>
      _AttendanceReportsTabState();
}

class _AttendanceReportsTabState extends ConsumerState<_AttendanceReportsTab> {
  String _reportView =
      'Daily Summary'; // 'Daily Summary', 'Real-Time Dashboard', 'Defaulter List', 'Consolidated Report', 'Monthly Register', 'Compliance Reports', 'Analytics & Trends'
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final students = ref.watch(academicStudentsProvider);
    final attendance = ref.watch(studentAttendanceProvider);
    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final branchRoster = students
        .where((s) => s.branchId == widget.branchId)
        .toList();

    // Compute attendance per student
    final List<_StudentAttendanceStat> stats = branchRoster.map((s) {
      final recs = attendance.where((r) => r.studentId == s.id).toList();
      final total = recs.length;
      final present = recs
          .where(
            (r) =>
                r.status == 'Present' ||
                r.status == 'Late' ||
                r.status == 'HalfDay',
          )
          .length;
      final absent = recs.where((r) => r.status == 'Absent').length;
      final late = recs.where((r) => r.status == 'Late').length;
      final percent = total > 0 ? (present / total) * 100 : 0.0;
      return _StudentAttendanceStat(
        studentId: s.id,
        studentName: s.name,
        rollNumber: s.rollNumber,
        total: total,
        present: present,
        absent: absent,
        late: late,
        percent: percent,
      );
    }).toList();

    // Overall metrics
    final double overallPercent = stats.isEmpty
        ? 0
        : stats.map((s) => s.percent).reduce((a, b) => a + b) / stats.length;
    final int totalAbsent = stats.fold(0, (a, s) => a + s.absent);
    final int totalLate = stats.fold(0, (a, s) => a + s.late);

    // Defaulters (below 75% or config)
    final defaulters = stats
        .where((s) => s.percent < 75.0 && s.total > 0)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Report Navigation Chips ───────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    'Daily Summary',
                    'Real-Time Dashboard',
                    'Defaulter List',
                    'Consolidated Report',
                    'Monthly Register',
                    'Compliance Reports',
                    'Analytics & Trends',
                  ].map((view) {
                    final isSelected = _reportView == view;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(view),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _reportView = view);
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : textSec,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        backgroundColor: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Conditional Report Render ─────────────
          if (_reportView == 'Daily Summary') ...[
            Row(
              children: [
                Expanded(
                  child: _ReportStatCard(
                    label: 'Overall Branch Attendance',
                    value: '${overallPercent.toStringAsFixed(1)}%',
                    icon: Icons.donut_large_rounded,
                    color: overallPercent >= 75
                        ? AppColors.secondary
                        : AppColors.error,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReportStatCard(
                    label: 'Total Absent Students',
                    value: '$totalAbsent',
                    icon: Icons.person_off_rounded,
                    color: AppColors.error,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReportStatCard(
                    label: 'Late Arrivals Today',
                    value: '$totalLate',
                    icon: Icons.schedule_rounded,
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Attendance Logs',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (stats.isEmpty)
                    Center(
                      child: Text(
                        'No attendance stats available',
                        style: TextStyle(color: textSec),
                      ),
                    )
                  else
                    ...stats.map(
                      (s) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              s.studentName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: textPri,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              s.percent >= 75 ? 'P' : 'A',
                              style: TextStyle(
                                color: s.percent >= 75
                                    ? AppColors.secondary
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ] else if (_reportView == 'Real-Time Dashboard') ...[
            // Real-Time dashboard elements
            _buildRealtimeDashboard(isDark, textPri, textSec, overallPercent),
          ] else if (_reportView == 'Defaulter List') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance Defaulters (Below 75%)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPri,
                        ),
                      ),
                      Text(
                        'Total: ${defaulters.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (defaulters.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Great! No student is below 75% attendance.',
                          style: TextStyle(color: textSec),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: defaulters.length,
                      itemBuilder: (context, idx) {
                        final d = defaulters[idx];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.studentName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textPri,
                                    ),
                                  ),
                                  Text(
                                    'Roll: ${d.rollNumber}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textSec,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                '${d.percent.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(
                                        attendanceNotificationsProvider
                                            .notifier,
                                      )
                                      .logNotification(
                                        studentId: d.studentId,
                                        studentName: d.studentName,
                                        parentName:
                                            'Parent of ${d.studentName}',
                                        channel: 'SMS',
                                        status: 'Sent',
                                      );
                                  _showSnack(
                                    context,
                                    'Alert notification sent to ${d.studentName}\'s parents',
                                  );
                                },
                                icon: const Icon(
                                  Icons.notifications_active_rounded,
                                  size: 12,
                                ),
                                label: const Text(
                                  'Notify',
                                  style: TextStyle(fontSize: 10),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ] else if (_reportView == 'Consolidated Report') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class-wise & Section-wise Statistics',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Table(
                    border: TableBorder.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      width: 0.5,
                    ),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Class & Section',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Total Students',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Present Rate',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Class 1 - Section A'),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('3'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '${overallPercent.toStringAsFixed(1)}%',
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Class 1 - Section B'),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('2'),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('85.0%'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Class 10 - Section A'),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('2'),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('90.0%'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Period-wise Breakdown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PeriodBreakdownTable(
                    attendance: attendance
                        .where((r) => r.branchId == widget.branchId)
                        .toList(),
                    isDark: isDark,
                    textPri: textPri,
                    textSec: textSec,
                  ),
                ],
              ),
            ),
          ] else if (_reportView == 'Monthly Register') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Monthly Attendance Register (August 2026)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPri,
                        ),
                      ),
                      const Spacer(),
                      _isDownloading
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : ElevatedButton.icon(
                              onPressed: () async {
                                setState(() => _isDownloading = true);
                                await Future.delayed(const Duration(seconds: 2));
                                if (!context.mounted) return;
                                setState(() => _isDownloading = false);
                                _showSnack(
                                  context,
                                  'PDF Register downloaded successfully!',
                                );
                              },
                              icon: const Icon(
                                Icons.download_rounded,
                                size: 14,
                              ),
                              label: const Text(
                                'Export Register',
                                style: TextStyle(fontSize: 11),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      defaultColumnWidth: const FixedColumnWidth(40),
                      border: TableBorder.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        width: 0.5,
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                          ),
                          children: [
                            const SizedBox(
                              width: 100,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Student',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            ...List.generate(
                              10,
                              (idx) => Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  '${idx + 1}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...branchRoster.map((student) {
                          return TableRow(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    student.name,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                              ...List.generate(10, (idx) {
                                final isPresent =
                                    (idx % 3 != 0) || (student.id == 'STU-001');
                                return Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    isPresent ? 'P' : 'A',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isPresent
                                          ? AppColors.secondary
                                          : AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_reportView == 'Compliance Reports') ...[
            _buildComplianceReports(isDark, textPri, textSec),
          ] else if (_reportView == 'Analytics & Trends') ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Attendance Rate Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildGraphBar('Week 1', 0.94, isDark, textSec),
                      _buildGraphBar('Week 2', 0.88, isDark, textSec),
                      _buildGraphBar('Week 3', 0.91, isDark, textSec),
                      _buildGraphBar('Week 4', 0.95, isDark, textSec),
                      _buildGraphBar('Week 5', 0.82, isDark, textSec),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGraphBar(
    String label,
    double value,
    bool isDark,
    Color textSec,
  ) {
    return Column(
      children: [
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 120 * value,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 11, color: textSec)),
      ],
    );
  }

  Widget _buildRealtimeDashboard(
    bool isDark,
    Color textPri,
    Color textSec,
    double overallPercent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    Text(
                      'Live Present Rate',
                      style: TextStyle(color: textSec, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: overallPercent / 100,
                            strokeWidth: 8,
                            color: AppColors.secondary,
                            backgroundColor: isDark
                                ? Colors.white10
                                : Colors.black12,
                          ),
                          Text(
                            '${overallPercent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textPri,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RFID / Biometric Sync Status',
                      style: TextStyle(color: textSec, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    _buildSyncStatusRow(
                      'Main Entrance RFID Gate',
                      'Online',
                      AppColors.secondary,
                    ),
                    _buildSyncStatusRow(
                      'Academic Block Biometric',
                      'Online',
                      AppColors.secondary,
                    ),
                    _buildSyncStatusRow(
                      'Staff Room Scanner',
                      'Maintenance',
                      AppColors.warning,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Real-Time Clock-In Feed Feed',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textPri,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView(
                  children: [
                    _buildFeedItem(
                      'Devendra Gowda',
                      'STU-005',
                      'Class 1-A',
                      '09:35 AM',
                      'RFID Gate 1',
                      isDark,
                    ),
                    _buildFeedItem(
                      'Aarav Sharma',
                      'STU-001',
                      'Class 1-A',
                      '09:30 AM',
                      'Biometric Block B',
                      isDark,
                    ),
                    _buildFeedItem(
                      'Mrs. Rupa Ganguly',
                      'STF-002',
                      'Staff (Teacher)',
                      '07:42 AM',
                      'Fingerprint Main',
                      isDark,
                    ),
                    _buildFeedItem(
                      'Dr. Priya Sharma',
                      'STF-004',
                      'Staff (HOD)',
                      '07:38 AM',
                      'Face Scanner Entrance',
                      isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncStatusRow(String name, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 11))),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem(
    String name,
    String id,
    String desc,
    String time,
    String dev,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 10,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Text(
                '$id • $desc',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                dev,
                style: const TextStyle(fontSize: 8, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceReports(bool isDark, Color textPri, Color textSec) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Government Compliance Reports',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textPri,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Generate and sign formal attendance registers verified for national Ministry standards.',
            style: TextStyle(color: textSec, fontSize: 11),
          ),
          const SizedBox(height: 16),
          _DropdownFilter(
            label: 'Compliance Standard',
            value: 'Ministry of Education Standard EMIS',
            items: const [
              'Ministry of Education Standard EMIS',
              'State Board Monthly Audit',
              'Funding & Scholarship Compliance register',
            ],
            displayItems: const [
              'Ministry of Education Standard EMIS',
              'State Board Monthly Audit',
              'Funding & Scholarship Compliance register',
            ],
            onChanged: (_) {},
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Include Digital Principal Signatures & Verification Keys?',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              Switch(
                value: true,
                onChanged: (_) {},
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _isDownloading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _isDownloading = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() => _isDownloading = false);
                          _showSnack(
                            context,
                            'Compliance file (EMIS-COMPLIANCE.csv) generated successfully!',
                          );
                        }
                      });
                    },
                    icon: const Icon(Icons.verified_user_rounded, size: 16),
                    label: const Text('Export Compliant CSV File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 4 — Biometric / RFID Device Management
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _BiometricDevicesTab extends ConsumerStatefulWidget {
  final String branchId;
  const _BiometricDevicesTab({required this.branchId});

  @override
  ConsumerState<_BiometricDevicesTab> createState() =>
      _BiometricDevicesTabState();
}

class _BiometricDevicesTabState extends ConsumerState<_BiometricDevicesTab> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  String _deviceType = 'Biometric';
  String _deviceStatus = 'Online';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _serialCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final devices = ref.watch(biometricDevicesProvider);
    final branchDevices = devices
        .where((d) => d.branchId == widget.branchId)
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
          // ─── Add Device Form ───────────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register New Device',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _FormField(
                        controller: _nameCtrl,
                        label: 'Device Name',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormField(
                        controller: _locationCtrl,
                        label: 'Location',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _FormField(
                        controller: _serialCtrl,
                        label: 'Serial Number',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DropdownFilter(
                        label: 'Type',
                        value: _deviceType,
                        items: const [
                          'Biometric',
                          'RFID',
                          'Facial Recognition',
                          'Mobile App',
                        ],
                        displayItems: const [
                          'Biometric',
                          'RFID',
                          'Facial Recognition',
                          'Mobile App',
                        ],
                        onChanged: (v) => setState(() => _deviceType = v),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DropdownFilter(
                        label: 'Status',
                        value: _deviceStatus,
                        items: const ['Online', 'Offline', 'Maintenance'],
                        displayItems: const [
                          'Online',
                          'Offline',
                          'Maintenance',
                        ],
                        onChanged: (v) => setState(() => _deviceStatus = v),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_nameCtrl.text.trim().isEmpty) return;
                    ref
                        .read(biometricDevicesProvider.notifier)
                        .addDevice(
                          BiometricDeviceEntity(
                            id: 'DEV-${DateTime.now().millisecondsSinceEpoch}',
                            branchId: widget.branchId,
                            name: _nameCtrl.text.trim(),
                            type: _deviceType,
                            location: _locationCtrl.text.trim(),
                            serialNumber: _serialCtrl.text.trim(),
                            status: _deviceStatus,
                            lastSynced: DateTime.now()
                                .toIso8601String()
                                .substring(0, 19),
                          ),
                        );
                    _nameCtrl.clear();
                    _locationCtrl.clear();
                    _serialCtrl.clear();
                    _showSnack(context, 'Device registered successfully!');
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Register Device'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Device List ───────────────────────────
          Text(
            'Registered Devices (${branchDevices.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPri,
            ),
          ),
          const SizedBox(height: 10),

          ...branchDevices.map(
            (device) => _DeviceCard(
              device: device,
              isDark: isDark,
              textPri: textPri,
              textSec: textSec,
              onSync: () {
                ref
                    .read(biometricDevicesProvider.notifier)
                    .syncDevice(device.id);
                _showSnack(context, '${device.name} synced!');
              },
              onToggleStatus: () {
                ref
                    .read(biometricDevicesProvider.notifier)
                    .toggleDeviceStatus(device.id);
              },
              onDelete: () {
                ref
                    .read(biometricDevicesProvider.notifier)
                    .removeDevice(device.id);
                _showSnack(context, 'Device removed');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 5 — Attendance Configuration
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AttendanceConfigTab extends ConsumerStatefulWidget {
  final String branchId;
  const _AttendanceConfigTab({required this.branchId});

  @override
  ConsumerState<_AttendanceConfigTab> createState() =>
      _AttendanceConfigTabState();
}

class _AttendanceConfigTabState extends ConsumerState<_AttendanceConfigTab> {
  late int _lateGrace;
  late String _halfDayCutoff;
  late double _minAttendance;
  late bool _autoNotify;
  late bool _periodWise;
  late bool _subjectWise;
  late List<String> _enabledMethods;

  bool _initialized = false;
  final _cutoffCtrl = TextEditingController();

  // Holiday rule form controllers
  final _holidayNameCtrl = TextEditingController();
  DateTime _holidayStart = DateTime.now();
  DateTime _holidayEnd = DateTime.now();
  bool _isAcademicDay = false;

  @override
  void dispose() {
    _cutoffCtrl.dispose();
    _holidayNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final configs = ref.watch(attendanceConfigProvider);
    final holidays = ref
        .watch(holidayRulesProvider)
        .where((h) => h.branchId == widget.branchId)
        .toList();
    final notificationLogs = ref.watch(attendanceNotificationsProvider);

    final cfg = configs.firstWhere(
      (c) => c.branchId == widget.branchId,
      orElse: () => AttendanceConfigEntity(branchId: widget.branchId),
    );

    if (!_initialized) {
      _lateGrace = cfg.lateGraceMinutes;
      _halfDayCutoff = cfg.halfDayCutoffTime;
      _minAttendance = cfg.minAttendancePercent;
      _autoNotify = cfg.autoNotifyParents;
      _periodWise = cfg.periodWiseEnabled;
      _subjectWise = cfg.subjectWiseEnabled;
      _enabledMethods = List<String>.from(cfg.enabledInputMethods);
      _cutoffCtrl.text = _halfDayCutoff;
      _initialized = true;
    }

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
          // ─── Time Settings ─────────────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time & Threshold Settings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Late Arrival Grace Period: $_lateGrace minutes',
                  style: TextStyle(fontSize: 13, color: textSec),
                ),
                Slider(
                  value: _lateGrace.toDouble(),
                  min: 0,
                  max: 60,
                  divisions: 12,
                  activeColor: AppColors.primary,
                  label: '$_lateGrace min',
                  onChanged: (v) => setState(() => _lateGrace = v.toInt()),
                ),

                const SizedBox(height: 8),

                _FormField(
                  controller: _cutoffCtrl,
                  label: 'Half-Day Cutoff Time (e.g. 12:00 PM)',
                  isDark: isDark,
                  onChanged: (v) => _halfDayCutoff = v,
                ),

                const SizedBox(height: 16),

                Text(
                  'Minimum Attendance Requirement: ${_minAttendance.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 13, color: textSec),
                ),
                Slider(
                  value: _minAttendance,
                  min: 50,
                  max: 100,
                  divisions: 10,
                  activeColor: AppColors.primary,
                  label: '${_minAttendance.toStringAsFixed(0)}%',
                  onChanged: (v) => setState(() => _minAttendance = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Holiday Rules Section ─────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Holiday & Event-based Rules',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPri,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddHolidayDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 14),
                      label: const Text(
                        'Add Rule',
                        style: TextStyle(fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (holidays.isEmpty)
                  Text(
                    'No custom holiday rules created for this branch.',
                    style: TextStyle(color: textSec, fontSize: 12),
                  )
                else
                  ...holidays.map(
                    (rule) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        rule.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textPri,
                        ),
                      ),
                      subtitle: Text(
                        '${rule.startDate.day}/${rule.startDate.month}/${rule.startDate.year} - ${rule.endDate.day}/${rule.endDate.month}/${rule.endDate.year} (${rule.isAcademicDay ? "Mandatory Attendance" : "No Attendance Required"})',
                        style: TextStyle(color: textSec, fontSize: 11),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 18,
                        ),
                        onPressed: () {
                          ref
                              .read(holidayRulesProvider.notifier)
                              .removeHolidayRule(rule.id);
                          _showSnack(context, 'Holiday rule deleted');
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Notification Logs ─────────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent Notification Logs',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 12),
                if (notificationLogs.isEmpty)
                  Text(
                    'No automated notifications logged yet.',
                    style: TextStyle(color: textSec, fontSize: 12),
                  )
                else
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: notificationLogs.length,
                      itemBuilder: (context, idx) {
                        final log = notificationLogs[idx];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                log.channel == 'SMS'
                                    ? Icons.sms_outlined
                                    : Icons.email_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Sent ${log.channel} to ${log.parentName} for ${log.studentName}',
                                  style: TextStyle(
                                    color: textPri,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Text(
                                '${log.date.day}/${log.date.month} ${log.sentAt}',
                                style: TextStyle(color: textSec, fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Notification & Mode Toggles ───────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications & Tracking Modes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 8),
                _ConfigToggle(
                  title: 'Auto-Notify Parents on Absence',
                  subtitle: 'Send SMS/email to parents when student is absent',
                  value: _autoNotify,
                  isDark: isDark,
                  onChanged: (v) => setState(() => _autoNotify = v),
                ),
                _ConfigToggle(
                  title: 'Period-wise Attendance Tracking',
                  subtitle: 'Track attendance per period/lecture',
                  value: _periodWise,
                  isDark: isDark,
                  onChanged: (v) => setState(() => _periodWise = v),
                ),
                _ConfigToggle(
                  title: 'Subject-wise Attendance Tracking',
                  subtitle: 'Track attendance per subject/teacher',
                  value: _subjectWise,
                  isDark: isDark,
                  onChanged: (v) => setState(() => _subjectWise = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Input Methods ─────────────────────────
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enabled Attendance Input Methods',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select which input methods are active for this branch',
                  style: TextStyle(fontSize: 12, color: textSec),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                        'Manual',
                        'Biometric',
                        'RFID',
                        'Facial Recognition',
                        'Mobile App',
                      ].map((method) {
                        final enabled = _enabledMethods.contains(method);
                        return FilterChip(
                          label: Text(
                            method,
                            style: TextStyle(
                              fontSize: 12,
                              color: enabled
                                  ? Colors.white
                                  : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                            ),
                          ),
                          selected: enabled,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _enabledMethods.add(method);
                              } else {
                                _enabledMethods.remove(method);
                              }
                            });
                          },
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          backgroundColor: isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          side: BorderSide(
                            color: enabled
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ─── Save Button ───────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final updated = AttendanceConfigEntity(
                  branchId: widget.branchId,
                  lateGraceMinutes: _lateGrace,
                  halfDayCutoffTime: _cutoffCtrl.text.trim().isEmpty
                      ? _halfDayCutoff
                      : _cutoffCtrl.text.trim(),
                  minAttendancePercent: _minAttendance,
                  autoNotifyParents: _autoNotify,
                  periodWiseEnabled: _periodWise,
                  subjectWiseEnabled: _subjectWise,
                  enabledInputMethods: _enabledMethods,
                );
                ref
                    .read(attendanceConfigProvider.notifier)
                    .updateConfig(updated);
                _showSnack(context, 'Configuration saved!');
              },
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save Configuration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddHolidayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Holiday Rule'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _holidayNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Rule Name (e.g. Winter Break)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Starts: ${_holidayStart.day}/${_holidayStart.month}/${_holidayStart.year}',
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _holidayStart,
                              firstDate: DateTime(2026, 1, 1),
                              lastDate: DateTime(2026, 12, 31),
                            );
                            if (picked != null) {
                              setDialogState(() => _holidayStart = picked);
                            }
                          },
                          child: const Text('Select'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Ends: ${_holidayEnd.day}/${_holidayEnd.month}/${_holidayEnd.year}',
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _holidayEnd,
                              firstDate: DateTime(2026, 1, 1),
                              lastDate: DateTime(2026, 12, 31),
                            );
                            if (picked != null) {
                              setDialogState(() => _holidayEnd = picked);
                            }
                          },
                          child: const Text('Select'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Mandatory Attendance Day?',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        Switch(
                          value: _isAcademicDay,
                          onChanged: (v) {
                            setDialogState(() => _isAcademicDay = v);
                          },
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
                    if (_holidayNameCtrl.text.trim().isEmpty) return;
                    ref
                        .read(holidayRulesProvider.notifier)
                        .addHolidayRule(
                          HolidayRuleEntity(
                            id: 'H-${DateTime.now().millisecondsSinceEpoch}',
                            branchId: widget.branchId,
                            name: _holidayNameCtrl.text.trim(),
                            startDate: _holidayStart,
                            endDate: _holidayEnd,
                            isAcademicDay: _isAcademicDay,
                          ),
                        );
                    _holidayNameCtrl.clear();
                    Navigator.pop(context);
                    _showSnack(context, 'Holiday Rule added successfully!');
                  },
                  child: const Text('Add Rule'),
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
// TAB 6 — Corrections Workflow Tab
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _CorrectionsWorkflowTab extends ConsumerWidget {
  final String branchId;
  const _CorrectionsWorkflowTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requests = ref
        .watch(attendanceCorrectionRequestsProvider)
        .where((r) => r.branchId == branchId)
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
          Text(
            'Pending Approval Requests',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textPri,
            ),
          ),
          const SizedBox(height: 12),
          if (requests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No correction requests found.',
                  style: TextStyle(color: textSec, fontSize: 13),
                ),
              ),
            )
          else
            ...requests.map((req) {
              final statusColor = req.status == 'Approved'
                  ? AppColors.secondary
                  : (req.status == 'Rejected'
                        ? AppColors.error
                        : AppColors.warning);
              final isPending = req.status == 'Pending';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            req.personName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textPri,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              req.status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${req.role} • Date: ${req.date.day}/${req.date.month}/${req.date.year}',
                        style: TextStyle(fontSize: 12, color: textSec),
                      ),
                      Text(
                        'Requested Correction: ${req.requestedStatus}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Reason: ${req.reason}',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: textPri,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isPending)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                ref
                                    .read(
                                      attendanceCorrectionRequestsProvider
                                          .notifier,
                                    )
                                    .rejectRequest(req.id, 'Administrator');
                                _showSnack(
                                  context,
                                  'Correction Request rejected.',
                                );
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: AppColors.error,
                              ),
                              label: const Text(
                                'Reject',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(
                                      attendanceCorrectionRequestsProvider
                                          .notifier,
                                    )
                                    .approveRequest(req.id, 'Administrator');
                                _showSnack(
                                  context,
                                  'Correction Request approved & attendance updated!',
                                );
                              },
                              icon: const Icon(Icons.check_rounded, size: 14),
                              label: const Text(
                                'Approve',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                              ),
                            ),
                          ],
                        )
                      else if (req.reviewedBy.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Reviewed by: ${req.reviewedBy}',
                            style: TextStyle(fontSize: 11, color: textSec),
                          ),
                        ),
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
// HELPER WIDGETS & DIALOG FLOWS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

void _showCorrectionDialog(
  BuildContext context,
  WidgetRef ref, {
  required String branchId,
  required String recordId,
  required String personId,
  required String personName,
  required String role,
  required DateTime date,
  required String period,
}) {
  final reasonCtrl = TextEditingController();
  String requestedStatus = 'Present';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Request Attendance Correction'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Submit an attendance status adjustment request for $personName.',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  _DropdownFilter(
                    label: 'Requested Status',
                    value: requestedStatus,
                    items: const ['Present', 'Absent', 'Late', 'HalfDay'],
                    displayItems: const [
                      'Present',
                      'Absent',
                      'Late',
                      'HalfDay',
                    ],
                    onChanged: (v) {
                      setDialogState(() => requestedStatus = v);
                    },
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Adjustment',
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
                  if (reasonCtrl.text.trim().isEmpty) return;
                  ref
                      .read(attendanceCorrectionRequestsProvider.notifier)
                      .requestCorrection(
                        branchId: branchId,
                        recordId: recordId,
                        personId: personId,
                        personName: personName,
                        role: role,
                        date: date,
                        period: period,
                        requestedStatus: requestedStatus,
                        reason: reasonCtrl.text.trim(),
                        requestedBy: 'Class Teacher',
                      );
                  Navigator.pop(context);
                  _showSnack(
                    context,
                    'Adjustment request submitted successfully!',
                  );
                },
                child: const Text('Submit Request'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _StudentAttendanceRow extends StatelessWidget {
  final StudentEntity student;
  final String status;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color textPri;
  final Color textSec;
  final VoidCallback onRequestCorrection;
  final ValueChanged<String> onStatusChanged;

  const _StudentAttendanceRow({
    required this.student,
    required this.status,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textPri,
    required this.textSec,
    required this.onRequestCorrection,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOnLeave = status == 'OnLeave';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 550;

          final avatar = CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              student.name.isNotEmpty ? student.name[0] : 'S',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          );

          final details = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPri,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Roll: ${student.rollNumber.isNotEmpty ? student.rollNumber : "-"}',
                      style: TextStyle(fontSize: 11, color: textSec),
                    ),
                    if (isOnLeave) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'On Approved Leave',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.accentAmber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );

          final adjustmentButton = IconButton(
            onPressed: onRequestCorrection,
            icon: const Icon(
              Icons.edit_note_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            tooltip: 'Request Adjustment',
          );

          final chips = [
            'Present',
            'Absent',
            'Late',
            'HalfDay',
            if (isOnLeave) 'OnLeave',
          ].map((s) {
            final isSelected = status == s;
            final chipColor = _statusColor(s);
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: GestureDetector(
                onTap: () => onStatusChanged(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? chipColor : chipColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? chipColor
                          : chipColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    s == 'HalfDay'
                        ? 'Half'
                        : s == 'OnLeave'
                        ? 'Leave'
                        : s,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : chipColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList();

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    avatar,
                    const SizedBox(width: 10),
                    details,
                    adjustmentButton,
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: chips,
                ),
              ],
            );
          }

          return Row(
            children: [
              avatar,
              const SizedBox(width: 10),
              details,
              adjustmentButton,
              const SizedBox(width: 4),
              ...chips,
            ],
          );
        },
      ),
    );
  }
}

class _StaffAttendanceRow extends StatelessWidget {
  final String staffId;
  final String staffName;
  final String designation;
  final String status;
  final String arrivalTime;
  final String departureTime;
  final String inputMethod;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color textPri;
  final Color textSec;
  final VoidCallback onRequestCorrection;
  final ValueChanged<String> onStatusChanged;

  const _StaffAttendanceRow({
    required this.staffId,
    required this.staffName,
    required this.designation,
    required this.status,
    required this.arrivalTime,
    required this.departureTime,
    required this.inputMethod,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textPri,
    required this.textSec,
    required this.onRequestCorrection,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOnLeave = status == 'OnLeave';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 550;

          final topRow = Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.secondaryGradient.colors.first
                    .withValues(alpha: 0.15),
                child: Text(
                  staffName.isNotEmpty ? staffName[0] : 'T',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staffName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPri,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          designation,
                          style: TextStyle(fontSize: 11, color: textSec),
                        ),
                        if (isOnLeave) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'On Approved Leave',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.accentAmber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRequestCorrection,
                icon: const Icon(
                  Icons.edit_note_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                tooltip: 'Request Adjustment',
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  inputMethod,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );

          final timeDetails = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (arrivalTime.isNotEmpty) ...[
                Icon(Icons.login_rounded, size: 12, color: textSec),
                const SizedBox(width: 4),
                Text(
                  arrivalTime,
                  style: TextStyle(fontSize: 11, color: textSec),
                ),
                const SizedBox(width: 12),
              ],
              if (departureTime.isNotEmpty) ...[
                Icon(Icons.logout_rounded, size: 12, color: textSec),
                const SizedBox(width: 4),
                Text(
                  departureTime,
                  style: TextStyle(fontSize: 11, color: textSec),
                ),
              ],
            ],
          );

          final chips = ['Present', 'Absent', 'Late', 'HalfDay', 'OnLeave'].map((s) {
            final isSelected = status == s;
            final chipColor = _statusColor(s);
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: GestureDetector(
                onTap: () => onStatusChanged(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? chipColor
                        : chipColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? chipColor
                          : chipColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    s == 'HalfDay'
                        ? 'Half'
                        : s == 'OnLeave'
                        ? 'Leave'
                        : s,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : chipColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList();

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                topRow,
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    timeDetails,
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: chips,
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              topRow,
              const SizedBox(height: 8),
              Row(
                children: [
                  timeDetails,
                  const Spacer(),
                  ...chips,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final BiometricDeviceEntity device;
  final bool isDark;
  final Color textPri;
  final Color textSec;
  final VoidCallback onSync;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _DeviceCard({
    required this.device,
    required this.isDark,
    required this.textPri,
    required this.textSec,
    required this.onSync,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = device.status == 'Online';
    final statusColor = isOnline ? AppColors.secondary : AppColors.error;
    final typeIcon = _deviceTypeIcon(device.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeIcon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          device.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPri,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              device.status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${device.type} • ${device.location}',
                    style: TextStyle(fontSize: 11, color: textSec),
                  ),
                  Text(
                    'SN: ${device.serialNumber}',
                    style: TextStyle(fontSize: 11, color: textSec),
                  ),
                  Text(
                    'Last synced: ${device.lastSynced.replaceAll('T', ' ')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  onPressed: onSync,
                  icon: const Icon(Icons.sync_rounded),
                  color: AppColors.primary,
                  iconSize: 18,
                  tooltip: 'Sync Device',
                ),
                IconButton(
                  onPressed: onToggleStatus,
                  icon: Icon(
                    isOnline
                        ? Icons.toggle_on_rounded
                        : Icons.toggle_off_rounded,
                  ),
                  color: isOnline ? AppColors.secondary : AppColors.error,
                  iconSize: 22,
                  tooltip: isOnline ? 'Set Offline' : 'Set Online',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.error,
                  iconSize: 18,
                  tooltip: 'Remove Device',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodBreakdownTable extends StatelessWidget {
  final List<StudentAttendanceRecordEntity> attendance;
  final bool isDark;
  final Color textPri;
  final Color textSec;

  const _PeriodBreakdownTable({
    required this.attendance,
    required this.isDark,
    required this.textPri,
    required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    final periods = attendance.map((r) => r.period).toSet().toList()..sort();
    if (periods.isEmpty) {
      return Text(
        'No data available',
        style: TextStyle(color: textSec, fontSize: 12),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      border: TableBorder.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 0.5,
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: AppColors.primarySurface),
          children: [
            _TableCell('Period', textPri, isHeader: true),
            _TableCell('Present', AppColors.secondary, isHeader: true),
            _TableCell('Absent', AppColors.error, isHeader: true),
            _TableCell('Late', AppColors.warning, isHeader: true),
          ],
        ),
        ...periods.map((period) {
          final recs = attendance.where((r) => r.period == period).toList();
          final present = recs
              .where((r) => r.status == 'Present' || r.status == 'HalfDay')
              .length;
          final absent = recs.where((r) => r.status == 'Absent').length;
          final late = recs.where((r) => r.status == 'Late').length;
          return TableRow(
            children: [
              _TableCell(period, textPri),
              _TableCell('$present', AppColors.secondary),
              _TableCell('$absent', AppColors.error),
              _TableCell('$late', AppColors.warning),
            ],
          );
        }),
      ],
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final Color color;
  final bool isHeader;

  const _TableCell(this.text, this.color, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _ReportStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ConfigToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textPri = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSec = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textPri,
                  ),
                ),
                Text(subtitle, style: TextStyle(fontSize: 11, color: textSec)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _AttendanceSummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _AttendanceSummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isDark;
  final ValueChanged<String>? onChanged;

  const _FormField({
    required this.controller,
    required this.label,
    required this.isDark,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA MODELS (local helpers)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _StudentAttendanceStat {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final int total;
  final int present;
  final int absent;
  final int late;
  final double percent;

  const _StudentAttendanceStat({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.percent,
  });
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UTILITIES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Color _statusColor(String status) {
  switch (status) {
    case 'Present':
      return AppColors.secondary;
    case 'Absent':
      return AppColors.error;
    case 'Late':
      return AppColors.warning;
    case 'HalfDay':
      return AppColors.accentCyan;
    case 'EarlyDeparture':
      return AppColors.accentAmber;
    case 'OnLeave':
      return AppColors.accentPink;
    default:
      return AppColors.error;
  }
}

IconData _deviceTypeIcon(String type) {
  switch (type) {
    case 'Biometric':
      return Icons.fingerprint_rounded;
    case 'RFID':
      return Icons.nfc_rounded;
    case 'Facial Recognition':
      return Icons.face_rounded;
    case 'Mobile App':
      return Icons.phone_android_rounded;
    default:
      return Icons.devices_rounded;
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

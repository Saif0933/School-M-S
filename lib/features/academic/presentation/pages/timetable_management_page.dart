import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../../staff/providers.dart';
import '../../providers.dart';

class TimetableManagementPage extends ConsumerStatefulWidget {
  const TimetableManagementPage({super.key});

  @override
  ConsumerState<TimetableManagementPage> createState() => _TimetableManagementPageState();
}

class _TimetableManagementPageState extends ConsumerState<TimetableManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Active Shift State
  String _selectedShift = 'Morning Shift';

  // Tab 1 (Class & Section Grid) State
  String? _selectedClassId;
  String? _selectedSectionId;

  // Tab 2 (Teacher-Wise View) State
  String? _selectedTeacherName;

  // Tab 4 (Substitution) State
  String? _substTeacherName;
  final String _substDate = '2026-08-13';

  // Conflict Alert state
  String? _conflictError;

  // Mock State for Timetable Sharing, Export, Calendar & Notifications
  bool _studentPortalShared = true;
  bool _parentPortalShared = true;
  final List<Map<String, String>> _shareLogs = [
    {'time': 'Aug 14, 2026 09:00 AM', 'channel': 'Portal Broadcast', 'scope': 'BR-001 Students & Parents', 'status': 'Published'},
    {'time': 'Aug 12, 2026 03:30 PM', 'channel': 'SMS Broadcast', 'scope': 'Class 10-A Parents', 'status': 'Delivered (82 alerts)'},
  ];

  bool _googleSyncEnabled = true;
  bool _outlookSyncEnabled = false;

  bool _dailyAlertsEnabled = true;
  String _dailyAlertTime = '07:30 AM';
  bool _alertPush = true;
  bool _alertEmail = true;
  bool _alertSms = false;
  final List<Map<String, String>> _alertLogs = [
    {'time': 'Aug 14, 2026 07:30 AM', 'title': 'Daily Agenda Alert', 'sent': '340 recipients', 'failures': '0'},
    {'time': 'Aug 13, 2026 07:30 AM', 'title': 'Daily Agenda Alert', 'sent': '340 recipients', 'failures': '0'},
    {'time': 'Aug 12, 2026 07:30 AM', 'title': 'Daily Agenda Alert', 'sent': '340 recipients', 'failures': '0'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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

    // Auth & Branch Context
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranch?.branchId;

    if (activeBranchId == null) {
      return const Scaffold(
        body: Center(
          child: Text('No active branch selected. Please select a branch from the top bar.'),
        ),
      );
    }

    // Branch Settings
    final allBranchSettings = ref.watch(branchTimetableSettingsProvider);
    final branchSettings = allBranchSettings.firstWhere(
      (s) => s.branchId == activeBranchId,
      orElse: () => BranchTimetableSettingsEntity(
        branchId: activeBranchId,
        workingDays: const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        periodDurationMinutes: 45,
        schoolStartTime: _selectedShift == 'Morning Shift' ? '08:15 AM' : '01:15 PM',
        breaks: const [],
      ),
    );

    // Classes & Sections for this branch
    final classes = ref.watch(academicClassesProvider).where((c) => c.branchId == activeBranchId).toList();
    final sections = ref.watch(academicSectionsProvider);

    // Branch Staff Teachers
    final allStaff = ref.watch(staffProvider);
    final branchTeachers = allStaff.where((s) => s.branchId == activeBranchId && (s.role.toLowerCase() == 'teacher' || s.designation.toLowerCase().contains('teacher') || s.role.toLowerCase() == 'hod')).toList();

    // Default Selection Logic
    if (_selectedClassId == null && classes.isNotEmpty) {
      _selectedClassId = classes.first.id;
    }
    final filteredSections = sections.where((s) => s.classId == _selectedClassId).toList();
    if (_selectedSectionId == null && filteredSections.isNotEmpty) {
      _selectedSectionId = filteredSections.first.id;
    }

    if (_selectedTeacherName == null && branchTeachers.isNotEmpty) {
      _selectedTeacherName = branchTeachers.first.name;
    }

    if (_substTeacherName == null && branchTeachers.isNotEmpty) {
      _substTeacherName = branchTeachers.first.name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Multi-Shift & Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isDark ? AppColors.darkBg : Colors.grey[100],
          child: Row(
            children: [
              const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Active Timetable Shift:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 12),

              // Shift Selector Chips
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'Morning Shift',
                    label: Text('Morning Shift (08:00 AM - 01:30 PM)', style: TextStyle(fontSize: 10)),
                    icon: Icon(Icons.wb_sunny_outlined, size: 14),
                  ),
                  ButtonSegment(
                    value: 'Afternoon Shift',
                    label: Text('Afternoon/Evening Shift (01:30 PM - 06:30 PM)', style: TextStyle(fontSize: 10)),
                    icon: Icon(Icons.wb_twilight_rounded, size: 14),
                  ),
                ],
                selected: {_selectedShift},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedShift = newSelection.first;
                  });
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const Spacer(),

              // Weekend Policy Info Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_note_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Weekend Policy: ${branchSettings.weekendPolicy}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab Headers (5 Tabs)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: const [
              Tab(
                icon: Icon(Icons.calendar_view_week_rounded, size: 16),
                text: 'Class Schedule',
              ),
              Tab(
                icon: Icon(Icons.badge_rounded, size: 16),
                text: 'Teacher Schedule View',
              ),
              Tab(
                icon: Icon(Icons.auto_awesome_rounded, size: 16),
                text: 'Allocations & AI Generator',
              ),
              Tab(
                icon: Icon(Icons.published_with_changes_rounded, size: 16),
                text: 'Substitutions & Adjustments',
              ),
              Tab(
                icon: Icon(Icons.settings_suggest_rounded, size: 16),
                text: 'Branch Timetable Settings',
              ),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildClassGridTab(isDark, activeBranchId, branchSettings, classes, filteredSections),
              _buildTeacherViewTab(isDark, activeBranchId, branchSettings, branchTeachers, classes, sections),
              _buildAllocationsAndAITab(isDark, activeBranchId, branchSettings, classes, sections, branchTeachers),
              _buildSubstitutionsTab(isDark, activeBranchId, branchSettings, branchTeachers, classes, sections),
              _buildBranchConfigTab(isDark, activeBranchId, branchSettings),
            ],
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 1: CLASS & SECTION WEEKLY GRID
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildClassGridTab(
    bool isDark,
    String branchId,
    BranchTimetableSettingsEntity settings,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    final allSlots = ref.watch(timetableSlotsProvider);
    final branchSlots = allSlots.where((s) => s.branchId == branchId && s.shiftName == _selectedShift).toList();
    final classSectionSlots = branchSlots.where((s) =>
        s.classId == _selectedClassId &&
        (s.sectionId == 'ALL' || s.sectionId == _selectedSectionId)).toList();

    final timeSlots = settings.calculateTimeSlots(8);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Board (Class & Section)
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Target Class & Section:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 24),

                // Class Selection
                Text('Class: ', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 11)),
                const SizedBox(width: 6),
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedClassId,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      onChanged: (val) {
                        setState(() {
                          _selectedClassId = val;
                          final list = ref.read(academicSectionsProvider).where((s) => s.classId == val).toList();
                          _selectedSectionId = list.isNotEmpty ? list.first.id : null;
                        });
                      },
                      items: classes.map((c) {
                        return DropdownMenuItem(value: c.id, child: Text(c.name));
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Section Selection
                Text('Section: ', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 11)),
                const SizedBox(width: 6),
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSectionId,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      onChanged: (val) {
                        setState(() {
                          _selectedSectionId = val;
                        });
                      },
                      items: sections.map((s) {
                        return DropdownMenuItem(value: s.id, child: Text('Section ${s.name}'));
                      }).toList(),
                    ),
                  ),
                ),
                const Spacer(),

                // Add Schedule Button
                ElevatedButton.icon(
                  onPressed: () => _showScheduleDialog(context, isDark, branchId, settings, classes, sections, null),
                  icon: const Icon(Icons.add_rounded, size: 14),
                  label: const Text('Add Lecture / Lab Slot', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
          ),
          _buildToolbarActions(context, isDark, branchId, settings),
          const SizedBox(height: 16),

          if (_selectedClassId == null || _selectedSectionId == null)
            const GlassCard(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Please select a valid class and section.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            )
          else ...[
            // Weekly Grid Board
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Days & Times
                    Row(
                      children: [
                        Container(
                          width: 100,
                          alignment: Alignment.center,
                          child: Text(
                            'Day / Period',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                        ...timeSlots.map((ts) {
                          return Container(
                            width: (ts.isBreak || ts.isAssembly) ? 100 : 150,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: ts.isAssembly
                                  ? Colors.amber.withValues(alpha: isDark ? 0.25 : 0.15)
                                  : (ts.isBreak
                                      ? (isDark ? Colors.grey[800]!.withValues(alpha: 0.3) : Colors.grey[300]!.withValues(alpha: 0.4))
                                      : AppColors.primarySurface),
                              borderRadius: BorderRadius.circular(6),
                              border: ts.isAssembly ? Border.all(color: Colors.amber.withValues(alpha: 0.5)) : null,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  ts.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: ts.isAssembly ? Colors.amber[800] : (ts.isBreak ? Colors.grey : AppColors.primary),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${ts.startTime} - ${ts.endTime}',
                                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Rows for each working day
                    ...settings.workingDays.map((day) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              height: 90,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : Colors.grey[100],
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                day,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            ...timeSlots.map((ts) {
                              if (ts.isAssembly) {
                                return Container(
                                  width: 100,
                                  height: 90,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 16),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Morning\nAssembly',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                            color: isDark ? Colors.amber[300] : Colors.amber[900],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              if (ts.isBreak) {
                                return Container(
                                  width: 100,
                                  height: 90,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[900]!.withValues(alpha: 0.5) : Colors.grey[200]!.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Center(
                                    child: RotatedBox(
                                      quarterTurns: 3,
                                      child: Text(
                                        ts.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                          letterSpacing: 2,
                                          color: isDark ? Colors.grey[600] : Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final slotMatch = classSectionSlots.firstWhere(
                                (s) => s.dayOfWeek == day && s.periodName == ts.name,
                                orElse: () => const TimetableSlotEntity(
                                  id: '', branchId: '', classId: '', sectionId: '',
                                  dayOfWeek: '', periodName: '', startTime: '', endTime: '',
                                  subjectName: '', teacherName: '',
                                ),
                              );

                              final hasSlot = slotMatch.id.isNotEmpty;

                              return Container(
                                width: 150,
                                height: 90,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                child: hasSlot
                                    ? _buildPeriodCard(isDark, slotMatch, branchId, settings, classes, sections)
                                    : _buildEmptyPeriodCard(isDark, day, ts.name, branchId, settings, classes, sections),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 2: TEACHER-WISE TIMETABLE VIEW (BRANCH SCOPED)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildTeacherViewTab(
    bool isDark,
    String branchId,
    BranchTimetableSettingsEntity settings,
    List<StaffEntity> branchTeachers,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    final allSlots = ref.watch(timetableSlotsProvider);
    final branchSlots = allSlots.where((s) => s.branchId == branchId && s.shiftName == _selectedShift).toList();

    final teacherSlots = branchSlots.where((s) =>
        s.teacherName.toLowerCase() == (_selectedTeacherName ?? '').toLowerCase()).toList();

    final timeSlots = settings.calculateTimeSlots(8);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.badge_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Select Branch Teacher:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 16),

                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTeacherName,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      onChanged: (val) {
                        setState(() {
                          _selectedTeacherName = val;
                        });
                      },
                      items: branchTeachers.map((t) {
                        return DropdownMenuItem(value: t.name, child: Text('${t.name} (${t.designation})'));
                      }).toList(),
                    ),
                  ),
                ),
                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Weekly Load: ${teacherSlots.length} Periods',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_selectedTeacherName == null)
            const GlassCard(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text('No teachers found in active branch staff directory.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            )
          else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 100,
                          alignment: Alignment.center,
                          child: Text(
                            'Day / Period',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ),
                        ...timeSlots.map((ts) {
                          return Container(
                            width: (ts.isBreak || ts.isAssembly) ? 100 : 150,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: ts.isAssembly
                                  ? Colors.amber.withValues(alpha: isDark ? 0.25 : 0.15)
                                  : (ts.isBreak
                                      ? (isDark ? Colors.grey[800]!.withValues(alpha: 0.3) : Colors.grey[300]!.withValues(alpha: 0.4))
                                      : AppColors.primarySurface),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              children: [
                                Text(ts.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: ts.isAssembly ? Colors.amber[800] : (ts.isBreak ? Colors.grey : AppColors.primary))),
                                const SizedBox(height: 2),
                                Text('${ts.startTime} - ${ts.endTime}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ...settings.workingDays.map((day) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              height: 80,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : Colors.grey[100],
                                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            ),

                            ...timeSlots.map((ts) {
                              if (ts.isAssembly || ts.isBreak) {
                                return Container(
                                  width: 100,
                                  height: 80,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[900]!.withValues(alpha: 0.5) : Colors.grey[200]!.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: RotatedBox(
                                      quarterTurns: 3,
                                      child: Text(ts.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: Colors.grey)),
                                    ),
                                  ),
                                );
                              }

                              final slotMatch = teacherSlots.firstWhere(
                                (s) => s.dayOfWeek == day && s.periodName == ts.name,
                                orElse: () => const TimetableSlotEntity(id: '', branchId: '', classId: '', sectionId: '', dayOfWeek: '', periodName: '', startTime: '', endTime: '', subjectName: '', teacherName: ''),
                              );

                              final hasSlot = slotMatch.id.isNotEmpty;

                              if (!hasSlot) {
                                return Container(
                                  width: 150,
                                  height: 80,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isDark ? Colors.grey[850]! : Colors.grey[300]!),
                                  ),
                                  child: const Center(
                                    child: Text('Free Period', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                  ),
                                );
                              }

                              final targetClass = classes.firstWhere((c) => c.id == slotMatch.classId, orElse: () => ClassEntity(id: '', branchId: '', departmentId: '', name: 'Class', code: '', maxStudentsCapacity: 0));
                              final targetSec = sections.firstWhere((s) => s.id == slotMatch.sectionId, orElse: () => SectionEntity(id: '', classId: '', name: 'A', roomNumber: '', classTeacher: '', maxStudentsCapacity: 0));

                              return Container(
                                width: 150,
                                height: 80,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${targetClass.name} - Sec ${targetSec.name}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      slotMatch.subjectName,
                                      style: const TextStyle(fontSize: 9, color: AppColors.primary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      slotMatch.roomNumber.isNotEmpty ? 'Room ${slotMatch.roomNumber}' : 'N/A',
                                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TAB 3: SUBJECT ALLOCATION & AI TIMETABLE GENERATOR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildAllocationsAndAITab(
    bool isDark,
    String branchId,
    BranchTimetableSettingsEntity settings,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
    List<StaffEntity> branchTeachers,
  ) {
    final subjects = ref.watch(branchSubjectsProvider).where((s) => s.branchId == branchId).toList();
    final allocations = ref.watch(subjectAllocationsProvider).where((a) => a.branchId == branchId).toList();
    final labs = ref.watch(branchLabsProvider).where((l) => l.branchId == branchId).toList();

    final selectedAllocClass = classes.firstWhere(
      (c) => c.id == (_selectedClassId ?? (classes.isNotEmpty ? classes.first.id : '')),
      orElse: () => ClassEntity(id: '', branchId: '', departmentId: '', name: 'Class 1', code: '', maxStudentsCapacity: 0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Generator Hero Banner
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Timetable Optimization Engine (Branch Scoped)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Automatically generate a complete, 100% conflict-free weekly schedule across all classes and sections using branch subject quotas, working days, lab allocations, and teacher pools.',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (allocations.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please add subject allocations for classes first.')),
                      );
                      return;
                    }
                    ref.read(timetableSlotsProvider.notifier).autoGenerateBranchTimetable(
                      branchId: branchId,
                      classes: classes,
                      sections: sections,
                      allocations: allocations,
                      settings: settings,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI Optimization Complete! Conflict-free timetable generated for current shift.')),
                    );
                  },
                  icon: const Icon(Icons.flash_on_rounded, size: 16),
                  label: const Text('Auto-Generate Timetable', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branch Subject Master List & Branch Labs
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Branch Subjects Master', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _showAddSubjectDialog(context, isDark, branchId),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (subjects.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: Text('No subjects added for this branch.', style: TextStyle(fontSize: 11, color: Colors.grey))),
                            )
                          else
                            ...subjects.map((sub) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkBg : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                        const SizedBox(height: 2),
                                        Text('${sub.code} • ${sub.category}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        ref.read(branchSubjectsProvider.notifier).removeSubject(sub.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Branch Science & IT Labs List
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Branch Labs & Practical Rooms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _showAddLabDialog(context, isDark, branchId),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (labs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: Text('No labs registered for this branch.', style: TextStyle(fontSize: 11, color: Colors.grey))),
                            )
                          else
                            ...labs.map((lab) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkBg : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.science_rounded, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(lab.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                        Text('${lab.building} (Cap: ${lab.capacity})', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Class-Wise Subject Quota Allocation
              Expanded(
                flex: 6,
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subject Period Allocation — ${selectedAllocClass.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBg : Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedAllocClass.id,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                                dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedClassId = val);
                                },
                                items: classes.map((c) {
                                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ...subjects.map((sub) {
                        final alloc = allocations.firstWhere(
                          (a) => a.classId == selectedAllocClass.id && a.subjectName == sub.name,
                          orElse: () => SubjectAllocationEntity(id: '', branchId: branchId, classId: selectedAllocClass.id, subjectName: sub.name, periodsPerWeek: 4, assignedTeacherName: branchTeachers.isNotEmpty ? branchTeachers.first.name : ''),
                        );

                        final periodsCtrl = TextEditingController(text: alloc.periodsPerWeek.toString());
                        String selectedTeacher = alloc.assignedTeacherName.isNotEmpty ? alloc.assignedTeacherName : (branchTeachers.isNotEmpty ? branchTeachers.first.name : '');

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 32,
                                  child: TextField(
                                    controller: periodsCtrl,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 11),
                                    decoration: const InputDecoration(labelText: 'Periods/Wk', isDense: true),
                                    onSubmitted: (val) {
                                      final numPeriods = int.tryParse(val) ?? 4;
                                      ref.read(subjectAllocationsProvider.notifier).setAllocation(
                                        branchId: branchId,
                                        classId: selectedAllocClass.id,
                                        subjectName: sub.name,
                                        periodsPerWeek: numPeriods,
                                        assignedTeacherName: selectedTeacher,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkBg : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: branchTeachers.any((t) => t.name == selectedTeacher) ? selectedTeacher : (branchTeachers.isNotEmpty ? branchTeachers.first.name : null),
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 10),
                                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                                      onChanged: (val) {
                                        if (val != null) {
                                          ref.read(subjectAllocationsProvider.notifier).setAllocation(
                                            branchId: branchId,
                                            classId: selectedAllocClass.id,
                                            subjectName: sub.name,
                                            periodsPerWeek: int.tryParse(periodsCtrl.text) ?? 4,
                                            assignedTeacherName: val,
                                          );
                                        }
                                      },
                                      items: branchTeachers.map((t) {
                                        return DropdownMenuItem(value: t.name, child: Text(t.name));
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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
  // TAB 4: SUBSTITUTION & ADJUSTMENT MANAGEMENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSubstitutionsTab(
    bool isDark,
    String branchId,
    BranchTimetableSettingsEntity settings,
    List<StaffEntity> branchTeachers,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    final allSlots = ref.watch(timetableSlotsProvider).where((s) => s.branchId == branchId && s.shiftName == _selectedShift).toList();
    final substitutions = ref.watch(timetableSubstitutionsProvider).where((s) => s.branchId == branchId).toList();

    final absentTeacherSlots = allSlots.where((s) =>
        s.teacherName.toLowerCase() == (_substTeacherName ?? '').toLowerCase()).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.published_with_changes_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                const Text('Select Absent / On-Leave Teacher:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 16),

                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _substTeacherName,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      onChanged: (val) {
                        setState(() => _substTeacherName = val);
                      },
                      items: branchTeachers.map((t) {
                        return DropdownMenuItem(value: t.name, child: Text(t.name));
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Text('Date: $_substDate', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Affected Lectures for $_substTeacherName',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 12),

                      if (absentTeacherSlots.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('No scheduled lectures for this teacher.', style: TextStyle(fontSize: 11, color: Colors.grey))),
                        )
                      else
                        ...absentTeacherSlots.map((slot) {
                          final cls = classes.firstWhere((c) => c.id == slot.classId, orElse: () => ClassEntity(id: '', branchId: '', departmentId: '', name: 'Class', code: '', maxStudentsCapacity: 0));
                          final sec = sections.firstWhere((s) => s.id == slot.sectionId, orElse: () => SectionEntity(id: '', classId: '', name: 'A', roomNumber: '', classTeacher: '', maxStudentsCapacity: 0));

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBg : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${slot.dayOfWeek} • ${slot.periodName} (${slot.startTime})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text('${cls.name} Section ${sec.name} — ${slot.subjectName}', style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _showAssignSubstituteDialog(context, isDark, branchId, slot, branchTeachers),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                                  child: const Text('Assign Sub', style: TextStyle(fontSize: 10, color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                flex: 5,
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Assigned Substitutions Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 12),

                      if (substitutions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('No substitution adjustments logged.', style: TextStyle(fontSize: 11, color: Colors.grey))),
                        )
                      else
                        ...substitutions.map((subst) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBg : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${subst.dayOfWeek} • ${subst.periodName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                      child: Text(subst.status, style: const TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Original: ${subst.originalTeacherName} ➔ Substitute: ${subst.substituteTeacherName}', style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                                const SizedBox(height: 2),
                                Text('Reason: ${subst.reason}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                              ],
                            ),
                          );
                        }),
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
  // TAB 5: BRANCH SCHEDULING & HOLIDAYS CONFIGURATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildBranchConfigTab(
    bool isDark,
    String branchId,
    BranchTimetableSettingsEntity settings,
  ) {
    final startController = TextEditingController(text: settings.schoolStartTime);
    final durationController = TextEditingController(text: settings.periodDurationMinutes.toString());
    final assemblyStartCtrl = TextEditingController(text: settings.assemblyStartTime);
    final assemblyEndCtrl = TextEditingController(text: settings.assemblyEndTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Working Days & Weekend Policy
              Expanded(
                flex: 4,
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Working Days & Weekend Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text('Configure branch working days and Saturday off policy.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: settings.weekendPolicy,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                        decoration: const InputDecoration(labelText: 'Saturday Policy', isDense: true),
                        dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                        items: const [
                          DropdownMenuItem(value: 'All Saturdays On', child: Text('All Saturdays Active')),
                          DropdownMenuItem(value: '2nd & 4th Saturday Off', child: Text('2nd & 4th Saturday Off')),
                          DropdownMenuItem(value: 'All Saturdays Off', child: Text('All Saturdays Off')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(branchTimetableSettingsProvider.notifier).updateSettings(
                              settings.copyWith(weekendPolicy: val),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((day) {
                        final isActive = settings.workingDays.contains(day);
                        return CheckboxListTile(
                          title: Text(day, style: const TextStyle(fontSize: 11)),
                          value: isActive,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          activeColor: AppColors.primary,
                          onChanged: (checked) {
                            var newList = List<String>.from(settings.workingDays);
                            if (checked == true && !newList.contains(day)) {
                              newList.add(day);
                            } else if (checked == false) {
                              newList.remove(day);
                            }
                            ref.read(branchTimetableSettingsProvider.notifier).updateSettings(
                              settings.copyWith(workingDays: newList),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    // Assembly & Timings
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Assembly & Period Timings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 12),

                          // Assembly Timings
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: TextField(
                                  controller: assemblyStartCtrl,
                                  style: const TextStyle(fontSize: 11),
                                  decoration: const InputDecoration(labelText: 'Assembly Start Time', isDense: true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 5,
                                child: TextField(
                                  controller: assemblyEndCtrl,
                                  style: const TextStyle(fontSize: 11),
                                  decoration: const InputDecoration(labelText: 'Assembly End Time', isDense: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Expanded(flex: 4, child: Text('School Day Start Time:', style: TextStyle(fontSize: 11))),
                              Expanded(
                                flex: 5,
                                child: TextField(
                                  controller: startController,
                                  style: const TextStyle(fontSize: 11),
                                  decoration: const InputDecoration(labelText: 'e.g. 08:15 AM', isDense: true, suffixIcon: Icon(Icons.access_time_rounded, size: 16)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Expanded(flex: 4, child: Text('Period Duration (mins):', style: TextStyle(fontSize: 11))),
                              Expanded(
                                flex: 5,
                                child: TextField(
                                  controller: durationController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 11),
                                  decoration: const InputDecoration(labelText: 'e.g. 45', isDense: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ref.read(branchTimetableSettingsProvider.notifier).updateSettings(
                                  settings.copyWith(
                                    assemblyStartTime: assemblyStartCtrl.text.trim(),
                                    assemblyEndTime: assemblyEndCtrl.text.trim(),
                                    schoolStartTime: startController.text.trim(),
                                    periodDurationMinutes: int.tryParse(durationController.text) ?? 45,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Assembly & Period timings updated.')),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 11)),
                              child: const Text('Save Timings Config'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Breaks & Holidays
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('School Breaks / Recess', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _showAddBreakDialog(context, isDark, branchId),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (settings.breaks.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: Text('No breaks configured. Add recess or lunch breaks.', style: TextStyle(fontSize: 11, color: Colors.grey))),
                            )
                          else
                            ...settings.breaks.map((brk) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkBg : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(brk.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                        const SizedBox(height: 2),
                                        Text('${brk.startTime} - ${brk.endTime} (After Period ${brk.afterPeriodNumber})', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        ref.read(branchTimetableSettingsProvider.notifier).removeBreak(branchId, brk.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Branch School Day Timeline Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                const Text('A visual projection of how morning assembly, lectures, and breaks flow chronologically.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 16),

                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: settings.calculateTimeSlots(8).map((ts) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: ts.isAssembly
                              ? Colors.amber.withValues(alpha: isDark ? 0.25 : 0.15)
                              : (ts.isBreak
                                  ? (isDark ? Colors.amber[900]!.withValues(alpha: 0.2) : Colors.amber[50])
                                  : AppColors.primarySurface),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: ts.isAssembly
                                ? Colors.amber
                                : (ts.isBreak ? Colors.amber.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.5)),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(ts.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: ts.isAssembly ? Colors.amber[800] : (ts.isBreak ? Colors.amber[800] : AppColors.primary))),
                            const SizedBox(height: 2),
                            Text('${ts.startTime} - ${ts.endTime}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Classrooms Manager
              Expanded(
                flex: 1,
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Branch Classrooms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showAddClassroomDialog(context, isDark, branchId),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Define classrooms available in this branch.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(height: 12),
                      
                      // List of Classrooms
                      Consumer(
                        builder: (context, ref, child) {
                          final classrooms = ref.watch(branchClassroomsProvider).where((rm) => rm.branchId == branchId).toList();
                          if (classrooms.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text('No classrooms registered yet.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: classrooms.length,
                            itemBuilder: (context, index) {
                              final rm = classrooms[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkBg : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(rm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                        Text('${rm.building} • Cap: ${rm.capacity}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        ref.read(branchClassroomsProvider.notifier).removeClassroom(rm.id);
                                      },
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
              ),
              const SizedBox(width: 16),
              
              // Resources Manager
              Expanded(
                flex: 1,
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Shared Resource Pool', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showAddResourceDialog(context, isDark, branchId),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Manage projectors, smart boards, and AV devices.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(height: 12),
                      
                      // List of Resources
                      Consumer(
                        builder: (context, ref, child) {
                          final resources = ref.watch(branchResourcesProvider).where((r) => r.branchId == branchId).toList();
                          if (resources.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text('No resources registered yet.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: resources.length,
                            itemBuilder: (context, index) {
                              final res = resources[index];
                              final isAvail = res.status == 'Available';
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkBg : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(res.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                        Text('Type: ${res.type}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            ref.read(branchResourcesProvider.notifier).toggleResourceStatus(res.id);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isAvail ? Colors.green.withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: isAvail ? Colors.green : Colors.amber),
                                            ),
                                            child: Text(
                                              res.status,
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: isAvail ? Colors.green : Colors.amber[805]!,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            ref.read(branchResourcesProvider.notifier).removeResource(res.id);
                                          },
                                        ),
                                      ],
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddClassroomDialog(BuildContext context, bool isDark, String branchId) {
    final nameCtrl = TextEditingController();
    final bldCtrl = TextEditingController(text: 'Main Block');
    final capCtrl = TextEditingController(text: '40');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          title: const Text('Add Classroom', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Room Name / Number (e.g. Room 204)', isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: bldCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Building Wing', isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: capCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Seating Capacity', isDense: true)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  ref.read(branchClassroomsProvider.notifier).addClassroom(
                    branchId: branchId,
                    name: nameCtrl.text.trim(),
                    building: bldCtrl.text.trim(),
                    capacity: int.tryParse(capCtrl.text) ?? 40,
                  );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Add Classroom', style: TextStyle(fontSize: 11, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddResourceDialog(BuildContext context, bool isDark, String branchId) {
    final nameCtrl = TextEditingController();
    String selectedType = 'Projector';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              title: const Text('Register Equipment Resource', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Resource Name (e.g. BenQ Projector 3)', isDense: true)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                    decoration: const InputDecoration(labelText: 'Resource Type', isDense: true),
                    dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                    items: const [
                      DropdownMenuItem(value: 'Projector', child: Text('Projector')),
                      DropdownMenuItem(value: 'Audio', child: Text('Audio / Speaker')),
                      DropdownMenuItem(value: 'Computing', child: Text('Computing / Laptops')),
                      DropdownMenuItem(value: 'Smart Board', child: Text('Smart Board')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedType = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      ref.read(branchResourcesProvider.notifier).addResource(
                        branchId: branchId,
                        name: nameCtrl.text.trim(),
                        type: selectedType,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Add Resource', style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // DIALOGS & ACTION HANDLERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildPeriodCard(
    bool isDark,
    TimetableSlotEntity slot,
    String branchId,
    BranchTimetableSettingsEntity settings,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    Color colorTheme = AppColors.primary;
    if (slot.isLabSession) {
      colorTheme = Colors.purple;
    } else if (slot.subjectName.toLowerCase().contains('math')) {
      colorTheme = Colors.indigo;
    } else if (slot.subjectName.toLowerCase().contains('eng')) {
      colorTheme = Colors.amber[700]!;
    } else if (slot.subjectName.toLowerCase().contains('sci') || slot.subjectName.toLowerCase().contains('phys')) {
      colorTheme = Colors.teal;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorTheme.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorTheme.withValues(alpha: 0.5), width: slot.isLabSession ? 2 : 1),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (slot.isLabSession) const Icon(Icons.science_rounded, size: 12, color: Colors.purple),
                  if (slot.isLabSession) const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      slot.subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: isDark ? Colors.white : colorTheme.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(Icons.person_outline_rounded, size: 10, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      slot.teacherName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(Icons.room_outlined, size: 10, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      slot.roomNumber.isNotEmpty ? slot.roomNumber : 'N/A',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              if (slot.allocatedResourceIds.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.devices_other_rounded, size: 10, color: colorTheme),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Resources: ${slot.allocatedResourceIds.length}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 8, color: colorTheme, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          Positioned(
            right: -6,
            top: -6,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 10, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showScheduleDialog(context, isDark, branchId, settings, classes, sections, slot),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 10, color: Colors.redAccent),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    ref.read(timetableSlotsProvider.notifier).removeSlot(slot.id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPeriodCard(
    bool isDark,
    String day,
    String periodName,
    String branchId,
    BranchTimetableSettingsEntity settings,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
  ) {
    return InkWell(
      onTap: () {
        final dialogSlot = TimetableSlotEntity(
          id: '', branchId: branchId, classId: _selectedClassId ?? '', sectionId: _selectedSectionId ?? '',
          dayOfWeek: day, periodName: periodName, startTime: '', endTime: '', subjectName: '', teacherName: '',
        );
        _showScheduleDialog(context, isDark, branchId, settings, classes, sections, dialogSlot);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[350]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded, size: 14, color: isDark ? Colors.grey[600] : Colors.grey[400]),
              const SizedBox(height: 4),
              Text('Schedule', style: TextStyle(fontSize: 8, color: isDark ? Colors.grey[600] : Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context, bool isDark, String branchId) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    String category = 'Core';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          title: const Text('Add Branch Subject', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Subject Name (e.g. Biology)', isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: codeCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Subject Code (e.g. BIO-101)', isDense: true)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                decoration: const InputDecoration(labelText: 'Category', isDense: true),
                dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                items: const [
                  DropdownMenuItem(value: 'Core', child: Text('Core Subject')),
                  DropdownMenuItem(value: 'Elective', child: Text('Elective Subject')),
                  DropdownMenuItem(value: 'Lab', child: Text('Practical / Lab')),
                  DropdownMenuItem(value: 'Activity', child: Text('Co-Curricular / Activity')),
                ],
                onChanged: (val) {
                  if (val != null) category = val;
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  ref.read(branchSubjectsProvider.notifier).addSubject(
                    branchId: branchId,
                    name: nameCtrl.text.trim(),
                    code: codeCtrl.text.trim(),
                    category: category,
                  );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save Subject', style: TextStyle(fontSize: 11, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddLabDialog(BuildContext context, bool isDark, String branchId) {
    final nameCtrl = TextEditingController();
    final bldCtrl = TextEditingController(text: 'Science Block A');
    final capCtrl = TextEditingController(text: '40');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          title: const Text('Add Branch Science / IT Lab', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Lab Name (e.g. Physics Lab 2)', isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: bldCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Building / Floor Location', isDense: true)),
              const SizedBox(height: 12),
              TextField(controller: capCtrl, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Student Capacity', isDense: true)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  ref.read(branchLabsProvider.notifier).addLab(
                    branchId: branchId,
                    name: nameCtrl.text.trim(),
                    building: bldCtrl.text.trim(),
                    capacity: int.tryParse(capCtrl.text) ?? 40,
                  );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Register Lab', style: TextStyle(fontSize: 11, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAssignSubstituteDialog(
    BuildContext context,
    bool isDark,
    String branchId,
    TimetableSlotEntity slot,
    List<StaffEntity> branchTeachers,
  ) {
    final availableTeachers = branchTeachers.where((t) => t.name.toLowerCase() != slot.teacherName.toLowerCase()).toList();
    String? selectedSubstTeacher = availableTeachers.isNotEmpty ? availableTeachers.first.name : null;
    final reasonCtrl = TextEditingController(text: 'Casual Leave');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          title: const Text('Assign Substitution Teacher', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Original Lecture: ${slot.dayOfWeek} ${slot.periodName} (${slot.subjectName})', style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
              Text('Absent Teacher: ${slot.teacherName}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: selectedSubstTeacher,
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                decoration: const InputDecoration(labelText: 'Select Free Substitute Teacher', isDense: true),
                dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                items: availableTeachers.map((t) {
                  return DropdownMenuItem(value: t.name, child: Text(t.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedSubstTeacher = val;
                },
              ),
              const SizedBox(height: 12),
              TextField(controller: reasonCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Reason for Adjustment', isDense: true)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
            ElevatedButton(
              onPressed: () {
                if (selectedSubstTeacher != null) {
                  ref.read(timetableSubstitutionsProvider.notifier).assignSubstitution(
                    branchId: branchId,
                    date: _substDate,
                    dayOfWeek: slot.dayOfWeek,
                    periodName: slot.periodName,
                    classId: slot.classId,
                    sectionId: slot.sectionId,
                    originalTeacherName: slot.teacherName,
                    substituteTeacherName: selectedSubstTeacher!,
                    reason: reasonCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Substitution assigned successfully.')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Confirm Substitution', style: TextStyle(fontSize: 11, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddBreakDialog(BuildContext context, bool isDark, String branchId) {
    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: '10:00 AM');
    final endCtrl = TextEditingController(text: '10:30 AM');
    int afterPeriod = 3;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          title: const Text('Add Recess / Break Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Break Name (e.g. Lunch Break)', isDense: true)),
                const SizedBox(height: 12),
                TextField(controller: startCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Start Time (e.g. 10:15 AM)', isDense: true)),
                const SizedBox(height: 12),
                TextField(controller: endCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'End Time (e.g. 10:45 AM)', isDense: true)),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: afterPeriod,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                  decoration: const InputDecoration(labelText: 'Occurs After Period', isDense: true),
                  dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                  items: List.generate(8, (index) => index + 1).map((periodNum) {
                    return DropdownMenuItem(value: periodNum, child: Text('Period $periodNum'));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) afterPeriod = val;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  ref.read(branchTimetableSettingsProvider.notifier).addBreak(
                    branchId,
                    BranchBreakEntity(
                      id: 'BRK-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      startTime: startCtrl.text.trim(),
                      endTime: endCtrl.text.trim(),
                      afterPeriodNumber: afterPeriod,
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Add Break', style: TextStyle(fontSize: 11, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showScheduleDialog(
    BuildContext context,
    bool isDark,
    String branchId,
    BranchTimetableSettingsEntity settings,
    List<ClassEntity> classes,
    List<SectionEntity> sections,
    TimetableSlotEntity? existingSlot,
  ) {
    final isEditing = existingSlot != null && existingSlot.id.isNotEmpty;

    final allStaff = ref.read(staffProvider);
    final teachers = allStaff.where((s) => s.branchId == branchId && (s.role.toLowerCase() == 'teacher' || s.designation.toLowerCase().contains('teacher') || s.role.toLowerCase() == 'hod')).toList();
    final branchLabs = ref.read(branchLabsProvider).where((l) => l.branchId == branchId).toList();
    final classrooms = ref.read(branchClassroomsProvider).where((rm) => rm.branchId == branchId).toList();
    final resources = ref.read(branchResourcesProvider).where((r) => r.branchId == branchId && r.status == 'Available').toList();

    String selectedDay = existingSlot?.dayOfWeek ?? settings.workingDays.first;
    String selectedPeriodName = existingSlot?.periodName ?? 'Period 1';

    final subjectCtrl = TextEditingController(text: existingSlot?.subjectName);
    String selectedRoomName = existingSlot?.roomNumber ?? '';
    bool isLabSession = existingSlot?.isLabSession ?? false;
    bool isDoublePeriod = existingSlot?.isDoublePeriod ?? false;
    List<String> selectedResourceIds = List<String>.from(existingSlot?.allocatedResourceIds ?? []);

    String? selectedTeacherName = existingSlot?.teacherName;
    if (selectedTeacherName == null && teachers.isNotEmpty) {
      selectedTeacherName = teachers.first.name;
    }

    _conflictError = null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final computedSlots = settings.calculateTimeSlots(8).where((ts) => !ts.isBreak && !ts.isAssembly).toList();
            final matchedTime = computedSlots.firstWhere(
              (ts) => ts.name == selectedPeriodName,
              orElse: () => CalculatedTimeSlot(periodNumber: 1, startTime: '08:15 AM', endTime: '09:00 AM', isBreak: false, name: 'Period 1'),
            );

            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              title: Text(isEditing ? 'Edit Lecture Schedule' : 'Schedule Lecture / Lab Slot', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Scheduling for: Class ${classes.firstWhere((c) => c.id == (existingSlot?.classId ?? _selectedClassId)).name} - ${sections.firstWhere((s) => s.id == (existingSlot?.sectionId ?? _selectedSectionId), orElse: () => const SectionEntity(id:'', classId:'', name:'A', roomNumber:'', classTeacher:'', maxStudentsCapacity:40)).name}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: selectedDay,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Day of Week', isDense: true),
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      items: settings.workingDays.map((day) {
                        return DropdownMenuItem(value: day, child: Text(day));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedDay = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: selectedPeriodName,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Period Slot', isDense: true),
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      items: computedSlots.map((ts) {
                        return DropdownMenuItem(value: ts.name, child: Text('${ts.name} (${ts.startTime} - ${ts.endTime})'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedPeriodName = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Lab & Double Period Toggles
                    Row(
                      children: [
                        FilterChip(
                          label: const Text('Science/IT Lab Session', style: TextStyle(fontSize: 10)),
                          selected: isLabSession,
                          avatar: Icon(Icons.science_rounded, size: 14, color: isLabSession ? Colors.white : AppColors.primary),
                          selectedColor: Colors.purple,
                          onSelected: (selected) {
                            setDialogState(() {
                              isLabSession = selected;
                              if (selected && branchLabs.isNotEmpty) {
                                selectedRoomName = branchLabs.first.name;
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Double Period', style: TextStyle(fontSize: 10)),
                          selected: isDoublePeriod,
                          avatar: Icon(Icons.schedule_rounded, size: 14, color: isDoublePeriod ? Colors.white : AppColors.primary),
                          selectedColor: AppColors.primary,
                          onSelected: (selected) {
                            setDialogState(() => isDoublePeriod = selected);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(controller: subjectCtrl, style: const TextStyle(fontSize: 11), decoration: const InputDecoration(labelText: 'Subject Name (e.g. Computer Practical)', isDense: true)),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: selectedTeacherName,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Assigned Teacher', isDense: true),
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      items: teachers.map((teacher) {
                        return DropdownMenuItem(value: teacher.name, child: Text('${teacher.name} (${teacher.designation})'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedTeacherName = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: selectedRoomName.isEmpty ? null : selectedRoomName,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Classroom / Lab Allocation', isDense: true),
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      items: [
                        const DropdownMenuItem(value: '', child: Text('No Classroom Allocated')),
                        ...classrooms.map((rm) {
                          return DropdownMenuItem(value: rm.name, child: Text('${rm.name} (${rm.building}, Cap: ${rm.capacity})'));
                        }),
                        if (isLabSession) ...branchLabs.map((l) {
                          return DropdownMenuItem(value: l.name, child: Text('${l.name} (${l.building}, Cap: ${l.capacity})'));
                        }),
                      ],
                      onChanged: (val) {
                        setDialogState(() => selectedRoomName = val ?? '');
                      },
                    ),
                    const SizedBox(height: 12),

                    const Text('Allocate Equipment Resources:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 6),
                    if (resources.isEmpty)
                      const Text('No available resources in this branch.', style: TextStyle(fontSize: 9, color: Colors.grey))
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        decoration: BoxDecoration(
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          children: resources.map((res) {
                            final isChecked = selectedResourceIds.contains(res.id);
                            return CheckboxListTile(
                              title: Text('${res.name} (${res.type})', style: const TextStyle(fontSize: 10)),
                              value: isChecked,
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              activeColor: AppColors.primary,
                              onChanged: (checked) {
                                setDialogState(() {
                                  if (checked == true) {
                                    selectedResourceIds.add(res.id);
                                  } else {
                                    selectedResourceIds.remove(res.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 16),

                    if (_conflictError != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(_conflictError!, style: const TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
                ElevatedButton(
                  onPressed: () {
                    final targetClass = existingSlot?.classId ?? _selectedClassId!;
                    final targetSection = existingSlot?.sectionId ?? _selectedSectionId!;
                    final subject = subjectCtrl.text.trim();

                    if (subject.isEmpty || selectedTeacherName == null) {
                      setDialogState(() {
                        _conflictError = 'Subject and Teacher must be specified.';
                      });
                      return;
                    }

                    final allSlots = ref.read(timetableSlotsProvider);

                    // Conflict Check 1: Teacher Conflict
                    final teacherConflictingSlot = allSlots.where((slot) {
                      if (isEditing && slot.id == existingSlot.id) return false;
                      return slot.branchId == branchId &&
                             slot.shiftName == _selectedShift &&
                             slot.dayOfWeek == selectedDay &&
                             slot.periodName == selectedPeriodName &&
                             slot.teacherName.toLowerCase() == selectedTeacherName!.toLowerCase();
                    }).firstOrNull;

                    if (teacherConflictingSlot != null) {
                      final confClass = classes.firstWhere((c) => c.id == teacherConflictingSlot.classId, orElse: () => ClassEntity(id:'', branchId:'', departmentId:'', name:'Unknown Class', code:'', maxStudentsCapacity:0));
                      final confSec = sections.firstWhere((s) => s.id == teacherConflictingSlot.sectionId, orElse: () => SectionEntity(id:'', classId:'', name:'A', roomNumber:'', classTeacher:'', maxStudentsCapacity:0));
                      setDialogState(() {
                        _conflictError = 'Teacher Conflict: $selectedTeacherName is already scheduled for Class ${confClass.name} - Section ${confSec.name} during $selectedPeriodName on $selectedDay.';
                      });
                      return;
                    }

                    // Conflict Check 2: Classroom Clash
                    if (selectedRoomName.isNotEmpty) {
                      final roomConflictingSlot = allSlots.where((slot) {
                        if (isEditing && slot.id == existingSlot.id) return false;
                        return slot.branchId == branchId &&
                               slot.shiftName == _selectedShift &&
                               slot.dayOfWeek == selectedDay &&
                               slot.periodName == selectedPeriodName &&
                               slot.roomNumber.toLowerCase() == selectedRoomName.toLowerCase();
                      }).firstOrNull;

                      if (roomConflictingSlot != null) {
                        final confClass = classes.firstWhere((c) => c.id == roomConflictingSlot.classId, orElse: () => ClassEntity(id:'', branchId:'', departmentId:'', name:'Unknown Class', code:'', maxStudentsCapacity:0));
                        final confSec = sections.firstWhere((s) => s.id == roomConflictingSlot.sectionId, orElse: () => SectionEntity(id:'', classId:'', name:'A', roomNumber:'', classTeacher:'', maxStudentsCapacity:0));
                        setDialogState(() {
                          _conflictError = 'Classroom Clash: Room $selectedRoomName is already occupied by Class ${confClass.name} - Section ${confSec.name} during $selectedPeriodName on $selectedDay.';
                        });
                        return;
                      }
                    }

                    // Conflict Check 3: Resource Clash
                    for (final resId in selectedResourceIds) {
                      final resourceConflictingSlot = allSlots.where((slot) {
                        if (isEditing && slot.id == existingSlot.id) return false;
                        return slot.branchId == branchId &&
                               slot.dayOfWeek == selectedDay &&
                               slot.periodName == selectedPeriodName &&
                               slot.shiftName == _selectedShift &&
                               slot.allocatedResourceIds.contains(resId);
                      }).firstOrNull;

                      if (resourceConflictingSlot != null) {
                        final confClass = classes.firstWhere((c) => c.id == resourceConflictingSlot.classId, orElse: () => ClassEntity(id:'', branchId:'', departmentId:'', name:'Unknown Class', code:'', maxStudentsCapacity:0));
                        final confSec = sections.firstWhere((s) => s.id == resourceConflictingSlot.sectionId, orElse: () => SectionEntity(id:'', classId:'', name:'A', roomNumber:'', classTeacher:'', maxStudentsCapacity:0));
                        final targetResName = resources.firstWhere((r) => r.id == resId, orElse: () => BranchResourceEntity(id: '', branchId: '', name: 'Resource', type: '')).name;
                        setDialogState(() {
                          _conflictError = 'Resource Clash: "$targetResName" is already allocated to Class ${confClass.name} - Section ${confSec.name} during $selectedPeriodName on $selectedDay.';
                        });
                        return;
                      }
                    }

                    if (isEditing) {
                      ref.read(timetableSlotsProvider.notifier).removeSlot(existingSlot.id);
                    }

                    ref.read(timetableSlotsProvider.notifier).addSlot(
                      branchId: branchId,
                      classId: targetClass,
                      sectionId: targetSection,
                      dayOfWeek: selectedDay,
                      periodName: selectedPeriodName,
                      startTime: matchedTime.startTime,
                      endTime: matchedTime.endTime,
                      subjectName: subject,
                      teacherName: selectedTeacherName!,
                      roomNumber: selectedRoomName,
                      isLabSession: isLabSession,
                      isDoublePeriod: isDoublePeriod,
                      shiftName: _selectedShift,
                      allocatedResourceIds: selectedResourceIds,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Schedule updated.' : 'Lecture scheduled successfully.')),
                    );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(isEditing ? 'Update Schedule' : 'Confirm Schedule', style: const TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildToolbarActions(
    BuildContext context,
    bool isDark,
    String branchId,
    BranchTimetableSettingsEntity settings,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          // Export Button
          Expanded(
            child: InkWell(
              onTap: () => _showExportDialog(context, isDark, branchId),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('Export PDF/Excel', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primary)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Share Button
          Expanded(
            child: InkWell(
              onTap: () => _showShareDialog(context, isDark, branchId),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share_rounded, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Text('Share Schedule', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.green)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Calendar Sync Button
          Expanded(
            child: InkWell(
              onTap: () => _showCalendarSyncDialog(context, isDark, branchId),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 14, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text('Calendar Sync', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Daily Alerts Button
          Expanded(
            child: InkWell(
              onTap: () => _showDailyAlertsDialog(context, isDark, branchId),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_active_rounded, size: 14, color: Colors.purple),
                    const SizedBox(width: 6),
                    Text('Daily Alerts', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.purple)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, bool isDark, String branchId) {
    String selectedFormat = 'PDF Document (.pdf)';
    String selectedScope = 'Class-Wise Schedule';
    bool includeBreaks = true;
    bool includeRooms = true;
    bool isGenerating = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.download_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Export Branch Timetable', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export settings will generate high-quality outputs scoped strictly to this branch.',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: selectedScope,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                      decoration: const InputDecoration(labelText: 'Export Scope', isDense: true),
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      items: const [
                        DropdownMenuItem(value: 'Class-Wise Schedule', child: Text('Class-Wise Schedule (Selected Class)')),
                        DropdownMenuItem(value: 'Teacher-Wise Load', child: Text('Teacher-Wise Schedules (All Teachers)')),
                        DropdownMenuItem(value: 'Branch Master Plan', child: Text('Branch Master Matrix Grid')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedScope = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: selectedFormat,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                      decoration: const InputDecoration(labelText: 'File Format', isDense: true),
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      items: const [
                        DropdownMenuItem(value: 'PDF Document (.pdf)', child: Text('PDF Document (.pdf) - Print Ready')),
                        DropdownMenuItem(value: 'Excel Spreadsheet (.xlsx)', child: Text('Excel Spreadsheet (.xlsx) - Data Plan')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedFormat = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text('Include Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    CheckboxListTile(
                      title: const Text('Break Periods & Assemblies', style: TextStyle(fontSize: 11)),
                      value: includeBreaks,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      onChanged: (val) => setDialogState(() => includeBreaks = val ?? true),
                    ),
                    CheckboxListTile(
                      title: const Text('Classroom & Lab Room Names', style: TextStyle(fontSize: 11)),
                      value: includeRooms,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      onChanged: (val) => setDialogState(() => includeRooms = val ?? true),
                    ),
                    const SizedBox(height: 12),

                    if (isGenerating) ...[
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(strokeWidth: 2),
                            SizedBox(height: 8),
                            Text('Compiling vector layout data...', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBg : Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedFormat.contains('PDF') ? Icons.picture_as_pdf_rounded : Icons.table_chart_rounded,
                              color: selectedFormat.contains('PDF') ? Colors.redAccent : Colors.green,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedFormat.contains('PDF') ? 'SMS_BR001_CLS_10_A.pdf' : 'SMS_BR001_CLS_10_A.xlsx',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                  const Text('Ready to build & download • 1.2 MB', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
                ElevatedButton.icon(
                  onPressed: isGenerating
                      ? null
                      : () {
                          setDialogState(() => isGenerating = true);
                          Future.delayed(const Duration(milliseconds: 1200), () {
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green[700],
                                  content: Text('Downloaded $selectedScope successfully in $selectedFormat format!'),
                                ),
                              );
                            }
                          });
                        },
                  icon: const Icon(Icons.download_rounded, size: 14, color: Colors.white),
                  label: const Text('Build & Download', style: TextStyle(fontSize: 11, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showShareDialog(BuildContext context, bool isDark, String branchId) {
    bool isBroadcasting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.share_rounded, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Share Branch Timetable', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share timetable with students & parents of this branch only. No inter-branch access allowed.',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Copy Feed URL Section
                    const Text('Live Calendar Subscription URL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBg : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'https://sms.symbosys.edu/shared/timetable/$branchId/c10a',
                              style: const TextStyle(fontSize: 9, fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy_all_rounded, size: 14, color: Colors.green),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Live share link copied to clipboard.')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Portals Toggle Section
                    const Text('Portal Broadcast Settings:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    SwitchListTile(
                      title: const Text('Publish on Student Portal Feed', style: TextStyle(fontSize: 11)),
                      subtitle: const Text('Visible to students of BR-001 only', style: TextStyle(fontSize: 9)),
                      value: _studentPortalShared,
                      dense: true,
                      activeThumbColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => _studentPortalShared = val);
                        setDialogState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Publish on Parent Portal Feed', style: TextStyle(fontSize: 11)),
                      subtitle: const Text('Visible to parents of BR-001 only', style: TextStyle(fontSize: 9)),
                      value: _parentPortalShared,
                      dense: true,
                      activeThumbColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => _parentPortalShared = val);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 12),

                    // Trigger BroadCast Alert
                    if (isBroadcasting) ...[
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                            SizedBox(height: 8),
                            Text('Sending SMS/Push notifications to branch users...', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setDialogState(() => isBroadcasting = true);
                            Future.delayed(const Duration(milliseconds: 1000), () {
                              setState(() {
                                _shareLogs.insert(0, {
                                  'time': 'Aug 14, 2026 ${DateFormat('hh:mm a').format(DateTime.now())}',
                                  'channel': 'SMS & Email Alert',
                                  'scope': 'Class 10-A Students & Parents',
                                  'status': 'Broadcast Sent (80 alerts)',
                                });
                              });
                              if (ctx.mounted) {
                                setDialogState(() => isBroadcasting = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Timetable broadcast alert sent to Class 10-A students & parents!')),
                                );
                              }
                            });
                          },
                          icon: const Icon(Icons.notifications_active_rounded, size: 14),
                          label: const Text('Broadcast Live Alert Now', style: TextStyle(fontSize: 11, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    const Text('Previous Sharing History Logs:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: ListView(
                        shrinkWrap: true,
                        children: _shareLogs.map((log) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${log['time']} • ${log['channel']}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    Text('Target: ${log['scope']}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                  child: Text(log['status']!, style: const TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(fontSize: 11))),
              ],
            );
          },
        );
      },
    );
  }

  void _showCalendarSyncDialog(BuildContext context, bool isDark, String branchId) {
    bool isSyncing = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.sync_rounded, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Calendar Integration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sync your branch class schedule events directly into personal external calendars.',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text('Google Calendar Auto-Sync', style: TextStyle(fontSize: 11)),
                      subtitle: const Text('Syncs lectures automatically on save', style: TextStyle(fontSize: 9)),
                      value: _googleSyncEnabled,
                      activeThumbColor: Colors.blue,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => _googleSyncEnabled = val);
                        setDialogState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Outlook Calendar Sync', style: TextStyle(fontSize: 11)),
                      subtitle: const Text('Syncs with Office 365 Exchange account', style: TextStyle(fontSize: 9)),
                      value: _outlookSyncEnabled,
                      activeThumbColor: Colors.blue,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => _outlookSyncEnabled = val);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text('iCal Subscriptions Address (Apple/Google):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBg : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'webcal://sms.symbosys.edu/feeds/$branchId/c10a.ics',
                              style: const TextStyle(fontSize: 9, fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy_all_rounded, size: 14, color: Colors.blue),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('iCalendar subscription feed link copied.')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (isSyncing) ...[
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                            SizedBox(height: 8),
                            Text('Re-pushing 42 calendar events...', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setDialogState(() => isSyncing = true);
                            Future.delayed(const Duration(milliseconds: 1000), () {
                              if (ctx.mounted) {
                                setDialogState(() => isSyncing = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sync completed successfully! 42 events updated in external accounts.')),
                                );
                              }
                            });
                          },
                          icon: const Icon(Icons.sync_rounded, size: 14),
                          label: const Text('Force Manual Re-Sync Now', style: TextStyle(fontSize: 11, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Dismiss', style: TextStyle(fontSize: 11))),
              ],
            );
          },
        );
      },
    );
  }

  void _showDailyAlertsDialog(BuildContext context, bool isDark, String branchId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.notifications_active_rounded, color: Colors.purple),
                  SizedBox(width: 8),
                  Text('Daily Agenda Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Schedule automated alerts to push the daily lecture timetable details to branch students & parents.',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text('Enable Daily Morning Notifications', style: TextStyle(fontSize: 11)),
                      value: _dailyAlertsEnabled,
                      activeThumbColor: Colors.purple,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => _dailyAlertsEnabled = val);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 12),

                    if (_dailyAlertsEnabled) ...[
                      Row(
                        children: [
                          const Expanded(flex: 5, child: Text('Target Delivery Time:', style: TextStyle(fontSize: 11))),
                          Expanded(
                            flex: 5,
                            child: DropdownButtonFormField<String>(
                              initialValue: _dailyAlertTime,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11),
                              decoration: const InputDecoration(isDense: true),
                              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                              items: const [
                                DropdownMenuItem(value: '07:00 AM', child: Text('07:00 AM')),
                                DropdownMenuItem(value: '07:30 AM', child: Text('07:30 AM')),
                                DropdownMenuItem(value: '08:00 AM', child: Text('08:00 AM')),
                                DropdownMenuItem(value: '08:30 AM', child: Text('08:30 AM')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _dailyAlertTime = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text('Delivery Alert Channels:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                      CheckboxListTile(
                        title: const Text('Push Notification (Mobile App)', style: TextStyle(fontSize: 11)),
                        value: _alertPush,
                        dense: true,
                        activeColor: Colors.purple,
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) => setDialogState(() => setState(() => _alertPush = val ?? true)),
                      ),
                      CheckboxListTile(
                        title: const Text('Email Notification Inbox', style: TextStyle(fontSize: 11)),
                        value: _alertEmail,
                        dense: true,
                        activeColor: Colors.purple,
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) => setDialogState(() => setState(() => _alertEmail = val ?? true)),
                      ),
                      CheckboxListTile(
                        title: const Text('SMS / WhatsApp Alert', style: TextStyle(fontSize: 11)),
                        value: _alertSms,
                        dense: true,
                        activeColor: Colors.purple,
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) => setDialogState(() => setState(() => _alertSms = val ?? false)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text('Daily Notification Alert History Logs:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: ListView(
                        shrinkWrap: true,
                        children: _alertLogs.map((log) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(log['time']!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    Text('Recipients: ${log['sent']}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('SENT', style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Daily notifications settings updated.')),
                    );
                  },
                  child: const Text('Save Settings', style: TextStyle(fontSize: 11)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

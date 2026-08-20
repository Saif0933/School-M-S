import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../../academic/providers.dart';
import '../../admissions_providers.dart';

class AdmissionsManagementPage extends ConsumerStatefulWidget {
  const AdmissionsManagementPage({super.key});

  @override
  ConsumerState<AdmissionsManagementPage> createState() => _AdmissionsManagementPageState();
}

class _AdmissionsManagementPageState extends ConsumerState<AdmissionsManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Inquiry Form
  final _nameCtrl = TextEditingController();
  final _guardianCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _selectedCategory = 'General';
  String _selectedLeadSource = 'Website';
  String _selectedClassId = 'CLS-001';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _guardianCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';
    final applications = ref.watch(admissionsProvider).where((a) => a.branchId == activeBranchId).toList();

    return Scaffold(
      body: Column(
        children: [
          // Sub Header with summary & Prospectus Download
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;
              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Admissions Dashboard: ${user?.activeBranch?.branchName ?? "Primary Campus"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total Applications Filed: ${applications.length} | Completed: ${applications.where((a) => a.status == "Approved").length}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              );

              final actionButton = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => _simulateProspectusDownload(context, activeBranchId),
                icon: const Icon(Icons.download_rounded, color: Colors.white, size: 16),
                label: const Text('Download Branch Prospectus', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              );

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleWidget,
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: actionButton,
                          ),
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

          // Custom TabBar
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
                Tab(icon: Icon(Icons.person_search_rounded, size: 16), text: 'Leads & Inquiries'),
                Tab(icon: Icon(Icons.quiz_rounded, size: 16), text: 'Exams & Merit Lists'),
                Tab(icon: Icon(Icons.assignment_ind_rounded, size: 16), text: 'Interviews & Verification'),
                Tab(icon: Icon(Icons.event_seat_rounded, size: 16), text: 'Seat Availability'),
                Tab(icon: Icon(Icons.auto_awesome_motion_rounded, size: 16), text: 'Database Migration'),
                Tab(icon: Icon(Icons.analytics_rounded, size: 16), text: 'Organization Analytics'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _LeadsTab(
                  applications: applications,
                  onAddInquiry: () => _showAddInquiryDialog(context, activeBranchId),
                ),
                _ExamsTab(applications: applications),
                _InterviewsTab(applications: applications),
                _SeatsTab(branchId: activeBranchId),
                _MigrationTab(applications: applications),
                _OrgAnalyticsTab(allApplications: ref.watch(admissionsProvider)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _simulateProspectusDownload(BuildContext context, String branchId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Secure Fetch: Downloading prospectus PDF for ${branchId == "BR-001" ? "Delhi International SIS" : "Mumbai Public SPS"} branch catalog...'),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  void _showAddInquiryDialog(BuildContext context, String branchId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Admission Inquiry / Lead'),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Student Full Name')),
                  TextField(controller: _guardianCtrl, decoration: const InputDecoration(labelText: 'Guardian Name')),
                  TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
                  TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email address')),
                  TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Residential Address')),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Reservation Quota Category'),
                    items: const [
                      DropdownMenuItem(value: 'General', child: Text('General')),
                      DropdownMenuItem(value: 'OBC', child: Text('OBC')),
                      DropdownMenuItem(value: 'SC', child: Text('SC')),
                      DropdownMenuItem(value: 'ST', child: Text('ST')),
                    ],
                    onChanged: (val) => setState(() => _selectedCategory = val ?? 'General'),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLeadSource,
                    decoration: const InputDecoration(labelText: 'Lead Acquisition Source'),
                    items: const [
                      DropdownMenuItem(value: 'Website', child: Text('Website')),
                      DropdownMenuItem(value: 'Social Media', child: Text('Social Media')),
                      DropdownMenuItem(value: 'Referral', child: Text('Referral')),
                      DropdownMenuItem(value: 'Newspaper Advert', child: Text('Newspaper Advert')),
                    ],
                    onChanged: (val) => setState(() => _selectedLeadSource = val ?? 'Website'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (_nameCtrl.text.isNotEmpty && _phoneCtrl.text.isNotEmpty) {
                  final uniqueAppId = 'APP-${branchId.replaceAll("BR-", "")}-2026-${DateTime.now().millisecond}';
                  ref.read(admissionsProvider.notifier).addApplication(
                    AdmissionApplicationEntity(
                      id: uniqueAppId,
                      branchId: branchId,
                      classId: _selectedClassId,
                      className: branchId == 'BR-001' ? 'Class 1 Delhi' : 'Class 10 Mumbai',
                      studentName: _nameCtrl.text,
                      guardianName: _guardianCtrl.text,
                      phone: _phoneCtrl.text,
                      email: _emailCtrl.text,
                      address: _addressCtrl.text,
                      reservationCategory: _selectedCategory,
                      leadSource: _selectedLeadSource,
                      status: 'Inquiry',
                      createdAt: 'Today',
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✓ Intake Created! Generated Lead/App ID: $uniqueAppId')),
                  );
                  // clear
                  _nameCtrl.clear();
                  _guardianCtrl.clear();
                  _phoneCtrl.clear();
                  _emailCtrl.clear();
                  _addressCtrl.clear();
                }
              },
              child: const Text('Create Lead Inquiry'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 1 — Leads & Inquiries List
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _LeadsTab extends ConsumerWidget {
  final List<AdmissionApplicationEntity> applications;
  final VoidCallback onAddInquiry;

  const _LeadsTab({required this.applications, required this.onAddInquiry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: onAddInquiry,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${app.studentName} [${app.id}]',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _statusChip(app.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Class: ${app.className} | Category: ${app.reservationCategory}\nSource: ${app.leadSource} | Counselor: ${app.assignedCounselor}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            if (app.status == 'Inquiry') ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    minimumSize: const Size(60, 32),
                                  ),
                                  onPressed: () => _assignCounselor(context, ref, app.id),
                                  child: const Text('Assign Counselor', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${app.studentName} [${app.id}]',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Class: ${app.className} | Category: ${app.reservationCategory}\nSource: ${app.leadSource} | Counselor: ${app.assignedCounselor}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _statusChip(app.status),
                                if (app.status == 'Inquiry') ...[
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      minimumSize: const Size(60, 28),
                                    ),
                                    onPressed: () => _assignCounselor(context, ref, app.id),
                                    child: const Text('Assign Counselor', style: TextStyle(fontSize: 10, color: Colors.white)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 9, color: _getStatusColor(status), fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Inquiry': return Colors.grey;
      case 'Application Submitted': return Colors.blue;
      case 'Test Scheduled': return Colors.orange;
      case 'Test Completed': return Colors.indigo;
      case 'Interview Scheduled': return Colors.deepPurple;
      case 'Verification Pending': return Colors.pink;
      case 'Approved': return Colors.green;
      case 'Rejected': return Colors.red;
      default: return Colors.brown;
    }
  }

  void _assignCounselor(BuildContext context, WidgetRef ref, String appID) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Assign Counselor / Officer'),
          children: [
            _counselorTile(context, ref, appID, 'Amit Mishra'),
            _counselorTile(context, ref, appID, 'Pooja Nair'),
            _counselorTile(context, ref, appID, 'Siddharth Sen'),
          ],
        );
      },
    );
  }

  Widget _counselorTile(BuildContext context, WidgetRef ref, String appID, String name) {
    return SimpleDialogOption(
      onPressed: () {
        ref.read(admissionsProvider.notifier).updateCounselor(appID, name);
        ref.read(admissionsProvider.notifier).updateApplicationStatus(appID, 'Application Submitted');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ Assigned counselor $name to review documents.')),
        );
      },
      child: Text(name),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 2 — Exams & Merit Lists
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ExamsTab extends ConsumerWidget {
  final List<AdmissionApplicationEntity> applications;
  const _ExamsTab({required this.applications});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meritList = List<AdmissionApplicationEntity>.from(applications)
      ..sort((a, b) => b.entranceTestScore.compareTo(a.entranceTestScore));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final headerWidget = isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Schedule Admission Entrance Exams', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Status: Isolated per Branch', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Schedule Admission Entrance Exams', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Status: Isolated per Branch', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerWidget,
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(app.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('Score: ${app.entranceTestScore == -1 ? "Pending" : "${app.entranceTestScore}/100"}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                if (app.status == 'Application Submitted' || app.status == 'Test Scheduled') ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _examActionButton(context, ref, app),
                                  ),
                                ],
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(app.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Score: ${app.entranceTestScore == -1 ? "Pending" : "${app.entranceTestScore}/100"}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                _examActionButton(context, ref, app),
                              ],
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('🏆 Generated Branch Merit List Rankings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              isMobile
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: meritList.length,
                      itemBuilder: (context, idx) {
                        final app = meritList[idx];
                        return Card(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade50,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primary,
                              child: Text('${idx + 1}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(app.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            subtitle: Text('Score: ${app.entranceTestScore == -1 ? "Pending" : app.entranceTestScore}  |  Status: ${app.status}', style: const TextStyle(fontSize: 10)),
                          ),
                        );
                      },
                    )
                  : Table(
                      border: TableBorder.all(color: Colors.grey.withValues(alpha: 0.2)),
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(color: Colors.white10),
                          children: [
                            Padding(padding: EdgeInsets.all(8), child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Student Candidate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Exam Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Admissions Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          ],
                        ),
                        ...meritList.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final app = entry.value;
                          return TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(8), child: Text('${idx + 1}', style: const TextStyle(fontSize: 11))),
                              Padding(padding: const EdgeInsets.all(8), child: Text(app.studentName, style: const TextStyle(fontSize: 11))),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  app.entranceTestScore == -1 ? 'Pending' : '${app.entranceTestScore}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(padding: const EdgeInsets.all(8), child: Text(app.status, style: const TextStyle(fontSize: 10, color: Colors.grey))),
                            ],
                          );
                        }),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _examActionButton(BuildContext context, WidgetRef ref, AdmissionApplicationEntity app) {
    if (app.status == 'Application Submitted') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 8)),
        onPressed: () {
          ref.read(admissionsProvider.notifier).updateApplicationStatus(app.id, 'Test Scheduled');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Entrance test slot scheduled & link dispatched via SMS!')),
          );
        },
        child: const Text('Schedule Test Slot', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      );
    } else if (app.status == 'Test Scheduled') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(horizontal: 8)),
        onPressed: () => _simulateEntranceExam(context, ref, app.id),
        child: const Text('Launch Mock Exam', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }
    return const SizedBox.shrink();
  }

  void _simulateEntranceExam(BuildContext context, WidgetRef ref, String appID) {
    final questions = ref.read(admissionsEntranceExamQuestions);
    final selectedAnswers = <int, String>{};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('🖥️ Online Entrance Exam Portal'),
              content: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: questions.length,
                  itemBuilder: (context, qIdx) {
                    final q = questions[qIdx];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${qIdx + 1}. ${q.question}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ...q.choices.map((choice) {
                          return RadioListTile<String>(
                            title: Text(choice, style: const TextStyle(fontSize: 11)),
                            value: choice,
                            groupValue: selectedAnswers[qIdx],
                            onChanged: (val) {
                              setDialogState(() {
                                selectedAnswers[qIdx] = val!;
                              });
                            },
                          );
                        }),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    // Score computation
                    int correct = 0;
                    for (int i = 0; i < questions.length; i++) {
                      if (selectedAnswers[i] == questions[i].correctChoice) {
                        correct++;
                      }
                    }
                    final finalPercent = ((correct / questions.length) * 100).round();
                    ref.read(admissionsProvider.notifier).updateApplicationScore(appID, finalPercent);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✓ MCQ test submitted. Candidate scored $finalPercent%.')),
                    );
                  },
                  child: const Text('Submit & Auto-Grade'),
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
// SUB-TAB 3 — Interviews & Verifications
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _InterviewsTab extends ConsumerWidget {
  final List<AdmissionApplicationEntity> applications;
  const _InterviewsTab({required this.applications});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingInterviews = applications.where((a) => a.status == 'Test Completed' || a.status == 'Interview Scheduled' || a.status == 'Verification Pending').toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingInterviews.length,
      itemBuilder: (context, index) {
        final app = pendingInterviews[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(app.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(app.status, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Reservation Category: ${app.reservationCategory} | Test Score: ${app.entranceTestScore}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (app.status == 'Test Completed')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(horizontal: 10)),
                        onPressed: () {
                          ref.read(admissionsProvider.notifier).updateApplicationStatus(app.id, 'Interview Scheduled');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Panel meeting slot booked on branch calendar.')),
                          );
                        },
                        child: const Text('Schedule Panel Interview', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    if (app.status == 'Interview Scheduled')
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, padding: const EdgeInsets.symmetric(horizontal: 10)),
                        onPressed: () {
                          ref.read(admissionsProvider.notifier).updateApplicationStatus(app.id, 'Verification Pending');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Checked document vault: Status moved to verification.')),
                          );
                        },
                        child: const Text('Move to Document Verification', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    if (app.status == 'Verification Pending')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: app.documentsVerified,
                            onChanged: (val) {
                              ref.read(admissionsProvider.notifier).updateVerification(app.id, val ?? false);
                            },
                          ),
                          const Flexible(
                            child: Text('Documents Verified (Aadhar/Birth cert)', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 4 — Seat Availability & Reservations
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _SeatsTab extends ConsumerWidget {
  final String branchId;
  const _SeatsTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seats = ref.watch(seatCapacityProvider).where((s) => s.branchId == branchId).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: seats.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500,
        mainAxisExtent: 220,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final seat = seats[index];
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(seat.className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Seats Available:', style: TextStyle(fontSize: 12)),
                  Text('${seat.availableTotal} / ${seat.totalSeats}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal)),
                ],
              ),
              const Divider(height: 20),
              const Text('Category-Wise Seat Quota Reservation status:', style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 8),
              _reservationBar(context, 'General Quota', seat.filledGeneral, seat.generalQuota, Colors.blue),
              _reservationBar(context, 'OBC Quota', seat.filledObc, seat.obcQuota, Colors.orange),
              _reservationBar(context, 'SC/ST Reserved Quota', seat.filledScSt, seat.scStQuota, Colors.pink),
            ],
          ),
        );
      },
    );
  }

  Widget _reservationBar(BuildContext context, String label, int filled, int max, Color color) {
    final pct = max > 0 ? (filled / max) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11)),
              Text('$filled / $max Filled', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: pct, color: color, backgroundColor: Colors.white10),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 5 — Database Migration (Enrollment)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _MigrationTab extends ConsumerWidget {
  final List<AdmissionApplicationEntity> applications;
  const _MigrationTab({required this.applications});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = applications.where((a) => a.status == 'Verification Pending' || a.status == 'Approved' || a.status == 'Waitlisted').toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: candidates.length,
          itemBuilder: (context, index) {
            final app = candidates[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Score: ${app.entranceTestScore}% | Documents Verified: ${app.documentsVerified ? "YES" : "NO"}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: _migrationActionWidget(context, ref, app, isMobile),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(app.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('Score: ${app.entranceTestScore}% | Documents Verified: ${app.documentsVerified ? "YES" : "NO"}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          _migrationActionWidget(context, ref, app, isMobile),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _migrationActionWidget(BuildContext context, WidgetRef ref, AdmissionApplicationEntity app, bool isMobile) {
    if (app.status != 'Approved') {
      final approveButton = ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        onPressed: app.documentsVerified
            ? () => _migrateCandidate(context, ref, app)
            : null,
        child: const Text('Approve & Migrate', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      );

      final waitlistButton = ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        onPressed: () {
          ref.read(admissionsProvider.notifier).updateApplicationStatus(app.id, 'Waitlisted');
        },
        child: const Text('Waitlist', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      );

      if (isMobile) {
        return Column(
          children: [
            SizedBox(width: double.infinity, child: approveButton),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: waitlistButton),
          ],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            approveButton,
            const SizedBox(width: 8),
            waitlistButton,
          ],
        );
      }
    } else {
      return Chip(
        label: Text('Enrolled: ${app.enrollmentNumber}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      );
    }
  }

  void _migrateCandidate(BuildContext context, WidgetRef ref, AdmissionApplicationEntity app) {
    final uniqueEnrollmentNo = 'ENR-${app.branchId.replaceAll("BR-", "")}-${100 + DateTime.now().millisecond}';

    // 1. Mark Admission application as approved
    ref.read(admissionsProvider.notifier).approveAdmission(app.id, uniqueEnrollmentNo);

    // 2. Allocate seat category counts
    ref.read(seatCapacityProvider.notifier).allocateSeat(app.branchId, app.classId, app.reservationCategory);

    // 3. Migrate data directly to global student list database provider
    ref.read(academicStudentsProvider.notifier).addStudent(
      branchId: app.branchId,
      classId: app.classId,
      sectionId: app.branchId == 'BR-001' ? 'SEC-A-001' : 'SEC-A-010',
      name: app.studentName,
      admissionNumber: uniqueEnrollmentNo,
      rollNumber: '', // will be alphabetical auto-generated
      phone: app.phone,
      email: app.email,
      address: app.address,
      guardianName: app.guardianName,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Student ${app.studentName} auto-migrated to branch directory database with Roll enrollment code: $uniqueEnrollmentNo'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 6 — Organization Admission Comparison Analytics
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _OrgAnalyticsTab extends ConsumerWidget {
  final List<AdmissionApplicationEntity> allApplications;
  const _OrgAnalyticsTab({required this.allApplications});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delhiApps = allApplications.where((a) => a.branchId == 'BR-001').toList();
    final mumbaiApps = allApplications.where((a) => a.branchId == 'BR-002').toList();

    // Group lead sources
    final webLeads = allApplications.where((a) => a.leadSource == 'Website').length;
    final socialLeads = allApplications.where((a) => a.leadSource == 'Social Media').length;
    final referralLeads = allApplications.where((a) => a.leadSource == 'Referral').length;
    final paperLeads = allApplications.where((a) => a.leadSource == 'Newspaper Advert').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏢 Organization Consolidated Admission Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),

          // Cross-Branch intake comparison
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Branch-Wise Intake Summary (Applications vs Approved Enrollments)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 12),
                _branchPerformanceBar('Delhi Central SIS Campus (BR-001)', delhiApps),
                const SizedBox(height: 12),
                _branchPerformanceBar('Mumbai South SPS Campus (BR-002)', mumbaiApps),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // Marketing Source breakdown
          const Text('📈 Lead Generation & Marketing Channel Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isMobile ? 4.5 : 3.5,
                children: [
                  _metricCard('Website Portal', webLeads, Colors.blue),
                  _metricCard('Social Media Campaigns', socialLeads, Colors.purple),
                  _metricCard('Direct Referral word-of-mouth', referralLeads, Colors.teal),
                  _metricCard('Newspaper & Prints', paperLeads, Colors.brown),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _branchPerformanceBar(String branchLabel, List<AdmissionApplicationEntity> apps) {
    final total = apps.length;
    final enrolled = apps.where((a) => a.status == 'Approved').length;
    final pct = total > 0 ? (enrolled / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(branchLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('Apps: $total | Enrolled: $enrolled (${(pct * 100).toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: pct, color: AppColors.primary, backgroundColor: Colors.white10, minHeight: 8),
      ],
    );
  }

  Widget _metricCard(String channel, int value, Color iconColor) {
    return GlassCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.15),
            child: Icon(Icons.show_chart_rounded, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(channel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 2),
                Text('$value Leads', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

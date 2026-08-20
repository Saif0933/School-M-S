import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class HomeworkManagementPage extends ConsumerStatefulWidget {
  const HomeworkManagementPage({super.key});

  @override
  ConsumerState<HomeworkManagementPage> createState() => _HomeworkManagementPageState();
}

class _HomeworkManagementPageState extends ConsumerState<HomeworkManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Assignment fields
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dueDateCtrl = TextEditingController(text: '2026-08-25');
  final _attachmentCtrl = TextEditingController();
  String _selectedClass = 'Class 11';
  String _selectedSubject = 'Physics';
  String _selectedAttachmentType = 'PDF';
  bool _saveAsTemplate = false;

  // Submission inputs
  final _onlineAnswerCtrl = TextEditingController();
  String? _mockAttachedPhoto;

  // Grading controllers
  final _marksCtrl = TextEditingController();
  final _feedbackCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dueDateCtrl.dispose();
    _attachmentCtrl.dispose();
    _onlineAnswerCtrl.dispose();
    _marksCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final allHw = ref.watch(homeworkProvider).where((h) => h.branchId == activeBranchId).toList();
    final submissions = ref.watch(submissionsProvider);
    final templates = ref.watch(homeworkTemplatesProvider);

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
                    'Homework & Assignments: $branchName',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Text(
                    'Branch Assignments Database | Late Submissions Trackers: Operational',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              );

              final actionButton = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => _tabController.animateTo(0),
                icon: const Icon(Icons.note_add_rounded, color: Colors.white, size: 16),
                label: const Text('New Assignment', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
                Tab(icon: Icon(Icons.assignment_add, size: 16), text: 'Assign Homework'),
                Tab(icon: Icon(Icons.send_and_archive_rounded, size: 16), text: 'Student Submission Desk'),
                Tab(icon: Icon(Icons.rule_rounded, size: 16), text: 'Teacher Grading Desk'),
                Tab(icon: Icon(Icons.assessment_rounded, size: 16), text: 'Templates & Reports'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Assignment creation
                _buildAssignTab(activeBranchId),

                // Tab 2: Submission desk
                _buildSubmissionTab(allHw),

                // Tab 3: Grading & Plagiarism
                _buildGradingTab(submissions, allHw),

                // Tab 4: Templates & reports
                _buildTemplatesTab(templates, allHw, submissions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Assign Homework Form
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildAssignTab(String branchId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✏️ Assign Homework to Students', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedClass,
            decoration: const InputDecoration(labelText: 'Class Level Selection'),
            items: const [
              DropdownMenuItem(value: 'Class 11', child: Text('Class 11 Science')),
              DropdownMenuItem(value: 'Class 12', child: Text('Class 12 Commerce')),
            ],
            onChanged: (val) => setState(() => _selectedClass = val ?? 'Class 11'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
            decoration: const InputDecoration(labelText: 'Subject Classification'),
            items: const [
              DropdownMenuItem(value: 'Physics', child: Text('Physics')),
              DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
              DropdownMenuItem(value: 'Chemistry', child: Text('Chemistry')),
            ],
            onChanged: (val) => setState(() => _selectedSubject = val ?? 'Physics'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Homework Topic Title')),
          TextField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Instructions / Questions details')),
          TextField(controller: _dueDateCtrl, decoration: const InputDecoration(labelText: 'Due Date deadline (YYYY-MM-DD)')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedAttachmentType,
            decoration: const InputDecoration(labelText: 'Reference File Attachment Type'),
            items: const [
              DropdownMenuItem(value: 'PDF', child: Text('PDF Document (.pdf)')),
              DropdownMenuItem(value: 'Image', child: Text('Drawing Reference (.png/.jpg)')),
              DropdownMenuItem(value: 'Video', child: Text('Lecture Video MP4')),
              DropdownMenuItem(value: 'Link', child: Text('External Reference Link')),
            ],
            onChanged: (val) => setState(() => _selectedAttachmentType = val ?? 'PDF'),
          ),
          TextField(controller: _attachmentCtrl, decoration: const InputDecoration(labelText: 'File Name / Link Url')),
          const SizedBox(height: 12),
          SwitchListTile(
            dense: true,
            title: const Text('Save as reusable template for future syllabus lessons', style: TextStyle(fontSize: 11)),
            value: _saveAsTemplate,
            onChanged: (val) => setState(() => _saveAsTemplate = val),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (_titleCtrl.text.isNotEmpty && _dueDateCtrl.text.isNotEmpty) {
                  ref.read(homeworkProvider.notifier).addHomework(
                    HomeworkEntity(
                      id: 'HW-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: branchId,
                      classId: _selectedClass,
                      subject: _selectedSubject,
                      title: _titleCtrl.text,
                      description: _descCtrl.text,
                      dueDate: _dueDateCtrl.text,
                      attachmentType: _selectedAttachmentType,
                      attachmentName: _attachmentCtrl.text.isNotEmpty ? _attachmentCtrl.text : 'ref_file.bin',
                      isTemplate: _saveAsTemplate,
                    ),
                  );
                  _titleCtrl.clear();
                  _descCtrl.clear();
                  _attachmentCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Homework assigned. Parents notified via SMS/Push alarms!')),
                  );
                  _tabController.animateTo(1);
                }
              },
              child: const Text('Publish Assignment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Student Submission Desk
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSubmissionTab(List<HomeworkEntity> homework) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: homework.length,
      itemBuilder: (context, index) {
        final hw = homework[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text('[${hw.subject}] ${hw.classId}', style: const TextStyle(fontSize: 8, color: Colors.white)),
                      backgroundColor: Colors.indigo,
                    ),
                    Text('Due Date: ${hw.dueDate}', style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(hw.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(hw.description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.attachment_rounded, size: 14, color: Colors.teal),
                    const SizedBox(width: 4),
                    Text('${hw.attachmentType}: ${hw.attachmentName}', style: const TextStyle(fontSize: 10, color: Colors.teal)),
                  ],
                ),
                const Divider(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _showSubmissionDialog(context, hw.id),
                    icon: const Icon(Icons.upload_file_rounded, size: 14, color: Colors.white),
                    label: const Text('Submit Work', style: TextStyle(fontSize: 10, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSubmissionDialog(BuildContext context, String homeworkId) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Online Homework Submission'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _onlineAnswerCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Type online answers details'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          _mockAttachedPhoto = 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe';
                        });
                      },
                      icon: const Icon(Icons.photo_camera_rounded),
                      label: const Text('Upload Handwritten Work Photo'),
                    ),
                    if (_mockAttachedPhoto != null) ...[
                      const SizedBox(height: 8),
                      Image.network(_mockAttachedPhoto!, height: 100, fit: BoxFit.cover),
                      const Text('[Mock Handwritten Page Attached]', style: TextStyle(fontSize: 9, color: Colors.teal)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _onlineAnswerCtrl.clear();
                    _mockAttachedPhoto = null;
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(submissionsProvider.notifier).addSubmission(
                      HomeworkSubmission(
                        id: 'SUB-${DateTime.now().millisecondsSinceEpoch}',
                        homeworkId: homeworkId,
                        studentName: 'Sunita Rao',
                        submissionDate: '2026-08-19',
                        onlineAnswer: _onlineAnswerCtrl.text,
                        photoUrl: _mockAttachedPhoto,
                        isLate: false,
                        status: 'Submitted',
                      ),
                    );
                    Navigator.pop(context);
                    _onlineAnswerCtrl.clear();
                    _mockAttachedPhoto = null;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Assignment submitted successfully!')),
                    );
                    _tabController.animateTo(2);
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Teacher Grading Desk
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildGradingTab(List<HomeworkSubmission> subs, List<HomeworkEntity> homework) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subs.length,
      itemBuilder: (context, index) {
        final sub = subs[index];
        final hw = homework.firstWhere((h) => h.id == sub.homeworkId, orElse: () => const HomeworkEntity(id: '', branchId: '', classId: '', subject: '', title: 'General HW', description: '', dueDate: '', attachmentType: '', attachmentName: ''));

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Student: ${sub.studentName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Chip(
                      label: Text(sub.status, style: const TextStyle(fontSize: 8, color: Colors.white)),
                      backgroundColor: sub.status == 'Graded' ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
                Text('Topic: ${hw.title}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Submitted Text: "${sub.onlineAnswer}"', style: const TextStyle(fontSize: 11)),
                if (sub.photoUrl != null) ...[
                  const SizedBox(height: 8),
                  const Text('Attachment: handwritten_pic.jpg', style: TextStyle(fontSize: 10, color: Colors.teal)),
                ],
                if (sub.status == 'Graded') ...[
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Marks Awarded: ${sub.marksAwarded}/100', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      Text('Plagiarism Scan Match: ${sub.plagiarismMatch.toStringAsFixed(0)}%', style: TextStyle(color: sub.plagiarismMatch > 20 ? Colors.red : Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Feedback: "${sub.feedbackRemarks}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                ] else ...[
                  const Divider(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _showGradingDialog(context, sub.id),
                      icon: const Icon(Icons.grading_rounded, size: 14, color: Colors.white),
                      label: const Text('Grade & Plagiarism Scan', style: TextStyle(fontSize: 10, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGradingDialog(BuildContext context, String submissionId) {
    double mockPlagiarism = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Grade student submission'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _marksCtrl, decoration: const InputDecoration(labelText: 'Marks Awarded (out of 100)')),
                  TextField(controller: _feedbackCtrl, decoration: const InputDecoration(labelText: 'Remarks / Feedback')),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setDialogState(() {
                            mockPlagiarism = 12.5; // Mock low matches
                          });
                        },
                        child: const Text('Run Plagiarism Scan', style: TextStyle(fontSize: 10)),
                      ),
                      Text(
                        mockPlagiarism > 0 ? 'Match: ${mockPlagiarism.toStringAsFixed(1)}%' : 'Not Scanned',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _marksCtrl.clear();
                    _feedbackCtrl.clear();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(submissionsProvider.notifier).gradeSubmission(
                      submissionId,
                      int.tryParse(_marksCtrl.text) ?? 80,
                      _feedbackCtrl.text,
                      mockPlagiarism,
                    );
                    Navigator.pop(context);
                    _marksCtrl.clear();
                    _feedbackCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Grade recorded. Student results updated.')),
                    );
                  },
                  child: const Text('Save Grade'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Templates & Reports Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildTemplatesTab(List<HomeworkEntity> templates, List<HomeworkEntity> homework, List<HomeworkSubmission> subs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reusable templates
          const Text('📚 Reusable Syllabus Templates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ...templates.map((tpl) => Card(
                child: ListTile(
                  leading: const Icon(Icons.collections_bookmark_rounded, color: Colors.amber),
                  title: Text(tpl.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  subtitle: Text('[${tpl.subject}] ${tpl.classId}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () {
                      setState(() {
                        _selectedClass = tpl.classId;
                        _selectedSubject = tpl.subject;
                        _titleCtrl.text = tpl.title;
                        _descCtrl.text = tpl.description;
                        _selectedAttachmentType = tpl.attachmentType;
                        _attachmentCtrl.text = tpl.attachmentName;
                        _tabController.animateTo(0);
                      });
                    },
                    child: const Text('Use Template', style: TextStyle(fontSize: 9, color: Colors.white)),
                  ),
                ),
              )),
          const SizedBox(height: 24),

          // Completion Analytics
          const Text('📊 Branch Submission rate analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue.withValues(alpha: 0.05),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Physics Completion rate:', style: TextStyle(fontSize: 11)),
                      Text('92% completed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 11)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mathematics Completion rate:', style: TextStyle(fontSize: 11)),
                      Text('85% completed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Committing Homework summaries to PDF... download started.')),
                );
              },
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: const Text('Export Parent-Teacher Homework Report', style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

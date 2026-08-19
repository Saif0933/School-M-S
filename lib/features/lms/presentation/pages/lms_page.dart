import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class LMSManagementPage extends ConsumerStatefulWidget {
  const LMSManagementPage({super.key});

  @override
  ConsumerState<LMSManagementPage> createState() => _LMSManagementPageState();
}

class _LMSManagementPageState extends ConsumerState<LMSManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Schedule class
  final _classTitleCtrl = TextEditingController();
  final _classSubjCtrl = TextEditingController();
  final _classUrlCtrl = TextEditingController();
  String _selectedPlatform = 'In-Platform';

  // Controllers for Study material
  final _matTitleCtrl = TextEditingController();
  final _matSubjCtrl = TextEditingController();
  String _selectedFileType = 'PDF';

  // Search Filter
  String _videoSearchQuery = '';

  // Whiteboard drawings list
  final List<Offset> _whiteboardPoints = [];

  // Quiz active indices
  int _selectedQuizAnswer = -1;
  bool _quizSubmitted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _classTitleCtrl.dispose();
    _classSubjCtrl.dispose();
    _classUrlCtrl.dispose();
    _matTitleCtrl.dispose();
    _matSubjCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';

    final liveClasses = ref.watch(liveClassesProvider).where((c) => c.branchId == activeBranchId).toList();
    final recordedVideos = ref.watch(recordedVideosProvider)
        .where((v) => v.branchId == activeBranchId && v.title.toLowerCase().contains(_videoSearchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          // Subheader
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Online Classes & LMS portal: ${user?.activeBranch?.branchName ?? "Primary Campus"}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Branch Learning Database | Sync Status: Connected',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () => _showScheduleClassDialog(context, activeBranchId),
                      icon: const Icon(Icons.add_to_queue_rounded, color: Colors.white, size: 16),
                      label: const Text('Schedule Class', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: () => _showUploadMaterialDialog(context, activeBranchId),
                      icon: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 16),
                      label: const Text('Upload Study File', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: isDark ? Colors.black12 : Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: const [
                Tab(icon: Icon(Icons.video_camera_front_rounded, size: 16), text: 'Live Timetable & Conference'),
                Tab(icon: Icon(Icons.video_library_rounded, size: 16), text: 'Recorded lectures'),
                Tab(icon: Icon(Icons.menu_book_rounded, size: 16), text: 'Study Materials'),
                Tab(icon: Icon(Icons.forum_rounded, size: 16), text: 'Discussion Forum'),
                Tab(icon: Icon(Icons.sports_esports_rounded, size: 16), text: 'Gamification Leaderboard'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _LiveClassesTimetableTab(
                  liveClasses: liveClasses,
                  whiteboardPoints: _whiteboardPoints,
                  onWhiteboardUpdated: () => setState(() {}),
                ),
                _RecordedLecturesTab(
                  recordedVideos: recordedVideos,
                  onSearchChanged: (val) => setState(() => _videoSearchQuery = val),
                ),
                _StudyMaterialsTab(branchId: activeBranchId),
                _DiscussionForumTab(branchId: activeBranchId),
                _GamificationTab(
                  selectedQuizAnswer: _selectedQuizAnswer,
                  quizSubmitted: _quizSubmitted,
                  onAnswerSelected: (val) => setState(() => _selectedQuizAnswer = val),
                  onQuizSubmitted: (val) => setState(() => _quizSubmitted = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleClassDialog(BuildContext context, String branchId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Schedule Live Class Lecture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _classTitleCtrl, decoration: const InputDecoration(labelText: 'Lecture Title (e.g. Vectors)')),
              TextField(controller: _classSubjCtrl, decoration: const InputDecoration(labelText: 'Subject (e.g. Mathematics)')),
              TextField(controller: _classUrlCtrl, decoration: const InputDecoration(labelText: 'Platform Join URL (Optional)')),
              DropdownButtonFormField<String>(
                initialValue: _selectedPlatform,
                decoration: const InputDecoration(labelText: 'Web Conferencing Account'),
                items: const [
                  DropdownMenuItem(value: 'In-Platform', child: Text('In-Platform Conference Server')),
                  DropdownMenuItem(value: 'Zoom', child: Text('Zoom Account (Delhi Campus)')),
                  DropdownMenuItem(value: 'Google Meet', child: Text('Google Meet Classroom')),
                ],
                onChanged: (val) => setState(() => _selectedPlatform = val ?? 'In-Platform'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (_classTitleCtrl.text.isNotEmpty && _classSubjCtrl.text.isNotEmpty) {
                  ref.read(liveClassesProvider.notifier).scheduleClass(
                    LiveClassEntity(
                      id: 'LC-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: branchId,
                      title: _classTitleCtrl.text,
                      subject: _classSubjCtrl.text,
                      time: 'Today, 04:30 PM',
                      platform: _selectedPlatform,
                      joinUrl: _classUrlCtrl.text.isNotEmpty ? _classUrlCtrl.text : 'https://meet.symbosys.com/del/class',
                    ),
                  );
                  Navigator.pop(context);
                  _classTitleCtrl.clear();
                  _classSubjCtrl.clear();
                  _classUrlCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Live Class scheduled and student sync alarms set!')),
                  );
                }
              },
              child: const Text('Schedule'),
            ),
          ],
        );
      },
    );
  }

  void _showUploadMaterialDialog(BuildContext context, String branchId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload Course Study Material'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _matTitleCtrl, decoration: const InputDecoration(labelText: 'Material Title')),
              TextField(controller: _matSubjCtrl, decoration: const InputDecoration(labelText: 'Subject Name')),
              DropdownButtonFormField<String>(
                initialValue: _selectedFileType,
                decoration: const InputDecoration(labelText: 'File Type Classification'),
                items: const [
                  DropdownMenuItem(value: 'PDF', child: Text('PDF Worksheet (.pdf)')),
                  DropdownMenuItem(value: 'PPT', child: Text('Presentation Slide (.ppt)')),
                  DropdownMenuItem(value: 'Video', child: Text('Video Lecture File (.mp4)')),
                  DropdownMenuItem(value: 'Audio', child: Text('Audio Recording (.mp3)')),
                ],
                onChanged: (val) => setState(() => _selectedFileType = val ?? 'PDF'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (_matTitleCtrl.text.isNotEmpty) {
                  ref.read(studyMaterialProvider.notifier).addMaterial(
                    StudyMaterialEntity(
                      id: 'MAT-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: branchId,
                      title: _matTitleCtrl.text,
                      subject: _matSubjCtrl.text,
                      fileType: _selectedFileType,
                      fileUrl: 'materials/chapter_download.bin',
                    ),
                  );
                  Navigator.pop(context);
                  _matTitleCtrl.clear();
                  _matSubjCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Resource file published to branch LMS library.')),
                  );
                }
              },
              child: const Text('Publish file'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 1 — Live Classes & Video Conference
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _LiveClassesTimetableTab extends StatelessWidget {
  final List<LiveClassEntity> liveClasses;
  final List<Offset> whiteboardPoints;
  final VoidCallback onWhiteboardUpdated;

  const _LiveClassesTimetableTab({
    required this.liveClasses,
    required this.whiteboardPoints,
    required this.onWhiteboardUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: liveClasses.length,
      itemBuilder: (context, index) {
        final lc = liveClasses[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: lc.platform == 'In-Platform' ? Colors.indigo : Colors.blue,
              child: const Icon(Icons.video_call_rounded, color: Colors.white),
            ),
            title: Text(lc.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Subject: ${lc.subject} | Time: ${lc.time}\nProvider: ${lc.platform}'),
            trailing: ElevatedButton(
              onPressed: () => _launchConferenceRoom(context, lc.title),
              child: const Text('Join Video Room', style: TextStyle(fontSize: 10)),
            ),
          ),
        );
      },
    );
  }

  void _launchConferenceRoom(BuildContext context, String title) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, anim1, anim2) {
        return _InPlatformConferenceDialog(
          title: title,
          whiteboardPoints: whiteboardPoints,
          onWhiteboardUpdated: onWhiteboardUpdated,
        );
      },
    );
  }
}

class _InPlatformConferenceDialog extends StatefulWidget {
  final String title;
  final List<Offset> whiteboardPoints;
  final VoidCallback onWhiteboardUpdated;

  const _InPlatformConferenceDialog({
    required this.title,
    required this.whiteboardPoints,
    required this.onWhiteboardUpdated,
  });

  @override
  State<_InPlatformConferenceDialog> createState() => _InPlatformConferenceDialogState();
}

class _InPlatformConferenceDialogState extends State<_InPlatformConferenceDialog> {
  bool _micMuted = false;
  bool _cameraMuted = false;
  bool _showWhiteboard = false;
  final List<String> _chatMessages = ['Delhi physics instructor joined.'];
  final _chatCtrl = TextEditingController();

  @override
  void dispose() {
    _chatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.red),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Left video room. Attendance logged successfully!')),
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                // Video Screen Area
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                    child: Stack(
                      children: [
                        if (_showWhiteboard)
                          GestureDetector(
                            onPanUpdate: (details) {
                              widget.whiteboardPoints.add(details.localPosition);
                              widget.onWhiteboardUpdated();
                              setState(() {});
                            },
                            child: CustomPaint(
                              painter: _WhiteboardPainter(widget.whiteboardPoints),
                              size: Size.infinite,
                            ),
                          )
                        else if (!_cameraMuted)
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.videocam_rounded, size: 64, color: Colors.grey),
                                SizedBox(height: 12),
                                Text('[Simulated Live Webcam Feed]', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          )
                        else
                          const Center(
                            child: Text('Camera Feed Muted', style: TextStyle(color: Colors.white38)),
                          ),

                        // Control icons
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(_micMuted ? Icons.mic_off_rounded : Icons.mic_rounded, color: _micMuted ? Colors.red : Colors.green),
                                onPressed: () => setState(() => _micMuted = !_micMuted),
                              ),
                              IconButton(
                                icon: Icon(_cameraMuted ? Icons.videocam_off_rounded : Icons.videocam_rounded, color: _cameraMuted ? Colors.red : Colors.green),
                                onPressed: () => setState(() => _cameraMuted = !_cameraMuted),
                              ),
                              IconButton(
                                icon: Icon(Icons.border_color_rounded, color: _showWhiteboard ? Colors.amber : Colors.white),
                                onPressed: () => setState(() => _showWhiteboard = !_showWhiteboard),
                              ),
                              if (_showWhiteboard)
                                IconButton(
                                  icon: const Icon(Icons.clear_all_rounded, color: Colors.red),
                                  onPressed: () {
                                    widget.whiteboardPoints.clear();
                                    widget.onWhiteboardUpdated();
                                    setState(() {});
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Live class text chat panel
                Container(
                  width: 240,
                  color: Colors.black87,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Live Class Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      const Divider(color: Colors.white24),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _chatMessages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                _chatMessages[index],
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chatCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                                decoration: const InputDecoration(
                                  hintText: 'Type text message...',
                                  hintStyle: TextStyle(color: Colors.white38),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send_rounded, size: 14, color: AppColors.primary),
                              onPressed: () {
                                if (_chatCtrl.text.isNotEmpty) {
                                  setState(() {
                                    _chatMessages.add('Me: ${_chatCtrl.text}');
                                  });
                                  _chatCtrl.clear();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteboardPainter extends CustomPainter {
  final List<Offset> points;
  const _WhiteboardPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    // Draw whiteboard grid back
    canvas.drawColor(Colors.white12, BlendMode.srcOver);

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 2 — Recorded Lectures
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _RecordedLecturesTab extends StatelessWidget {
  final List<RecordedVideoEntity> recordedVideos;
  final ValueChanged<String> onSearchChanged;

  const _RecordedLecturesTab({
    required this.recordedVideos,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Recorded Video Library...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recordedVideos.length,
            itemBuilder: (context, index) {
              final rec = recordedVideos[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.play_circle_fill_rounded, color: Colors.red, size: 36),
                  title: Text(rec.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: Text('Subject: ${rec.subject} | Duration: ${rec.duration}\nRecorded: ${rec.recordedDate}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, color: Colors.blue),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ Opening YouTube/Vimeo integrated class recording...')),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 3 — Study Materials
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _StudyMaterialsTab extends ConsumerWidget {
  final String branchId;
  const _StudyMaterialsTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materials = ref.watch(studyMaterialProvider).where((m) => m.branchId == branchId).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final mat = materials[index];
        return Card(
          child: ListTile(
            leading: Icon(
              mat.fileType == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.slideshow_rounded,
              color: mat.fileType == 'PDF' ? Colors.red : Colors.orange,
              size: 32,
            ),
            title: Text(mat.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Subject: ${mat.subject} | Classification: SCORM integrated ${mat.fileType}'),
            trailing: IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.teal),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Downloading chapter workbook to local storage...')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 4 — Discussion Forums
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _DiscussionForumTab extends ConsumerWidget {
  final String branchId;
  const _DiscussionForumTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(forumTopicsProvider).where((t) => t.branchId == branchId).toList();
    final replyCtrl = TextEditingController();

    return Column(
      children: [
        // Ask doubt header button
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Discussion doubt threads:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => _showAddThreadDialog(context, ref),
                child: const Text('Ask Subject Doubt', style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('[${topic.subject}] Thread', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text('By: ${topic.poster}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const Divider(height: 20),
                      if (topic.replies.isNotEmpty) ...[
                        const Text('Replies:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        const SizedBox(height: 4),
                        ...topic.replies.map((rep) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('➔ $rep', style: const TextStyle(fontSize: 11, color: Colors.teal)),
                            )),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: replyCtrl,
                              style: const TextStyle(fontSize: 11),
                              decoration: const InputDecoration(
                                hintText: 'Type answer or reply thread...',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: const Size(60, 30)),
                            onPressed: () {
                              if (replyCtrl.text.isNotEmpty) {
                                ref.read(forumTopicsProvider.notifier).addReply(topic.id, replyCtrl.text);
                                replyCtrl.clear();
                              }
                            },
                            child: const Text('Reply', style: TextStyle(fontSize: 10)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddThreadDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final subjCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Post New Subject Doubt thread'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Doubt Question details')),
              TextField(controller: subjCtrl, decoration: const InputDecoration(labelText: 'Subject (e.g. Physics)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  ref.read(forumTopicsProvider.notifier).addTopic(
                    ForumTopicEntity(
                      id: 'FRM-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: branchId,
                      subject: subjCtrl.text.isNotEmpty ? subjCtrl.text : 'General',
                      title: titleCtrl.text,
                      poster: 'Student User',
                      replies: [],
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit Thread'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 5 — Gamification & MCQ Quiz
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _GamificationTab extends ConsumerWidget {
  final int selectedQuizAnswer;
  final bool quizSubmitted;
  final ValueChanged<int> onAnswerSelected;
  final ValueChanged<bool> onQuizSubmitted;

  const _GamificationTab({
    required this.selectedQuizAnswer,
    required this.quizSubmitted,
    required this.onAnswerSelected,
    required this.onQuizSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(leaderboardProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // XP Leaderboard
          const Text('🏆 Campus Gamified XP Leaderboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          ...users.map((u) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(u.name[0])),
                  title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: Text('Badges Awarded: ${u.badges.join(", ")}'),
                  trailing: Chip(
                    label: Text('${u.xpPoints} XP', style: const TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: AppColors.primary,
                  ),
                ),
              )),

          const SizedBox(height: 24),

          // MCQ Quiz desk
          const Text('📝 Daily Auto-Graded MCQ Quiz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Question 1: What is the first law of thermodynamics concerned with?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 12),
                  _quizOption(0, 'Conservation of Momentum'),
                  _quizOption(1, 'Conservation of Energy'),
                  _quizOption(2, 'Entropy Generation'),
                  const SizedBox(height: 16),
                  if (!quizSubmitted)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: selectedQuizAnswer != -1
                          ? () {
                              onQuizSubmitted(true);
                              if (selectedQuizAnswer == 1) {
                                // Correct answer! Award 50 XP to STU-01
                                ref.read(leaderboardProvider.notifier).awardXP('STU-01', 50);
                                ref.read(leaderboardProvider.notifier).awardBadge('STU-01', 'Quiz Whiz');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✓ Correct! Awarded 50 XP points and "Quiz Whiz" Badge!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('❌ Incorrect answer! Try again tomorrow.')),
                                );
                              }
                            }
                          : null,
                      child: const Text('Submit & Auto-Grade', style: TextStyle(fontSize: 10, color: Colors.white)),
                    )
                  else ...[
                    const Text('Grading Result: Complete', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: () {
                        onQuizSubmitted(false);
                        onAnswerSelected(-1);
                      },
                      child: const Text('Reset Quiz', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizOption(int idx, String optionText) {
    return RadioListTile<int>(
      dense: true,
      title: Text(optionText, style: const TextStyle(fontSize: 11)),
      value: idx,
      groupValue: selectedQuizAnswer,
      onChanged: quizSubmitted ? null : (val) => onAnswerSelected(val ?? -1),
    );
  }
}

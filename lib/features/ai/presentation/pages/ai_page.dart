import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class AIFeaturesPage extends ConsumerStatefulWidget {
  const AIFeaturesPage({super.key});

  @override
  ConsumerState<AIFeaturesPage> createState() => _AIFeaturesPageState();
}

class _AIFeaturesPageState extends ConsumerState<AIFeaturesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Chatbot states
  final List<Map<String, String>> _chatMessages = [
    {'sender': 'AI Assistant', 'text': 'Hello! Ask me any questions regarding branch timetables, fee collection status, or syllabus topics.'}
  ];
  String _selectedChatQuery = 'Fee details for active campus';

  // Sentiment states
  final _feedbackCtrl = TextEditingController(text: 'Teachers are extremely supportive, but class B lab desks need urgent cleanups.');
  String _sentimentResult = '';
  Color _sentimentColor = Colors.grey;

  // OCR/Handwriting states
  String _extractedText = '';
  String _autoComment = '';
  bool _scanningFace = false;
  bool _scanComplete = false;

  // NLQ states
  final _nlqCtrl = TextEditingController(text: 'Show top 10 students of Branch Delhi');

  // Timetable solver states
  bool _solvingTimetable = false;
  String _timetableStatus = 'Conflicts unresolved: 3 classes clash on Monday Room 102';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _feedbackCtrl.dispose();
    _nlqCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final risks = ref.watch(dropoutPredictorProvider);
    final queries = ref.watch(nlqQueriesProvider);

    return Scaffold(
      body: Column(
        children: [
          // Subheader
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
                child: isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI-Powered Advanced Features: $branchName',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'OCR Recognition | Genetic Optimization: Active',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NLP Engine: Active',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade400, fontSize: 11),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI-Powered Advanced Features: $branchName',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'OCR Handwriting Recognition | Genetic Timetable Optimization: Active',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'NLP Engine: Active',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade400, fontSize: 11),
                          ),
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
                Tab(icon: Icon(Icons.forum_rounded, size: 16), text: 'AI Chatbot & Feedbacks Sentiment'),
                Tab(icon: Icon(Icons.face_retouching_natural_rounded, size: 16), text: 'Facial Attendance & Handwriting Scan'),
                Tab(icon: Icon(Icons.terminal_rounded, size: 16), text: 'NLQ Console & Timetable Solver'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatTab(),
                _buildScannerTab(),
                _buildNlqTab(risks, queries),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — AI Chatbot & Sentiment Analyzer
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildChatTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final chatbotCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🤖 Branch Query Chatbot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final msg = _chatMessages[index];
                      final isAi = msg['sender'] == 'AI Assistant';
                      return Align(
                        alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isAi ? Colors.teal.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${msg["sender"]}: ${msg["text"]}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedChatQuery,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 11, color: Colors.indigo),
                        items: const [
                          DropdownMenuItem(value: 'Fee details for active campus', child: Text('What is the fee deadline?')),
                          DropdownMenuItem(value: 'Next scheduled parents meet', child: Text('When is the next PTA?')),
                          DropdownMenuItem(value: 'Syllabus and chapter details', child: Text('Show Class 11 Science physics syllabus')),
                        ],
                        onChanged: (val) => setState(() => _selectedChatQuery = val ?? 'Fee details for active campus'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _chatMessages.add({'sender': 'User', 'text': _selectedChatQuery});
                          // Simulated reply
                          String reply = 'Default AI reply';
                          if (_selectedChatQuery.contains('Fee')) {
                            reply = 'Term 2 fees must be paid by August 28th. Check out Canteen / Library penalties.';
                          } else if (_selectedChatQuery.contains('parents')) {
                            reply = 'Branch Principal has scheduled parent assembly on August 22nd, 10 AM.';
                          } else {
                            reply = 'Physics syllabus covers kinematics, mechanics, and laboratory hours reschedule sheets.';
                          }
                          _chatMessages.add({'sender': 'AI Assistant', 'text': reply});
                        });
                      },
                      child: const Text('Ask AI', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        final sentimentCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📊 Feedback Sentiment Analyzer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                const Text(
                  'AI NLP algorithms evaluate parent feedback comments to flag concerns instantly.',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _feedbackCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Feedback Comments Text Body'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () {
                      setState(() {
                        final text = _feedbackCtrl.text.toLowerCase();
                        if (text.contains('desks need') || text.contains('oily')) {
                          _sentimentResult = 'Neutral/Dissatisfied (Desk cleanups flagged)';
                          _sentimentColor = Colors.orange;
                        } else {
                          _sentimentResult = 'Positive Sentiment (Confidence: 94%)';
                          _sentimentColor = Colors.green;
                        }
                      });
                    },
                    child: const Text('Analyze Feedback Sentiment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (_sentimentResult.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text('AI Prediction Analysis:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(_sentimentResult, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    backgroundColor: _sentimentColor,
                  ),
                ],
              ],
            ),
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: isMobile
              ? Column(
                  children: [
                    chatbotCard,
                    const SizedBox(height: 16),
                    sentimentCard,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: chatbotCard),
                    const SizedBox(width: 24),
                    Expanded(child: sentimentCard),
                  ],
                ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Facial & Handwriting Scanners Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildScannerTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final facialCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📸 Contactless Facial Recognition Scanner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                const Text('Marks attendance by scanning student faces in classrooms via camera streams.', style: TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 16),
                if (_scanningFace)
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.black,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.green),
                          SizedBox(height: 12),
                          Text('[SCANNING STUDENT FACES...]', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else if (_scanComplete)
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.green.withValues(alpha: 0.1),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.green, size: 40),
                          SizedBox(height: 8),
                          Text('✓ Facial scan complete. 27 students present.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey.withValues(alpha: 0.1),
                    child: const Center(
                      child: Icon(Icons.face_retouching_natural_rounded, size: 48, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () async {
                      setState(() {
                        _scanningFace = true;
                      });
                      await Future.delayed(const Duration(seconds: 2));
                      if (!mounted) return;
                      setState(() {
                        _scanningFace = false;
                        _scanComplete = true;
                      });
                    },
                    child: const Text('Start Classroom Facial Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );

        final handwritingCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✍️ AI Handwriting recognition & Grading', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                const Text('Upload photos of handwritten answer papers to digitize and generate report comments.', style: TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () {
                      setState(() {
                        _extractedText = '"The Newton second law states force equals mass times rate of acceleration (F = ma)."';
                        _autoComment = 'Excellent layout flow. Shows robust grasp of physics kinematics and mechanics.';
                      });
                    },
                    child: const Text('Transcribe uploaded answer paper', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (_extractedText.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text('Extracted Answer Text:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  Text(_extractedText, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 12),
                  const Text('AI-generated report comments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  Text(_autoComment, style: const TextStyle(fontSize: 11, color: Colors.teal)),
                ],
              ],
            ),
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    facialCard,
                    const SizedBox(height: 16),
                    handwritingCard,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: facialCard),
                    const SizedBox(width: 24),
                    Expanded(child: handwritingCard),
                  ],
                ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — NLQ Console & Timetable Solver
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildNlqTab(List<StudentRiskModel> risks, List<NlqQueryLog> queries) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 800;

              final nlqSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🖥️ Natural Language Query Console', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nlqCtrl,
                          decoration: const InputDecoration(labelText: 'Natural Language query request', isDense: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_nlqCtrl.text.isNotEmpty) {
                            ref.read(nlqQueriesProvider.notifier).runQuery(_nlqCtrl.text);
                          }
                        },
                        child: const Text('Execute', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...queries.map((q) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NLQ: "${q.queryText}"', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.indigo)),
                            Text(q.resultSummary, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Table(
                                defaultColumnWidth: const IntrinsicColumnWidth(),
                                border: TableBorder.all(color: Colors.grey.shade300),
                                children: q.resultTable.map((row) {
                                  return TableRow(
                                    children: row.values.map((val) => Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(val, style: const TextStyle(fontSize: 9)),
                                        )).toList(),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );

              final timetableSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🧬 Genetic Timetable Solver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  const Text('Solves campus timetables by checking teacher availability and room capacity constraints using genetic optimization.', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  const SizedBox(height: 12),
                  Text(_timetableStatus, style: const TextStyle(fontSize: 11, color: Colors.orange)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _solvingTimetable ? Colors.grey : AppColors.primary),
                      onPressed: _solvingTimetable
                          ? null
                          : () async {
                              setState(() {
                                _solvingTimetable = true;
                                _timetableStatus = '[Computing genetic generation rosters...]';
                              });
                              await Future.delayed(const Duration(seconds: 2));
                              if (!mounted) return;
                              setState(() {
                                _solvingTimetable = false;
                                _timetableStatus = '✓ Timetable generated successfully! 0 Clashes | Generations: 142';
                              });
                            },
                      child: Text(_solvingTimetable ? 'Solving...' : 'Resolve Timetable Clashes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    nlqSection,
                    const SizedBox(height: 24),
                    timetableSection,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: nlqSection),
                  const SizedBox(width: 24),
                  Expanded(child: timetableSection),
                ],
              );
            },
          ),
          const Divider(height: 36),

          // Dropout Risk predictive analytics
          const Text('📉 Predictive dropout Risk analysis today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: risks.length,
            itemBuilder: (context, index) {
              final r = risks[index];
              final isWarn = r.status == 'Warning';

              return Card(
                color: isWarn ? Colors.orange.withValues(alpha: 0.05) : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isWarn ? Colors.orange : Colors.green,
                    child: Icon(isWarn ? Icons.warning_rounded : Icons.check_circle_rounded, color: Colors.white),
                  ),
                  title: Text(r.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: Text('Class: ${r.classId}\nKey factors: ${r.keyFactors}'),
                  trailing: Text('Risk: ${r.dropoutRiskPct}%', style: TextStyle(fontWeight: FontWeight.bold, color: isWarn ? Colors.orange : Colors.green, fontSize: 13)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

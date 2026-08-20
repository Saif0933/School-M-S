import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../providers.dart'; // import communication providers

class CommunicationManagementPage extends ConsumerStatefulWidget {
  const CommunicationManagementPage({super.key});

  @override
  ConsumerState<CommunicationManagementPage> createState() => _CommunicationManagementPageState();
}

class _CommunicationManagementPageState extends ConsumerState<CommunicationManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranch?.branchId ?? 'BR-001';
    final isOrgExecutive = user?.role.isOrgLevel ?? false;

    return Column(
      children: [
        // Tab Navigation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: isDark ? Colors.black12 : Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
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
                icon: Icon(Icons.send_rounded, size: 16),
                text: 'Compose Broadcaster',
              ),
              Tab(
                icon: Icon(Icons.history_edu_rounded, size: 16),
                text: 'Circulars & Logs',
              ),
              Tab(
                icon: Icon(Icons.password_rounded, size: 16),
                text: 'SMS Credits Pool',
              ),
              Tab(
                icon: Icon(Icons.text_snippet_rounded, size: 16),
                text: 'Multi-lang Templates',
              ),
              Tab(
                icon: Icon(Icons.forum_rounded, size: 16),
                text: 'Parent-Teacher Chat',
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ComposeTab(branchId: activeBranchId, isOrg: isOrgExecutive),
              _LogsTab(branchId: activeBranchId, isOrg: isOrgExecutive),
              _CreditsTab(branchId: activeBranchId, isOrg: isOrgExecutive),
              _TemplatesTab(branchId: activeBranchId),
              _ChatTab(branchId: activeBranchId),
            ],
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 1 — Compose Broadcaster
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ComposeTab extends StatefulWidget {
  final String branchId;
  final bool isOrg;
  const _ComposeTab({required this.branchId, required this.isOrg});

  @override
  State<_ComposeTab> createState() => _ComposeTabState();
}

class _ComposeTabState extends State<_ComposeTab> {
  final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  final _recipientCtrl = TextEditingController(text: 'All Parents');
  String _selectedChannel = 'SMS';
  String _selectedScope = 'Branch-specific';
  String? _simulatedAttachment;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    _recipientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;

              final formSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compose Announcement Broadcast',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedScope,
                    decoration: const InputDecoration(labelText: 'Broadcast Scope'),
                    items: [
                      if (widget.isOrg)
                        const DropdownMenuItem(value: 'Organization-wide', child: Text('Organization-wide (All Branches)')),
                      const DropdownMenuItem(value: 'Branch-specific', child: Text('Branch-specific (Active Branch Only)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedScope = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedChannel,
                    decoration: const InputDecoration(labelText: 'Transmission Channel'),
                    items: const [
                      DropdownMenuItem(value: 'SMS', child: Text('SMS Text Message')),
                      DropdownMenuItem(value: 'Email', child: Text('Email Newsletter')),
                      DropdownMenuItem(value: 'Push Notification', child: Text('In-App Push Notification')),
                      DropdownMenuItem(value: 'WhatsApp', child: Text('WhatsApp Business Message')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedChannel = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _recipientCtrl,
                    decoration: const InputDecoration(labelText: 'Recipient Target Audience'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Message Subject / Header'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _msgCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Message Body Text'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _simulatedAttachment = 'circular_attachment_${DateTime.now().millisecond}.pdf';
                          });
                        },
                        icon: const Icon(Icons.attach_file_rounded),
                        label: const Text('Simulate Attachment'),
                      ),
                      if (_simulatedAttachment != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Chip(
                            label: Text(_simulatedAttachment!, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                            onDeleted: () {
                              setState(() {
                                _simulatedAttachment = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      if (_titleCtrl.text.isNotEmpty && _msgCtrl.text.isNotEmpty) {
                        ref.read(communicationLogsProvider.notifier).sendBroadcast(
                          CommunicationLogEntity(
                            id: 'COM-${DateTime.now().millisecondsSinceEpoch}',
                            scope: _selectedScope,
                            branchId: _selectedScope == 'Branch-specific' ? widget.branchId : null,
                            branchName: _selectedScope == 'Branch-specific' ? 'Current Branch' : 'All Branches',
                            channel: _selectedChannel,
                            recipientGroup: _recipientCtrl.text,
                            title: _titleCtrl.text,
                            message: _msgCtrl.text,
                            attachmentName: _simulatedAttachment,
                            dateSent: DateTime.now(),
                            smsCreditsUsed: _selectedChannel == 'SMS' ? 950 : 0,
                            deliveryRate: 1.0,
                            readRate: 0.0,
                          ),
                        );

                        if (_selectedChannel == 'SMS') {
                          ref.read(smsCreditPoolsProvider.notifier).consumeCredits(widget.branchId, 950);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🚀 Circular Broadcast Transmitted successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        _titleCtrl.clear();
                        _msgCtrl.clear();
                        setState(() {
                          _simulatedAttachment = null;
                        });
                      }
                    },
                    icon: const Icon(Icons.rocket_launch_rounded),
                    label: const Text('Transmit Broadcast', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );

              final guidelinesSection = const GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Broadcast Guidelines:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                    SizedBox(height: 8),
                    Text('1. Scoped Logins: Scopes are locked by role privilege. Branch operators cannot send org-wide campaigns.', style: TextStyle(fontSize: 11)),
                    SizedBox(height: 6),
                    Text('2. Credits Consumption: Transmitting bulk SMS deducts credits dynamically from the active branch pool.', style: TextStyle(fontSize: 11)),
                    SizedBox(height: 6),
                    Text('3. Attachments: Supports uploads of circulars, syllabus updates, and emergency instructions.', style: TextStyle(fontSize: 11)),
                  ],
                ),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: isMobile
                    ? Column(
                        children: [
                          guidelinesSection,
                          const SizedBox(height: 24),
                          formSection,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: formSection),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: guidelinesSection,
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 2 — Circulars & Logs
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _LogsTab extends ConsumerWidget {
  final String branchId;
  final bool isOrg;
  const _LogsTab({required this.branchId, required this.isOrg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLogs = ref.watch(communicationLogsProvider);

    // Filter: if org level, show all logs. Else show branch only logs
    final logs = isOrg ? allLogs : allLogs.where((l) => l.branchId == null || l.branchId == branchId).toList();

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final dateStr = '${log.dateSent.day}/${log.dateSent.month}';
          final statsStr = log.channel == 'SMS'
              ? 'Credits Used: ${log.smsCreditsUsed} | Delivery: ${(log.deliveryRate * 100).toStringAsFixed(0)}%'
              : 'Delivery: ${(log.deliveryRate * 100).toStringAsFixed(0)}% | Read Rate: ${(log.readRate * 100).toStringAsFixed(0)}%';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: log.scope == 'Organization-wide' ? Colors.indigo.withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          log.scope,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: log.scope == 'Organization-wide' ? Colors.indigo : Colors.orange,
                          ),
                        ),
                      ),
                      Text(dateStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(log.message, style: const TextStyle(fontSize: 11)),
                  if (log.attachmentName != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.attach_file_rounded, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(log.attachmentName!, style: const TextStyle(fontSize: 10, color: AppColors.primary, decoration: TextDecoration.underline)),
                      ],
                    ),
                  ],
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Channel: ${log.channel} | Group: ${log.recipientGroup}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(statsStr, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 3 — SMS Credits Pool
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _CreditsTab extends ConsumerWidget {
  final String branchId;
  final bool isOrg;
  const _CreditsTab({required this.branchId, required this.isOrg});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pools = ref.watch(smsCreditPoolsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organization SMS Credits Pools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor consumed and allocated text balance blocks across various nodes.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pools.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: MediaQuery.of(context).size.width < 600 ? 1.3 : 1.6,
              ),
              itemBuilder: (context, index) {
                final p = pools[index];
                final progress = p.allocated > 0 ? p.used / p.allocated : 0.0;

                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p.branchName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (isOrg)
                            IconButton(
                              onPressed: () => _allocateCreditsModal(context, ref, p.branchId),
                              icon: const Icon(Icons.add_card_rounded, size: 16),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Allocated: ${p.allocated} credits', style: const TextStyle(fontSize: 12)),
                      Text('Consumed: ${p.used} credits', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pool Utilization:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          color: progress >= 0.8 ? Colors.red : AppColors.primary,
                          backgroundColor: isDark ? Colors.white10 : Colors.black12,
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
    );
  }

  void _allocateCreditsModal(BuildContext context, WidgetRef ref, String bId) {
    final amtCtrl = TextEditingController(text: '10000');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Top-up Branch SMS pool'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Credits allocation amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final extra = int.tryParse(amtCtrl.text) ?? 10000;
                ref.read(smsCreditPoolsProvider.notifier).allocateCredits(bId, extra);
                Navigator.pop(context);
              },
              child: const Text('Allocate'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 4 — Custom Templates
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _TemplatesTab extends ConsumerWidget {
  final String branchId;
  const _TemplatesTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTemplates = ref.watch(messageTemplatesProvider);
    final templates = allTemplates.where((t) => t.branchId == null || t.branchId == branchId).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddTemplateModal(context, ref, branchId),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Template', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Message Templates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create emergency logs, results alerts, and automated multi-lingual templates.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: templates.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: MediaQuery.of(context).size.width < 600 ? 1.4 : 1.8,
              ),
              itemBuilder: (context, index) {
                final t = templates[index];
                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              t.category,
                              style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(t.language, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          t.messageBody,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.fade,
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
    );
  }

  void _showAddTemplateModal(BuildContext context, WidgetRef ref, String bId) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'General');
    final langCtrl = TextEditingController(text: 'English');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Message Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Template Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: catCtrl,
                decoration: const InputDecoration(labelText: 'Category (Fee/Results/General)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: langCtrl,
                decoration: const InputDecoration(labelText: 'Language (English/Hindi/Marathi)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bodyCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Template Body Text'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty && bodyCtrl.text.isNotEmpty) {
                  ref.read(messageTemplatesProvider.notifier).addTemplate(
                    MessageTemplateEntity(
                      id: 'TMP-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: bId,
                      title: titleCtrl.text,
                      category: catCtrl.text,
                      messageBody: bodyCtrl.text,
                      language: langCtrl.text,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 5 — Parent-Teacher Chat
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ChatTab extends StatefulWidget {
  final String branchId;
  const _ChatTab({required this.branchId});

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer(
      builder: (context, ref, child) {
        final allChats = ref.watch(chatMessagesProvider);
        final chats = allChats.where((c) => c.branchId == widget.branchId).toList();

        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final c = chats[index];
                    final isTeacher = c.sender == 'Teacher';

                    return Align(
                      alignment: isTeacher ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isTeacher
                              ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04))
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTeacher ? '${c.teacherName} (Teacher)' : '${c.studentName} (Parent)',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isTeacher ? Colors.grey : Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.message,
                              style: TextStyle(
                                fontSize: 12,
                                color: isTeacher ? (isDark ? Colors.white : Colors.black87) : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Type your reply message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_msgCtrl.text.isNotEmpty) {
                          ref.read(chatMessagesProvider.notifier).sendMessage(
                            ChatMessageEntity(
                              id: 'MSG-${DateTime.now().millisecondsSinceEpoch}',
                              branchId: widget.branchId,
                              studentName: 'Active Student',
                              teacherName: 'Class Teacher',
                              sender: 'Parent', // Simulate Parent response
                              message: _msgCtrl.text,
                              timestamp: DateTime.now(),
                            ),
                          );
                          _msgCtrl.clear();
                        }
                      },
                      icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

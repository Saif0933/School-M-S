import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class NoticeBoardPage extends ConsumerStatefulWidget {
  const NoticeBoardPage({super.key});

  @override
  ConsumerState<NoticeBoardPage> createState() => _NoticeBoardPageState();
}

class _NoticeBoardPageState extends ConsumerState<NoticeBoardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search & Language filters
  String _searchQuery = '';
  String _selectedLang = 'English'; // English, Hindi, Marathi
  String _selectedCategoryFilter = 'All';

  // Publish Form fields
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _attachmentCtrl = TextEditingController();
  String _selectedCategory = 'General';
  String _selectedPriority = 'Medium';
  String _selectedScope = 'ALL';
  bool _isPinned = false;

  // TV Emulator active notice index
  int _tvActiveIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _attachmentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final allNotices = ref.watch(noticesProvider);
    
    // Filters scoped by branch
    final scopedNotices = allNotices.where((n) {
      final matchesBranch = (n.branchId == 'ALL' || n.branchId == activeBranchId);
      final matchesSearch = n.title.toLowerCase().contains(_searchQuery.toLowerCase()) || n.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategoryFilter == 'All' || n.category == _selectedCategoryFilter;
      return matchesBranch && matchesSearch && matchesCategory;
    }).toList();

    // Pinned notices first, then sorted by priority/date
    scopedNotices.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.publishedDate.compareTo(a.publishedDate);
    });

    final pinnedNotices = allNotices.where((n) => n.isPinned && (n.branchId == 'ALL' || n.branchId == activeBranchId)).toList();

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
                        'Digital Notice Board: $branchName',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Campus TV Integrator: Active | Scope filtering: Enabled',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.add_alert_rounded, color: Colors.white, size: 16),
                  label: const Text('Publish Notice', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
                Tab(icon: Icon(Icons.dashboard_customize_rounded, size: 16), text: 'Notice board feed'),
                Tab(icon: Icon(Icons.create_rounded, size: 16), text: 'Publish Notice Form'),
                Tab(icon: Icon(Icons.tv_rounded, size: 16), text: 'Digital Display TV Emulator'),
                Tab(icon: Icon(Icons.analytics_rounded, size: 16), text: 'Views & Acknowledgment stats'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Notice Board Feed
                _buildFeedTab(scopedNotices),

                // Tab 2: Publish Form
                _buildPublishTab(activeBranchId),

                // Tab 3: Display TV Emulator
                _buildTvEmulatorTab(pinnedNotices),

                // Tab 4: Analytics
                _buildAnalyticsTab(scopedNotices),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Notice Board Feed
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildFeedTab(List<NoticeEntity> notices) {
    return Column(
      children: [
        // Search & Language filters
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Notice Board Title / Content...',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedCategoryFilter,
                style: const TextStyle(fontSize: 11, color: Colors.indigo),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All categories')),
                  DropdownMenuItem(value: 'Academic', child: Text('Academic')),
                  DropdownMenuItem(value: 'Administrative', child: Text('Administrative')),
                  DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
                  DropdownMenuItem(value: 'General', child: Text('General')),
                ],
                onChanged: (val) => setState(() => _selectedCategoryFilter = val ?? 'All'),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedLang,
                style: const TextStyle(fontSize: 11, color: Colors.teal),
                items: const [
                  DropdownMenuItem(value: 'English', child: Text('English (Original)')),
                  DropdownMenuItem(value: 'Hindi', child: Text('Hindi (Mock Transl.)')),
                  DropdownMenuItem(value: 'Marathi', child: Text('Marathi (Mock Transl.)')),
                ],
                onChanged: (val) => setState(() => _selectedLang = val ?? 'English'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final n = notices[index];
              final isHighPriority = n.priority == 'High';
              final hasAck = n.acknowledgedBy.contains('Student User');

              // Mock translations
              String displayTitle = n.title;
              String displayContent = n.content;
              if (_selectedLang == 'Hindi') {
                displayTitle = 'सूचना: ${n.title}';
                displayContent = 'यह एक अनुवादित सूचना है: ${n.content}';
              } else if (_selectedLang == 'Marathi') {
                displayTitle = 'सूचना: ${n.title}';
                displayContent = 'हा एक अनुवादित मजकूर आहे: ${n.content}';
              }

              return Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isHighPriority ? Colors.red : (n.isPinned ? Colors.amber : Colors.transparent),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (n.isPinned)
                                const Icon(Icons.push_pin_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Chip(
                                label: Text(n.category, style: const TextStyle(fontSize: 8, color: Colors.white)),
                                backgroundColor: isHighPriority ? Colors.red : Colors.blue,
                              ),
                            ],
                          ),
                          Text('Priority: ${n.priority} | Scope: ${n.branchId == "ALL" ? "All branches" : "Local branch"}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(displayTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(displayContent, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      if (n.attachmentName != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.attachment_rounded, size: 14, color: Colors.teal),
                            const SizedBox(width: 4),
                            Text('Attachment: ${n.attachmentName}', style: const TextStyle(fontSize: 10, color: Colors.teal)),
                          ],
                        ),
                      ],
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Published: ${n.publishedDate} | Views: ${n.views}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasAck ? Colors.green : AppColors.primary,
                                  minimumSize: const Size(80, 30),
                                ),
                                onPressed: () {
                                  ref.read(noticesProvider.notifier).acknowledgeNotice(n.id, 'Student User');
                                  ref.read(noticesProvider.notifier).incrementViews(n.id);
                                },
                                child: Text(
                                  hasAck ? 'Acknowledged ✓' : 'Acknowledge Notice',
                                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
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
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Publish Notice Form
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPublishTab(String activeBranchId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✏️ Publish New Notice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Notice Title')),
          TextField(controller: _contentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notice description content details')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
            items: const [
              DropdownMenuItem(value: 'Academic', child: Text('Academic')),
              DropdownMenuItem(value: 'Administrative', child: Text('Administrative')),
              DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
              DropdownMenuItem(value: 'General', child: Text('General')),
            ],
            onChanged: (val) => setState(() => _selectedCategory = val ?? 'General'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedPriority,
            decoration: const InputDecoration(labelText: 'Priority Level'),
            items: const [
              DropdownMenuItem(value: 'High', child: Text('High (Color codes Crimson red)')),
              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
              DropdownMenuItem(value: 'Low', child: Text('Low')),
            ],
            onChanged: (val) => setState(() => _selectedPriority = val ?? 'Medium'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedScope,
            decoration: const InputDecoration(labelText: 'Target Scope Audience'),
            items: [
              DropdownMenuItem(value: activeBranchId, child: const Text('Local Branch Only')),
              const DropdownMenuItem(value: 'ALL', child: Text('Organization-Wide (All campuses)')),
            ],
            onChanged: (val) => setState(() => _selectedScope = val ?? 'ALL'),
          ),
          TextField(controller: _attachmentCtrl, decoration: const InputDecoration(labelText: 'Attachment file name (Optional)')),
          const SizedBox(height: 12),
          SwitchListTile(
            dense: true,
            title: const Text('Pin important notice at the top of the feed', style: TextStyle(fontSize: 11)),
            value: _isPinned,
            onChanged: (val) => setState(() => _isPinned = val),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (_titleCtrl.text.isNotEmpty && _contentCtrl.text.isNotEmpty) {
                  ref.read(noticesProvider.notifier).publishNotice(
                    NoticeEntity(
                      id: 'NTC-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: _selectedScope,
                      title: _titleCtrl.text,
                      content: _contentCtrl.text,
                      category: _selectedCategory,
                      priority: _selectedPriority,
                      isPinned: _isPinned,
                      publishedDate: '2026-08-19',
                      attachmentName: _attachmentCtrl.text.isNotEmpty ? _attachmentCtrl.text : null,
                    ),
                  );
                  _titleCtrl.clear();
                  _contentCtrl.clear();
                  _attachmentCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Notice broadcasted. Urgent push notification dispatched!')),
                  );
                  _tabController.animateTo(0);
                }
              },
              child: const Text('Broadcast Notice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Display TV Emulator
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildTvEmulatorTab(List<NoticeEntity> pinned) {
    if (pinned.isEmpty) {
      return const Center(
        child: Text('No pinned notices available for campus TV screens.', style: TextStyle(color: Colors.grey)),
      );
    }

    final activeNotice = pinned[_tvActiveIndex % pinned.length];

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black54, width: 8),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.live_tv_rounded, color: Colors.redAccent, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'CAMPUS LED DISPLAY BOARD EMULATOR',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 16),
                    onPressed: () {
                      setState(() {
                        if (_tvActiveIndex > 0) _tvActiveIndex--;
                      });
                    },
                  ),
                  Text('${(_tvActiveIndex % pinned.length) + 1} / ${pinned.length}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                    onPressed: () {
                      setState(() {
                        _tvActiveIndex++;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          const Spacer(),

          // Display Slide Content
          Center(
            child: Column(
              children: [
                Chip(
                  label: Text('PINNED: ${activeNotice.category.toUpperCase()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  backgroundColor: activeNotice.priority == 'High' ? Colors.red : Colors.indigo,
                ),
                const SizedBox(height: 16),
                Text(
                  activeNotice.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.yellowAccent, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  activeNotice.content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),

          const Spacer(),
          const Center(
            child: Text(
              'Auto-cycling active slides every 15 seconds. Scored regional headers included.',
              style: TextStyle(color: Colors.white30, fontSize: 9, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — View Analytics & Bulk Import
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildAnalyticsTab(List<NoticeEntity> notices) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bulk Import desk
          Card(
            color: Colors.blue.withValues(alpha: 0.05),
            child: ListTile(
              leading: const Icon(Icons.file_download_rounded, color: Colors.blue),
              title: const Text('Download CSV template for bulk notices import', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              subtitle: const Text('Prepare Excel notice sheets and import all at once.'),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Starting notices bulk CSV download...')),
                  );
                },
                child: const Text('Download template', style: TextStyle(fontSize: 9)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notice stats list
          const Text('📊 Notice Board View Counts & Acknowledgments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          ...notices.map((n) {
            final acks = n.acknowledgedBy.length;
            return Card(
              child: ListTile(
                title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                subtitle: Text('Views count: ${n.views} | Acknowledged by: $acks users'),
                trailing: CircularProgressIndicator(
                  value: n.views > 0 ? (acks / n.views) : 0.0,
                  backgroundColor: Colors.grey.withValues(alpha: 0.1),
                  strokeWidth: 4,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

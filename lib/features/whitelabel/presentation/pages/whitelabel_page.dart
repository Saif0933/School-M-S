import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class WhiteLabelPage extends ConsumerStatefulWidget {
  const WhiteLabelPage({super.key});

  @override
  ConsumerState<WhiteLabelPage> createState() => _WhiteLabelPageState();
}

class _WhiteLabelPageState extends ConsumerState<WhiteLabelPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Selected Branch settings editor
  String _selectedEditBranchId = 'BR-001';

  // Form Fields
  final _subDomainCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _smsIdCtrl = TextEditingController();
  String _selectedTerm = 'Class/Teacher';
  String _selectedColor = '#4F46E5';

  // Email template builder fields
  String _selectedEmailTemplateId = 'FEE-ALERT';
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  // URL shortener fields
  final _longUrlCtrl = TextEditingController(text: 'https://sunrise.symbosys.edu/delhi/canteen/ordering/ticket/129380128');
  String _shortenedUrl = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBranchConfig();
  }

  void _loadBranchConfig() {
    final configs = ref.read(branchWhiteLabelProvider);
    final c = configs.firstWhere((element) => element.branchId == _selectedEditBranchId);
    _subDomainCtrl.text = c.subDomain;
    _logoCtrl.text = c.logoOverride;
    _smsIdCtrl.text = c.smsSenderId;
    _selectedTerm = c.terminology;
    _selectedColor = c.primaryColorHex;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subDomainCtrl.dispose();
    _logoCtrl.dispose();
    _smsIdCtrl.dispose();
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    _longUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final emailTemplates = ref.watch(emailTemplatesProvider).where((t) => t.branchId == _selectedEditBranchId).toList();
    final configs = ref.watch(branchWhiteLabelProvider);
    final activeConfig = configs.firstWhere((element) => element.branchId == _selectedEditBranchId);

    return Scaffold(
      body: Column(
        children: [
          // Subheader
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;

              final titleCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'White-Label & Branding: $branchName',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Custom Terminology overrides | Custom Sub-domains mapping: Active',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              );

              final dropdown = DropdownButton<String>(
                value: _selectedEditBranchId,
                style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold),
                items: const [
                  DropdownMenuItem(value: 'BR-001', child: Text('Delhi Campus (BR-001)')),
                  DropdownMenuItem(value: 'BR-002', child: Text('Mumbai Campus (BR-002)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedEditBranchId = val;
                      _loadBranchConfig();
                    });
                  }
                },
              );

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleCol,
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedEditBranchId,
                              style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold),
                              items: const [
                                DropdownMenuItem(value: 'BR-001', child: Text('Delhi Campus (BR-001)')),
                                DropdownMenuItem(value: 'BR-002', child: Text('Mumbai Campus (BR-002)')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedEditBranchId = val;
                                    _loadBranchConfig();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: titleCol),
                          const SizedBox(width: 16),
                          dropdown,
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
                Tab(icon: Icon(Icons.palette_rounded, size: 16), text: 'Branch Domain & Colors Override'),
                Tab(icon: Icon(Icons.mail_outline_rounded, size: 16), text: 'Email & SMS templates customizer'),
                Tab(icon: Icon(Icons.visibility_off_rounded, size: 16), text: 'Menu visibility & URL shortener'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildThemeTab(activeConfig),
                _buildEmailTab(emailTemplates),
                _buildMenuTab(activeConfig),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Branch Domain & Theme overrides
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildThemeTab(BranchWhiteLabelConfig activeConfig) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;

        final formWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✏️ Branch Branding configurations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(controller: _subDomainCtrl, decoration: const InputDecoration(labelText: 'Branch Sub-Domain (e.g. delhi.org.com)')),
            TextField(controller: _logoCtrl, decoration: const InputDecoration(labelText: 'Branch Logo file override name')),
            TextField(controller: _smsIdCtrl, decoration: const InputDecoration(labelText: 'Branch SMS Sender ID (6 Characters)')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedTerm,
              decoration: const InputDecoration(labelText: 'Custom Terminology Mapping'),
              items: const [
                DropdownMenuItem(value: 'Class/Teacher', child: Text('Standard (Class, Section, Teacher)')),
                DropdownMenuItem(value: 'Grade/Educator', child: Text('Modern International (Grade, Group, Educator)')),
              ],
              onChanged: (val) => setState(() => _selectedTerm = val ?? 'Class/Teacher'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedColor,
              decoration: const InputDecoration(labelText: 'Custom Branch Color Theme'),
              items: const [
                DropdownMenuItem(value: '#4F46E5', child: Text('Classic Indigo Blue (#4F46E5)')),
                DropdownMenuItem(value: '#0D9488', child: Text('Emerald Green (#0D9488)')),
                DropdownMenuItem(value: '#D97706', child: Text('Sunset Orange (#D97706)')),
              ],
              onChanged: (val) => setState(() => _selectedColor = val ?? '#4F46E5'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  final updated = activeConfig.copyWith(
                    subDomain: _subDomainCtrl.text,
                    logoOverride: _logoCtrl.text,
                    smsSenderId: _smsIdCtrl.text,
                    terminology: _selectedTerm,
                    primaryColorHex: _selectedColor,
                  );
                  ref.read(branchWhiteLabelProvider.notifier).updateConfig(_selectedEditBranchId, updated);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Custom branch branding overrides saved.')),
                  );
                },
                child: const Text('Save Branch Overrides', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );

        final previewWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🛡️ Branch login page white-label preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield, color: Colors.blueAccent, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        _selectedEditBranchId == 'BR-001' ? 'SUNRISE DELHI' : 'SUNRISE MUMBAI',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Sub-Domain: ${_subDomainCtrl.text}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text('SMS Sender ID: ${_smsIdCtrl.text}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Email Address / Username', isDense: true),
                  ),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password', isDense: true),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedColor == '#0D9488'
                          ? Colors.teal
                          : (_selectedColor == '#D97706' ? Colors.amber.shade800 : Colors.indigo),
                    ),
                    onPressed: () {},
                    child: const Text('Login securely', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    formWidget,
                    const SizedBox(height: 32),
                    previewWidget,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: formWidget),
                    const SizedBox(width: 24),
                    Expanded(child: previewWidget),
                  ],
                ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Email & SMS template builder
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildEmailTab(List<BrandedEmailTemplate> templates) {
    if (templates.isNotEmpty) {
      final t = templates.firstWhere((element) => element.id == _selectedEmailTemplateId, orElse: () => templates.first);
      _subjectCtrl.text = t.subject;
      _bodyCtrl.text = t.body;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✏️ Custom Email Notification templates builder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedEmailTemplateId,
                decoration: const InputDecoration(labelText: 'Notification Trigger Trigger'),
                items: const [
                  DropdownMenuItem(value: 'FEE-ALERT', child: Text('Fees collection alert email template')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedEmailTemplateId = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(controller: _subjectCtrl, decoration: const InputDecoration(labelText: 'Custom Subject Header')),
              TextField(controller: _bodyCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Body Text Content')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    ref.read(emailTemplatesProvider.notifier).updateTemplate(
                      _selectedEmailTemplateId,
                      _selectedEditBranchId,
                      _subjectCtrl.text,
                      _bodyCtrl.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Custom email trigger template saved.')),
                    );
                  },
                  child: const Text('Save Custom Email Template', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Menu Visibility & URL shortener
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildMenuTab(BranchWhiteLabelConfig activeConfig) {
    final modulesList = ['Online Classes & LMS', 'Canteen & Wallet', 'Alumni network', 'Health & Medical'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;

        final togglesWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('👁️ Branch Menu Visibility controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            ...modulesList.map((modName) {
              final isHidden = activeConfig.hiddenMenuIds.contains(modName);
              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(modName, style: const TextStyle(fontSize: 11)),
                subtitle: const Text('Show in branch navigation sidebars', style: TextStyle(fontSize: 9)),
                value: !isHidden,
                onChanged: (val) {
                  final updatedList = List<String>.from(activeConfig.hiddenMenuIds);
                  if (val == true) {
                    updatedList.remove(modName);
                  } else {
                    if (!updatedList.contains(modName)) updatedList.add(modName);
                  }
                  ref.read(branchWhiteLabelProvider.notifier).updateConfig(
                    _selectedEditBranchId,
                    activeConfig.copyWith(hiddenMenuIds: updatedList),
                  );
                },
              );
            }),
          ],
        );

        final shortenerWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔗 White-Label custom URL Shortener', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            const Text('Generate short custom links using your custom domains.', style: TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 12),
            TextField(controller: _longUrlCtrl, decoration: const InputDecoration(labelText: 'Long URL Address Link')),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  setState(() {
                    _shortenedUrl = 'http://sun.rs/del-fee';
                  });
                },
                child: const Text('Generate Short Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            if (_shortenedUrl.isNotEmpty) ...[
              const Divider(height: 24),
              const Text('Shortened Link:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 4),
              Text(_shortenedUrl, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13)),
            ],
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    togglesWidget,
                    const SizedBox(height: 32),
                    shortenerWidget,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: togglesWidget),
                    const SizedBox(width: 24),
                    Expanded(child: shortenerWidget),
                  ],
                ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../../academic/providers.dart';
import '../../providers.dart';

class VisitorSecurityPage extends ConsumerStatefulWidget {
  const VisitorSecurityPage({super.key});

  @override
  ConsumerState<VisitorSecurityPage> createState() => _VisitorSecurityPageState();
}

class _VisitorSecurityPageState extends ConsumerState<VisitorSecurityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Pre-registration form fields
  final _visitorNameCtrl = TextEditingController();
  final _visitorPhoneCtrl = TextEditingController();
  final _visitorPurposeCtrl = TextEditingController();
  final _whomToMeetCtrl = TextEditingController();
  final _vehicleCtrl = TextEditingController();
  bool _isBlacklisted = false;
  VisitorRecord? _latestPassVisitor;

  // Gate Pass form fields
  StudentEntity? _selectedStudent;
  final _parentNameCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _pickupCodeCtrl = TextEditingController();

  // Incident form fields
  final _incidentDescCtrl = TextEditingController();
  String _selectedIncidentType = 'Trespassing';
  String _selectedIncidentSeverity = 'Warning';

  // Material ledger fields
  final _matDescCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  String _selectedMatType = 'Inward';

  // Evacuation trigger alarm active state
  bool _evacuationActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _visitorNameCtrl.dispose();
    _visitorPhoneCtrl.dispose();
    _visitorPurposeCtrl.dispose();
    _whomToMeetCtrl.dispose();
    _vehicleCtrl.dispose();
    _parentNameCtrl.dispose();
    _reasonCtrl.dispose();
    _pickupCodeCtrl.dispose();
    _incidentDescCtrl.dispose();
    _matDescCtrl.dispose();
    _vendorCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final students = ref.watch(academicStudentsProvider).where((s) => s.branchId == activeBranchId).toList();
    final visitors = ref.watch(visitorsProvider).where((v) => v.branchId == activeBranchId).toList();
    final gatePasses = ref.watch(gatePassesProvider).where((g) => g.branchId == activeBranchId).toList();
    final incidents = ref.watch(incidentsProvider).where((i) => i.branchId == activeBranchId).toList();
    final materials = ref.watch(materialsProvider).where((m) => m.branchId == activeBranchId).toList();

    return Scaffold(
      body: Column(
        children: [
          // Subheader
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;

                final textDetails = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visitor & Security Desk: $branchName',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Text(
                      'Campus CCTV Integrations: Active | Biometrics gates: Operational',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                );

                final actionButton = ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    setState(() {
                      _evacuationActive = !_evacuationActive;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: _evacuationActive ? Colors.red : Colors.green,
                        content: Text(
                          _evacuationActive
                              ? '⚠️ CRITICAL ALARM: Evacuation active, sirens sounding!'
                              : '✓ Emergency alarm reset. Gates unlocked.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.emergency_share_rounded, color: Colors.white, size: 16),
                  label: Text(
                    _evacuationActive ? 'Reset Siren' : 'Evacuation Siren',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                );

                return isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textDetails,
                          const SizedBox(height: 10),
                          SizedBox(width: double.infinity, child: actionButton),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: textDetails),
                          const SizedBox(width: 16),
                          actionButton,
                        ],
                      );
              },
            ),
          ),

          // Panic Evacuation banner
          if (_evacuationActive)
            Container(
              width: double.infinity,
              color: Colors.red.shade900,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    '⚠️ DANGER: EVACUATION DRILL ALARM TRIGGERED! Gate checkpoints unlocked. Siren active.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
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
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: const [
                Tab(icon: Icon(Icons.people_alt_rounded, size: 16), text: 'Visitor Pre-reg & Passes'),
                Tab(icon: Icon(Icons.vpn_key_rounded, size: 16), text: 'Student Gate Passes'),
                Tab(icon: Icon(Icons.videocam_rounded, size: 16), text: 'CCTV & Patrol Logs'),
                Tab(icon: Icon(Icons.report_problem_rounded, size: 16), text: 'Incidents & Material ledgers'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVisitorTab(visitors, activeBranchId, branchName),
                _buildGatePassTab(gatePasses, students, activeBranchId),
                _buildCctvTab(),
                _buildIncidentsTab(incidents, materials, activeBranchId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Visitor Pre-registration & Passes
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildVisitorTab(List<VisitorRecord> visitors, String branchId, String branchName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobileView = constraints.maxWidth < 768;

              final formColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✏️ Pre-Register Visitor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  TextField(controller: _visitorNameCtrl, decoration: const InputDecoration(labelText: 'Visitor Name')),
                  TextField(controller: _visitorPhoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
                  TextField(controller: _whomToMeetCtrl, decoration: const InputDecoration(labelText: 'Whom to Meet (e.g. Faculty Name)')),
                  TextField(controller: _visitorPurposeCtrl, decoration: const InputDecoration(labelText: 'Purpose description')),
                  TextField(controller: _vehicleCtrl, decoration: const InputDecoration(labelText: 'Vehicle Plate (Optional)')),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    dense: true,
                    title: const Text('Blacklist visitor (Block entrance gate keys)', style: TextStyle(fontSize: 11)),
                    value: _isBlacklisted,
                    onChanged: (val) => setState(() => _isBlacklisted = val),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () {
                        if (_visitorNameCtrl.text.isNotEmpty) {
                          final record = VisitorRecord(
                            id: 'VIS-${DateTime.now().millisecondsSinceEpoch}',
                            branchId: branchId,
                            name: _visitorNameCtrl.text,
                            phone: _visitorPhoneCtrl.text,
                            purpose: _visitorPurposeCtrl.text,
                            whomToMeet: _whomToMeetCtrl.text,
                            vehicleNumber: _vehicleCtrl.text.isNotEmpty ? _vehicleCtrl.text : null,
                            checkInTime: '',
                            status: 'Pre-registered',
                            isBlacklisted: _isBlacklisted,
                          );
                          ref.read(visitorsProvider.notifier).preRegister(record);
                          _visitorNameCtrl.clear();
                          _visitorPhoneCtrl.clear();
                          _whomToMeetCtrl.clear();
                          _visitorPurposeCtrl.clear();
                          _vehicleCtrl.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Visitor pre-registered on gate logs.')),
                          );
                        }
                      },
                      child: const Text('Add Pre-Registration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );

              final passPreviewWidget = _latestPassVisitor != null
                  ? Center(
                      child: Container(
                        width: 240,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.teal, width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(branchName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.indigo)),
                            const Text('VISITOR PASS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal, letterSpacing: 0.8)),
                            const Divider(height: 16),
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(_latestPassVisitor!.photoUrl),
                            ),
                            const SizedBox(height: 8),
                            Text(_latestPassVisitor!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
                            Text('Meet: ${_latestPassVisitor!.whomToMeet}', style: const TextStyle(fontSize: 9, color: Colors.black87)),
                            Text('Purpose: ${_latestPassVisitor!.purpose}', style: const TextStyle(fontSize: 8, color: Colors.black54)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Serial: ${_latestPassVisitor!.id.replaceAll("VIS-", "PASS-")}', style: const TextStyle(fontSize: 6, color: Colors.black54)),
                                    Text('In time: ${_latestPassVisitor!.checkInTime}', style: const TextStyle(fontSize: 8, color: Colors.black)),
                                  ],
                                ),
                                const Icon(Icons.qr_code_2_rounded, size: 28, color: Colors.black),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink();

              return isMobileView
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        formColumn,
                        if (_latestPassVisitor != null) ...[
                          const SizedBox(height: 24),
                          passPreviewWidget,
                        ],
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: formColumn),
                        if (_latestPassVisitor != null) ...[
                          const SizedBox(width: 24),
                          Expanded(child: passPreviewWidget),
                        ],
                      ],
                    );
            },
          ),
          const Divider(height: 36),

          const Text('📋 Active Visitors Log Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visitors.length,
            itemBuilder: (context, index) {
              final v = visitors[index];
              return Card(
                color: v.isBlacklisted ? Colors.red.withValues(alpha: 0.05) : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (context, cardConstraints) {
                      final isCardMobile = cardConstraints.maxWidth < 500;

                      final avatarWidget = CircleAvatar(
                        backgroundColor: v.isBlacklisted ? Colors.red : Colors.grey,
                        child: Icon(v.isBlacklisted ? Icons.block : Icons.person, color: Colors.white),
                      );

                      final detailsWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            'Meeting: ${v.whomToMeet} for ${v.purpose}\nPhone: ${v.phone} | Status: ${v.status}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      );

                      final actionRow = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (v.status == 'Pre-registered' && !v.isBlacklisted)
                            ElevatedButton(
                              onPressed: () {
                                ref.read(visitorsProvider.notifier).checkIn(v.id, '12:15 PM');
                                setState(() {
                                  _latestPassVisitor = v.copyWith(status: 'Checked-In', checkInTime: '12:15 PM');
                                });
                              },
                              child: const Text('Check-In', style: TextStyle(fontSize: 9)),
                            )
                          else if (v.status == 'Checked-In')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                              onPressed: () {
                                ref.read(visitorsProvider.notifier).checkOut(v.id, '03:30 PM');
                              },
                              child: const Text('Check-Out', style: TextStyle(fontSize: 9, color: Colors.white)),
                            )
                          else if (v.isBlacklisted)
                            const Chip(
                              label: Text('BLACKLISTED', style: TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.red,
                            ),
                        ],
                      );

                      return isCardMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    avatarWidget,
                                    const SizedBox(width: 12),
                                    Expanded(child: detailsWidget),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(alignment: Alignment.centerRight, child: actionRow),
                              ],
                            )
                          : Row(
                              children: [
                                avatarWidget,
                                const SizedBox(width: 12),
                                Expanded(child: detailsWidget),
                                const SizedBox(width: 12),
                                actionRow,
                              ],
                            );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Student Gate Passes
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildGatePassTab(List<GatePassRecord> passes, List<StudentEntity> students, String branchId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✏️ Request Student Gate Pass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          DropdownButtonFormField<StudentEntity>(
            initialValue: _selectedStudent,
            decoration: const InputDecoration(labelText: 'Select Student'),
            items: students.map((s) {
              return DropdownMenuItem<StudentEntity>(
                value: s,
                child: Text(s.name),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedStudent = val),
          ),
          const SizedBox(height: 12),
          TextField(controller: _parentNameCtrl, decoration: const InputDecoration(labelText: 'Pickup Guardian Name')),
          TextField(controller: _pickupCodeCtrl, decoration: const InputDecoration(labelText: 'Pickup Verification Code (PIN)')),
          TextField(controller: _reasonCtrl, decoration: const InputDecoration(labelText: 'Reason details (e.g. sick leave)')),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (_selectedStudent != null && _parentNameCtrl.text.isNotEmpty) {
                  ref.read(gatePassesProvider.notifier).requestGatePass(
                    GatePassRecord(
                      id: 'GP-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: branchId,
                      studentName: _selectedStudent!.name,
                      parentName: _parentNameCtrl.text,
                      pickupCode: _pickupCodeCtrl.text.isNotEmpty ? _pickupCodeCtrl.text : 'PICK-0000',
                      reason: _reasonCtrl.text,
                      passTime: '01:45 PM',
                      status: 'Pending',
                    ),
                  );
                  _parentNameCtrl.clear();
                  _pickupCodeCtrl.clear();
                  _reasonCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Gate Pass requested. Pending Principal e-signature check.')),
                  );
                }
              },
              child: const Text('Generate Gate Pass Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const Divider(height: 36),

          const Text('📋 Student Gate Passes Log Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: passes.length,
            itemBuilder: (context, index) {
              final g = passes[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (context, cardConstraints) {
                      final isCardMobile = cardConstraints.maxWidth < 500;

                      final iconWidget = const Icon(Icons.no_accounts_rounded, color: Colors.amber);

                      final detailsWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            'Guardian: ${g.parentName} | PIN: ${g.pickupCode}\nReason: ${g.reason} | Time: ${g.passTime}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      );

                      final actionsWidget = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(g.status, style: const TextStyle(fontSize: 8, color: Colors.white)),
                            backgroundColor: g.status == 'Approved' ? Colors.green : (g.status == 'Departed' ? Colors.indigo : Colors.orange),
                          ),
                          const SizedBox(width: 8),
                          if (g.status == 'Pending')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(minimumSize: const Size(60, 20), padding: const EdgeInsets.symmetric(horizontal: 8)),
                              onPressed: () => ref.read(gatePassesProvider.notifier).updatePassStatus(g.id, 'Approved'),
                              child: const Text('Approve', style: TextStyle(fontSize: 8)),
                            )
                          else if (g.status == 'Approved')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(60, 20), padding: const EdgeInsets.symmetric(horizontal: 8)),
                              onPressed: () => ref.read(gatePassesProvider.notifier).updatePassStatus(g.id, 'Departed'),
                              child: const Text('Depart', style: TextStyle(fontSize: 8, color: Colors.white)),
                            ),
                        ],
                      );

                      return isCardMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    iconWidget,
                                    const SizedBox(width: 12),
                                    Expanded(child: detailsWidget),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(alignment: Alignment.centerRight, child: actionsWidget),
                              ],
                            )
                          : Row(
                              children: [
                                iconWidget,
                                const SizedBox(width: 12),
                                Expanded(child: detailsWidget),
                                const SizedBox(width: 12),
                                actionsWidget,
                              ],
                            );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — CCTV Feeds & Guard patrols
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildCctvTab() {
    final feeds = ['Gate 1 Entrance', 'Lobby Block A', 'Library Desk', 'Sports Field'];
    final patrols = [
      {'checkpoint': 'Gate 1 main entrance', 'time': '10:00 AM', 'guard': 'Guard Shinde', 'status': 'Verified'},
      {'checkpoint': 'Block A Chemistry Lab', 'time': '11:30 AM', 'guard': 'Guard Shinde', 'status': 'Verified'},
      {'checkpoint': 'Block B Playground corner', 'time': '12:00 PM', 'guard': 'Guard Patil', 'status': 'Pending Check-In'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎥 Live CCTV Camera Feeds Integrator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 550 ? 1 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: MediaQuery.of(context).size.width < 550 ? 2.2 : 1.6,
            ),
            itemCount: feeds.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.black87,
                child: Stack(
                  children: [
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_rounded, color: Colors.green, size: 36),
                          SizedBox(height: 8),
                          Text('[LIVE STREAM ACTIVE]', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Text(feeds[index], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(minimumSize: const Size(60, 24), padding: const EdgeInsets.symmetric(horizontal: 8)),
                        onPressed: () => _watchCctvScreen(context, feeds[index]),
                        child: const Text('Fullscreen Feed', style: TextStyle(fontSize: 8)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          const Text('🚶 Security Guard patrol checkpoints logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ...patrols.map((pt) => Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_walk_rounded, color: Colors.teal),
                  title: Text(pt['checkpoint']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  subtitle: Text('Roster Guard: ${pt["guard"]} | Expected: ${pt["time"]}'),
                  trailing: Chip(
                    label: Text(pt['status']!, style: const TextStyle(fontSize: 8, color: Colors.white)),
                    backgroundColor: pt['status'] == 'Verified' ? Colors.green : Colors.orange,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _watchCctvScreen(BuildContext context, String cameraName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(cameraName, style: const TextStyle(color: Colors.white)),
          content: Container(
            width: double.infinity,
            height: 240,
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('[Syncing live scanlines video feeds...]', style: TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close Stream', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Incidents & Materials ledgers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildIncidentsTab(List<SecurityIncident> incidents, List<MaterialRecord> materials, String branchId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;

              final incidentForm = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✏️ Report Security Incident', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedIncidentType,
                    decoration: const InputDecoration(labelText: 'Incident Type'),
                    items: const [
                      DropdownMenuItem(value: 'Trespassing', child: Text('Trespassing')),
                      DropdownMenuItem(value: 'Theft', child: Text('Theft / Burglary')),
                      DropdownMenuItem(value: 'Medical', child: Text('Medical Emergency')),
                      DropdownMenuItem(value: 'Damage', child: Text('Property Damage')),
                    ],
                    onChanged: (val) => setState(() => _selectedIncidentType = val ?? 'Trespassing'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedIncidentSeverity,
                    decoration: const InputDecoration(labelText: 'Severity level'),
                    items: const [
                      DropdownMenuItem(value: 'Critical', child: Text('Critical Danger')),
                      DropdownMenuItem(value: 'Warning', child: Text('Warning Alert')),
                      DropdownMenuItem(value: 'Info', child: Text('Info log')),
                    ],
                    onChanged: (val) => setState(() => _selectedIncidentSeverity = val ?? 'Warning'),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _incidentDescCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description details')),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        if (_incidentDescCtrl.text.isNotEmpty) {
                          ref.read(incidentsProvider.notifier).reportIncident(
                            SecurityIncident(
                              id: 'INC-${DateTime.now().millisecondsSinceEpoch}',
                              branchId: branchId,
                              type: _selectedIncidentType,
                              details: _incidentDescCtrl.text,
                              date: '2026-08-19',
                              severity: _selectedIncidentSeverity,
                            ),
                          );
                          _incidentDescCtrl.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Security incident logged in report file.')),
                          );
                        }
                      },
                      child: const Text('Log Incident Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );

              final materialForm = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✏️ Log Material Inward/Outward', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMatType,
                    decoration: const InputDecoration(labelText: 'Entry Type'),
                    items: const [
                      DropdownMenuItem(value: 'Inward', child: Text('Material Inward Entry')),
                      DropdownMenuItem(value: 'Outward', child: Text('Material Outward Entry')),
                    ],
                    onChanged: (val) => setState(() => _selectedMatType = val ?? 'Inward'),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _matDescCtrl, decoration: const InputDecoration(labelText: 'Material description (e.g. Uniforms)')),
                  TextField(controller: _vendorCtrl, decoration: const InputDecoration(labelText: 'Vendor Name')),
                  TextField(controller: _qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity')),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: () {
                        if (_matDescCtrl.text.isNotEmpty) {
                          ref.read(materialsProvider.notifier).logMaterial(
                            MaterialRecord(
                              id: 'MAT-${DateTime.now().millisecondsSinceEpoch}',
                              branchId: branchId,
                              description: _matDescCtrl.text,
                              type: _selectedMatType,
                              quantity: int.tryParse(_qtyCtrl.text) ?? 1,
                              vendor: _vendorCtrl.text.isNotEmpty ? _vendorCtrl.text : 'General Vendor',
                              time: '02:00 PM',
                            ),
                          );
                          _matDescCtrl.clear();
                          _vendorCtrl.clear();
                          _qtyCtrl.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Material ledger updated successfully.')),
                          );
                        }
                      },
                      child: const Text('Log Material Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );

              return isMobile
                  ? Column(
                      children: [
                        incidentForm,
                        const SizedBox(height: 24),
                        materialForm,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: incidentForm),
                        const SizedBox(width: 24),
                        Expanded(child: materialForm),
                      ],
                    );
            },
          ),
          const Divider(height: 36),

          const Text('📋 Incident and Material registries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;

              final incidentsWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Incident Reports today:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 8),
                  if (incidents.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No incident reports logged today.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    )
                  else
                    ...incidents.map((inc) => Card(
                          child: ListTile(
                            title: Text(inc.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            subtitle: Text('Details: ${inc.details}\nSeverity: ${inc.severity}'),
                          ),
                        )),
                ],
              );

              final materialsWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Materials ledger entries today:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 8),
                  if (materials.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No material entries logged today.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    )
                  else
                    ...materials.map((mat) => Card(
                          child: ListTile(
                            title: Text(mat.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            subtitle: Text('Type: ${mat.type} | Qty: ${mat.quantity}\nVendor: ${mat.vendor}'),
                          ),
                        )),
                ],
              );

              return isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        incidentsWidget,
                        const SizedBox(height: 24),
                        materialsWidget,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: incidentsWidget),
                        const SizedBox(width: 16),
                        Expanded(child: materialsWidget),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../providers.dart'; // import hostel providers

class HostelManagementPage extends ConsumerStatefulWidget {
  const HostelManagementPage({super.key});

  @override
  ConsumerState<HostelManagementPage> createState() => _HostelManagementPageState();
}

class _HostelManagementPageState extends ConsumerState<HostelManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
                icon: Icon(Icons.apartment_rounded, size: 16),
                text: 'Buildings & Rooms',
              ),
              Tab(
                icon: Icon(Icons.restaurant_menu_rounded, size: 16),
                text: 'Students & Mess',
              ),
              Tab(
                icon: Icon(Icons.checklist_rtl_rounded, size: 16),
                text: 'Curfew Attendance',
              ),
              Tab(
                icon: Icon(Icons.meeting_room_rounded, size: 16),
                text: 'Visitor Registry',
              ),
              Tab(
                icon: Icon(Icons.vpn_key_rounded, size: 16),
                text: 'Leaves & Gate Passes',
              ),
              Tab(
                icon: Icon(Icons.local_laundry_service_rounded, size: 16),
                text: 'Laundry Services',
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Scoped views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _BuildingsRoomsTab(branchId: activeBranchId),
              _StudentMessTab(branchId: activeBranchId),
              _CurfewTab(branchId: activeBranchId),
              _VisitorsTab(branchId: activeBranchId),
              _LeavesTab(branchId: activeBranchId),
              _LaundryTab(branchId: activeBranchId),
            ],
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 1 — Buildings & Rooms
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _BuildingsRoomsTab extends ConsumerWidget {
  final String branchId;
  const _BuildingsRoomsTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allBuildings = ref.watch(hostelBuildingsProvider);
    final buildings = allBuildings.where((b) => b.branchId == branchId).toList();

    final allRooms = ref.watch(hostelRoomsProvider);
    final rooms = allRooms.where((r) => r.branchId == branchId).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddRoomModal(context, ref, branchId, buildings),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Room', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hostel Buildings & Wardens',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: buildings.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: MediaQuery.of(context).size.width < 600 ? 1.8 : 2.2,
              ),
              itemBuilder: (context, index) {
                final b = buildings[index];
                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                      ),
                      const SizedBox(height: 6),
                      Text('Warden: ${b.wardenName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('Contact: ${b.wardenPhone}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const Spacer(),
                      Text('Total Registered Rooms: ${b.totalRooms}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Dormitories & Room Occupancies',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (rooms.isEmpty)
              const Center(child: Text('No rooms registered.'))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rooms.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: MediaQuery.of(context).size.width < 600 ? 1.3 : 1.6,
                ),
                itemBuilder: (context, index) {
                  final r = rooms[index];
                  final bedRatio = '${r.occupiedBeds}/${r.capacity} Beds';
                  final progress = r.capacity > 0 ? r.occupiedBeds / r.capacity : 0.0;

                  return GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(r.roomNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: r.status == 'Available' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                r.status,
                                style: TextStyle(fontSize: 9, color: r.status == 'Available' ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(r.buildingName, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('Type: ${r.roomType} | Rent: ₹${r.monthlyRent.toStringAsFixed(0)}/mo', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Beds Allocated:', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(bedRatio, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            color: progress >= 1.0 ? Colors.red : AppColors.primary,
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

  void _showAddRoomModal(BuildContext context, WidgetRef ref, String bId, List<HostelBuildingEntity> buildings) {
    if (buildings.isEmpty) return;
    final roomNoCtrl = TextEditingController();
    final rentCtrl = TextEditingController(text: '3000');
    final capCtrl = TextEditingController(text: '2');
    String selectedBldId = buildings.first.id;
    String selectedType = 'Double';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Hostel Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedBldId,
                decoration: const InputDecoration(labelText: 'Select Building'),
                items: buildings.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                onChanged: (val) {
                  if (val != null) selectedBldId = val;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: roomNoCtrl,
                decoration: const InputDecoration(labelText: 'Room Number (e.g. Room 103)'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: 'Room Type'),
                items: const [
                  DropdownMenuItem(value: 'Single', child: Text('Single')),
                  DropdownMenuItem(value: 'Double', child: Text('Double')),
                  DropdownMenuItem(value: 'Triple', child: Text('Triple')),
                  DropdownMenuItem(value: 'Dormitory', child: Text('Dormitory')),
                ],
                onChanged: (val) {
                  if (val != null) selectedType = val;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: capCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacity (Beds)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Rent (₹)'),
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
                if (roomNoCtrl.text.isNotEmpty) {
                  final bld = buildings.firstWhere((b) => b.id == selectedBldId);
                  ref.read(hostelRoomsProvider.notifier).addRoom(
                    HostelRoomEntity(
                      id: 'RM-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: bId,
                      buildingId: selectedBldId,
                      buildingName: bld.name,
                      roomNo: roomNoCtrl.text,
                      roomType: selectedType,
                      capacity: int.tryParse(capCtrl.text) ?? 2,
                      occupiedBeds: 0,
                      monthlyRent: double.tryParse(rentCtrl.text) ?? 3000.0,
                      status: 'Available',
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Room'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 2 — Student Directory & Mess Menu Plans
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _StudentMessTab extends ConsumerWidget {
  final String branchId;
  const _StudentMessTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allocations = ref.watch(hostelAllocationsProvider).where((a) => a.branchId == branchId).toList();
    final messPlans = ref.watch(messPlansProvider).where((p) => p.branchId == branchId).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Hostel Boarders',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (allocations.isEmpty)
              const Center(child: Text('No student allocations made.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allocations.length,
                itemBuilder: (context, index) {
                  final a = allocations[index];
                  final netRent = a.monthlyFee - a.waiverAmount;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person_rounded, color: Colors.white),
                      ),
                      title: Text(a.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${a.buildingName} | ${a.roomNo} (${a.bedNo}) \n'
                        'Mess Plan: ${a.messPlanName} | Rent: ₹${a.monthlyFee.toStringAsFixed(0)} (Concession: ₹${a.waiverAmount.toStringAsFixed(0)})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      isThreeLine: true,
                      trailing: TextButton.icon(
                        onPressed: () => _showWaiverDialog(context, ref, a.id, a.waiverAmount),
                        icon: const Icon(Icons.discount_rounded, size: 14),
                        label: Text('₹${netRent.toStringAsFixed(0)}/mo', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            Text(
              'Mess Plans & Weekly Menus',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...messPlans.map((p) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p.planName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: p.foodType == 'Veg' ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p.foodType,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: p.foodType == 'Veg' ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Weekly Schedule:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
                      const SizedBox(height: 2),
                      Text(p.weeklyMenu, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const Divider(height: 16),
                      Text('Monthly Charge: ₹${p.monthlyCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showWaiverDialog(BuildContext context, WidgetRef ref, String aId, double currentWaiver) {
    final waiverCtrl = TextEditingController(text: currentWaiver.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Apply Fee Waiver'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: waiverCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Waiver Concession Amount (₹)'),
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
                final amt = double.tryParse(waiverCtrl.text) ?? 0.0;
                ref.read(hostelAllocationsProvider.notifier).updateWaiver(aId, amt);
                Navigator.pop(context);
              },
              child: const Text('Save Waiver'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 3 — Curfew Attendance (Morning/Evening/Night)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _CurfewTab extends StatefulWidget {
  final String branchId;
  const _CurfewTab({required this.branchId});

  @override
  State<_CurfewTab> createState() => _CurfewTabState();
}

class _CurfewTabState extends State<_CurfewTab> {
  String _curfewSlot = 'Night Curfew (09:00 PM)';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer(
      builder: (context, ref, child) {
        final allocations = ref.watch(hostelAllocationsProvider).where((a) => a.branchId == widget.branchId).toList();

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hostel Curfew & Mess Attendance Roll Call',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mark student curfew check-ins and meal attendance.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: _curfewSlot,
                      items: const [
                        DropdownMenuItem(value: 'Morning Attendance', child: Text('Morning (08:00 AM)')),
                        DropdownMenuItem(value: 'Evening Attendance', child: Text('Evening (06:30 PM)')),
                        DropdownMenuItem(value: 'Night Curfew (09:00 PM)', child: Text('Night Curfew (09:00 PM)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _curfewSlot = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (allocations.isEmpty)
                  const Center(child: Text('No active boarders registered for attendance.'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allocations.length,
                    itemBuilder: (context, index) {
                      final a = allocations[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 450;
                              final infoColumn = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${a.buildingName} | ${a.roomNo}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              );
                              final buttons = Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    onPressed: () => _showMarkedSnack(context, a.studentName, 'Present'),
                                    child: const Text('Present', style: TextStyle(color: Colors.white, fontSize: 11)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => _showMarkedSnack(context, a.studentName, 'Absent'),
                                    child: const Text('Absent', style: TextStyle(color: Colors.white, fontSize: 11)),
                                  ),
                                ],
                              );

                              return isMobile
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        infoColumn,
                                        const SizedBox(height: 12),
                                        buttons,
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: infoColumn),
                                        const SizedBox(width: 8),
                                        buttons,
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
          ),
        );
      },
    );
  }

  void _showMarkedSnack(BuildContext context, String student, String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Marked $student as $status in $_curfewSlot log.'),
        backgroundColor: status == 'Present' ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 4 — Visitor Registry
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _VisitorsTab extends ConsumerWidget {
  final String branchId;
  const _VisitorsTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visitors = ref.watch(hostelVisitorsProvider).where((v) => v.branchId == branchId).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddVisitorModal(context, ref, branchId),
        icon: const Icon(Icons.badge_rounded, color: Colors.white),
        label: const Text('Log Visitor Check-In', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hostel Gate Visitor Entries',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verify check-in lists, relations, and record checkout clearances.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (visitors.isEmpty)
              const Center(child: Text('No visitor entries recorded.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visitors.length,
                itemBuilder: (context, index) {
                  final v = visitors[index];
                  final checkInStr = '${v.checkInTime.hour}:${v.checkInTime.minute}';
                  final isCheckedOut = v.checkOutTime != null;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Icon(Icons.people_rounded, color: Colors.white),
                      ),
                      title: Text(v.visitorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Relation: ${v.relationToStudent} | Visiting: ${v.studentName} (${v.buildingName})\n'
                        'Check-In: $checkInStr | Status: ${isCheckedOut ? "Checked Out" : "Still Inside"}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: isCheckedOut
                          ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                              onPressed: () => ref.read(hostelVisitorsProvider.notifier).checkOutVisitor(v.id),
                              child: const Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddVisitorModal(BuildContext context, WidgetRef ref, String bId) {
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController(text: 'Parent');
    final studentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Visitor Check-In'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Visitor Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: relationCtrl,
                decoration: const InputDecoration(labelText: 'Relation to Boarder'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: studentCtrl,
                decoration: const InputDecoration(labelText: 'Boarder Student Name'),
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
                if (nameCtrl.text.isNotEmpty && studentCtrl.text.isNotEmpty) {
                  ref.read(hostelVisitorsProvider.notifier).logVisitor(
                    HostelVisitorEntity(
                      id: 'VIS-H-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: bId,
                      visitorName: nameCtrl.text,
                      relationToStudent: relationCtrl.text,
                      studentName: studentCtrl.text,
                      buildingName: 'Main Hostel Tower',
                      checkInTime: DateTime.now(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Log Entry'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 5 — Leaves & Gate Passes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _LeavesTab extends ConsumerWidget {
  final String branchId;
  const _LeavesTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leaves = ref.watch(hostelLeavesProvider).where((l) => l.branchId == branchId).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekend Leaves & Outing Approvals',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Review weekend out-of-dorm leaves and weekend checkout permissions.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (leaves.isEmpty)
              const Center(child: Text('No leave applications recorded.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leaves.length,
                itemBuilder: (context, index) {
                  final l = leaves[index];
                  final isPending = l.status == 'Pending';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: l.status == 'Approved'
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : l.status == 'Pending'
                                          ? Colors.amber.withValues(alpha: 0.15)
                                          : Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l.status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: l.status == 'Approved'
                                        ? Colors.green
                                        : l.status == 'Pending'
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Leave Type: ${l.leaveType} | Room: ${l.roomNo} (${l.buildingName})', style: const TextStyle(fontSize: 12)),
                          Text('Reason: ${l.reason}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Duration: ${l.startDate.day}/${l.startDate.month} to ${l.endDate.day}/${l.endDate.month}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              if (isPending)
                                Row(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                      onPressed: () => ref.read(hostelLeavesProvider.notifier).approveLeave(l.id, 'Approved'),
                                      child: const Text('Approve', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                      onPressed: () => ref.read(hostelLeavesProvider.notifier).approveLeave(l.id, 'Rejected'),
                                      child: const Text('Reject', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                  ],
                                )
                              else
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                                  onPressed: () => _printGatePass(context, l.studentName),
                                  icon: const Icon(Icons.print_rounded, size: 14, color: Colors.white),
                                  label: const Text('Print Gate Pass', style: TextStyle(color: Colors.white, fontSize: 11)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _printGatePass(BuildContext context, String student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🖨️ Digital Gate Pass generated & shared with Warden for $student.'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 6 — Laundry & Support Services
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _LaundryTab extends ConsumerWidget {
  final String branchId;
  const _LaundryTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logs = ref.watch(laundryLogsProvider).where((l) => l.branchId == branchId).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddLaundryModal(context, ref, branchId),
        icon: const Icon(Icons.local_laundry_service_rounded, color: Colors.white),
        label: const Text('Record Clothes Intake', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laundry Intake & Dispatch Board',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Log student laundry bags, monitor wash schedules, and mark items ready for collection.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (logs.isEmpty)
              const Center(child: Text('No laundry logs recorded.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final l = logs[index];
                  final subDateStr = '${l.submissionDate.day}/${l.submissionDate.month}';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.local_laundry_service_rounded, color: Colors.white),
                      ),
                      title: Text(l.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Items: ${l.itemsCount} clothes | Intake Date: $subDateStr | Status: ${l.status}', style: const TextStyle(fontSize: 11)),
                      trailing: DropdownButton<String>(
                        value: l.status,
                        items: const [
                          DropdownMenuItem(value: 'Submitted', child: Text('Submitted')),
                          DropdownMenuItem(value: 'In Laundry', child: Text('In Laundry')),
                          DropdownMenuItem(value: 'Ready', child: Text('Ready')),
                          DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(laundryLogsProvider.notifier).updateStatus(l.id, val);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddLaundryModal(BuildContext context, WidgetRef ref, String bId) {
    final studentCtrl = TextEditingController();
    final countCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record Clothes Intake'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentCtrl,
                decoration: const InputDecoration(labelText: 'Boarder Student Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: countCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Number of Clothes'),
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
                if (studentCtrl.text.isNotEmpty) {
                  ref.read(laundryLogsProvider.notifier).addLaundry(
                    LaundryLogEntity(
                      id: 'LAUN-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: bId,
                      studentName: studentCtrl.text,
                      itemsCount: int.tryParse(countCtrl.text) ?? 10,
                      submissionDate: DateTime.now(),
                      status: 'Submitted',
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Intake'),
            ),
          ],
        );
      },
    );
  }
}

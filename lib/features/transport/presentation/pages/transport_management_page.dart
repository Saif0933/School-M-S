import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../providers.dart'; // import transport providers

class TransportManagementPage extends ConsumerStatefulWidget {
  const TransportManagementPage({super.key});

  @override
  ConsumerState<TransportManagementPage> createState() => _TransportManagementPageState();
}

class _TransportManagementPageState extends ConsumerState<TransportManagementPage>
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
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
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
                icon: Icon(Icons.directions_bus_rounded, size: 16),
                text: 'Fleet Management',
              ),
              Tab(
                icon: Icon(Icons.badge_rounded, size: 16),
                text: 'Drivers & Staff',
              ),
              Tab(
                icon: Icon(Icons.alt_route_rounded, size: 16),
                text: 'Routes & Stops',
              ),
              Tab(
                icon: Icon(Icons.assignment_ind_rounded, size: 16),
                text: 'Student Routes',
              ),
              Tab(
                icon: Icon(Icons.playlist_add_check_circle_rounded, size: 16),
                text: 'Daily Attendance',
              ),
              Tab(
                icon: Icon(Icons.build_rounded, size: 16),
                text: 'Service & Expenses',
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Tab views scoped to activeBranchId
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _FleetTab(branchId: activeBranchId),
              _DriversTab(branchId: activeBranchId),
              _RoutesTab(branchId: activeBranchId),
              _StudentsTab(branchId: activeBranchId),
              _AttendanceTab(branchId: activeBranchId),
              _ExpensesTab(branchId: activeBranchId),
            ],
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 1 — Fleet & Vehicle Details
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _FleetTab extends ConsumerWidget {
  final String branchId;
  const _FleetTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allVehicles = ref.watch(vehiclesProvider);
    final vehicles = allVehicles.where((v) => v.branchId == branchId).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddVehicleModal(context, ref, branchId),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Vehicle', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Branch Vehicles & Fleet Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track registration documents, GPS status, and vehicle fitness reports.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (vehicles.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No vehicles registered for this branch.'),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vehicles.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.35,
                ),
                itemBuilder: (context, index) {
                  final v = vehicles[index];
                  final isPucExpired = v.pucValidity.isBefore(DateTime.now());

                  return GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                v.regNo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: v.status == 'Active'
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                v.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: v.status == 'Active' ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          v.model,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Capacity: ${v.capacity} Passengers | GPS: ${v.gpsDeviceId}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const Divider(height: 16),
                        _buildValidityRow('Insurance:', v.insuranceValidity, false),
                        _buildValidityRow('Fitness Cert:', v.fitnessValidity, false),
                        _buildValidityRow('PUC Validity:', v.pucValidity, isPucExpired),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                final newStatus = v.status == 'Active' ? 'Maintenance' : 'Active';
                                ref.read(vehiclesProvider.notifier).updateStatus(v.id, newStatus);
                              },
                              icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                              label: Text(v.status == 'Active' ? 'Send to Service' : 'Activate'),
                            ),
                          ],
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

  Widget _buildValidityRow(String label, DateTime date, bool isAlert) {
    final dateStr = '${date.day}/${date.month}/${date.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isAlert ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddVehicleModal(BuildContext context, WidgetRef ref, String bId) {
    final regCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final capCtrl = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Register Fleet Vehicle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: regCtrl,
                decoration: const InputDecoration(labelText: 'Registration No (e.g. MH-01-AB-1234)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modelCtrl,
                decoration: const InputDecoration(labelText: 'Vehicle Model (e.g. Ashok Leyland Bus)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacity (Seats)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (regCtrl.text.isNotEmpty && modelCtrl.text.isNotEmpty) {
                  ref.read(vehiclesProvider.notifier).addVehicle(
                    VehicleEntity(
                      id: 'VEH-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: bId,
                      regNo: regCtrl.text,
                      model: modelCtrl.text,
                      capacity: int.tryParse(capCtrl.text) ?? 30,
                      insuranceValidity: DateTime.now().add(const Duration(days: 365)),
                      fitnessValidity: DateTime.now().add(const Duration(days: 365)),
                      pucValidity: DateTime.now().add(const Duration(days: 180)),
                      gpsDeviceId: 'GPS-NEW-${regCtrl.text.hashCode.toString().substring(0,4)}',
                      status: 'Active',
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Register', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 2 — Drivers & Staff
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _DriversTab extends ConsumerWidget {
  final String branchId;
  const _DriversTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allStaff = ref.watch(transportStaffProvider);
    final staff = allStaff.where((s) => s.branchId == branchId).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddStaffModal(context, ref, branchId),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Hire Staff', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transport Drivers & Conductors Pool',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage licenses, expiry warnings, and active contact numbers for transport staff.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (staff.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No transport staff hired for this branch.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: staff.length,
                itemBuilder: (context, index) {
                  final s = staff[index];
                  final expiryStr = s.role == 'Driver'
                      ? '${s.licenseExpiry.day}/${s.licenseExpiry.month}/${s.licenseExpiry.year}'
                      : 'N/A';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: s.role == 'Driver' ? AppColors.primary : AppColors.secondary,
                        child: Icon(
                          s.role == 'Driver' ? Icons.directions_car_rounded : Icons.support_agent_rounded,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Role: ${s.role} | License: ${s.licenseNo} | Expiry: $expiryStr', style: const TextStyle(fontSize: 11)),
                      trailing: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.call_rounded, size: 14),
                        label: Text(s.phone),
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

  void _showAddStaffModal(BuildContext context, WidgetRef ref, String bId) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Driver');
    final phoneCtrl = TextEditingController();
    final licCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hire Transport Staff'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Staff Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleCtrl,
                decoration: const InputDecoration(labelText: 'Role (Driver/Conductor)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: licCtrl,
                decoration: const InputDecoration(labelText: 'Driving License No (If Driver)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                  ref.read(transportStaffProvider.notifier).addStaff(
                    TransportStaffEntity(
                      id: 'TSTAFF-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: bId,
                      name: nameCtrl.text,
                      role: roleCtrl.text,
                      phone: phoneCtrl.text,
                      licenseNo: roleCtrl.text == 'Driver' ? licCtrl.text : 'N/A',
                      licenseExpiry: DateTime.now().add(const Duration(days: 365)),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Hire', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 3 — Routes & Stops (With AI Route Optimization)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _RoutesTab extends ConsumerWidget {
  final String branchId;
  const _RoutesTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allRoutes = ref.watch(transportRoutesProvider);
    final routes = allRoutes.where((r) => r.branchId == branchId).toList();

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
                      'Bus Routes & Intermediate Stops',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure stops, timing, and assign routes to vehicle operators.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _simulateRouteOptimization(context),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                  label: const Text('Optimize Routes (AI)'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (routes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No routes created for this branch.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final r = routes[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r.routeName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Bus: ${r.vehicleRegNo}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Assigned Operator: ${r.driverName} | Stops: ${r.stops.length}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Route Stops Timetable & Cost Matrix:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            border: TableBorder.all(color: isDark ? Colors.white10 : Colors.black12, width: 0.5),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12),
                                children: const [
                                  Padding(padding: EdgeInsets.all(6), child: Text('Stop Name', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(6), child: Text('Pickup', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(6), child: Text('Drop', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(6), child: Text('Fee', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                                ],
                              ),
                              ...r.stops.map((s) => TableRow(
                                children: [
                                  Padding(padding: const EdgeInsets.all(6), child: Text(s.name, style: const TextStyle(fontSize: 10))),
                                  Padding(padding: const EdgeInsets.all(6), child: Text(s.pickupTime, style: const TextStyle(fontSize: 10, color: Colors.green))),
                                  Padding(padding: const EdgeInsets.all(6), child: Text(s.dropTime, style: const TextStyle(fontSize: 10, color: Colors.red))),
                                  Padding(padding: const EdgeInsets.all(6), child: Text('₹${s.fee.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                                ],
                              )),
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

  void _simulateRouteOptimization(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.teal),
              SizedBox(width: 8),
              Text('AI Route Optimizer'),
            ],
          ),
          content: const Text(
            'Analyzing route metrics, peak-hour congestion, and fuel-burn profiles... \n\n'
            '✓ Dwarka route bypass route calculated (saves 12 mins)\n'
            '✓ Santacruz stop rearranged to avoid construction corridor\n'
            '✓ Expected fuel efficiency improvement: +8.4%',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Changes'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 4 — Student Assignments & Concessions
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _StudentsTab extends ConsumerWidget {
  final String branchId;
  const _StudentsTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allAssignments = ref.watch(studentRouteAssignmentsProvider);
    final assignments = allAssignments.where((a) => a.branchId == branchId).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Bus Registrations & Concessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure fee waivers, trigger safety tracking dispatches, and notify parents on bus updates.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (assignments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No student assigned to transport in this branch.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final a = assignments[index];
                  final netFee = a.monthlyFee - a.waiverAmount;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                a.studentName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: a.status == 'Active' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                a.status,
                                style: TextStyle(fontSize: 10, color: a.status == 'Active' ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Class: ${a.classSection} | Stop: ${a.stopName}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Route: ${a.routeName}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Base Fee: ₹${a.monthlyFee.toStringAsFixed(0)} | Concession: ₹${a.waiverAmount.toStringAsFixed(0)} | Net Fee: ₹${netFee.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showWaiverDialog(context, ref, a.id, a.waiverAmount),
                                  icon: const Icon(Icons.discount_rounded, size: 14),
                                  label: const Text('Edit Waiver', style: TextStyle(fontSize: 11)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  ),
                                  onPressed: () => _triggerNotify(context, a.studentName),
                                  icon: const Icon(Icons.notifications_active_rounded, size: 14),
                                  label: const Text('Notify Parent', style: TextStyle(fontSize: 11, color: Colors.white)),
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
                ref.read(studentRouteAssignmentsProvider.notifier).updateAssignmentWaiver(aId, amt);
                Navigator.pop(context);
              },
              child: const Text('Save Waiver'),
            ),
          ],
        );
      },
    );
  }

  void _triggerNotify(BuildContext context, String studentName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ SMS Alert Dispatched: Parent of $studentName notified that Bus is arriving in 5 mins.'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 5 — Transport Attendance
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AttendanceTab extends StatefulWidget {
  final String branchId;
  const _AttendanceTab({required this.branchId});

  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab> {
  String _selectedSession = 'Morning Pickup';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer(
      builder: (context, ref, child) {
        final allAssignments = ref.watch(studentRouteAssignmentsProvider);
        final assignments = allAssignments.where((a) => a.branchId == widget.branchId && a.status == 'Active').toList();

        final allLogs = ref.watch(transportAttendanceProvider);
        final todayLogs = allLogs.where((l) => l.branchId == widget.branchId && l.session == _selectedSession).toList();

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
                          'Daily Transport Attendance Board',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mark pickup and drop status of school bus passengers.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: _selectedSession,
                      items: const [
                        DropdownMenuItem(value: 'Morning Pickup', child: Text('Morning Pickup')),
                        DropdownMenuItem(value: 'Afternoon Drop', child: Text('Afternoon Drop')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSession = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (assignments.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('No active transport students found for attendance.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final a = assignments[index];
                      final log = todayLogs.firstWhere(
                        (l) => l.studentName == a.studentName,
                        orElse: () => TransportAttendanceEntity(
                          id: '',
                          branchId: widget.branchId,
                          studentName: a.studentName,
                          routeName: a.routeName,
                          stopName: a.stopName,
                          date: DateTime.now(),
                          session: _selectedSession,
                          status: 'Not Boarded',
                        ),
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${a.stopName} | ${a.routeName}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildAttendanceChoiceButton(ref, log, 'Boarded', Colors.green),
                                  const SizedBox(width: 8),
                                  _buildAttendanceChoiceButton(ref, log, 'Absent', Colors.red),
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
      },
    );
  }

  Widget _buildAttendanceChoiceButton(WidgetRef ref, TransportAttendanceEntity currentLog, String option, Color activeColor) {
    final isSelected = currentLog.status == option;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? activeColor : Colors.grey.withValues(alpha: 0.1),
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      onPressed: () {
        ref.read(transportAttendanceProvider.notifier).markAttendance(
          TransportAttendanceEntity(
            id: 'TATT-${DateTime.now().millisecondsSinceEpoch}',
            branchId: widget.branchId,
            studentName: currentLog.studentName,
            routeName: currentLog.routeName,
            stopName: currentLog.stopName,
            date: DateTime.now(),
            session: _selectedSession,
            status: option,
          ),
        );
      },
      child: Text(option, style: TextStyle(color: isSelected ? Colors.white : null, fontSize: 11)),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 6 — Service logs & Expenses
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ExpensesTab extends ConsumerWidget {
  final String branchId;
  const _ExpensesTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allExpenses = ref.watch(vehicleExpensesProvider);
    final expenses = allExpenses.where((e) => e.branchId == branchId).toList();
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddExpenseModal(context, ref, branchId),
        icon: const Icon(Icons.post_add_rounded, color: Colors.white),
        label: const Text('Log Expense', style: TextStyle(color: Colors.white)),
      ),
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
                      'Fleet Service Logs & Fuel Consumption',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor garage repair invoices, fuel fills, and overall fleet running expenses.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total Running Cost: ₹${totalSpent.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (expenses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No service or fuel logs recorded for this branch.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final e = expenses[index];
                  final expenseDate = '${e.date.day}/${e.date.month}/${e.date.year}';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        e.type == 'Fuel' ? Icons.local_gas_station_rounded : Icons.build_rounded,
                        color: e.type == 'Fuel' ? Colors.orange : Colors.blueGrey,
                      ),
                      title: Text(
                        '${e.type} for Vehicle: ${e.regNo}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Date: $expenseDate | Remarks: ${e.remarks}', style: const TextStyle(fontSize: 11)),
                      trailing: Text(
                        '₹${e.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

  void _showAddExpenseModal(BuildContext context, WidgetRef ref, String bId) {
    final typeCtrl = TextEditingController(text: 'Fuel');
    final amountCtrl = TextEditingController();
    final remarksCtrl = TextEditingController();
    final regCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Fleet Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: regCtrl,
                decoration: const InputDecoration(labelText: 'Vehicle Registration No'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: typeCtrl,
                decoration: const InputDecoration(labelText: 'Expense Type (Fuel/Maintenance/PUC)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: remarksCtrl,
                decoration: const InputDecoration(labelText: 'Remarks / Invoice notes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (regCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                  ref.read(vehicleExpensesProvider.notifier).addExpense(
                    VehicleExpenseEntity(
                      id: 'EXP-V-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: bId,
                      vehicleId: 'VEH-USER',
                      regNo: regCtrl.text,
                      type: typeCtrl.text,
                      amount: double.tryParse(amountCtrl.text) ?? 0.0,
                      date: DateTime.now(),
                      remarks: remarksCtrl.text,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Log', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

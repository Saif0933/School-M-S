import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../auth/providers.dart';
import '../../providers.dart'; // import parent providers

class ParentPortalPage extends ConsumerStatefulWidget {
  const ParentPortalPage({super.key});

  @override
  ConsumerState<ParentPortalPage> createState() => _ParentPortalPageState();
}

class _ParentPortalPageState extends ConsumerState<ParentPortalPage>
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
    final children = ref.watch(parentChildrenProvider);
    final activeChildId = ref.watch(activeChildIdProvider);
    final activeChild = children.firstWhere((c) => c.id == activeChildId, orElse: () => children.first);

    return Scaffold(
      body: Column(
        children: [
          // ─── Multi-Child Selector Bar ───
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
              border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                final headerRow = Row(
                  children: [
                    const Icon(Icons.family_restroom_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Parent Ward Directory:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                );

                final selectorChips = SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: children.map((c) {
                      final isSelected = c.id == activeChildId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          avatar: CircleAvatar(
                            radius: 10,
                            backgroundImage: NetworkImage(c.avatarUrl),
                          ),
                          label: Text(
                            '${c.name} (${c.branchId == "BR-001" ? "Delhi" : "Mumbai"})',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : null),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          onSelected: (val) {
                            if (val) {
                              ref.read(activeChildIdProvider.notifier).state = c.id;
                              // Switch user active branch dynamically!
                              ref.read(authStateProvider.notifier).switchBranch(c.branchId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✓ Switched active ward to ${c.name} (${c.branchId == "BR-001" ? "Delhi Central" : "Mumbai South"} branch scope)'),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );

                return isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headerRow,
                          const SizedBox(height: 8),
                          selectorChips,
                        ],
                      )
                    : Row(
                        children: [
                          headerRow,
                          const SizedBox(width: 16),
                          Expanded(child: selectorChips),
                        ],
                      );
              },
            ),
          ),

          // ─── Main Portal Sub-tabs ───
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
                Tab(icon: Icon(Icons.dashboard_customize_rounded, size: 16), text: 'Student Overview'),
                Tab(icon: Icon(Icons.school_rounded, size: 16), text: 'Academics & Exams'),
                Tab(icon: Icon(Icons.account_balance_wallet_rounded, size: 16), text: 'Fee Payments'),
                Tab(icon: Icon(Icons.directions_bus_rounded, size: 16), text: 'Facilities & Logistics'),
                Tab(icon: Icon(Icons.rate_review_rounded, size: 16), text: 'Support & Interaction'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(childEntity: activeChild),
                _AcademicsTab(childEntity: activeChild),
                _FeesTab(childEntity: activeChild),
                _FacilitiesTab(childEntity: activeChild),
                _SupportTab(childEntity: activeChild),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 1 — Student Overview Dashboard
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _OverviewTab extends ConsumerWidget {
  final ParentChildEntity childEntity;
  const _OverviewTab({required this.childEntity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(childEntity.avatarUrl),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    childEntity.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    'Roll No: ${childEntity.rollNo} | ${childEntity.className} (${childEntity.sectionName})',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Campus: ${childEntity.branchId == "BR-001" ? "Delhi Central Campus" : "Mumbai South Campus"}',
                      style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Core Stats Grid
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: MediaQuery.of(context).size.width < 450 ? 1.2 : 1.5,
            children: [
              _statCard(context, 'Attendance Rate', '94.2%', Icons.check_circle_rounded, Colors.green),
              _statCard(context, 'Fee Outstanding', '₹15,000', Icons.payments_rounded, Colors.red),
              _statCard(context, 'Hostel Room', childEntity.hostelRoom, Icons.hotel_rounded, Colors.amber),
              _statCard(context, 'Library Books Due', '1 Book Due', Icons.library_books_rounded, Colors.indigo),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Branch Alerts & Notice Board',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, cardConstraints) {
                    final isCardMobile = cardConstraints.maxWidth < 550;
                    final infoWidget = Row(
                      children: [
                        const Icon(Icons.campaign_rounded, color: Colors.orange, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Founders Day Sports meet details shared', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              const Text('The sports circular and events schedule list has been dispatched to all parent accounts.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    );

                    final viewButton = TextButton(
                      onPressed: () => _viewAttachment(context, 'founders_day_invite.pdf'),
                      child: const Text('View PDF', style: TextStyle(fontSize: 11)),
                    );

                    return isCardMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              infoWidget,
                              const SizedBox(height: 8),
                              SizedBox(width: double.infinity, child: Align(alignment: Alignment.centerRight, child: viewButton)),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: infoWidget),
                              const SizedBox(width: 16),
                              viewButton,
                            ],
                          );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String val, IconData icon, Color color) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            val,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  void _viewAttachment(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📄 Opening $name from branch secure server...'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 2 — Academics, Timetable & Examinations
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AcademicsTab extends ConsumerWidget {
  final ParentChildEntity childEntity;
  const _AcademicsTab({required this.childEntity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Teacher info card
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.school_rounded, color: AppColors.primary, size: 28),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class Teacher: ${childEntity.branchId == "BR-001" ? "Mrs. Kavita Verma" : "Mrs. Rekha Joshi"}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Text('Available for calls Mon-Fri 02:00 PM - 03:00 PM', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Timetable Preview
          Text(
            "Today's Timetable Slots",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _timetableRow('08:30 AM - 09:30 AM', 'Mathematics (Algebra)', 'Room 101'),
          _timetableRow('09:30 AM - 10:30 AM', 'Physics Laboratory', 'Lab 2'),
          _timetableRow('10:30 AM - 11:00 AM', 'Recess / Meal Break', 'Canteen Area'),
          _timetableRow('11:00 AM - 12:00 PM', 'Computer Sciences', 'IT Lab B'),
          const SizedBox(height: 24),

          // Exams & Marks Summary
          Text(
            "Term 1 Grading & Exam Report Card",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
            children: const [
              TableRow(
                decoration: BoxDecoration(color: Colors.white10),
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Max Marks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Scored Marks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Grade Letter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                ],
              ),
              TableRow(
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('Mathematics', style: TextStyle(fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('100', style: TextStyle(fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('92', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green))),
                  Padding(padding: EdgeInsets.all(8), child: Text('A+', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green))),
                ],
              ),
              TableRow(
                children: [
                  Padding(padding: EdgeInsets.all(8), child: Text('Physics Science', style: TextStyle(fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('100', style: TextStyle(fontSize: 11))),
                  Padding(padding: EdgeInsets.all(8), child: Text('85', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green))),
                  Padding(padding: EdgeInsets.all(8), child: Text('A', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timetableRow(String time, String subject, String room) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
        title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        subtitle: Text(room, style: const TextStyle(fontSize: 10)),
        trailing: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 3 — Fee Payments & Digital Gateway Checkout
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _FeesTab extends ConsumerWidget {
  final ParentChildEntity childEntity;
  const _FeesTab({required this.childEntity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outstanding Fee Breakdown',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _feeDetailRow('Admission / Registration dues', '₹5,000'),
                  _feeDetailRow('Tuition Installment (Term 1)', '₹8,000'),
                  _feeDetailRow('Bus Transport Facility Fee', '₹2,000'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Total Outstanding Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('₹15,000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _simulateFeeCheckout(context, childEntity.branchId, 15000),
                      icon: const Icon(Icons.payment_rounded, color: Colors.white),
                      label: const Text('Pay Online Now (Stripe / Razorpay)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feeDetailRow(String head, String amt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(head, style: const TextStyle(fontSize: 12)),
          Text(amt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  void _simulateFeeCheckout(BuildContext context, String bId, double amount) {
    final gatewayName = bId == 'BR-001' ? 'Razorpay Delhi Merchant Pool' : 'Stripe Mumbai Express Account';
    final merchantId = bId == 'BR-001' ? 'rzp_live_del8804' : 'acct_stripe_mumb992';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.lock_rounded, color: Colors.green),
              SizedBox(width: 8),
              Text('Secure Checkout Gateway'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Merchant Name: $gatewayName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Merchant Account: $merchantId', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const Divider(height: 16),
              Text('Amount to pay: ₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'This simulates a secure redirect call. Clicking "Approve Payment" will process the collection and dispatch a webhook callback to clear fees.',
                style: TextStyle(fontSize: 10, color: Colors.grey),
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ Payment cleared! Receipt generated. Merchant Ref: ${DateTime.now().millisecondsSinceEpoch}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Approve Payment'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 4 — Facilities & Logistics (Transport, Hostel, Canteen)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _FacilitiesTab extends ConsumerWidget {
  final ParentChildEntity childEntity;
  const _FacilitiesTab({required this.childEntity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canteenMenu = ref.watch(canteenMenuProvider);
    final canteenOrders = ref.watch(canteenOrdersProvider).where((o) => o.studentId == childEntity.id).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transport tracking simulation
            Text(
              '🚌 Real-time Transport Tracking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Assigned Bus: ${childEntity.transportBusNo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('STATUS: IN TRANSIT', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  Text('Route: ${childEntity.transportRoute}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),
                  // Mock MAP box
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '🗺️ [Live Google Map Simulation]\nBus is currently near Santacruz Crossing. 5 mins to arrival.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Hostel Info
            Text(
              '🏢 Hostel Room Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.hotel_rounded, color: Colors.blueAccent, size: 28),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${childEntity.hostelBuilding} | ${childEntity.hostelRoom}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const Text('Warden: Milind Gawde | Contact: +91 99008 87766', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Canteen pre-ordering
            Text(
              '🍽️ Canteen Pre-Ordering Menu (${canteenOrders.length} active orders)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Pre-order lunch meals or healthy snacks to be served during recess recess break.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: canteenMenu.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final item = canteenMenu[index];
                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Category: ${item.category}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                            onPressed: () {
                              ref.read(canteenOrdersProvider.notifier).preOrderFood(
                                CanteenOrderEntity(
                                  id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
                                  studentId: childEntity.id,
                                  itemName: item.name,
                                  amount: item.price,
                                  orderDate: 'Today',
                                  status: 'Ordered',
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✓ Pre-ordered ${item.name} for child lunch break!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text('Order', style: TextStyle(color: Colors.white, fontSize: 10)),
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
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAB 5 — Support, Interaction & Polls
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _SupportTab extends ConsumerWidget {
  final ParentChildEntity childEntity;
  const _SupportTab({required this.childEntity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leaves = ref.watch(childLeavesProvider).where((l) => l.studentId == childEntity.id).toList();
    final apps = ref.watch(appointmentsProvider).where((a) => a.studentId == childEntity.id).toList();
    final polls = ref.watch(branchPollsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poll widget
            Text(
              '🗳️ Active Branch Polls',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...polls.map((p) => GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 10),
                      ...p.options.map((opt) {
                        final isVoted = p.userVote == opt;
                        final totalVotes = p.votes.values.fold<int>(0, (a, b) => a + b);
                        final optionVotes = p.votes[opt] ?? 0;
                        final pct = totalVotes > 0 ? (optionVotes / totalVotes * 100).toStringAsFixed(0) : '0';

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isVoted ? AppColors.primary.withValues(alpha: 0.1) : null,
                            ),
                            onPressed: p.userVote.isNotEmpty
                                ? null
                                : () => ref.read(branchPollsProvider.notifier).castVote(p.id, opt),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(opt, style: const TextStyle(fontSize: 11)),
                                if (p.userVote.isNotEmpty)
                                  Text('$pct% ($optionVotes)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
                                else
                                  const Icon(Icons.arrow_forward_rounded, size: 14),
                              ],
                            ),
                          ),
                        );
                      })
                    ],
                  ),
                )),

            const SizedBox(height: 24),
            // Leaves trigger
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📝 Ward Leave Applications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: Colors.green),
                  onPressed: () => _applyLeaveModal(context, ref, childEntity),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (leaves.isEmpty)
              const Center(child: Text('No leave applications submitted.'))
            else
              ...leaves.map((l) => Card(
                    child: ListTile(
                      title: Text(l.reason, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('Dates: ${l.fromDate.day}/${l.fromDate.month} to ${l.toDate.day}/${l.toDate.month}'),
                      trailing: Chip(
                        label: Text(l.status, style: const TextStyle(fontSize: 10)),
                        backgroundColor: l.status == 'Approved' ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                      ),
                    ),
                  )),

            const SizedBox(height: 24),
            // Teacher Appointments booking
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🗓️ Book Teacher Appointments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: Colors.green),
                  onPressed: () => _bookAppointmentModal(context, ref, childEntity),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (apps.isEmpty)
              const Center(child: Text('No scheduled appointments.'))
            else
              ...apps.map((a) => Card(
                    child: ListTile(
                      title: Text('Meeting with ${a.teacherName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('Time: ${a.dateTime} | Purpose: ${a.purpose}'),
                      trailing: Chip(
                        label: Text(a.status, style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _applyLeaveModal(BuildContext context, WidgetRef ref, ParentChildEntity child) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Apply Leave for Ward'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(labelText: 'Reason for Leave'),
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
                if (reasonCtrl.text.isNotEmpty) {
                  ref.read(childLeavesProvider.notifier).submitLeave(
                    ChildLeaveEntity(
                      id: 'LV-${DateTime.now().millisecondsSinceEpoch}',
                      studentId: child.id,
                      studentName: child.name,
                      branchId: child.branchId,
                      fromDate: DateTime.now().add(const Duration(days: 2)),
                      toDate: DateTime.now().add(const Duration(days: 3)),
                      reason: reasonCtrl.text,
                      status: 'Pending',
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Leave application submitted successfully to warden/class teacher.')),
                  );
                }
              },
              child: const Text('Submit Application'),
            ),
          ],
        );
      },
    );
  }

  void _bookAppointmentModal(BuildContext context, WidgetRef ref, ParentChildEntity child) {
    final purposeCtrl = TextEditingController();
    String teacherName = child.branchId == 'BR-001' ? 'Mrs. Kavita Verma' : 'Mrs. Rekha Joshi';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Schedule Teacher Meeting'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Meeting Teacher: $teacherName', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: purposeCtrl,
                decoration: const InputDecoration(labelText: 'Purpose of Meeting'),
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
                if (purposeCtrl.text.isNotEmpty) {
                  ref.read(appointmentsProvider.notifier).scheduleAppointment(
                    AppointmentEntity(
                      id: 'APP-${DateTime.now().millisecondsSinceEpoch}',
                      studentId: child.id,
                      teacherName: teacherName,
                      branchId: child.branchId,
                      dateTime: 'Next Monday, 02:30 PM',
                      purpose: purposeCtrl.text,
                      status: 'Scheduled',
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Appointment requested! A confirmation SMS will be dispatched shortly.')),
                  );
                }
              },
              child: const Text('Book Appointment'),
            ),
          ],
        );
      },
    );
  }
}

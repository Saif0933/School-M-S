import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class CanteenManagementPage extends ConsumerStatefulWidget {
  const CanteenManagementPage({super.key});

  @override
  ConsumerState<CanteenManagementPage> createState() => _CanteenManagementPageState();
}

class _CanteenManagementPageState extends ConsumerState<CanteenManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Wallet top-up controller
  final _topUpCtrl = TextEditingController();

  // Menu Creation fields
  final _itemNameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _nutriCtrl = TextEditingController();
  String _selectedCategory = 'Meals';
  String _selectedDietary = 'Veg';

  // Wastage Fields
  final _wasteItemCtrl = TextEditingController();
  final _wasteWeightCtrl = TextEditingController();
  final _wasteReasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topUpCtrl.dispose();
    _itemNameCtrl.dispose();
    _priceCtrl.dispose();
    _nutriCtrl.dispose();
    _wasteItemCtrl.dispose();
    _wasteWeightCtrl.dispose();
    _wasteReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final menu = ref.watch(canteenMenuProvider).where((m) => m.branchId == activeBranchId).toList();
    final orders = ref.watch(canteenOrdersProvider).where((o) => o.branchId == activeBranchId).toList();
    final wasteLogs = ref.watch(wasteLogProvider).where((w) => w.branchId == activeBranchId).toList();
    final walletBalance = ref.watch(walletProvider);

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
                        'Canteen & Pocket Wallet: $branchName',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Cashless Cafeteria Roster | Daily Wastage Register: Active',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Wallet Balance: ₹${walletBalance.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13),
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
                Tab(icon: Icon(Icons.restaurant_menu_rounded, size: 16), text: 'Pre-Order & Wallet Top-up'),
                Tab(icon: Icon(Icons.storefront_rounded, size: 16), text: 'Add Item & Sales logs'),
                Tab(icon: Icon(Icons.delete_outline_rounded, size: 16), text: 'Wastage & Food reports'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderTab(menu, walletBalance, activeBranchId),
                _buildManageTab(orders, activeBranchId),
                _buildWastageTab(wasteLogs, activeBranchId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Pre-Order & Wallet Hub Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildOrderTab(List<CanteenMenuItem> menu, double balance, String branchId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu list
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🍔 Cashless Pre-Order Menu items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                ...menu.map((item) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.dietaryPref == 'Veg' ? Colors.green : Colors.red,
                          child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 16),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        subtitle: Text('Category: ${item.category} | Nutri: ${item.nutritionalInfo}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              onPressed: () {
                                final success = ref.read(walletProvider.notifier).deduct(item.price);
                                if (success) {
                                  ref.read(canteenOrdersProvider.notifier).createOrder(
                                    CanteenOrder(
                                      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
                                      branchId: branchId,
                                      studentName: 'Student User',
                                      itemName: item.name,
                                      amount: item.price,
                                      orderTime: '12:35 PM',
                                      status: 'Active',
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('✓ Cashless pre-order successful! Pocket ticket generated.')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('❌ Insufficient wallet balance! Top-up to pre-order.')),
                                  );
                                }
                              },
                              child: const Text('Pre-Order', style: TextStyle(fontSize: 10, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Wallet desk card
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💳 Pocket Wallet Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                Card(
                  color: Colors.teal.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cashless student balance:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('₹${balance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.teal)),
                        const Divider(height: 24),
                        TextField(
                          controller: _topUpCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(labelText: 'Top-up Amount (₹)', isDense: true),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                onPressed: () {
                                  final amt = double.tryParse(_topUpCtrl.text) ?? 0.0;
                                  if (amt > 0) {
                                    ref.read(walletProvider.notifier).topUp(amt);
                                    _topUpCtrl.clear();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('✓ Pocket wallet top-up completed cashless.')),
                                    );
                                  }
                                },
                                child: const Text('Top-Up', style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                onPressed: () {
                                  ref.read(walletProvider.notifier).refund(50.0);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('✓ Canteen meal voucher refund request processed.')),
                                  );
                                },
                                child: const Text('Refund', style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Canteen Management (Menu & Sales logs)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildManageTab(List<CanteenOrder> orders, String branchId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Menu item Form
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✏️ Publish New Menu Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                TextField(controller: _itemNameCtrl, decoration: const InputDecoration(labelText: 'Item Name')),
                TextField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price (₹)')),
                TextField(controller: _nutriCtrl, decoration: const InputDecoration(labelText: 'Nutritional Info (e.g. calories)')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Meals', child: Text('Full Meals thali')),
                    DropdownMenuItem(value: 'Snacks', child: Text('Breakfast & Snacks')),
                    DropdownMenuItem(value: 'Beverages', child: Text('Cold Drinks & Tea')),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val ?? 'Meals'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDietary,
                  decoration: const InputDecoration(labelText: 'Dietary Preference'),
                  items: const [
                    DropdownMenuItem(value: 'Veg', child: Text('Vegetarian')),
                    DropdownMenuItem(value: 'Non-Veg', child: Text('Non-Vegetarian')),
                  ],
                  onChanged: (val) => setState(() => _selectedDietary = val ?? 'Veg'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () {
                      if (_itemNameCtrl.text.isNotEmpty) {
                        ref.read(canteenMenuProvider.notifier).addMenuItem(
                          CanteenMenuItem(
                            id: 'MENU-${DateTime.now().millisecondsSinceEpoch}',
                            branchId: branchId,
                            name: _itemNameCtrl.text,
                            category: _selectedCategory,
                            price: double.tryParse(_priceCtrl.text) ?? 50.0,
                            dietaryPref: _selectedDietary,
                            nutritionalInfo: _nutriCtrl.text.isNotEmpty ? _nutriCtrl.text : '200 kcal',
                          ),
                        );
                        _itemNameCtrl.clear();
                        _priceCtrl.clear();
                        _nutriCtrl.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ New item added to branch price catalog.')),
                        );
                      }
                    },
                    child: const Text('Add Menu Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Daily Sales logs
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📋 Daily Pre-Order Sales Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                ...orders.map((o) => Card(
                      child: ListTile(
                        title: Text(o.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        subtitle: Text('Buyer: ${o.studentName} | Price: ₹${o.amount.toStringAsFixed(0)}'),
                        trailing: Chip(
                          label: Text(o.status, style: const TextStyle(fontSize: 8, color: Colors.white)),
                          backgroundColor: o.status == 'Collected' ? Colors.green : Colors.orange,
                        ),
                        onTap: o.status == 'Active'
                            ? () {
                                ref.read(canteenOrdersProvider.notifier).collectOrder(o.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✓ Meal collected! Ticket archived.')),
                                );
                              }
                            : null,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Wastage & Reports Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildWastageTab(List<WasteLog> wasteLogs, String branchId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food waste logger
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✏️ Log Kitchen Food Wastage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                TextField(controller: _wasteItemCtrl, decoration: const InputDecoration(labelText: 'Wasted Menu Item Name')),
                TextField(controller: _wasteWeightCtrl, decoration: const InputDecoration(labelText: 'Weight Wasted (Kg)')),
                TextField(controller: _wasteReasonCtrl, decoration: const InputDecoration(labelText: 'Reason (e.g. left-overs)')),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      if (_wasteItemCtrl.text.isNotEmpty) {
                        ref.read(wasteLogProvider.notifier).logWaste(
                          WasteLog(
                            id: 'WST-${DateTime.now().millisecondsSinceEpoch}',
                            branchId: branchId,
                            itemName: _wasteItemCtrl.text,
                            wasteWeightKg: double.tryParse(_wasteWeightCtrl.text) ?? 1.0,
                            reason: _wasteReasonCtrl.text,
                            date: '2026-08-19',
                          ),
                        );
                        _wasteItemCtrl.clear();
                        _wasteWeightCtrl.clear();
                        _wasteReasonCtrl.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Kitchen food waste entry logged in branch reports.')),
                        );
                      }
                    },
                    child: const Text('Log Waste Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Waste history & report triggers
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📋 Food Wastage Registry today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                ...wasteLogs.map((w) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
                        title: Text(w.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        subtitle: Text('Weight: ${w.wasteWeightKg} Kg | Reason: ${w.reason}'),
                      ),
                    )),
                const Divider(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ Compiling monthly canteen billing sheets...')),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, color: Colors.white),
                    label: const Text('Export Monthly Canteen Report', style: TextStyle(color: Colors.white, fontSize: 11)),
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

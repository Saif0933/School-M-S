import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class InventoryManagementPage extends ConsumerStatefulWidget {
  const InventoryManagementPage({super.key});

  @override
  ConsumerState<InventoryManagementPage> createState() => _InventoryManagementPageState();
}

class _InventoryManagementPageState extends ConsumerState<InventoryManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Asset Registration
  final _assetNameCtrl = TextEditingController();
  final _assetPriceCtrl = TextEditingController();
  final _assetBuildingCtrl = TextEditingController();
  final _assetRoomCtrl = TextEditingController();
  String _selectedAssetCategory = 'Electronics';

  // Controllers for Stock Item Creation
  final _itemNameCtrl = TextEditingController();
  final _itemQtyCtrl = TextEditingController();
  final _itemReorderCtrl = TextEditingController();
  final _itemValuationCtrl = TextEditingController();
  final _itemShelfCtrl = TextEditingController();
  String _selectedItemCategory = 'Stationery';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _assetNameCtrl.dispose();
    _assetPriceCtrl.dispose();
    _assetBuildingCtrl.dispose();
    _assetRoomCtrl.dispose();
    _itemNameCtrl.dispose();
    _itemQtyCtrl.dispose();
    _itemReorderCtrl.dispose();
    _itemValuationCtrl.dispose();
    _itemShelfCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';

    final assets = ref.watch(assetsProvider).where((a) => a.branchId == activeBranchId).toList();
    final inventory = ref.watch(inventoryProvider).where((i) => i.branchId == activeBranchId).toList();

    return Scaffold(
      body: Column(
        children: [
          // Subheader for stats & Quick Register triggers
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 750;
              final infoWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Asset & Inventory Register: ${user?.activeBranch?.branchName ?? "Primary Campus"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Registered Assets: ${assets.length} | Stock Valuation: ₹${inventory.fold<double>(0, (a, b) => a + b.totalValuation).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              );

              final actionButtons = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () => _showRegisterAssetDialog(context, activeBranchId, user?.activeBranch?.branchCode ?? "SIS-DEL"),
                    icon: const Icon(Icons.add_box_rounded, color: Colors.white, size: 16),
                    label: const Text('Add Asset', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () => _showAddStockDialog(context, activeBranchId),
                    icon: const Icon(Icons.playlist_add_rounded, color: Colors.white, size: 16),
                    label: const Text('Add Stock Item', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              );

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          infoWidget,
                          const SizedBox(height: 12),
                          actionButtons,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: infoWidget),
                          const SizedBox(width: 16),
                          actionButtons,
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
                Tab(icon: Icon(Icons.qr_code_scanner_rounded, size: 16), text: 'Assets Tagging'),
                Tab(icon: Icon(Icons.build_rounded, size: 16), text: 'Audits & Maintenance'),
                Tab(icon: Icon(Icons.inventory_2_rounded, size: 16), text: 'Stock Registry & Alerts'),
                Tab(icon: Icon(Icons.receipt_long_rounded, size: 16), text: 'Purchase & Vendors'),
                Tab(icon: Icon(Icons.analytics_rounded, size: 16), text: 'Valuation Analytics'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AssetsTaggingTab(assets: assets),
                _AssetsMaintenanceTab(assets: assets),
                _InventoryStockTab(inventory: inventory),
                _PurchaseOrdersTab(branchId: activeBranchId),
                _InventoryAnalyticsTab(allAssets: ref.watch(assetsProvider), allInventory: ref.watch(inventoryProvider)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRegisterAssetDialog(BuildContext context, String branchId, String branchCode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Register New Physical Asset'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _assetNameCtrl, decoration: const InputDecoration(labelText: 'Asset Name (e.g. Smart TV)')),
              TextField(controller: _assetPriceCtrl, decoration: const InputDecoration(labelText: 'Purchase Cost (₹)')),
              TextField(controller: _assetBuildingCtrl, decoration: const InputDecoration(labelText: 'Assigned Building Block')),
              TextField(controller: _assetRoomCtrl, decoration: const InputDecoration(labelText: 'Assigned Room / Lab')),
              DropdownButtonFormField<String>(
                initialValue: _selectedAssetCategory,
                decoration: const InputDecoration(labelText: 'Asset Classification'),
                items: const [
                  DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                  DropdownMenuItem(value: 'Furniture', child: Text('Furniture')),
                  DropdownMenuItem(value: 'Lab Equipment', child: Text('Lab Equipment')),
                ],
                onChanged: (val) => setState(() => _selectedAssetCategory = val ?? 'Electronics'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (_assetNameCtrl.text.isNotEmpty && _assetPriceCtrl.text.isNotEmpty) {
                  final assetCode = 'TAG-${branchCode.replaceAll("SIS-", "").replaceAll("SPS-", "")}-${DateTime.now().millisecond}';
                  ref.read(assetsProvider.notifier).addAsset(
                    AssetEntity(
                      id: 'AST-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: branchId,
                      name: _assetNameCtrl.text,
                      category: _selectedAssetCategory,
                      assetTag: assetCode,
                      building: _assetBuildingCtrl.text,
                      room: _assetRoomCtrl.text,
                      condition: 'Excellent',
                      purchasePrice: double.tryParse(_assetPriceCtrl.text) ?? 10000.0,
                      depreciationRate: 10.0,
                      warrantyExpiry: '2029-01-01',
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✓ Asset Registered! Printed code RFID/Barcode tag: $assetCode')),
                  );
                  _assetNameCtrl.clear();
                  _assetPriceCtrl.clear();
                  _assetBuildingCtrl.clear();
                  _assetRoomCtrl.clear();
                }
              },
              child: const Text('Print Tag & Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddStockDialog(BuildContext context, String branchId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Inventory Stock Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _itemNameCtrl, decoration: const InputDecoration(labelText: 'Item Name')),
              TextField(controller: _itemQtyCtrl, decoration: const InputDecoration(labelText: 'Quantity in hand')),
              TextField(controller: _itemReorderCtrl, decoration: const InputDecoration(labelText: 'Reorder Alert Threshold')),
              TextField(controller: _itemValuationCtrl, decoration: const InputDecoration(labelText: 'Unit Valuation Cost (₹)')),
              TextField(controller: _itemShelfCtrl, decoration: const InputDecoration(labelText: 'Shelf Sub-location shelving')),
              DropdownButtonFormField<String>(
                initialValue: _selectedItemCategory,
                decoration: const InputDecoration(labelText: 'Stock Category'),
                items: const [
                  DropdownMenuItem(value: 'Stationery', child: Text('Stationery')),
                  DropdownMenuItem(value: 'Uniforms', child: Text('Uniforms')),
                  DropdownMenuItem(value: 'Books', child: Text('Books')),
                ],
                onChanged: (val) => setState(() => _selectedItemCategory = val ?? 'Stationery'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (_itemNameCtrl.text.isNotEmpty) {
                  ref.read(inventoryProvider.notifier).addInventoryItem(
                    InventoryItemEntity(
                      id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: branchId,
                      itemName: _itemNameCtrl.text,
                      category: _selectedItemCategory,
                      stockQuantity: int.tryParse(_itemQtyCtrl.text) ?? 50,
                      reorderLevel: int.tryParse(_itemReorderCtrl.text) ?? 10,
                      unitValuation: double.tryParse(_itemValuationCtrl.text) ?? 100.0,
                      subLocation: _itemShelfCtrl.text,
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Inventory item register configured.')),
                  );
                  _itemNameCtrl.clear();
                  _itemQtyCtrl.clear();
                  _itemReorderCtrl.clear();
                  _itemValuationCtrl.clear();
                  _itemShelfCtrl.clear();
                }
              },
              child: const Text('Save Stock Config'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 1 — Assets Tagging Registry
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AssetsTaggingTab extends ConsumerWidget {
  final List<AssetEntity> assets;
  const _AssetsTaggingTab({required this.assets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final a = assets[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.qr_code_2_rounded, size: 36, color: AppColors.primary),
            title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('RFID Tag: ${a.assetTag}\nClassification: ${a.category} | Location: ${a.building} - ${a.room}'),
            trailing: Chip(
              label: Text(a.condition, style: const TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: a.condition == 'Excellent' ? Colors.green : (a.condition == 'Good' ? Colors.teal : Colors.orange),
            ),
          ),
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 2 — Physical Asset Audits & Maintenance
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AssetsMaintenanceTab extends ConsumerWidget {
  final List<AssetEntity> assets;
  const _AssetsMaintenanceTab({required this.assets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final a = assets[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Cost: ₹${a.purchasePrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Calculated Depreciation (After 2 years): ₹${a.calculateDepreciatedValue(2).toStringAsFixed(0)} (${a.depreciationRate}% Annual)',
                  style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold),
                ),
                if (a.maintenanceLogs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Logs: ${a.maintenanceLogs.join(", ")}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
                const Divider(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: () => _updateCondition(context, ref, a.id),
                      child: const Text('Update Condition', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                      onPressed: () => _logMaintenance(context, ref, a.id),
                      child: const Text('Log Maintenance note', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                      onPressed: () => _transferLocation(context, ref, a.id),
                      child: const Text('Transfer Location', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateCondition(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Condition State'),
          children: [
            _conditionOption(context, ref, id, 'Excellent'),
            _conditionOption(context, ref, id, 'Good'),
            _conditionOption(context, ref, id, 'Fair'),
            _conditionOption(context, ref, id, 'Needs Maintenance'),
          ],
        );
      },
    );
  }

  Widget _conditionOption(BuildContext context, WidgetRef ref, String id, String status) {
    return SimpleDialogOption(
      onPressed: () {
        ref.read(assetsProvider.notifier).updateCondition(id, status);
        Navigator.pop(context);
      },
      child: Text(status),
    );
  }

  void _logMaintenance(BuildContext context, WidgetRef ref, String id) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Maintenance Log entry'),
          content: TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Details')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (noteCtrl.text.isNotEmpty) {
                  ref.read(assetsProvider.notifier).addMaintenance(id, noteCtrl.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Note'),
            ),
          ],
        );
      },
    );
  }

  void _transferLocation(BuildContext context, WidgetRef ref, String id) {
    final blockCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Transfer Asset within Campus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: blockCtrl, decoration: const InputDecoration(labelText: 'New Building block')),
              TextField(controller: roomCtrl, decoration: const InputDecoration(labelText: 'New Room / Lab room')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(assetsProvider.notifier).transferLocation(id, blockCtrl.text, roomCtrl.text);
                Navigator.pop(context);
              },
              child: const Text('Submit Transfer'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 3 — Inventory Stock & Alerts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _InventoryStockTab extends ConsumerWidget {
  final List<InventoryItemEntity> inventory;
  const _InventoryStockTab({required this.inventory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: inventory.length,
      itemBuilder: (context, index) {
        final item = inventory[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    if (item.isBelowReorder)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                        child: const Text('LOW STOCK ALERT', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'In Hand: ${item.stockQuantity} Pcs (Min: ${item.reorderLevel}) | Shelf Location: ${item.subLocation}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text('Valuation: ₹${item.totalValuation.toStringAsFixed(0)} (Unit: ₹${item.unitValuation})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const Divider(height: 20),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
                          onPressed: () => ref.read(inventoryProvider.notifier).adjustStock(item.id, -5),
                        ),
                        const Text('Adjust Stock', style: TextStyle(fontSize: 11)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.green),
                          onPressed: () => ref.read(inventoryProvider.notifier).adjustStock(item.id, 5),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                      onPressed: () => _transferShelf(context, ref, item.id),
                      child: const Text('Shelf Transfer', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _transferShelf(BuildContext context, WidgetRef ref, String id) {
    final shelfCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Transfer Sub-Location Shelf shelving'),
          content: TextField(controller: shelfCtrl, decoration: const InputDecoration(labelText: 'Cabinet/Shelf Name')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (shelfCtrl.text.isNotEmpty) {
                  ref.read(inventoryProvider.notifier).transferStockSubLocation(id, shelfCtrl.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Transfer'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 4 — Purchase Orders & Vendor Payments
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _PurchaseOrdersTab extends ConsumerWidget {
  final String branchId;
  const _PurchaseOrdersTab({required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(purchaseOrdersProvider).where((o) => o.branchId == branchId).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final po = orders[index];
        final isPaid = po.status == 'Paid';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 550;

                final info = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${po.vendorName} [${po.id}]', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('${po.details}\nTotal Dues: ₹${po.amount.toStringAsFixed(0)} | Date: ${po.date}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                );

                final statusActions = Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    Chip(
                      label: Text(po.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                      backgroundColor: isPaid ? Colors.green : Colors.orange,
                    ),
                    if (!isPaid) ...[
                      const SizedBox(height: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(80, 30),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          ref.read(purchaseOrdersProvider.notifier).updateOrderStatus(po.id, 'Paid');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Vendor balance cleared! Payment recorded in branch expense registers.')),
                          );
                        },
                        child: const Text('Pay Vendor', style: TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    ],
                  ],
                );

                return isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          info,
                          const SizedBox(height: 12),
                          statusActions,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: info),
                          const SizedBox(width: 16),
                          statusActions,
                        ],
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
// SUB-TAB 5 — Inventory Analytics Comparison
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _InventoryAnalyticsTab extends ConsumerWidget {
  final List<AssetEntity> allAssets;
  final List<InventoryItemEntity> allInventory;

  const _InventoryAnalyticsTab({required this.allAssets, required this.allInventory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Delhi BR-001 Gross Valuations
    final delhiVal = allInventory.where((i) => i.branchId == 'BR-001').fold<double>(0, (a, b) => a + b.totalValuation);
    final delhiAssets = allAssets.where((a) => a.branchId == 'BR-001').fold<double>(0, (a, b) => a + b.purchasePrice);

    // Mumbai BR-002 Gross Valuations
    final mumbaiVal = allInventory.where((i) => i.branchId == 'BR-002').fold<double>(0, (a, b) => a + b.totalValuation);
    final mumbaiAssets = allAssets.where((a) => a.branchId == 'BR-002').fold<double>(0, (a, b) => a + b.purchasePrice);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏢 Organization physical Asset Summary (Gross Purchase Value)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _analyticsBar('Delhi Central SIS Campus (BR-001)', delhiAssets, 150000.0, Colors.indigo),
          const SizedBox(height: 12),
          _analyticsBar('Mumbai South SPS Campus (BR-002)', mumbaiAssets, 150000.0, Colors.teal),

          const SizedBox(height: 24),
          const Text('📦 Consolidated stock inventory valuations comparison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _analyticsBar('Delhi Central SIS Campus (BR-001)', delhiVal, 100000.0, Colors.orange),
          const SizedBox(height: 12),
          _analyticsBar('Mumbai South SPS Campus (BR-002)', mumbaiVal, 100000.0, Colors.pink),
        ],
      ),
    );
  }

  Widget _analyticsBar(String label, double value, double maxVal, Color color) {
    final pct = value > 0 ? (value / maxVal).clamp(0.0, 1.0) : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text('₹${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: pct, color: color, backgroundColor: Colors.white10, minHeight: 8),
          ],
        ),
      ),
    );
  }
}

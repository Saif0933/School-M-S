import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Asset Entity Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AssetEntity {
  final String id;
  final String branchId;
  final String name;
  final String category; // 'Electronics', 'Furniture', 'Lab Equipment'
  final String assetTag; // Branch prefix e.g. ASSET-DEL-104
  final String building;
  final String room;
  final String condition; // 'Excellent', 'Good', 'Fair', 'Needs Maintenance'
  final double purchasePrice;
  final double depreciationRate; // Annual % e.g. 10.0
  final String warrantyExpiry;
  final List<String> maintenanceLogs;

  const AssetEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.category,
    required this.assetTag,
    required this.building,
    required this.room,
    required this.condition,
    required this.purchasePrice,
    required this.depreciationRate,
    required this.warrantyExpiry,
    this.maintenanceLogs = const [],
  });

  double calculateDepreciatedValue(int years) {
    double val = purchasePrice;
    for (int i = 0; i < years; i++) {
      val = val * (1 - (depreciationRate / 100));
    }
    return val;
  }

  AssetEntity copyWith({
    String? condition,
    String? building,
    String? room,
    List<String>? maintenanceLogs,
  }) {
    return AssetEntity(
      id: id,
      branchId: branchId,
      name: name,
      category: category,
      assetTag: assetTag,
      building: building ?? this.building,
      room: room ?? this.room,
      condition: condition ?? this.condition,
      purchasePrice: purchasePrice,
      depreciationRate: depreciationRate,
      warrantyExpiry: warrantyExpiry,
      maintenanceLogs: maintenanceLogs ?? this.maintenanceLogs,
    );
  }
}

class AssetsNotifier extends StateNotifier<List<AssetEntity>> {
  AssetsNotifier() : super([
    // Delhi Campus BR-001
    const AssetEntity(
      id: 'AST-DEL-001',
      branchId: 'BR-001',
      name: 'Sony Smart Projector X1',
      category: 'Electronics',
      assetTag: 'TAG-DEL-EL-001',
      building: 'Aravali Block A',
      room: 'Physics Lab Room 302',
      condition: 'Excellent',
      purchasePrice: 65000.0,
      depreciationRate: 15.0,
      warrantyExpiry: '2027-12-15',
      maintenanceLogs: ['Installed & Calibrated on 2026-04-10'],
    ),
    const AssetEntity(
      id: 'AST-DEL-002',
      branchId: 'BR-001',
      name: 'Oak wood study desk (Class 10)',
      category: 'Furniture',
      assetTag: 'TAG-DEL-FN-002',
      building: 'Shivalik Tower C',
      room: 'Room 104',
      condition: 'Good',
      purchasePrice: 12000.0,
      depreciationRate: 8.0,
      warrantyExpiry: '2030-01-01',
    ),
    // Mumbai Campus BR-002
    const AssetEntity(
      id: 'AST-MUM-001',
      branchId: 'BR-002',
      name: 'Panasonic Smart Board 4K',
      category: 'Electronics',
      assetTag: 'TAG-MUM-EL-201',
      building: 'Sahyadri Tower B',
      room: 'Chemistry Lab Room 405',
      condition: 'Needs Maintenance',
      purchasePrice: 85000.0,
      depreciationRate: 12.0,
      warrantyExpiry: '2028-06-20',
      maintenanceLogs: ['Panel service required on screen corners.'],
    ),
  ]);

  void addAsset(AssetEntity asset) {
    state = [...state, asset];
  }

  void updateCondition(String id, String condition) {
    state = state.map((a) => a.id == id ? a.copyWith(condition: condition) : a).toList();
  }

  void transferLocation(String id, String building, String room) {
    state = state.map((a) => a.id == id ? a.copyWith(building: building, room: room) : a).toList();
  }

  void addMaintenance(String id, String log) {
    state = state.map((a) {
      if (a.id == id) {
        return a.copyWith(maintenanceLogs: [...a.maintenanceLogs, log]);
      }
      return a;
    }).toList();
  }
}

final assetsProvider = StateNotifierProvider<AssetsNotifier, List<AssetEntity>>((ref) {
  return AssetsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Inventory Item Entity Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class InventoryItemEntity {
  final String id;
  final String branchId;
  final String itemName;
  final String category; // 'Stationery', 'Uniforms', 'Books'
  final int stockQuantity;
  final int reorderLevel;
  final double unitValuation;
  final String subLocation; // Storage cabinet / shelf e.g. "Store Room Shelf A"

  const InventoryItemEntity({
    required this.id,
    required this.branchId,
    required this.itemName,
    required this.category,
    required this.stockQuantity,
    required this.reorderLevel,
    required this.unitValuation,
    required this.subLocation,
  });

  double get totalValuation => stockQuantity * unitValuation;
  bool get isBelowReorder => stockQuantity <= reorderLevel;

  InventoryItemEntity copyWith({int? stockQuantity, String? subLocation}) {
    return InventoryItemEntity(
      id: id,
      branchId: branchId,
      itemName: itemName,
      category: category,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderLevel: reorderLevel,
      unitValuation: unitValuation,
      subLocation: subLocation ?? this.subLocation,
    );
  }
}

class InventoryNotifier extends StateNotifier<List<InventoryItemEntity>> {
  InventoryNotifier() : super([
    // Delhi Campus BR-001
    const InventoryItemEntity(
      id: 'INV-DEL-101',
      branchId: 'BR-001',
      itemName: 'Mathematics Class 11 Textbooks',
      category: 'Books',
      stockQuantity: 120,
      reorderLevel: 25,
      unitValuation: 350.0,
      subLocation: 'Main Library Storage Shelf 4',
    ),
    const InventoryItemEntity(
      id: 'INV-DEL-102',
      branchId: 'BR-001',
      itemName: 'Official School Blazer (Medium)',
      category: 'Uniforms',
      stockQuantity: 15, // Low stock reorder alert!
      reorderLevel: 20,
      unitValuation: 1200.0,
      subLocation: 'Uniform Counter Room 102',
    ),
    // Mumbai Campus BR-002
    const InventoryItemEntity(
      id: 'INV-MUM-201',
      branchId: 'BR-002',
      itemName: 'Blue Ballpoint Pens (Box of 50)',
      category: 'Stationery',
      stockQuantity: 50,
      reorderLevel: 10,
      unitValuation: 250.0,
      subLocation: 'Admin Store Cupboard C',
    ),
  ]);

  void adjustStock(String id, int delta) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(stockQuantity: (item.stockQuantity + delta).clamp(0, 999999));
      }
      return item;
    }).toList();
  }

  void addInventoryItem(InventoryItemEntity item) {
    state = [...state, item];
  }

  void transferStockSubLocation(String id, String subLocation) {
    state = state.map((i) => i.id == id ? i.copyWith(subLocation: subLocation) : i).toList();
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, List<InventoryItemEntity>>((ref) {
  return InventoryNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Purchase Orders & Vendor Payments
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class PurchaseOrderEntity {
  final String id;
  final String branchId;
  final String vendorName;
  final String details;
  final double amount;
  final String status; // 'Pending Delivery', 'Invoiced', 'Paid'
  final String date;

  const PurchaseOrderEntity({
    required this.id,
    required this.branchId,
    required this.vendorName,
    required this.details,
    required this.amount,
    required this.status,
    required this.date,
  });

  PurchaseOrderEntity copyWith({String? status}) {
    return PurchaseOrderEntity(
      id: id,
      branchId: branchId,
      vendorName: vendorName,
      details: details,
      amount: amount,
      status: status ?? this.status,
      date: date,
    );
  }
}

class PurchaseOrdersNotifier extends StateNotifier<List<PurchaseOrderEntity>> {
  PurchaseOrdersNotifier() : super([
    const PurchaseOrderEntity(
      id: 'PO-DEL-2026-01',
      branchId: 'BR-001',
      vendorName: 'Bharat Uniform Suppliers',
      details: 'Inward purchase order of 100 uniform blazers (S/M/L sizes)',
      amount: 45000.0,
      status: 'Pending Delivery',
      date: '2026-08-10',
    ),
    const PurchaseOrderEntity(
      id: 'PO-MUM-2026-01',
      branchId: 'BR-002',
      vendorName: 'Vikas Stationery Mart',
      details: 'Whiteboard markers, office files, register books',
      amount: 15000.0,
      status: 'Paid',
      date: '2026-08-01',
    ),
  ]);

  void logPurchaseOrder(PurchaseOrderEntity po) {
    state = [po, ...state];
  }

  void updateOrderStatus(String id, String status) {
    state = state.map((po) => po.id == id ? po.copyWith(status: status) : po).toList();
  }
}

final purchaseOrdersProvider = StateNotifierProvider<PurchaseOrdersNotifier, List<PurchaseOrderEntity>>((ref) {
  return PurchaseOrdersNotifier();
});

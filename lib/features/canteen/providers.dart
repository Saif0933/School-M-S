import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Menu Item Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class CanteenMenuItem {
  final String id;
  final String branchId;
  final String name;
  final String category; // 'Meals', 'Snacks', 'Beverages'
  final double price;
  final String dietaryPref; // 'Veg', 'Non-Veg', 'Vegan'
  final String nutritionalInfo; // '350 kcal | 8g Prot'

  const CanteenMenuItem({
    required this.id,
    required this.branchId,
    required this.name,
    required this.category,
    required this.price,
    required this.dietaryPref,
    required this.nutritionalInfo,
  });
}

class MenuNotifier extends StateNotifier<List<CanteenMenuItem>> {
  MenuNotifier() : super([
    const CanteenMenuItem(
      id: 'MENU-DEL-01',
      branchId: 'BR-001',
      name: 'Paneer Masala Thali',
      category: 'Meals',
      price: 120.0,
      dietaryPref: 'Veg',
      nutritionalInfo: '550 kcal | 15g Protein',
    ),
    const CanteenMenuItem(
      id: 'MENU-DEL-02',
      branchId: 'BR-001',
      name: 'Whole Wheat Veg Club Sandwich',
      category: 'Snacks',
      price: 65.0,
      dietaryPref: 'Veg',
      nutritionalInfo: '320 kcal | 9g Protein',
    ),
    const CanteenMenuItem(
      id: 'MENU-MUM-01',
      branchId: 'BR-002',
      name: 'Mumbai Pav Bhaji Special',
      category: 'Snacks',
      price: 80.0,
      dietaryPref: 'Veg',
      nutritionalInfo: '450 kcal | 7g Protein',
    ),
  ]);

  void addMenuItem(CanteenMenuItem item) {
    state = [...state, item];
  }
}

final canteenMenuProvider = StateNotifierProvider<MenuNotifier, List<CanteenMenuItem>>((ref) {
  return MenuNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Pre-Order & Wallet Transaction Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class CanteenOrder {
  final String id;
  final String branchId;
  final String studentName;
  final String itemName;
  final double amount;
  final String orderTime;
  final String status; // 'Active', 'Collected'

  const CanteenOrder({
    required this.id,
    required this.branchId,
    required this.studentName,
    required this.itemName,
    required this.amount,
    required this.orderTime,
    required this.status,
  });

  CanteenOrder copyWith({String? status}) {
    return CanteenOrder(
      id: id,
      branchId: branchId,
      studentName: studentName,
      itemName: itemName,
      amount: amount,
      orderTime: orderTime,
      status: status ?? this.status,
    );
  }
}

class OrdersNotifier extends StateNotifier<List<CanteenOrder>> {
  OrdersNotifier() : super([
    const CanteenOrder(
      id: 'ORD-DEL-01',
      branchId: 'BR-001',
      studentName: 'Aarav Sharma',
      itemName: 'Paneer Masala Thali',
      amount: 120.0,
      orderTime: '11:45 AM',
      status: 'Active',
    ),
  ]);

  void createOrder(CanteenOrder order) {
    state = [order, ...state];
  }

  void collectOrder(String id) {
    state = state.map((o) => o.id == id ? o.copyWith(status: 'Collected') : o).toList();
  }
}

final canteenOrdersProvider = StateNotifierProvider<OrdersNotifier, List<CanteenOrder>>((ref) {
  return OrdersNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Cashless Wallet Balance state
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class WalletStateNotifier extends StateNotifier<double> {
  WalletStateNotifier() : super(450.0); // Default simulated student pocket wallet balance

  void topUp(double amount) {
    state = state + amount;
  }

  bool deduct(double amount) {
    if (state >= amount) {
      state = state - amount;
      return true;
    }
    return false;
  }

  void refund(double amount) {
    state = state + amount;
  }
}

final walletProvider = StateNotifierProvider<WalletStateNotifier, double>((ref) {
  return WalletStateNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Food Waste Tracker Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class WasteLog {
  final String id;
  final String branchId;
  final String itemName;
  final double wasteWeightKg;
  final String reason;
  final String date;

  const WasteLog({
    required this.id,
    required this.branchId,
    required this.itemName,
    required this.wasteWeightKg,
    required this.reason,
    required this.date,
  });
}

class WasteLogNotifier extends StateNotifier<List<WasteLog>> {
  WasteLogNotifier() : super([
    const WasteLog(
      id: 'WST-DEL-01',
      branchId: 'BR-001',
      itemName: 'Rice Preparations',
      wasteWeightKg: 4.2,
      reason: 'Over-preparation for lunch hour',
      date: '2026-08-18',
    ),
  ]);

  void logWaste(WasteLog log) {
    state = [log, ...state];
  }
}

final wasteLogProvider = StateNotifierProvider<WasteLogNotifier, List<WasteLog>>((ref) {
  return WasteLogNotifier();
});

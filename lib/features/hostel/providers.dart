import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Hostel Building Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HostelBuildingEntity {
  final String id;
  final String branchId;
  final String name;
  final String wardenName;
  final String wardenPhone;
  final int totalRooms;

  const HostelBuildingEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.wardenName,
    required this.wardenPhone,
    required this.totalRooms,
  });
}

class HostelBuildingsNotifier extends StateNotifier<List<HostelBuildingEntity>> {
  HostelBuildingsNotifier() : super([
    // Delhi Buildings (BR-001)
    const HostelBuildingEntity(
      id: 'BLD-001',
      branchId: 'BR-001',
      name: 'Aravali Boys Block A',
      wardenName: 'Mr. Satish Kumar',
      wardenPhone: '+91 99008 87766',
      totalRooms: 30,
    ),
    const HostelBuildingEntity(
      id: 'BLD-002',
      branchId: 'BR-001',
      name: 'Vindhya Girls Block B',
      wardenName: 'Mrs. Shanti Sharma',
      wardenPhone: '+91 99112 23344',
      totalRooms: 25,
    ),
    // Mumbai Buildings (BR-002)
    const HostelBuildingEntity(
      id: 'BLD-003',
      branchId: 'BR-002',
      name: 'Sahyadri Mixed Tower C',
      wardenName: 'Mr. Vijay Patil',
      wardenPhone: '+91 88776 65541',
      totalRooms: 40,
    ),
  ]);

  void addBuilding(HostelBuildingEntity building) {
    state = [...state, building];
  }
}

final hostelBuildingsProvider = StateNotifierProvider<HostelBuildingsNotifier, List<HostelBuildingEntity>>((ref) {
  return HostelBuildingsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Hostel Room Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HostelRoomEntity {
  final String id;
  final String branchId;
  final String buildingId;
  final String buildingName;
  final String roomNo;
  final String roomType; // 'Single', 'Double', 'Triple', 'Dormitory'
  final int capacity;
  final int occupiedBeds;
  final double monthlyRent;
  final String status; // 'Available', 'Fully Occupied', 'Maintenance'

  const HostelRoomEntity({
    required this.id,
    required this.branchId,
    required this.buildingId,
    required this.buildingName,
    required this.roomNo,
    required this.roomType,
    required this.capacity,
    required this.occupiedBeds,
    required this.monthlyRent,
    required this.status,
  });

  HostelRoomEntity copyWith({int? occupiedBeds, String? status}) {
    return HostelRoomEntity(
      id: id,
      branchId: branchId,
      buildingId: buildingId,
      buildingName: buildingName,
      roomNo: roomNo,
      roomType: roomType,
      capacity: capacity,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      monthlyRent: monthlyRent,
      status: status ?? this.status,
    );
  }
}

class HostelRoomsNotifier extends StateNotifier<List<HostelRoomEntity>> {
  HostelRoomsNotifier() : super([
    // Delhi Rooms
    const HostelRoomEntity(
      id: 'RM-001',
      branchId: 'BR-001',
      buildingId: 'BLD-001',
      buildingName: 'Aravali Boys Block A',
      roomNo: 'Room 101',
      roomType: 'Double',
      capacity: 2,
      occupiedBeds: 2,
      monthlyRent: 3500.0,
      status: 'Fully Occupied',
    ),
    const HostelRoomEntity(
      id: 'RM-002',
      branchId: 'BR-001',
      buildingId: 'BLD-001',
      buildingName: 'Aravali Boys Block A',
      roomNo: 'Room 102',
      roomType: 'Single',
      capacity: 1,
      occupiedBeds: 0,
      monthlyRent: 5000.0,
      status: 'Available',
    ),
    const HostelRoomEntity(
      id: 'RM-003',
      branchId: 'BR-001',
      buildingId: 'BLD-002',
      buildingName: 'Vindhya Girls Block B',
      roomNo: 'Room 201',
      roomType: 'Triple',
      capacity: 3,
      occupiedBeds: 1,
      monthlyRent: 2800.0,
      status: 'Available',
    ),
    // Mumbai Rooms
    const HostelRoomEntity(
      id: 'RM-004',
      branchId: 'BR-002',
      buildingId: 'BLD-003',
      buildingName: 'Sahyadri Mixed Tower C',
      roomNo: 'Room 101',
      roomType: 'Dormitory',
      capacity: 6,
      occupiedBeds: 4,
      monthlyRent: 2000.0,
      status: 'Available',
    ),
  ]);

  void addRoom(HostelRoomEntity room) {
    state = [...state, room];
  }

  void allocateBed(String roomId) {
    state = state.map((r) {
      if (r.id == roomId) {
        final newCount = r.occupiedBeds + 1;
        final newStatus = newCount >= r.capacity ? 'Fully Occupied' : 'Available';
        return r.copyWith(occupiedBeds: newCount, status: newStatus);
      }
      return r;
    }).toList();
  }
}

final hostelRoomsProvider = StateNotifierProvider<HostelRoomsNotifier, List<HostelRoomEntity>>((ref) {
  return HostelRoomsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Mess Menu & Plans Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class MessPlanEntity {
  final String id;
  final String branchId;
  final String planName;
  final String foodType; // 'Veg', 'Non-Veg', 'Jain'
  final String weeklyMenu;
  final double monthlyCost;

  const MessPlanEntity({
    required this.id,
    required this.branchId,
    required this.planName,
    required this.foodType,
    required this.weeklyMenu,
    required this.monthlyCost,
  });
}

class MessPlansNotifier extends StateNotifier<List<MessPlanEntity>> {
  MessPlansNotifier() : super([
    // Delhi Mess Plans
    const MessPlanEntity(
      id: 'MESS-001',
      branchId: 'BR-001',
      planName: 'Aravali Standard Veg',
      foodType: 'Veg',
      weeklyMenu: 'Mon: Roti/Dal, Tue: Rajma, Wed: Paneer Masala, Thu: Aloo Gobi, Fri: Kadhai Veg, Sat: Khichdi, Sun: Veg Biryani',
      monthlyCost: 2500.0,
    ),
    // Mumbai Mess Plans
    const MessPlanEntity(
      id: 'MESS-002',
      branchId: 'BR-002',
      planName: 'Sahyadri Premium Mix',
      foodType: 'Non-Veg',
      weeklyMenu: 'Mon: Veg Pulao, Tue: Chicken Curry / Paneer, Wed: Dal Makhani, Thu: Fish Fry / Veg, Fri: Egg Curry, Sat: Puri Bhaji, Sun: Biryani Feast',
      monthlyCost: 3500.0,
    ),
  ]);
}

final messPlansProvider = StateNotifierProvider<MessPlansNotifier, List<MessPlanEntity>>((ref) {
  return MessPlansNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Hostel Allocations
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HostelAllocationEntity {
  final String id;
  final String branchId;
  final String studentId;
  final String studentName;
  final String buildingName;
  final String roomNo;
  final String roomType;
  final String bedNo;
  final String messPlanName;
  final double monthlyFee;
  final double waiverAmount;

  const HostelAllocationEntity({
    required this.id,
    required this.branchId,
    required this.studentId,
    required this.studentName,
    required this.buildingName,
    required this.roomNo,
    required this.roomType,
    required this.bedNo,
    required this.messPlanName,
    required this.monthlyFee,
    required this.waiverAmount,
  });

  HostelAllocationEntity copyWith({double? waiverAmount}) {
    return HostelAllocationEntity(
      id: id,
      branchId: branchId,
      studentId: studentId,
      studentName: studentName,
      buildingName: buildingName,
      roomNo: roomNo,
      roomType: roomType,
      bedNo: bedNo,
      messPlanName: messPlanName,
      monthlyFee: monthlyFee,
      waiverAmount: waiverAmount ?? this.waiverAmount,
    );
  }
}

class HostelAllocationsNotifier extends StateNotifier<List<HostelAllocationEntity>> {
  HostelAllocationsNotifier() : super([
    // Delhi Allocations
    const HostelAllocationEntity(
      id: 'HAL-001',
      branchId: 'BR-001',
      studentId: 'STU-001',
      studentName: 'Aarav Sharma',
      buildingName: 'Aravali Boys Block A',
      roomNo: 'Room 101',
      roomType: 'Double',
      bedNo: 'Bed A',
      messPlanName: 'Aravali Standard Veg',
      monthlyFee: 6000.0, // Room rent + Mess fee
      waiverAmount: 0.0,
    ),
    const HostelAllocationEntity(
      id: 'HAL-002',
      branchId: 'BR-001',
      studentId: 'STU-002',
      studentName: 'Bhumika Gowda',
      buildingName: 'Vindhya Girls Block B',
      roomNo: 'Room 201',
      roomType: 'Triple',
      bedNo: 'Bed B',
      messPlanName: 'Aravali Standard Veg',
      monthlyFee: 5300.0,
      waiverAmount: 1000.0, // Scholarship deduction
    ),
    // Mumbai Allocations
    const HostelAllocationEntity(
      id: 'HAL-003',
      branchId: 'BR-002',
      studentId: 'STU-008',
      studentName: 'Sachin Tendulkar',
      buildingName: 'Sahyadri Mixed Tower C',
      roomNo: 'Room 101',
      roomType: 'Dormitory',
      bedNo: 'Bed C-2',
      messPlanName: 'Sahyadri Premium Mix',
      monthlyFee: 5500.0,
      waiverAmount: 0.0,
    ),
  ]);

  void allocateHostel(HostelAllocationEntity allocation) {
    state = [...state, allocation];
  }

  void updateWaiver(String id, double waiver) {
    state = state.map((a) => a.id == id ? a.copyWith(waiverAmount: waiver) : a).toList();
  }
}

final hostelAllocationsProvider =
    StateNotifierProvider<HostelAllocationsNotifier, List<HostelAllocationEntity>>((ref) {
  return HostelAllocationsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Hostel Visitor Entry Logs
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HostelVisitorEntity {
  final String id;
  final String branchId;
  final String visitorName;
  final String relationToStudent;
  final String studentName;
  final String buildingName;
  final DateTime checkInTime;
  final DateTime? checkOutTime;

  const HostelVisitorEntity({
    required this.id,
    required this.branchId,
    required this.visitorName,
    required this.relationToStudent,
    required this.studentName,
    required this.buildingName,
    required this.checkInTime,
    this.checkOutTime,
  });

  HostelVisitorEntity copyWith({DateTime? checkOutTime}) {
    return HostelVisitorEntity(
      id: id,
      branchId: branchId,
      visitorName: visitorName,
      relationToStudent: relationToStudent,
      studentName: studentName,
      buildingName: buildingName,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }
}

class HostelVisitorsNotifier extends StateNotifier<List<HostelVisitorEntity>> {
  HostelVisitorsNotifier() : super([
    // Delhi Visitor
    HostelVisitorEntity(
      id: 'VIS-H-001',
      branchId: 'BR-001',
      visitorName: 'Rajesh Sharma',
      relationToStudent: 'Father',
      studentName: 'Aarav Sharma',
      buildingName: 'Aravali Boys Block A',
      checkInTime: DateTime.now().subtract(const Duration(hours: 4)),
      checkOutTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    // Mumbai Visitor
    HostelVisitorEntity(
      id: 'VIS-H-002',
      branchId: 'BR-002',
      visitorName: 'Ramesh Tendulkar',
      relationToStudent: 'Brother',
      studentName: 'Sachin Tendulkar',
      buildingName: 'Sahyadri Mixed Tower C',
      checkInTime: DateTime.now().subtract(const Duration(hours: 1)),
      checkOutTime: null, // Still in building
    ),
  ]);

  void logVisitor(HostelVisitorEntity visitor) {
    state = [...state, visitor];
  }

  void checkOutVisitor(String id) {
    state = state.map((v) => v.id == id ? v.copyWith(checkOutTime: DateTime.now()) : v).toList();
  }
}

final hostelVisitorsProvider = StateNotifierProvider<HostelVisitorsNotifier, List<HostelVisitorEntity>>((ref) {
  return HostelVisitorsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Hostel Leave Applications & Gate Pass Logs
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HostelLeaveEntity {
  final String id;
  final String branchId;
  final String studentName;
  final String buildingName;
  final String roomNo;
  final String leaveType; // 'Weekend Outing', 'Night Out', 'Emergency Out'
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String reason;

  const HostelLeaveEntity({
    required this.id,
    required this.branchId,
    required this.studentName,
    required this.buildingName,
    required this.roomNo,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.reason,
  });

  HostelLeaveEntity copyWith({String? status}) {
    return HostelLeaveEntity(
      id: id,
      branchId: branchId,
      studentName: studentName,
      buildingName: buildingName,
      roomNo: roomNo,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
      reason: reason,
    );
  }
}

class HostelLeavesNotifier extends StateNotifier<List<HostelLeaveEntity>> {
  HostelLeavesNotifier() : super([
    // Delhi Leave
    HostelLeaveEntity(
      id: 'LEV-H-001',
      branchId: 'BR-001',
      studentName: 'Bhumika Gowda',
      buildingName: 'Vindhya Girls Block B',
      roomNo: 'Room 201',
      leaveType: 'Weekend Outing',
      startDate: DateTime.now().add(const Duration(days: 4)),
      endDate: DateTime.now().add(const Duration(days: 6)),
      status: 'Pending',
      reason: 'Visiting parents for festival celebration',
    ),
    // Mumbai Leave
    HostelLeaveEntity(
      id: 'LEV-H-002',
      branchId: 'BR-002',
      studentName: 'Sachin Tendulkar',
      buildingName: 'Sahyadri Mixed Tower C',
      roomNo: 'Room 101',
      leaveType: 'Night Out',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Approved',
      reason: 'Family gathering in South Mumbai',
    ),
  ]);

  void applyLeave(HostelLeaveEntity leave) {
    state = [...state, leave];
  }

  void approveLeave(String id, String newStatus) {
    state = state.map((l) => l.id == id ? l.copyWith(status: newStatus) : l).toList();
  }
}

final hostelLeavesProvider = StateNotifierProvider<HostelLeavesNotifier, List<HostelLeaveEntity>>((ref) {
  return HostelLeavesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Laundry Logs
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LaundryLogEntity {
  final String id;
  final String branchId;
  final String studentName;
  final int itemsCount;
  final DateTime submissionDate;
  final String status; // 'Submitted', 'In Laundry', 'Ready', 'Delivered'

  const LaundryLogEntity({
    required this.id,
    required this.branchId,
    required this.studentName,
    required this.itemsCount,
    required this.submissionDate,
    required this.status,
  });

  LaundryLogEntity copyWith({String? status}) {
    return LaundryLogEntity(
      id: id,
      branchId: branchId,
      studentName: studentName,
      itemsCount: itemsCount,
      submissionDate: submissionDate,
      status: status ?? this.status,
    );
  }
}

class LaundryLogsNotifier extends StateNotifier<List<LaundryLogEntity>> {
  LaundryLogsNotifier() : super([
    // Delhi Laundry
    LaundryLogEntity(
      id: 'LAUN-001',
      branchId: 'BR-001',
      studentName: 'Aarav Sharma',
      itemsCount: 8,
      submissionDate: DateTime.now().subtract(const Duration(days: 2)),
      status: 'Ready',
    ),
    // Mumbai Laundry
    LaundryLogEntity(
      id: 'LAUN-002',
      branchId: 'BR-002',
      studentName: 'Sachin Tendulkar',
      itemsCount: 12,
      submissionDate: DateTime.now().subtract(const Duration(days: 1)),
      status: 'In Laundry',
    ),
  ]);

  void addLaundry(LaundryLogEntity log) {
    state = [...state, log];
  }

  void updateStatus(String id, String status) {
    state = state.map((l) => l.id == id ? l.copyWith(status: status) : l).toList();
  }
}

final laundryLogsProvider = StateNotifierProvider<LaundryLogsNotifier, List<LaundryLogEntity>>((ref) {
  return LaundryLogsNotifier();
});

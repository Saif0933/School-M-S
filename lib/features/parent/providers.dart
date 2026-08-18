import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Parent Child Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ParentChildEntity {
  final String id;
  final String branchId;
  final String name;
  final String rollNo;
  final String className;
  final String sectionName;
  final String transportRoute;
  final String transportBusNo;
  final String hostelRoom;
  final String hostelBuilding;
  final String avatarUrl;

  const ParentChildEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.rollNo,
    required this.className,
    required this.sectionName,
    required this.transportRoute,
    required this.transportBusNo,
    required this.hostelRoom,
    required this.hostelBuilding,
    required this.avatarUrl,
  });
}

class ParentChildrenNotifier extends StateNotifier<List<ParentChildEntity>> {
  ParentChildrenNotifier() : super([
    // Child 1 - Aarav Sharma in Delhi Central (BR-001)
    const ParentChildEntity(
      id: 'STU-001',
      branchId: 'BR-001',
      name: 'Aarav Sharma',
      rollNo: '24',
      className: 'Class 11 Science',
      sectionName: 'Sec A',
      transportRoute: 'Route 101 - Rohini Sector 9',
      transportBusNo: 'DL-01-T-8877',
      hostelRoom: 'Room 101',
      hostelBuilding: 'Aravali Boys Block A',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150',
    ),
    // Child 2 - Sachin Tendulkar in Mumbai South (BR-002)
    const ParentChildEntity(
      id: 'STU-008',
      branchId: 'BR-002',
      name: 'Sachin Tendulkar',
      rollNo: '10',
      className: 'Class 12 Commerce',
      sectionName: 'Sec B',
      transportRoute: 'Route 501 - Bandra Expressway',
      transportBusNo: 'MH-01-TR-9905',
      hostelRoom: 'Room 101',
      hostelBuilding: 'Sahyadri Mixed Tower C',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=150',
    ),
  ]);
}

final parentChildrenProvider = StateNotifierProvider<ParentChildrenNotifier, List<ParentChildEntity>>((ref) {
  return ParentChildrenNotifier();
});

/// Selected active child ID in the parent portal session
final activeChildIdProvider = StateProvider<String>((ref) {
  final children = ref.watch(parentChildrenProvider);
  return children.isNotEmpty ? children.first.id : '';
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Simulated Leave Application
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ChildLeaveEntity {
  final String id;
  final String studentId;
  final String studentName;
  final String branchId;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'

  const ChildLeaveEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.branchId,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
  });

  ChildLeaveEntity copyWith({String? status}) {
    return ChildLeaveEntity(
      id: id,
      studentId: studentId,
      studentName: studentName,
      branchId: branchId,
      fromDate: fromDate,
      toDate: toDate,
      reason: reason,
      status: status ?? this.status,
    );
  }
}

class ChildLeavesNotifier extends StateNotifier<List<ChildLeaveEntity>> {
  ChildLeavesNotifier() : super([
    ChildLeaveEntity(
      id: 'LV-001',
      studentId: 'STU-001',
      studentName: 'Aarav Sharma',
      branchId: 'BR-001',
      fromDate: DateTime.now().add(const Duration(days: 3)),
      toDate: DateTime.now().add(const Duration(days: 4)),
      reason: 'Family wedding celebrations',
      status: 'Approved',
    ),
  ]);

  void submitLeave(ChildLeaveEntity leave) {
    state = [leave, ...state];
  }
}

final childLeavesProvider = StateNotifierProvider<ChildLeavesNotifier, List<ChildLeaveEntity>>((ref) {
  return ChildLeavesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Simulated Teacher Appointments
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AppointmentEntity {
  final String id;
  final String studentId;
  final String teacherName;
  final String branchId;
  final String dateTime;
  final String purpose;
  final String status; // 'Scheduled', 'Completed', 'Cancelled'

  const AppointmentEntity({
    required this.id,
    required this.studentId,
    required this.teacherName,
    required this.branchId,
    required this.dateTime,
    required this.purpose,
    required this.status,
  });
}

class AppointmentsNotifier extends StateNotifier<List<AppointmentEntity>> {
  AppointmentsNotifier() : super([
    const AppointmentEntity(
      id: 'APP-001',
      studentId: 'STU-001',
      teacherName: 'Mrs. Kavita Verma',
      branchId: 'BR-001',
      dateTime: 'Friday, 02:00 PM',
      purpose: 'Discuss term 1 mathematics progress',
      status: 'Scheduled',
    ),
  ]);

  void scheduleAppointment(AppointmentEntity app) {
    state = [app, ...state];
  }
}

final appointmentsProvider = StateNotifierProvider<AppointmentsNotifier, List<AppointmentEntity>>((ref) {
  return AppointmentsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Canteen Pre-order Menu
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class CanteenItemEntity {
  final String id;
  final String name;
  final double price;
  final String category; // 'Lunch', 'Snacks', 'Beverages'
  final bool isAvailable;

  const CanteenItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.isAvailable,
  });
}

final canteenMenuProvider = Provider<List<CanteenItemEntity>>((ref) {
  return const [
    CanteenItemEntity(id: 'CNT-001', name: 'Standard Thali (Roti, Sabzi, Rice, Dal)', price: 80.0, category: 'Lunch', isAvailable: true),
    CanteenItemEntity(id: 'CNT-002', name: 'Paneer Wrap / roll', price: 60.0, category: 'Snacks', isAvailable: true),
    CanteenItemEntity(id: 'CNT-003', name: 'Veg Sandwich (Grilled)', price: 45.0, category: 'Snacks', isAvailable: true),
    CanteenItemEntity(id: 'CNT-004', name: 'Fruit Juice (Fresh)', price: 30.0, category: 'Beverages', isAvailable: true),
    CanteenItemEntity(id: 'CNT-005', name: 'Idli Sambar (2 Pcs)', price: 40.0, category: 'Snacks', isAvailable: true),
  ];
});

class CanteenOrderEntity {
  final String id;
  final String studentId;
  final String itemName;
  final double amount;
  final String orderDate;
  final String status; // 'Ordered', 'Served'

  const CanteenOrderEntity({
    required this.id,
    required this.studentId,
    required this.itemName,
    required this.amount,
    required this.orderDate,
    required this.status,
  });
}

class CanteenOrdersNotifier extends StateNotifier<List<CanteenOrderEntity>> {
  CanteenOrdersNotifier() : super([
    const CanteenOrderEntity(
      id: 'ORD-001',
      studentId: 'STU-001',
      itemName: 'Standard Thali',
      amount: 80.0,
      orderDate: 'Today',
      status: 'Ordered',
    ),
  ]);

  void preOrderFood(CanteenOrderEntity order) {
    state = [order, ...state];
  }
}

final canteenOrdersProvider = StateNotifierProvider<CanteenOrdersNotifier, List<CanteenOrderEntity>>((ref) {
  return CanteenOrdersNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch Polls
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BranchPollEntity {
  final String id;
  final String question;
  final List<String> options;
  final Map<String, int> votes;
  final String userVote; // empty if not voted

  const BranchPollEntity({
    required this.id,
    required this.question,
    required this.options,
    required this.votes,
    this.userVote = '',
  });

  BranchPollEntity copyWith({String? userVote, Map<String, int>? votes}) {
    return BranchPollEntity(
      id: id,
      question: question,
      options: options,
      votes: votes ?? this.votes,
      userVote: userVote ?? this.userVote,
    );
  }
}

class BranchPollsNotifier extends StateNotifier<List<BranchPollEntity>> {
  BranchPollsNotifier() : super([
    const BranchPollEntity(
      id: 'POL-001',
      question: 'Should the school mandate digital textbooks / tablets for Class 11 onwards?',
      options: ['Yes, Fully Digital', 'No, Keep Printed Books', 'Hybrid Model'],
      votes: {'Yes, Fully Digital': 45, 'No, Keep Printed Books': 12, 'Hybrid Model': 30},
      userVote: '',
    ),
  ]);

  void castVote(String pollId, String option) {
    state = state.map((p) {
      if (p.id == pollId && p.userVote.isEmpty) {
        final newVotes = Map<String, int>.from(p.votes);
        newVotes[option] = (newVotes[option] ?? 0) + 1;
        return p.copyWith(userVote: option, votes: newVotes);
      }
      return p;
    }).toList();
  }
}

final branchPollsProvider = StateNotifierProvider<BranchPollsNotifier, List<BranchPollEntity>>((ref) {
  return BranchPollsNotifier();
});

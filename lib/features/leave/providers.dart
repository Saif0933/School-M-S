import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Leave Application Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LeaveApplicationRecord {
  final String id;
  final String branchId;
  final String applicantType; // 'Student', 'Staff'
  final String applicantName;
  final String leaveType; // 'Sick', 'Casual', 'Medical', 'Emergency'
  final String startDate;
  final String endDate;
  final String reason;
  final String? attachmentName;
  final String status; // 'Pending', 'Approved (Dept Head)', 'Approved', 'Rejected'

  const LeaveApplicationRecord({
    required this.id,
    required this.branchId,
    required this.applicantType,
    required this.applicantName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.attachmentName,
    required this.status,
  });

  LeaveApplicationRecord copyWith({String? status}) {
    return LeaveApplicationRecord(
      id: id,
      branchId: branchId,
      applicantType: applicantType,
      applicantName: applicantName,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      attachmentName: attachmentName,
      status: status ?? this.status,
    );
  }
}

class LeaveApplicationsNotifier extends StateNotifier<List<LeaveApplicationRecord>> {
  LeaveApplicationsNotifier() : super([
    const LeaveApplicationRecord(
      id: 'LVE-DEL-01',
      branchId: 'BR-001',
      applicantType: 'Student',
      applicantName: 'Aarav Sharma',
      leaveType: 'Sick',
      startDate: '2026-08-20',
      endDate: '2026-08-21',
      reason: 'Fever and viral cold recovery.',
      attachmentName: 'doctor_presc.pdf',
      status: 'Pending',
    ),
    const LeaveApplicationRecord(
      id: 'LVE-DEL-02',
      branchId: 'BR-001',
      applicantType: 'Staff',
      applicantName: 'Vikram Malhotra',
      leaveType: 'Casual',
      startDate: '2026-08-22',
      endDate: '2026-08-22',
      reason: 'Urgent family task at hometown.',
      status: 'Approved',
    ),
  ]);

  void applyLeave(LeaveApplicationRecord record) {
    state = [...state, record];
  }

  void updateApproval(String id, String newStatus) {
    state = state.map((l) => l.id == id ? l.copyWith(status: newStatus) : l).toList();
  }
}

final leaveApplicationsProvider = StateNotifierProvider<LeaveApplicationsNotifier, List<LeaveApplicationRecord>>((ref) {
  return LeaveApplicationsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Leave Balances Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LeaveBalance {
  final String category; // 'Sick', 'Casual', 'Medical', 'Emergency'
  final int total;
  final int used;

  const LeaveBalance({required this.category, required this.total, required this.used});
}

final leaveBalancesProvider = Provider<List<LeaveBalance>>((ref) {
  return const [
    LeaveBalance(category: 'Sick', total: 10, used: 2),
    LeaveBalance(category: 'Casual', total: 12, used: 4),
    LeaveBalance(category: 'Medical', total: 15, used: 0),
    LeaveBalance(category: 'Emergency', total: 5, used: 1),
  ];
});

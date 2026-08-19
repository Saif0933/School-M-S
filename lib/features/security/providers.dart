import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Visitor Record Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class VisitorRecord {
  final String id;
  final String branchId;
  final String name;
  final String phone;
  final String purpose;
  final String whomToMeet;
  final String? vehicleNumber;
  final String checkInTime;
  final String? checkOutTime;
  final String status; // 'Pre-registered', 'Checked-In', 'Checked-Out'
  final bool isBlacklisted;
  final String photoUrl;

  const VisitorRecord({
    required this.id,
    required this.branchId,
    required this.name,
    required this.phone,
    required this.purpose,
    required this.whomToMeet,
    this.vehicleNumber,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.isBlacklisted = false,
    this.photoUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
  });

  VisitorRecord copyWith({
    String? checkInTime,
    String? checkOutTime,
    String? status,
  }) {
    return VisitorRecord(
      id: id,
      branchId: branchId,
      name: name,
      phone: phone,
      purpose: purpose,
      whomToMeet: whomToMeet,
      vehicleNumber: vehicleNumber,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      isBlacklisted: isBlacklisted,
      photoUrl: photoUrl,
    );
  }
}

class VisitorsNotifier extends StateNotifier<List<VisitorRecord>> {
  VisitorsNotifier() : super([
    const VisitorRecord(
      id: 'VIS-DEL-01',
      branchId: 'BR-001',
      name: 'Rajesh Kumar',
      phone: '+91 9876543210',
      purpose: 'Parent-Teacher Meeting',
      whomToMeet: 'Physics Faculty',
      checkInTime: '10:00 AM',
      status: 'Checked-In',
    ),
    const VisitorRecord(
      id: 'VIS-DEL-02',
      branchId: 'BR-001',
      name: 'Vikram Malhotra',
      phone: '+91 9999911111',
      purpose: 'Auditing Vendor',
      whomToMeet: 'Administrative Admin',
      checkInTime: '08:30 AM',
      checkOutTime: '11:00 AM',
      status: 'Checked-Out',
    ),
    const VisitorRecord(
      id: 'VIS-DEL-03',
      branchId: 'BR-001',
      name: 'Blacklisted Scammer',
      phone: '+91 9000000000',
      purpose: 'Trespassing',
      whomToMeet: 'Students Office',
      checkInTime: '',
      status: 'Pre-registered',
      isBlacklisted: true,
    ),
  ]);

  void preRegister(VisitorRecord record) {
    state = [...state, record];
  }

  void checkIn(String id, String time) {
    state = state.map((v) => v.id == id ? v.copyWith(status: 'Checked-In', checkInTime: time) : v).toList();
  }

  void checkOut(String id, String time) {
    state = state.map((v) => v.id == id ? v.copyWith(status: 'Checked-Out', checkOutTime: time) : v).toList();
  }
}

final visitorsProvider = StateNotifierProvider<VisitorsNotifier, List<VisitorRecord>>((ref) {
  return VisitorsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Gate Pass Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class GatePassRecord {
  final String id;
  final String branchId;
  final String studentName;
  final String parentName;
  final String pickupCode;
  final String reason;
  final String passTime;
  final String status; // 'Pending', 'Approved', 'Departed'

  const GatePassRecord({
    required this.id,
    required this.branchId,
    required this.studentName,
    required this.parentName,
    required this.pickupCode,
    required this.reason,
    required this.passTime,
    required this.status,
  });

  GatePassRecord copyWith({String? status}) {
    return GatePassRecord(
      id: id,
      branchId: branchId,
      studentName: studentName,
      parentName: parentName,
      pickupCode: pickupCode,
      reason: reason,
      passTime: passTime,
      status: status ?? this.status,
    );
  }
}

class GatePassesNotifier extends StateNotifier<List<GatePassRecord>> {
  GatePassesNotifier() : super([
    const GatePassRecord(
      id: 'GP-DEL-01',
      branchId: 'BR-001',
      studentName: 'Aarav Sharma',
      parentName: 'Ramesh Sharma',
      pickupCode: 'PICK-9083',
      reason: 'Doctor Check-up Appointment',
      passTime: '11:15 AM',
      status: 'Approved',
    ),
  ]);

  void requestGatePass(GatePassRecord record) {
    state = [...state, record];
  }

  void updatePassStatus(String id, String status) {
    state = state.map((g) => g.id == id ? g.copyWith(status: status) : g).toList();
  }
}

final gatePassesProvider = StateNotifierProvider<GatePassesNotifier, List<GatePassRecord>>((ref) {
  return GatePassesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Incidents Registry
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SecurityIncident {
  final String id;
  final String branchId;
  final String type; // 'Trespassing', 'Theft', 'Medical', 'Damage'
  final String details;
  final String date;
  final String severity; // 'Critical', 'Warning', 'Info'

  const SecurityIncident({
    required this.id,
    required this.branchId,
    required this.type,
    required this.details,
    required this.date,
    required this.severity,
  });
}

class IncidentsNotifier extends StateNotifier<List<SecurityIncident>> {
  IncidentsNotifier() : super([
    const SecurityIncident(
      id: 'INC-DEL-01',
      branchId: 'BR-001',
      type: 'Trespassing',
      details: 'Unidentified vehicle entered gate 3 without permission.',
      date: '2026-08-18',
      severity: 'Warning',
    ),
  ]);

  void reportIncident(SecurityIncident inc) {
    state = [inc, ...state];
  }
}

final incidentsProvider = StateNotifierProvider<IncidentsNotifier, List<SecurityIncident>>((ref) {
  return IncidentsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Material Ledger (Inward/Outward)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class MaterialRecord {
  final String id;
  final String branchId;
  final String description;
  final String type; // 'Inward', 'Outward'
  final int quantity;
  final String vendor;
  final String time;

  const MaterialRecord({
    required this.id,
    required this.branchId,
    required this.description,
    required this.type,
    required this.quantity,
    required this.vendor,
    required this.time,
  });
}

class MaterialsNotifier extends StateNotifier<List<MaterialRecord>> {
  MaterialsNotifier() : super([
    const MaterialRecord(
      id: 'MAT-DEL-01',
      branchId: 'BR-001',
      description: 'Cartons of chemistry lab test tubes',
      type: 'Inward',
      quantity: 5,
      vendor: 'Borosil Lab Suppliers',
      time: '09:30 AM',
    ),
  ]);

  void logMaterial(MaterialRecord rec) {
    state = [rec, ...state];
  }
}

final materialsProvider = StateNotifierProvider<MaterialsNotifier, List<MaterialRecord>>((ref) {
  return MaterialsNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Vehicle Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class VehicleEntity {
  final String id;
  final String branchId;
  final String regNo;
  final String model;
  final int capacity;
  final DateTime insuranceValidity;
  final DateTime fitnessValidity;
  final DateTime pucValidity;
  final String gpsDeviceId;
  final String status; // 'Active', 'Maintenance', 'Inactive'

  const VehicleEntity({
    required this.id,
    required this.branchId,
    required this.regNo,
    required this.model,
    required this.capacity,
    required this.insuranceValidity,
    required this.fitnessValidity,
    required this.pucValidity,
    required this.gpsDeviceId,
    required this.status,
  });

  VehicleEntity copyWith({String? status}) {
    return VehicleEntity(
      id: id,
      branchId: branchId,
      regNo: regNo,
      model: model,
      capacity: capacity,
      insuranceValidity: insuranceValidity,
      fitnessValidity: fitnessValidity,
      pucValidity: pucValidity,
      gpsDeviceId: gpsDeviceId,
      status: status ?? this.status,
    );
  }
}

class VehiclesNotifier extends StateNotifier<List<VehicleEntity>> {
  VehiclesNotifier() : super([
    // Delhi Fleet (BR-001)
    VehicleEntity(
      id: 'VEH-001',
      branchId: 'BR-001',
      regNo: 'DL-01-S-4402',
      model: 'Tata Starbus 40-Seater',
      capacity: 40,
      insuranceValidity: DateTime.now().add(const Duration(days: 120)),
      fitnessValidity: DateTime.now().add(const Duration(days: 90)),
      pucValidity: DateTime.now().add(const Duration(days: 30)),
      gpsDeviceId: 'GPS-DEL-001',
      status: 'Active',
    ),
    VehicleEntity(
      id: 'VEH-002',
      branchId: 'BR-001',
      regNo: 'DL-01-S-8890',
      model: 'Force Traveler 17-Seater',
      capacity: 17,
      insuranceValidity: DateTime.now().add(const Duration(days: 180)),
      fitnessValidity: DateTime.now().add(const Duration(days: 150)),
      pucValidity: DateTime.now().subtract(const Duration(days: 2)), // Overdue PUC
      gpsDeviceId: 'GPS-DEL-002',
      status: 'Maintenance',
    ),
    // Mumbai Fleet (BR-002)
    VehicleEntity(
      id: 'VEH-003',
      branchId: 'BR-002',
      regNo: 'MH-01-TR-9905',
      model: 'Eicher Starline 32-Seater',
      capacity: 32,
      insuranceValidity: DateTime.now().add(const Duration(days: 210)),
      fitnessValidity: DateTime.now().add(const Duration(days: 180)),
      pucValidity: DateTime.now().add(const Duration(days: 45)),
      gpsDeviceId: 'GPS-MUM-001',
      status: 'Active',
    ),
  ]);

  void addVehicle(VehicleEntity vehicle) {
    state = [...state, vehicle];
  }

  void updateStatus(String id, String status) {
    state = state.map((v) => v.id == id ? v.copyWith(status: status) : v).toList();
  }
}

final vehiclesProvider = StateNotifierProvider<VehiclesNotifier, List<VehicleEntity>>((ref) {
  return VehiclesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Driver / Conductor Staff Pool
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TransportStaffEntity {
  final String id;
  final String branchId;
  final String name;
  final String role; // 'Driver', 'Conductor'
  final String phone;
  final String licenseNo;
  final DateTime licenseExpiry;

  const TransportStaffEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.role,
    required this.phone,
    required this.licenseNo,
    required this.licenseExpiry,
  });
}

class TransportStaffNotifier extends StateNotifier<List<TransportStaffEntity>> {
  TransportStaffNotifier() : super([
    // Delhi Staff
    TransportStaffEntity(
      id: 'TSTAFF-001',
      branchId: 'BR-001',
      name: 'Baldev Singh',
      role: 'Driver',
      phone: '+91 99887 76655',
      licenseNo: 'DL-DRIVER-001',
      licenseExpiry: DateTime.now().add(const Duration(days: 400)),
    ),
    TransportStaffEntity(
      id: 'TSTAFF-002',
      branchId: 'BR-001',
      name: 'Ramesh Lal',
      role: 'Conductor',
      phone: '+91 88776 65544',
      licenseNo: 'N/A',
      licenseExpiry: DateTime.now().add(const Duration(days: 9999)),
    ),
    // Mumbai Staff
    TransportStaffEntity(
      id: 'TSTAFF-003',
      branchId: 'BR-002',
      name: 'Milind Gawde',
      role: 'Driver',
      phone: '+91 77665 54433',
      licenseNo: 'MH-DRIVER-002',
      licenseExpiry: DateTime.now().add(const Duration(days: 600)),
    ),
  ]);

  void addStaff(TransportStaffEntity staff) {
    state = [...state, staff];
  }
}

final transportStaffProvider = StateNotifierProvider<TransportStaffNotifier, List<TransportStaffEntity>>((ref) {
  return TransportStaffNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Route Stop Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class RouteStopEntity {
  final String name;
  final String pickupTime;
  final String dropTime;
  final double fee;

  const RouteStopEntity({
    required this.name,
    required this.pickupTime,
    required this.dropTime,
    required this.fee,
  });
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Transport Route Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TransportRouteEntity {
  final String id;
  final String branchId;
  final String routeName;
  final String vehicleId;
  final String vehicleRegNo;
  final String driverName;
  final List<RouteStopEntity> stops;

  const TransportRouteEntity({
    required this.id,
    required this.branchId,
    required this.routeName,
    required this.vehicleId,
    required this.vehicleRegNo,
    required this.driverName,
    required this.stops,
  });
}

class TransportRoutesNotifier extends StateNotifier<List<TransportRouteEntity>> {
  TransportRoutesNotifier() : super([
    // Delhi Routes
    TransportRouteEntity(
      id: 'ROT-001',
      branchId: 'BR-001',
      routeName: 'Route 101 - Sector 15 to Dwarka',
      vehicleId: 'VEH-001',
      vehicleRegNo: 'DL-01-S-4402',
      driverName: 'Baldev Singh',
      stops: [
        RouteStopEntity(name: 'Sector 15 Cross', pickupTime: '07:30 AM', dropTime: '02:30 PM', fee: 1500.0),
        RouteStopEntity(name: 'Dwarka Metro Gate 2', pickupTime: '07:50 AM', dropTime: '02:10 PM', fee: 1800.0),
        RouteStopEntity(name: 'Janakpuri West', pickupTime: '08:10 AM', dropTime: '01:50 PM', fee: 2000.0),
      ],
    ),
    // Mumbai Routes
    TransportRouteEntity(
      id: 'ROT-002',
      branchId: 'BR-002',
      routeName: 'Route 501 - Bandra to Juhu Expressway',
      vehicleId: 'VEH-003',
      vehicleRegNo: 'MH-01-TR-9905',
      driverName: 'Milind Gawde',
      stops: [
        RouteStopEntity(name: 'Bandra West Bus Stand', pickupTime: '08:00 AM', dropTime: '03:15 PM', fee: 2200.0),
        RouteStopEntity(name: 'Santacruz Crossing', pickupTime: '08:20 AM', dropTime: '02:55 PM', fee: 2500.0),
        RouteStopEntity(name: 'Juhu Scheme Road 10', pickupTime: '08:40 AM', dropTime: '02:35 PM', fee: 3000.0),
      ],
    ),
  ]);

  void addRoute(TransportRouteEntity route) {
    state = [...state, route];
  }
}

final transportRoutesProvider = StateNotifierProvider<TransportRoutesNotifier, List<TransportRouteEntity>>((ref) {
  return TransportRoutesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Route Assignment Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StudentRouteAssignmentEntity {
  final String id;
  final String branchId;
  final String studentId;
  final String studentName;
  final String classSection;
  final String routeId;
  final String routeName;
  final String stopName;
  final double monthlyFee;
  final double waiverAmount;
  final String status; // 'Active', 'Suspended'

  const StudentRouteAssignmentEntity({
    required this.id,
    required this.branchId,
    required this.studentId,
    required this.studentName,
    required this.classSection,
    required this.routeId,
    required this.routeName,
    required this.stopName,
    required this.monthlyFee,
    required this.waiverAmount,
    required this.status,
  });

  StudentRouteAssignmentEntity copyWith({String? status, double? waiverAmount}) {
    return StudentRouteAssignmentEntity(
      id: id,
      branchId: branchId,
      studentId: studentId,
      studentName: studentName,
      classSection: classSection,
      routeId: routeId,
      routeName: routeName,
      stopName: stopName,
      monthlyFee: monthlyFee,
      waiverAmount: waiverAmount ?? this.waiverAmount,
      status: status ?? this.status,
    );
  }
}

class StudentRouteAssignmentsNotifier extends StateNotifier<List<StudentRouteAssignmentEntity>> {
  StudentRouteAssignmentsNotifier() : super([
    // Delhi Assignments
    StudentRouteAssignmentEntity(
      id: 'SRA-001',
      branchId: 'BR-001',
      studentId: 'STU-001',
      studentName: 'Aarav Sharma',
      classSection: 'Grade 10 - Sec A',
      routeId: 'ROT-001',
      routeName: 'Route 101 - Sector 15 to Dwarka',
      stopName: 'Sector 15 Cross',
      monthlyFee: 1500.0,
      waiverAmount: 0.0,
      status: 'Active',
    ),
    StudentRouteAssignmentEntity(
      id: 'SRA-002',
      branchId: 'BR-001',
      studentId: 'STU-002',
      studentName: 'Bhumika Gowda',
      classSection: 'Grade 10 - Sec A',
      routeId: 'ROT-001',
      routeName: 'Route 101 - Sector 15 to Dwarka',
      stopName: 'Janakpuri West',
      monthlyFee: 2000.0,
      waiverAmount: 500.0,
      status: 'Active',
    ),
    // Mumbai Assignments
    StudentRouteAssignmentEntity(
      id: 'SRA-003',
      branchId: 'BR-002',
      studentId: 'STU-008',
      studentName: 'Sachin Tendulkar',
      classSection: 'Class 11 Science - Sec A',
      routeId: 'ROT-002',
      routeName: 'Route 501 - Bandra to Juhu Expressway',
      stopName: 'Bandra West Bus Stand',
      monthlyFee: 2200.0,
      waiverAmount: 0.0,
      status: 'Active',
    ),
  ]);

  void assignRoute(StudentRouteAssignmentEntity assignment) {
    state = [...state, assignment];
  }

  void updateAssignmentWaiver(String id, double waiver) {
    state = state.map((a) => a.id == id ? a.copyWith(waiverAmount: waiver) : a).toList();
  }

  void toggleStatus(String id) {
    state = state.map((a) {
      if (a.id == id) {
        return a.copyWith(status: a.status == 'Active' ? 'Suspended' : 'Active');
      }
      return a;
    }).toList();
  }
}

final studentRouteAssignmentsProvider =
    StateNotifierProvider<StudentRouteAssignmentsNotifier, List<StudentRouteAssignmentEntity>>((ref) {
  return StudentRouteAssignmentsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Transport Attendance Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TransportAttendanceEntity {
  final String id;
  final String branchId;
  final String studentName;
  final String routeName;
  final String stopName;
  final DateTime date;
  final String session; // 'Morning Pickup', 'Afternoon Drop'
  final String status; // 'Boarded', 'Absent', 'Not Boarded'

  const TransportAttendanceEntity({
    required this.id,
    required this.branchId,
    required this.studentName,
    required this.routeName,
    required this.stopName,
    required this.date,
    required this.session,
    required this.status,
  });

  TransportAttendanceEntity copyWith({String? status}) {
    return TransportAttendanceEntity(
      id: id,
      branchId: branchId,
      studentName: studentName,
      routeName: routeName,
      stopName: stopName,
      date: date,
      session: session,
      status: status ?? this.status,
    );
  }
}

class TransportAttendanceNotifier extends StateNotifier<List<TransportAttendanceEntity>> {
  TransportAttendanceNotifier() : super([
    // Delhi Attendance Logs
    TransportAttendanceEntity(
      id: 'TATT-001',
      branchId: 'BR-001',
      studentName: 'Aarav Sharma',
      routeName: 'Route 101 - Sector 15 to Dwarka',
      stopName: 'Sector 15 Cross',
      date: DateTime.now(),
      session: 'Morning Pickup',
      status: 'Boarded',
    ),
    // Mumbai Attendance Logs
    TransportAttendanceEntity(
      id: 'TATT-002',
      branchId: 'BR-002',
      studentName: 'Sachin Tendulkar',
      routeName: 'Route 501 - Bandra to Juhu Expressway',
      stopName: 'Bandra West Bus Stand',
      date: DateTime.now(),
      session: 'Morning Pickup',
      status: 'Boarded',
    ),
  ]);

  void markAttendance(TransportAttendanceEntity log) {
    state = [
      for (final s in state)
        if (s.studentName == log.studentName && s.date.year == log.date.year && s.date.month == log.date.month && s.date.day == log.date.day && s.session == log.session)
          log
        else
          s
    ];
    if (!state.any((s) => s.studentName == log.studentName && s.date.year == log.date.year && s.date.month == log.date.month && s.date.day == log.date.day && s.session == log.session)) {
      state = [...state, log];
    }
  }
}

final transportAttendanceProvider =
    StateNotifierProvider<TransportAttendanceNotifier, List<TransportAttendanceEntity>>((ref) {
  return TransportAttendanceNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Vehicle Expense (Fuel & Maintenance Log) Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class VehicleExpenseEntity {
  final String id;
  final String branchId;
  final String vehicleId;
  final String regNo;
  final String type; // 'Fuel', 'Maintenance', 'Insurance Renewal', 'PUC Test'
  final double amount;
  final DateTime date;
  final String remarks;

  const VehicleExpenseEntity({
    required this.id,
    required this.branchId,
    required this.vehicleId,
    required this.regNo,
    required this.type,
    required this.amount,
    required this.date,
    required this.remarks,
  });
}

class VehicleExpensesNotifier extends StateNotifier<List<VehicleExpenseEntity>> {
  VehicleExpensesNotifier() : super([
    // Delhi Expenses
    VehicleExpenseEntity(
      id: 'EXP-V-001',
      branchId: 'BR-001',
      vehicleId: 'VEH-001',
      regNo: 'DL-01-S-4402',
      type: 'Fuel',
      amount: 4500.0,
      date: DateTime.now().subtract(const Duration(days: 3)),
      remarks: '50 Liters diesel refilled',
    ),
    VehicleExpenseEntity(
      id: 'EXP-V-002',
      branchId: 'BR-001',
      vehicleId: 'VEH-002',
      regNo: 'DL-01-S-8890',
      type: 'Maintenance',
      amount: 12000.0,
      date: DateTime.now().subtract(const Duration(days: 10)),
      remarks: 'Engine oil replacement & brake tuning',
    ),
    // Mumbai Expenses
    VehicleExpenseEntity(
      id: 'EXP-V-003',
      branchId: 'BR-002',
      vehicleId: 'VEH-003',
      regNo: 'MH-01-TR-9905',
      type: 'Fuel',
      amount: 5200.0,
      date: DateTime.now().subtract(const Duration(days: 2)),
      remarks: '60 Liters diesel refilled',
    ),
  ]);

  void addExpense(VehicleExpenseEntity exp) {
    state = [...state, exp];
  }
}

final vehicleExpensesProvider = StateNotifierProvider<VehicleExpensesNotifier, List<VehicleExpenseEntity>>((ref) {
  return VehicleExpensesNotifier();
});

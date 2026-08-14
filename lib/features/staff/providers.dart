import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Staff Entity Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffEntity {
  final String id;
  final String branchId; // Primary branch employment
  final String employeeId; // Unique employee ID (e.g., EMP-BR001-1002)
  final String name;
  final String designation; // e.g. Senior Teacher, Accountant, Administrator
  final String role; // UserRole equivalent: e.g. Teacher, Accountant, HOD
  final String dateOfJoining;
  final bool isActive;
  final String status; // 'Active', 'Inactive', 'On Leave', 'Suspended'
  final String departmentId; // Associated department

  // Personal Profile
  final String gender;
  final String dateOfBirth;
  final String bloodGroup;
  final String phone;
  final String email;
  final String address;

  // Qualifications & Professional Info
  final String qualification; // e.g. M.Ed, B.Sc, MCA
  final String specialization; // e.g. Mathematics, Computer Science
  final String institution;
  final int yearsOfExperience;
  final String previousEmployer;

  // Multi-Branch Sharing
  final List<String> sharedBranchIds; // Explicit cross-branch assignments

  // Document Storage (simulated file links)
  final List<String> uploadedDocuments;

  // RFID Card Mapping
  final String rfidCardNumber;

  const StaffEntity({
    required this.id,
    required this.branchId,
    required this.employeeId,
    required this.name,
    required this.designation,
    required this.role,
    required this.dateOfJoining,
    this.isActive = true,
    this.status = 'Active',
    this.departmentId = '',
    this.gender = 'Male',
    this.dateOfBirth = '1988-06-15',
    this.bloodGroup = 'A+',
    this.phone = '+91 98765 43210',
    this.email = 'staff@example.com',
    this.address = '456 Teacher Quarters',
    this.qualification = 'Master of Education (M.Ed)',
    this.specialization = 'Pedagogy',
    this.institution = 'Delhi University',
    this.yearsOfExperience = 5,
    this.previousEmployer = 'St. Xavier School',
    this.sharedBranchIds = const [],
    this.uploadedDocuments = const [
      'Resume.pdf',
      'Degree_Certificate.pdf',
      'ID_Proof.pdf',
    ],
    this.rfidCardNumber = '',
  });

  StaffEntity copyWith({
    String? id,
    String? branchId,
    String? employeeId,
    String? name,
    String? designation,
    String? role,
    String? dateOfJoining,
    bool? isActive,
    String? status,
    String? departmentId,
    String? gender,
    String? dateOfBirth,
    String? bloodGroup,
    String? phone,
    String? email,
    String? address,
    String? qualification,
    String? specialization,
    String? institution,
    int? yearsOfExperience,
    String? previousEmployer,
    List<String>? sharedBranchIds,
    List<String>? uploadedDocuments,
    String? rfidCardNumber,
  }) {
    return StaffEntity(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      role: role ?? this.role,
      dateOfJoining: dateOfJoining ?? this.dateOfJoining,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      departmentId: departmentId ?? this.departmentId,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      institution: institution ?? this.institution,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      previousEmployer: previousEmployer ?? this.previousEmployer,
      sharedBranchIds: sharedBranchIds ?? this.sharedBranchIds,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      rfidCardNumber: rfidCardNumber ?? this.rfidCardNumber,
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Staff State Notifier
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffNotifier extends StateNotifier<List<StaffEntity>> {
  StaffNotifier() : super(_defaultStaff);

  void registerStaff({
    required String branchId,
    required String name,
    required String designation,
    required String role,
    required String dateOfJoining,
    required String gender,
    required String dateOfBirth,
    required String bloodGroup,
    required String phone,
    required String email,
    required String address,
    required String qualification,
    required String specialization,
    required String institution,
    required int yearsOfExperience,
    required String previousEmployer,
    String departmentId = '',
  }) {
    final employeeId =
        'EMP-${branchId.toUpperCase().substring(0, 3)}-${1000 + state.length + 1}';
    final newStaff = StaffEntity(
      id: 'STF-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      employeeId: employeeId,
      name: name,
      designation: designation,
      role: role,
      dateOfJoining: dateOfJoining,
      gender: gender,
      dateOfBirth: dateOfBirth,
      bloodGroup: bloodGroup,
      phone: phone,
      email: email,
      address: address,
      qualification: qualification,
      specialization: specialization,
      institution: institution,
      yearsOfExperience: yearsOfExperience,
      previousEmployer: previousEmployer,
      departmentId: departmentId,
    );
    state = [...state, newStaff];
  }

  void updateStaffProfile(String id, StaffEntity updated) {
    state = state.map((s) => s.id == id ? updated : s).toList();
  }

  void addSharedBranch(String id, String targetBranchId) {
    state = state.map((s) {
      if (s.id == id) {
        if (!s.sharedBranchIds.contains(targetBranchId)) {
          return s.copyWith(
            sharedBranchIds: [...s.sharedBranchIds, targetBranchId],
          );
        }
      }
      return s;
    }).toList();
  }

  void removeSharedBranch(String id, String targetBranchId) {
    state = state.map((s) {
      if (s.id == id) {
        return s.copyWith(
          sharedBranchIds: s.sharedBranchIds
              .where((bId) => bId != targetBranchId)
              .toList(),
        );
      }
      return s;
    }).toList();
  }

  void uploadDocument(String id, String docName) {
    state = state.map((s) {
      if (s.id == id) {
        return s.copyWith(uploadedDocuments: [...s.uploadedDocuments, docName]);
      }
      return s;
    }).toList();
  }

  void setStaffStatus(String id, String status, bool isActive) {
    state = state.map((s) => s.id == id ? s.copyWith(status: status, isActive: isActive) : s).toList();
  }
}

final staffProvider = StateNotifierProvider<StaffNotifier, List<StaffEntity>>((
  ref,
) {
  return StaffNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Teacher Substitution Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TeacherSubstitutionEntity {
  final String id;
  final String branchId;
  final String date;
  final String originalTeacherId;
  final String substituteTeacherId;
  final String classId;
  final String sectionId;
  final String reason;
  final String status; // 'Active', 'Completed', 'Cancelled'

  const TeacherSubstitutionEntity({
    required this.id,
    required this.branchId,
    required this.date,
    required this.originalTeacherId,
    required this.substituteTeacherId,
    required this.classId,
    required this.sectionId,
    required this.reason,
    this.status = 'Active',
  });

  TeacherSubstitutionEntity copyWith({String? status}) {
    return TeacherSubstitutionEntity(
      id: id, branchId: branchId, date: date,
      originalTeacherId: originalTeacherId, substituteTeacherId: substituteTeacherId,
      classId: classId, sectionId: sectionId, reason: reason,
      status: status ?? this.status,
    );
  }
}

class SubstitutionNotifier extends StateNotifier<List<TeacherSubstitutionEntity>> {
  SubstitutionNotifier() : super([
    const TeacherSubstitutionEntity(
      id: 'SUB-MOCK-1', branchId: 'BR-001', date: '2026-08-15',
      originalTeacherId: 'STF-002', substituteTeacherId: 'STF-001',
      classId: 'CLS-001', sectionId: 'SEC-A-001',
      reason: 'Medical Leave (Fever)', status: 'Active',
    ),
  ]);

  void createSubstitution({required String branchId, required String date, required String originalTeacherId, required String substituteTeacherId, required String classId, required String sectionId, required String reason}) {
    state = [...state, TeacherSubstitutionEntity(id: 'SUB-${DateTime.now().millisecondsSinceEpoch}', branchId: branchId, date: date, originalTeacherId: originalTeacherId, substituteTeacherId: substituteTeacherId, classId: classId, sectionId: sectionId, reason: reason)];
  }

  void cancelSubstitution(String id) {
    state = state.map((s) => s.id == id ? s.copyWith(status: 'Cancelled') : s).toList();
  }
}

final substitutionProvider = StateNotifierProvider<SubstitutionNotifier, List<TeacherSubstitutionEntity>>((ref) {
  return SubstitutionNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Staff Leave Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffLeaveEntity {
  final String id;
  final String staffId;
  final String branchId;
  final String leaveType; // CL, EL, ML, Casual, Medical
  final String fromDate;
  final String toDate;
  final int days;
  final String reason;
  final String status; // Pending, Approved, Rejected

  const StaffLeaveEntity({
    required this.id,
    required this.staffId,
    required this.branchId,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.reason,
    this.status = 'Pending',
  });

  StaffLeaveEntity copyWith({String? status}) => StaffLeaveEntity(
        id: id, staffId: staffId, branchId: branchId, leaveType: leaveType,
        fromDate: fromDate, toDate: toDate, days: days, reason: reason,
        status: status ?? this.status,
      );
}

class StaffLeaveNotifier extends StateNotifier<List<StaffLeaveEntity>> {
  StaffLeaveNotifier() : super([
    const StaffLeaveEntity(id: 'LV-001', staffId: 'STF-002', branchId: 'BR-001', leaveType: 'Medical', fromDate: '2026-08-15', toDate: '2026-08-16', days: 2, reason: 'Fever and Cold', status: 'Approved'),
    const StaffLeaveEntity(id: 'LV-002', staffId: 'STF-001', branchId: 'BR-001', leaveType: 'CL', fromDate: '2026-08-20', toDate: '2026-08-20', days: 1, reason: 'Personal Work', status: 'Pending'),
  ]);

  void applyLeave({required String staffId, required String branchId, required String leaveType, required String fromDate, required String toDate, required int days, required String reason}) {
    state = [...state, StaffLeaveEntity(id: 'LV-${DateTime.now().millisecondsSinceEpoch}', staffId: staffId, branchId: branchId, leaveType: leaveType, fromDate: fromDate, toDate: toDate, days: days, reason: reason)];
  }

  void approveLeave(String id) => state = state.map((l) => l.id == id ? l.copyWith(status: 'Approved') : l).toList();
  void rejectLeave(String id) => state = state.map((l) => l.id == id ? l.copyWith(status: 'Rejected') : l).toList();
}

final staffLeaveProvider = StateNotifierProvider<StaffLeaveNotifier, List<StaffLeaveEntity>>((ref) => StaffLeaveNotifier());

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Staff Attendance Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffAttendanceEntity {
  final String id;
  final String staffId;
  final String branchId;
  final String date;
  final String status; // Present, Absent, HalfDay, Late, OnLeave
  final String checkInTime;
  final String checkOutTime;

  const StaffAttendanceEntity({
    required this.id, required this.staffId, required this.branchId,
    required this.date, required this.status,
    this.checkInTime = '08:00 AM', this.checkOutTime = '02:30 PM',
  });
}

class StaffAttendanceNotifier extends StateNotifier<List<StaffAttendanceEntity>> {
  StaffAttendanceNotifier() : super([
    const StaffAttendanceEntity(id: 'SA-001', staffId: 'STF-001', branchId: 'BR-001', date: '2026-08-13', status: 'Present', checkInTime: '07:55 AM', checkOutTime: '02:35 PM'),
    const StaffAttendanceEntity(id: 'SA-002', staffId: 'STF-002', branchId: 'BR-001', date: '2026-08-13', status: 'OnLeave'),
    const StaffAttendanceEntity(id: 'SA-003', staffId: 'STF-003', branchId: 'BR-002', date: '2026-08-13', status: 'Present', checkInTime: '08:10 AM', checkOutTime: '02:30 PM'),
  ]);

  void markAttendance({required String staffId, required String branchId, required String date, required String status, String checkIn = '', String checkOut = ''}) {
    state = [...state, StaffAttendanceEntity(id: 'SA-${DateTime.now().millisecondsSinceEpoch}', staffId: staffId, branchId: branchId, date: date, status: status, checkInTime: checkIn, checkOutTime: checkOut)];
  }
}

final staffAttendanceProvider = StateNotifierProvider<StaffAttendanceNotifier, List<StaffAttendanceEntity>>((ref) => StaffAttendanceNotifier());

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Staff Payroll Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffPayrollEntity {
  final String id;
  final String staffId;
  final String branchId;
  final String month; // e.g. 'August 2026'
  final double basicSalary;
  final double da;
  final double hra;
  final double ta;
  final double allowances;
  final double pfDeduction;
  final double esiDeduction;
  final double tdsDeduction;
  final double loanDeduction;
  final double netPay;
  final String status; // Pending, Processed, Paid

  const StaffPayrollEntity({
    required this.id, required this.staffId, required this.branchId,
    required this.month, required this.basicSalary,
    this.da = 0, this.hra = 0, this.ta = 0, this.allowances = 0,
    this.pfDeduction = 0, this.esiDeduction = 0, this.tdsDeduction = 0, this.loanDeduction = 0,
    required this.netPay, this.status = 'Pending',
  });

  StaffPayrollEntity copyWith({String? status}) => StaffPayrollEntity(
        id: id, staffId: staffId, branchId: branchId, month: month,
        basicSalary: basicSalary, da: da, hra: hra, ta: ta, allowances: allowances,
        pfDeduction: pfDeduction, esiDeduction: esiDeduction, tdsDeduction: tdsDeduction,
        loanDeduction: loanDeduction, netPay: netPay,
        status: status ?? this.status,
      );
}

class StaffPayrollNotifier extends StateNotifier<List<StaffPayrollEntity>> {
  StaffPayrollNotifier() : super([
    const StaffPayrollEntity(id: 'PAY-001', staffId: 'STF-001', branchId: 'BR-001', month: 'July 2026', basicSalary: 45000, da: 4500, hra: 9000, ta: 2000, allowances: 3000, pfDeduction: 5400, esiDeduction: 338, tdsDeduction: 2500, loanDeduction: 0, netPay: 55262, status: 'Paid'),
    const StaffPayrollEntity(id: 'PAY-002', staffId: 'STF-002', branchId: 'BR-001', month: 'July 2026', basicSalary: 35000, da: 3500, hra: 7000, ta: 1500, allowances: 2000, pfDeduction: 4200, esiDeduction: 263, tdsDeduction: 1500, loanDeduction: 5000, netPay: 38037, status: 'Paid'),
    const StaffPayrollEntity(id: 'PAY-003', staffId: 'STF-001', branchId: 'BR-001', month: 'August 2026', basicSalary: 45000, da: 4500, hra: 9000, ta: 2000, allowances: 3000, pfDeduction: 5400, esiDeduction: 338, tdsDeduction: 2500, loanDeduction: 0, netPay: 55262, status: 'Pending'),
  ]);

  void processPayroll({required String staffId, required String branchId, required String month, required double basicSalary, double da = 0, double hra = 0, double ta = 0, double allowances = 0, double pfDeduction = 0, double esiDeduction = 0, double tdsDeduction = 0, double loanDeduction = 0}) {
    final gross = basicSalary + da + hra + ta + allowances;
    final deductions = pfDeduction + esiDeduction + tdsDeduction + loanDeduction;
    state = [...state, StaffPayrollEntity(id: 'PAY-${DateTime.now().millisecondsSinceEpoch}', staffId: staffId, branchId: branchId, month: month, basicSalary: basicSalary, da: da, hra: hra, ta: ta, allowances: allowances, pfDeduction: pfDeduction, esiDeduction: esiDeduction, tdsDeduction: tdsDeduction, loanDeduction: loanDeduction, netPay: gross - deductions, status: 'Processed')];
  }

  void markPaid(String id) => state = state.map((p) => p.id == id ? p.copyWith(status: 'Paid') : p).toList();
}

final staffPayrollProvider = StateNotifierProvider<StaffPayrollNotifier, List<StaffPayrollEntity>>((ref) => StaffPayrollNotifier());

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Duty Roster Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class DutyRosterEntity {
  final String id;
  final String staffId;
  final String branchId;
  final String date;
  final String shift; // Morning, Evening, Full Day
  final String dutyType; // Teaching, Invigilation, Admin, Ground Duty

  const DutyRosterEntity({
    required this.id, required this.staffId, required this.branchId,
    required this.date, required this.shift, required this.dutyType,
  });
}

class DutyRosterNotifier extends StateNotifier<List<DutyRosterEntity>> {
  DutyRosterNotifier() : super([
    const DutyRosterEntity(id: 'DR-001', staffId: 'STF-001', branchId: 'BR-001', date: '2026-08-13', shift: 'Morning', dutyType: 'Teaching'),
    const DutyRosterEntity(id: 'DR-002', staffId: 'STF-002', branchId: 'BR-001', date: '2026-08-13', shift: 'Morning', dutyType: 'Teaching'),
    const DutyRosterEntity(id: 'DR-003', staffId: 'STF-001', branchId: 'BR-001', date: '2026-08-13', shift: 'Evening', dutyType: 'Ground Duty'),
  ]);

  void assignDuty({required String staffId, required String branchId, required String date, required String shift, required String dutyType}) {
    state = [...state, DutyRosterEntity(id: 'DR-${DateTime.now().millisecondsSinceEpoch}', staffId: staffId, branchId: branchId, date: date, shift: shift, dutyType: dutyType)];
  }
}

final dutyRosterProvider = StateNotifierProvider<DutyRosterNotifier, List<DutyRosterEntity>>((ref) => DutyRosterNotifier());

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Performance Review Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class PerformanceReviewEntity {
  final String id;
  final String staffId;
  final String branchId;
  final String reviewPeriod; // e.g. 'Q1 2026', 'Annual 2025-26'
  final int teachingScore; // 1-10
  final int disciplineScore;
  final int attendanceScore;
  final int parentFeedbackScore;
  final String remarks;
  final String reviewerName;

  const PerformanceReviewEntity({
    required this.id, required this.staffId, required this.branchId,
    required this.reviewPeriod,
    this.teachingScore = 8, this.disciplineScore = 9,
    this.attendanceScore = 7, this.parentFeedbackScore = 8,
    this.remarks = '', this.reviewerName = '',
  });
}

class PerformanceReviewNotifier extends StateNotifier<List<PerformanceReviewEntity>> {
  PerformanceReviewNotifier() : super([
    const PerformanceReviewEntity(id: 'PR-001', staffId: 'STF-001', branchId: 'BR-001', reviewPeriod: 'Annual 2025-26', teachingScore: 9, disciplineScore: 10, attendanceScore: 8, parentFeedbackScore: 9, remarks: 'Outstanding performance. Recommended for increment.', reviewerName: 'Dr. Principal'),
  ]);

  void addReview({required String staffId, required String branchId, required String reviewPeriod, required int teachingScore, required int disciplineScore, required int attendanceScore, required int parentFeedbackScore, required String remarks, required String reviewerName}) {
    state = [...state, PerformanceReviewEntity(id: 'PR-${DateTime.now().millisecondsSinceEpoch}', staffId: staffId, branchId: branchId, reviewPeriod: reviewPeriod, teachingScore: teachingScore, disciplineScore: disciplineScore, attendanceScore: attendanceScore, parentFeedbackScore: parentFeedbackScore, remarks: remarks, reviewerName: reviewerName)];
  }
}

final performanceReviewProvider = StateNotifierProvider<PerformanceReviewNotifier, List<PerformanceReviewEntity>>((ref) => PerformanceReviewNotifier());

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Staff Transfer Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffTransferEntity {
  final String id;
  final String staffId;
  final String fromBranchId;
  final String toBranchId;
  final String requestDate;
  final String reason;
  final String status; // Pending, Approved, Rejected, Completed

  const StaffTransferEntity({
    required this.id, required this.staffId, required this.fromBranchId,
    required this.toBranchId, required this.requestDate,
    required this.reason, this.status = 'Pending',
  });

  StaffTransferEntity copyWith({String? status}) => StaffTransferEntity(
    id: id, staffId: staffId, fromBranchId: fromBranchId,
    toBranchId: toBranchId, requestDate: requestDate,
    reason: reason, status: status ?? this.status,
  );
}

class StaffTransferNotifier extends StateNotifier<List<StaffTransferEntity>> {
  final Ref ref;
  StaffTransferNotifier(this.ref) : super([]);

  void requestTransfer({required String staffId, required String fromBranchId, required String toBranchId, required String reason}) {
    state = [...state, StaffTransferEntity(id: 'TRF-${DateTime.now().millisecondsSinceEpoch}', staffId: staffId, fromBranchId: fromBranchId, toBranchId: toBranchId, requestDate: DateTime.now().toString().substring(0, 10), reason: reason)];
  }

  void approveTransfer(String id) {
    state = state.map((t) {
      if (t.id == id) {
        final allStaff = ref.read(staffProvider);
        final staff = allStaff.firstWhere((s) => s.id == t.staffId);
        final newEmpId = 'EMP-${t.toBranchId.toUpperCase().substring(0, 3)}-${1000 + allStaff.length}';
        ref.read(staffProvider.notifier).updateStaffProfile(t.staffId, staff.copyWith(branchId: t.toBranchId, employeeId: newEmpId));
        return t.copyWith(status: 'Approved');
      }
      return t;
    }).toList();
  }

  void rejectTransfer(String id) => state = state.map((t) => t.id == id ? t.copyWith(status: 'Rejected') : t).toList();
}

final staffTransferProvider = StateNotifierProvider<StaffTransferNotifier, List<StaffTransferEntity>>((ref) {
  return StaffTransferNotifier(ref);
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Training & Workshop Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffTrainingEntity {
  final String id;
  final String branchId;
  final String title;
  final String date;
  final String trainer;
  final List<String> participantStaffIds;
  final String status; // Scheduled, Completed, Cancelled

  const StaffTrainingEntity({
    required this.id, required this.branchId, required this.title,
    required this.date, required this.trainer,
    this.participantStaffIds = const [], this.status = 'Scheduled',
  });
}

class StaffTrainingNotifier extends StateNotifier<List<StaffTrainingEntity>> {
  StaffTrainingNotifier() : super([
    const StaffTrainingEntity(id: 'TRN-001', branchId: 'BR-001', title: 'NEP 2020 Implementation Workshop', date: '2026-09-01', trainer: 'Dr. Rajendra Prasad (NCERT)', participantStaffIds: ['STF-001', 'STF-002'], status: 'Scheduled'),
    const StaffTrainingEntity(id: 'TRN-002', branchId: 'BR-001', title: 'Digital Classroom Tools Training', date: '2026-07-15', trainer: 'Google for Education', participantStaffIds: ['STF-001'], status: 'Completed'),
  ]);

  void addTraining({required String branchId, required String title, required String date, required String trainer, List<String> participants = const []}) {
    state = [...state, StaffTrainingEntity(id: 'TRN-${DateTime.now().millisecondsSinceEpoch}', branchId: branchId, title: title, date: date, trainer: trainer, participantStaffIds: participants)];
  }
}

final staffTrainingProvider = StateNotifierProvider<StaffTrainingNotifier, List<StaffTrainingEntity>>((ref) => StaffTrainingNotifier());


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Recruitment & Onboarding Candidate Model & State
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class RecruitmentCandidateEntity {
  final String id;
  final String branchId;
  final String name;
  final String designation;
  final String role;
  final String departmentId;
  final String email;
  final String phone;
  final String gender;
  final String dateOfBirth;
  final String qualification;
  final String specialization;
  final String institution;
  final int yearsOfExperience;
  final String previousEmployer;
  final String stage; // Applied, Interviewing, Offered, Onboarding, Hired
  final String interviewNotes;
  final double offeredSalary;
  final double onboardingProgress; // 0.0 to 1.0

  const RecruitmentCandidateEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.designation,
    required this.role,
    required this.departmentId,
    required this.email,
    required this.phone,
    this.gender = 'Male',
    this.dateOfBirth = '1995-01-01',
    this.qualification = 'B.Ed',
    this.specialization = 'English',
    this.institution = 'Delhi University',
    this.yearsOfExperience = 2,
    this.previousEmployer = 'St. Joseph School',
    this.stage = 'Applied',
    this.interviewNotes = '',
    this.offeredSalary = 25000,
    this.onboardingProgress = 0.0,
  });

  RecruitmentCandidateEntity copyWith({
    String? stage,
    String? interviewNotes,
    double? offeredSalary,
    double? onboardingProgress,
  }) {
    return RecruitmentCandidateEntity(
      id: id,
      branchId: branchId,
      name: name,
      designation: designation,
      role: role,
      departmentId: departmentId,
      email: email,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
      qualification: qualification,
      specialization: specialization,
      institution: institution,
      yearsOfExperience: yearsOfExperience,
      previousEmployer: previousEmployer,
      stage: stage ?? this.stage,
      interviewNotes: interviewNotes ?? this.interviewNotes,
      offeredSalary: offeredSalary ?? this.offeredSalary,
      onboardingProgress: onboardingProgress ?? this.onboardingProgress,
    );
  }
}

class RecruitmentNotifier extends StateNotifier<List<RecruitmentCandidateEntity>> {
  final Ref ref;
  RecruitmentNotifier(this.ref) : super(_defaultCandidates);

  void addCandidate({
    required String branchId,
    required String name,
    required String designation,
    required String role,
    required String departmentId,
    required String email,
    required String phone,
    required String qualification,
    required String specialization,
    required String institution,
    required int yearsOfExperience,
    required String previousEmployer,
  }) {
    state = [
      ...state,
      RecruitmentCandidateEntity(
        id: 'CAN-${DateTime.now().millisecondsSinceEpoch}',
        branchId: branchId,
        name: name,
        designation: designation,
        role: role,
        departmentId: departmentId,
        email: email,
        phone: phone,
        qualification: qualification,
        specialization: specialization,
        institution: institution,
        yearsOfExperience: yearsOfExperience,
        previousEmployer: previousEmployer,
      )
    ];
  }

  void advanceCandidateStage(String id, String newStage) {
    state = state.map((c) => c.id == id ? c.copyWith(stage: newStage) : c).toList();
  }

  void updateOnboardingProgress(String id, double progress) {
    state = state.map((c) => c.id == id ? c.copyWith(onboardingProgress: progress) : c).toList();
  }

  void updateInterviewNotes(String id, String notes) {
    state = state.map((c) => c.id == id ? c.copyWith(interviewNotes: notes) : c).toList();
  }

  void hireCandidate(String id) {
    final candidate = state.firstWhere((c) => c.id == id);
    ref.read(staffProvider.notifier).registerStaff(
      branchId: candidate.branchId,
      name: candidate.name,
      designation: candidate.designation,
      role: candidate.role,
      dateOfJoining: DateTime.now().toString().substring(0, 10),
      gender: candidate.gender,
      dateOfBirth: candidate.dateOfBirth,
      bloodGroup: 'O+',
      phone: candidate.phone,
      email: candidate.email,
      address: 'Onboarded Candidate Address',
      qualification: candidate.qualification,
      specialization: candidate.specialization,
      institution: candidate.institution,
      yearsOfExperience: candidate.yearsOfExperience,
      previousEmployer: candidate.previousEmployer,
      departmentId: candidate.departmentId,
    );
    state = state.map((c) => c.id == id ? c.copyWith(stage: 'Hired', onboardingProgress: 1.0) : c).toList();
  }
}

final recruitmentProvider = StateNotifierProvider<RecruitmentNotifier, List<RecruitmentCandidateEntity>>((ref) {
  return RecruitmentNotifier(ref);
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Staff Resignation & Offboarding Model & State
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffOffboardingEntity {
  final String id;
  final String staffId;
  final String branchId;
  final String resignationDate;
  final String lastWorkingDay;
  final String reason;
  final String exitFeedback;
  final bool clearanceIt;
  final bool clearanceLibrary;
  final bool clearanceAccounts;
  final bool clearanceHr;
  final double settlementAmount;
  final String status; // Pending, ClearanceInProgress, Settled

  const StaffOffboardingEntity({
    required this.id,
    required this.staffId,
    required this.branchId,
    required this.resignationDate,
    required this.lastWorkingDay,
    required this.reason,
    this.exitFeedback = '',
    this.clearanceIt = false,
    this.clearanceLibrary = false,
    this.clearanceAccounts = false,
    this.clearanceHr = false,
    this.settlementAmount = 0,
    this.status = 'Pending',
  });

  StaffOffboardingEntity copyWith({
    String? exitFeedback,
    bool? clearanceIt,
    bool? clearanceLibrary,
    bool? clearanceAccounts,
    bool? clearanceHr,
    double? settlementAmount,
    String? status,
  }) {
    return StaffOffboardingEntity(
      id: id,
      staffId: staffId,
      branchId: branchId,
      resignationDate: resignationDate,
      lastWorkingDay: lastWorkingDay,
      reason: reason,
      exitFeedback: exitFeedback ?? this.exitFeedback,
      clearanceIt: clearanceIt ?? this.clearanceIt,
      clearanceLibrary: clearanceLibrary ?? this.clearanceLibrary,
      clearanceAccounts: clearanceAccounts ?? this.clearanceAccounts,
      clearanceHr: clearanceHr ?? this.clearanceHr,
      settlementAmount: settlementAmount ?? this.settlementAmount,
      status: status ?? this.status,
    );
  }
}

class StaffOffboardingNotifier extends StateNotifier<List<StaffOffboardingEntity>> {
  final Ref ref;
  StaffOffboardingNotifier(this.ref) : super(_defaultOffboardings);

  void submitResignation({
    required String staffId,
    required String branchId,
    required String resignationDate,
    required String lastWorkingDay,
    required String reason,
  }) {
    state = [
      ...state,
      StaffOffboardingEntity(
        id: 'OFF-${DateTime.now().millisecondsSinceEpoch}',
        staffId: staffId,
        branchId: branchId,
        resignationDate: resignationDate,
        lastWorkingDay: lastWorkingDay,
        reason: reason,
      )
    ];
  }

  void updateClearances(String id, {bool? it, bool? lib, bool? acc, bool? hr}) {
    state = state.map((o) {
      if (o.id == id) {
        return o.copyWith(
          clearanceIt: it ?? o.clearanceIt,
          clearanceLibrary: lib ?? o.clearanceLibrary,
          clearanceAccounts: acc ?? o.clearanceAccounts,
          clearanceHr: hr ?? o.clearanceHr,
          status: 'ClearanceInProgress',
        );
      }
      return o;
    }).toList();
  }

  void completeExitInterview(String id, String feedback) {
    state = state.map((o) => o.id == id ? o.copyWith(exitFeedback: feedback) : o).toList();
  }

  void settleOffboarding(String id, double settlementAmount) {
    final off = state.firstWhere((o) => o.id == id);
    state = state.map((o) => o.id == id ? o.copyWith(settlementAmount: settlementAmount, status: 'Settled') : o).toList();
    ref.read(staffProvider.notifier).setStaffStatus(off.staffId, 'Inactive', false);
  }
}

final staffOffboardingProvider = StateNotifierProvider<StaffOffboardingNotifier, List<StaffOffboardingEntity>>((ref) {
  return StaffOffboardingNotifier(ref);
});

final List<RecruitmentCandidateEntity> _defaultCandidates = [
  const RecruitmentCandidateEntity(
    id: 'CAN-001',
    branchId: 'BR-001',
    name: 'Amit Patel',
    designation: 'Math Teacher',
    role: 'Teacher',
    departmentId: 'DEPT-001',
    email: 'amit.patel@gmail.com',
    phone: '+91 95000 11223',
    gender: 'Male',
    dateOfBirth: '1993-04-10',
    qualification: 'B.Sc Math, B.Ed',
    specialization: 'Algebra',
    institution: 'Delhi University',
    yearsOfExperience: 4,
    previousEmployer: 'Greenfield School',
    stage: 'Interviewing',
    interviewNotes: 'Good subject command. Communication is clear.',
    offeredSalary: 28000,
    onboardingProgress: 0.0,
  ),
  const RecruitmentCandidateEntity(
    id: 'CAN-002',
    branchId: 'BR-001',
    name: 'Pooja Hegde',
    designation: 'English Teacher',
    role: 'Teacher',
    departmentId: 'DEPT-001',
    email: 'pooja.h@yahoo.com',
    phone: '+91 96000 22334',
    gender: 'Female',
    dateOfBirth: '1995-08-15',
    qualification: 'M.A. English, B.Ed',
    specialization: 'Grammar',
    institution: 'Mumbai University',
    yearsOfExperience: 3,
    previousEmployer: 'Bright Minds Academy',
    stage: 'Onboarding',
    interviewNotes: 'Excellent vocabulary. Highly interactive teaching style.',
    offeredSalary: 30000,
    onboardingProgress: 0.6,
  ),
];

final List<StaffOffboardingEntity> _defaultOffboardings = [
  const StaffOffboardingEntity(
    id: 'OFF-001',
    staffId: 'STF-002',
    branchId: 'BR-001',
    resignationDate: '2026-08-01',
    lastWorkingDay: '2026-08-31',
    reason: 'Relocating to another city due to family reasons.',
    exitFeedback: 'Enjoyed my time here. School has a great teaching environment.',
    clearanceIt: true,
    clearanceLibrary: false,
    clearanceAccounts: true,
    clearanceHr: false,
    settlementAmount: 35000,
    status: 'ClearanceInProgress',
  ),
];


/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Mock Initial Staff List
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
final List<StaffEntity> _defaultStaff = [
  const StaffEntity(
    id: 'STF-001',
    branchId: 'BR-001',
    employeeId: 'EMP-DEL-1001',
    name: 'Vikram Malhotra',
    designation: 'Senior Math HOD',
    role: 'HOD',
    dateOfJoining: '2022-04-15',
    gender: 'Male',
    dateOfBirth: '1984-05-12',
    bloodGroup: 'B+',
    phone: '+91 98100 12345',
    email: 'vikram.m@school.com',
    address: 'A-22, Shalimar Bagh, Delhi',
    qualification: 'M.Sc. Mathematics, B.Ed',
    specialization: 'Algebra & Calculus',
    institution: 'Delhi University',
    yearsOfExperience: 12,
    previousEmployer: 'Delhi Public School',
    sharedBranchIds: ['BR-002'], // Shared with Mumbai Branch
    rfidCardNumber: 'RFID-110A-STF1',
  ),
  const StaffEntity(
    id: 'STF-002',
    branchId: 'BR-001',
    employeeId: 'EMP-DEL-1002',
    name: 'Sunita Sharma',
    designation: 'Secondary English Teacher',
    role: 'Teacher',
    dateOfJoining: '2023-06-01',
    gender: 'Female',
    dateOfBirth: '1990-11-20',
    bloodGroup: 'O+',
    phone: '+91 99100 54321',
    email: 'sunita.s@school.com',
    address: 'Flat 4B, Sector 15, Rohini, Delhi',
    qualification: 'M.A. English literature, M.Ed',
    specialization: 'British Literature',
    institution: 'IGNOU',
    yearsOfExperience: 8,
    previousEmployer: 'Dav Public School',
    sharedBranchIds: [],
    rfidCardNumber: '',
  ),
  const StaffEntity(
    id: 'STF-003',
    branchId: 'BR-002',
    employeeId: 'EMP-MUM-1003',
    name: 'Rahul Deshmukh',
    designation: 'Primary School Principal',
    role: 'branchAdmin',
    dateOfJoining: '2021-08-01',
    gender: 'Male',
    dateOfBirth: '1978-04-02',
    bloodGroup: 'A+',
    phone: '+91 98200 98765',
    email: 'rahul.d@school.com',
    address: '1502 Sea Breeze Apartments, Bandra, Mumbai',
    qualification: 'M.A. Education Administration, Ph.D',
    specialization: 'School Governance',
    institution: 'Bombay University',
    yearsOfExperience: 18,
    previousEmployer: 'St. Mary High School',
    sharedBranchIds: [],
    rfidCardNumber: 'RFID-902B-STF3',
  ),
];

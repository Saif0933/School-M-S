import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Admission Application Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AdmissionApplicationEntity {
  final String id;
  final String branchId;
  final String classId;
  final String className;
  final String studentName;
  final String guardianName;
  final String phone;
  final String email;
  final String address;
  final String reservationCategory; // 'General', 'OBC', 'SC', 'ST'
  final String leadSource; // 'Social Media', 'Website', 'Referral', 'Newspaper Advert'
  final String assignedCounselor; // 'Amit Mishra', 'Pooja Nair', 'Siddharth Sen'
  final double applicationFeePaid;
  final String status; // 'Inquiry', 'Application Submitted', 'Test Scheduled', 'Test Completed', 'Interview Scheduled', 'Verification Pending', 'Approved', 'Rejected', 'Waitlisted'
  final int entranceTestScore; // out of 100
  final String interviewSlot; // date/time
  final bool documentsVerified;
  final List<String> uploadedDocs;
  final String? enrollmentNumber; // generated upon approval
  final String createdAt;

  const AdmissionApplicationEntity({
    required this.id,
    required this.branchId,
    required this.classId,
    required this.className,
    required this.studentName,
    required this.guardianName,
    required this.phone,
    required this.email,
    required this.address,
    this.reservationCategory = 'General',
    this.leadSource = 'Website',
    this.assignedCounselor = 'Unassigned',
    this.applicationFeePaid = 0.0,
    required this.status,
    this.entranceTestScore = -1,
    this.interviewSlot = '',
    this.documentsVerified = false,
    this.uploadedDocs = const [],
    this.enrollmentNumber,
    required this.createdAt,
  });

  AdmissionApplicationEntity copyWith({
    String? status,
    int? entranceTestScore,
    String? interviewSlot,
    bool? documentsVerified,
    List<String>? uploadedDocs,
    String? enrollmentNumber,
    String? assignedCounselor,
    double? applicationFeePaid,
  }) {
    return AdmissionApplicationEntity(
      id: id,
      branchId: branchId,
      classId: classId,
      className: className,
      studentName: studentName,
      guardianName: guardianName,
      phone: phone,
      email: email,
      address: address,
      reservationCategory: reservationCategory,
      leadSource: leadSource,
      assignedCounselor: assignedCounselor ?? this.assignedCounselor,
      applicationFeePaid: applicationFeePaid ?? this.applicationFeePaid,
      status: status ?? this.status,
      entranceTestScore: entranceTestScore ?? this.entranceTestScore,
      interviewSlot: interviewSlot ?? this.interviewSlot,
      documentsVerified: documentsVerified ?? this.documentsVerified,
      uploadedDocs: uploadedDocs ?? this.uploadedDocs,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      createdAt: createdAt,
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Mock Admissions Database
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AdmissionsNotifier extends StateNotifier<List<AdmissionApplicationEntity>> {
  AdmissionsNotifier() : super([
    // Delhi Campus BR-001 Applications
    const AdmissionApplicationEntity(
      id: 'APP-DEL-2026-101',
      branchId: 'BR-001',
      classId: 'CLS-001',
      className: 'Class 1 Delhi',
      studentName: 'Rohan Deshmukh',
      guardianName: 'Vikas Deshmukh',
      phone: '+91 99911 22233',
      email: 'rohan.d@gmail.com',
      address: 'Dwarka Sector 6, New Delhi',
      reservationCategory: 'General',
      leadSource: 'Website',
      assignedCounselor: 'Pooja Nair',
      applicationFeePaid: 500.0,
      status: 'Test Scheduled',
      entranceTestScore: -1,
      createdAt: '2026-08-01',
    ),
    const AdmissionApplicationEntity(
      id: 'APP-DEL-2026-102',
      branchId: 'BR-001',
      classId: 'CLS-001',
      className: 'Class 1 Delhi',
      studentName: 'Megha Gupta',
      guardianName: 'Anoop Gupta',
      phone: '+91 88822 33344',
      email: 'megha.g@gmail.com',
      address: 'Janakpuri Area, Delhi',
      reservationCategory: 'OBC',
      leadSource: 'Referral',
      assignedCounselor: 'Amit Mishra',
      applicationFeePaid: 500.0,
      status: 'Approved',
      entranceTestScore: 88,
      documentsVerified: true,
      enrollmentNumber: 'ENR-SIS-DEL-2026-102',
      createdAt: '2026-08-03',
    ),
    // Mumbai Campus BR-002 Applications
    const AdmissionApplicationEntity(
      id: 'APP-MUM-2026-201',
      branchId: 'BR-002',
      classId: 'CLS-010',
      className: 'Class 10 Mumbai',
      studentName: 'Aditya Birla',
      guardianName: 'Sanjay Birla',
      phone: '+91 77733 44455',
      email: 'aditya.b@gmail.com',
      address: 'Worli Sea Face, Mumbai',
      reservationCategory: 'General',
      leadSource: 'Social Media',
      assignedCounselor: 'Siddharth Sen',
      applicationFeePaid: 600.0,
      status: 'Interview Scheduled',
      entranceTestScore: 94,
      interviewSlot: 'Thursday, 11:30 AM',
      createdAt: '2026-08-05',
    ),
    const AdmissionApplicationEntity(
      id: 'APP-MUM-2026-202',
      branchId: 'BR-002',
      classId: 'CLS-010',
      className: 'Class 10 Mumbai',
      studentName: 'Kriti Deshmukh',
      guardianName: 'Prakash Deshmukh',
      phone: '+91 99933 11100',
      email: 'kriti.desh@outlook.com',
      address: 'Thane Highway, Mumbai',
      reservationCategory: 'SC',
      leadSource: 'Newspaper Advert',
      assignedCounselor: 'Siddharth Sen',
      applicationFeePaid: 0.0, // unpaid inquiry
      status: 'Inquiry',
      createdAt: '2026-08-10',
    ),
  ]);

  void addApplication(AdmissionApplicationEntity app) {
    state = [...state, app];
  }

  void updateApplicationStatus(String appID, String status) {
    state = state.map((a) => a.id == appID ? a.copyWith(status: status) : a).toList();
  }

  void updateApplicationScore(String appID, int score) {
    state = state.map((a) => a.id == appID ? a.copyWith(entranceTestScore: score, status: 'Test Completed') : a).toList();
  }

  void updateVerification(String appID, bool status) {
    state = state.map((a) => a.id == appID ? a.copyWith(documentsVerified: status) : a).toList();
  }

  void updateCounselor(String appID, String counselor) {
    state = state.map((a) => a.id == appID ? a.copyWith(assignedCounselor: counselor) : a).toList();
  }

  void approveAdmission(String appID, String enrollmentNo) {
    state = state.map((a) => a.id == appID ? a.copyWith(status: 'Approved', enrollmentNumber: enrollmentNo, documentsVerified: true) : a).toList();
  }
}

final admissionsProvider = StateNotifierProvider<AdmissionsNotifier, List<AdmissionApplicationEntity>>((ref) {
  return AdmissionsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Seat Capacity & Category Reservation Configuration
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SeatAvailabilityEntity {
  final String branchId;
  final String classId;
  final String className;
  final int totalSeats;
  final int generalQuota;
  final int obcQuota;
  final int scStQuota;
  final int filledGeneral;
  final int filledObc;
  final int filledScSt;

  const SeatAvailabilityEntity({
    required this.branchId,
    required this.classId,
    required this.className,
    required this.totalSeats,
    required this.generalQuota,
    required this.obcQuota,
    required this.scStQuota,
    this.filledGeneral = 0,
    this.filledObc = 0,
    this.filledScSt = 0,
  });

  int get filledTotal => filledGeneral + filledObc + filledScSt;
  int get availableTotal => totalSeats - filledTotal;

  SeatAvailabilityEntity incrementFilled(String category) {
    if (category == 'General') {
      return SeatAvailabilityEntity(
        branchId: branchId,
        classId: classId,
        className: className,
        totalSeats: totalSeats,
        generalQuota: generalQuota,
        obcQuota: obcQuota,
        scStQuota: scStQuota,
        filledGeneral: filledGeneral + 1,
        filledObc: filledObc,
        filledScSt: filledScSt,
      );
    } else if (category == 'OBC') {
      return SeatAvailabilityEntity(
        branchId: branchId,
        classId: classId,
        className: className,
        totalSeats: totalSeats,
        generalQuota: generalQuota,
        obcQuota: obcQuota,
        scStQuota: scStQuota,
        filledGeneral: filledGeneral,
        filledObc: filledObc + 1,
        filledScSt: filledScSt,
      );
    } else {
      return SeatAvailabilityEntity(
        branchId: branchId,
        classId: classId,
        className: className,
        totalSeats: totalSeats,
        generalQuota: generalQuota,
        obcQuota: obcQuota,
        scStQuota: scStQuota,
        filledGeneral: filledGeneral,
        filledObc: filledObc,
        filledScSt: filledScSt + 1,
      );
    }
  }
}

class SeatCapacityNotifier extends StateNotifier<List<SeatAvailabilityEntity>> {
  SeatCapacityNotifier() : super([
    // Delhi BR-001 Quotas
    const SeatAvailabilityEntity(
      branchId: 'BR-001',
      classId: 'CLS-001',
      className: 'Class 1 Delhi',
      totalSeats: 40,
      generalQuota: 20,
      obcQuota: 10,
      scStQuota: 10,
      filledGeneral: 12,
      filledObc: 6,
      filledScSt: 4,
    ),
    // Mumbai BR-002 Quotas
    const SeatAvailabilityEntity(
      branchId: 'BR-002',
      classId: 'CLS-010',
      className: 'Class 10 Mumbai',
      totalSeats: 35,
      generalQuota: 18,
      obcQuota: 9,
      scStQuota: 8,
      filledGeneral: 15,
      filledObc: 8,
      filledScSt: 6,
    ),
  ]);

  void allocateSeat(String branchId, String classId, String category) {
    state = state.map((s) {
      if (s.branchId == branchId && s.classId == classId) {
        return s.incrementFilled(category);
      }
      return s;
    }).toList();
  }
}

final seatCapacityProvider = StateNotifierProvider<SeatCapacityNotifier, List<SeatAvailabilityEntity>>((ref) {
  return SeatCapacityNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Entrance Exam MCQs
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AdmissionsExamQuestion {
  final String question;
  final List<String> choices;
  final String correctChoice;

  const AdmissionsExamQuestion({
    required this.question,
    required this.choices,
    required this.correctChoice,
  });
}

final admissionsEntranceExamQuestions = Provider<List<AdmissionsExamQuestion>>((ref) {
  return const [
    AdmissionsExamQuestion(
      question: 'Which of the following is the capital city of India?',
      choices: ['Mumbai', 'New Delhi', 'Kolkata', 'Bangalore'],
      correctChoice: 'New Delhi',
    ),
    AdmissionsExamQuestion(
      question: 'What is the chemical symbol for Water?',
      choices: ['CO2', 'O2', 'H2O', 'NaCl'],
      correctChoice: 'H2O',
    ),
    AdmissionsExamQuestion(
      question: 'Solve: 15 x 6 + 10 = ?',
      choices: ['90', '100', '110', '120'],
      correctChoice: '100',
    ),
  ];
});

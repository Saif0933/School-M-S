import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Models for Academic Structure (Branch-Scoped)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DepartmentEntity {
  final String id;
  final String branchId;
  final String name;
  final String code;
  final String headOfDepartment;
  final String description;

  const DepartmentEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.code,
    required this.headOfDepartment,
    required this.description,
  });

  DepartmentEntity copyWith({
    String? id,
    String? branchId,
    String? name,
    String? code,
    String? headOfDepartment,
    String? description,
  }) {
    return DepartmentEntity(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      code: code ?? this.code,
      headOfDepartment: headOfDepartment ?? this.headOfDepartment,
      description: description ?? this.description,
    );
  }
}

class ClassEntity {
  final String id;
  final String branchId;
  final String departmentId;
  final String name;
  final String code;
  final int maxStudentsCapacity;
  final String reportCardTemplate;
  final bool isActive;

  const ClassEntity({
    required this.id,
    required this.branchId,
    required this.departmentId,
    required this.name,
    required this.code,
    required this.maxStudentsCapacity,
    this.reportCardTemplate = 'CBSE Standard 9-Point Template',
    this.isActive = true,
  });

  ClassEntity copyWith({
    String? id,
    String? branchId,
    String? departmentId,
    String? name,
    String? code,
    int? maxStudentsCapacity,
    String? reportCardTemplate,
    bool? isActive,
  }) {
    return ClassEntity(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      departmentId: departmentId ?? this.departmentId,
      name: name ?? this.name,
      code: code ?? this.code,
      maxStudentsCapacity: maxStudentsCapacity ?? this.maxStudentsCapacity,
      reportCardTemplate: reportCardTemplate ?? this.reportCardTemplate,
      isActive: isActive ?? this.isActive,
    );
  }
}

class SectionEntity {
  final String id;
  final String classId;
  final String name;
  final String roomNumber;
  final String classTeacher;
  final int maxStudentsCapacity;
  final bool isActive;

  const SectionEntity({
    required this.id,
    required this.classId,
    required this.name,
    required this.roomNumber,
    required this.classTeacher,
    required this.maxStudentsCapacity,
    this.isActive = true,
  });

  SectionEntity copyWith({
    String? id,
    String? classId,
    String? name,
    String? roomNumber,
    String? classTeacher,
    int? maxStudentsCapacity,
    bool? isActive,
  }) {
    return SectionEntity(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      name: name ?? this.name,
      roomNumber: roomNumber ?? this.roomNumber,
      classTeacher: classTeacher ?? this.classTeacher,
      maxStudentsCapacity: maxStudentsCapacity ?? this.maxStudentsCapacity,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Default Mock Data for Branch-Scoped Academic Structure
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final List<DepartmentEntity> _defaultDepartments = [
  // Delhi Branch (BR-001)
  const DepartmentEntity(
    id: 'DEP-001',
    branchId: 'BR-001',
    name: 'Primary Department',
    code: 'PRI-DEL',
    headOfDepartment: 'Mrs. Rupa Ganguly',
    description: 'Classes Grade 1 to Grade 5',
  ),
  const DepartmentEntity(
    id: 'DEP-002',
    branchId: 'BR-001',
    name: 'Secondary Department',
    code: 'SEC-DEL',
    headOfDepartment: 'Mr. Alok Nath',
    description: 'Classes Grade 6 to Grade 10',
  ),
  const DepartmentEntity(
    id: 'DEP-003',
    branchId: 'BR-001',
    name: 'Senior Secondary Department',
    code: 'SRSEC-DEL',
    headOfDepartment: 'Dr. Suresh Oberoi',
    description: 'Classes Grade 11 to Grade 12',
  ),

  // Mumbai Branch (BR-002)
  const DepartmentEntity(
    id: 'DEP-004',
    branchId: 'BR-002',
    name: 'Junior School Department',
    code: 'JUN-MUM',
    headOfDepartment: 'Mrs. Smita Patil',
    description: 'Classes Nursery to Class 4',
  ),
  const DepartmentEntity(
    id: 'DEP-005',
    branchId: 'BR-002',
    name: 'Middle School Department',
    code: 'MID-MUM',
    headOfDepartment: 'Mr. Naseeruddin Shah',
    description: 'Classes Class 5 to Class 8',
  ),
  const DepartmentEntity(
    id: 'DEP-006',
    branchId: 'BR-002',
    name: 'High School Department',
    code: 'HIGH-MUM',
    headOfDepartment: 'Mrs. Shabana Azmi',
    description: 'Classes Class 9 to Class 12',
  ),
];

final List<ClassEntity> _defaultClasses = [
  // Delhi Classes
  const ClassEntity(
    id: 'CLS-001',
    branchId: 'BR-001',
    departmentId: 'DEP-001',
    name: 'Class 1',
    code: 'C01',
    maxStudentsCapacity: 120,
  ),
  const ClassEntity(
    id: 'CLS-002',
    branchId: 'BR-001',
    departmentId: 'DEP-001',
    name: 'Class 2',
    code: 'C02',
    maxStudentsCapacity: 120,
  ),
  const ClassEntity(
    id: 'CLS-003',
    branchId: 'BR-001',
    departmentId: 'DEP-001',
    name: 'Class 3',
    code: 'C03',
    maxStudentsCapacity: 120,
  ),
  const ClassEntity(
    id: 'CLS-004',
    branchId: 'BR-001',
    departmentId: 'DEP-002',
    name: 'Class 9',
    code: 'C09',
    maxStudentsCapacity: 160,
  ),
  const ClassEntity(
    id: 'CLS-005',
    branchId: 'BR-001',
    departmentId: 'DEP-002',
    name: 'Class 10',
    code: 'C10',
    maxStudentsCapacity: 160,
  ),
  const ClassEntity(
    id: 'CLS-006',
    branchId: 'BR-001',
    departmentId: 'DEP-003',
    name: 'Class 11',
    code: 'C11',
    maxStudentsCapacity: 180,
  ),
  const ClassEntity(
    id: 'CLS-007',
    branchId: 'BR-001',
    departmentId: 'DEP-003',
    name: 'Class 12',
    code: 'C12',
    maxStudentsCapacity: 180,
  ),

  // Mumbai Classes
  const ClassEntity(
    id: 'CLS-008',
    branchId: 'BR-002',
    departmentId: 'DEP-004',
    name: 'Class 1',
    code: 'C01',
    maxStudentsCapacity: 100,
  ),
  const ClassEntity(
    id: 'CLS-009',
    branchId: 'BR-002',
    departmentId: 'DEP-005',
    name: 'Class 6',
    code: 'C06',
    maxStudentsCapacity: 100,
  ),
  const ClassEntity(
    id: 'CLS-010',
    branchId: 'BR-002',
    departmentId: 'DEP-006',
    name: 'Class 10',
    code: 'C10',
    maxStudentsCapacity: 120,
  ),
];

final List<SectionEntity> _defaultSections = [
  // Class 1 Delhi Sections
  const SectionEntity(
    id: 'SEC-A-001',
    classId: 'CLS-001',
    name: 'A',
    roomNumber: 'R101',
    classTeacher: 'Ms. Pooja Sharma',
    maxStudentsCapacity: 40,
  ),
  const SectionEntity(
    id: 'SEC-B-001',
    classId: 'CLS-001',
    name: 'B',
    roomNumber: 'R102',
    classTeacher: 'Ms. Neha Gupta',
    maxStudentsCapacity: 40,
  ),

  // Class 10 Delhi Sections
  const SectionEntity(
    id: 'SEC-A-002',
    classId: 'CLS-005',
    name: 'A',
    roomNumber: 'R301',
    classTeacher: 'Mr. Harish Sen',
    maxStudentsCapacity: 40,
  ),
  const SectionEntity(
    id: 'SEC-B-002',
    classId: 'CLS-005',
    name: 'B',
    roomNumber: 'R302',
    classTeacher: 'Mrs. Geeta Patel',
    maxStudentsCapacity: 40,
  ),
  const SectionEntity(
    id: 'SEC-C-002',
    classId: 'CLS-005',
    name: 'C',
    roomNumber: 'R303',
    classTeacher: 'Mr. Devendra Singh',
    maxStudentsCapacity: 40,
  ),
];

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Notifiers & Providers
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AcademicDepartmentsNotifier
    extends StateNotifier<List<DepartmentEntity>> {
  AcademicDepartmentsNotifier() : super(_defaultDepartments);

  void addDepartment({
    required String branchId,
    required String name,
    required String code,
    required String headOfDepartment,
    required String description,
  }) {
    final newDept = DepartmentEntity(
      id: 'DEP-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      name: name,
      code: code,
      headOfDepartment: headOfDepartment,
      description: description,
    );
    state = [...state, newDept];
  }

  void removeDepartment(String id) {
    state = state.where((dept) => dept.id != id).toList();
  }
}

final academicDepartmentsProvider =
    StateNotifierProvider<AcademicDepartmentsNotifier, List<DepartmentEntity>>((
      ref,
    ) {
      return AcademicDepartmentsNotifier();
    });

class AcademicClassesNotifier extends StateNotifier<List<ClassEntity>> {
  AcademicClassesNotifier() : super(_defaultClasses);

  void addClass({
    required String branchId,
    required String departmentId,
    required String name,
    required String code,
    required int maxStudentsCapacity,
    String reportCardTemplate = 'CBSE Standard 9-Point Template',
  }) {
    final newClass = ClassEntity(
      id: 'CLS-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      departmentId: departmentId,
      name: name,
      code: code,
      maxStudentsCapacity: maxStudentsCapacity,
      reportCardTemplate: reportCardTemplate,
    );
    state = [...state, newClass];
  }

  void toggleClassStatus(String id) {
    state = state
        .map((c) => c.id == id ? c.copyWith(isActive: !c.isActive) : c)
        .toList();
  }

  void updateClassTemplate(String id, String template) {
    state = state
        .map((c) => c.id == id ? c.copyWith(reportCardTemplate: template) : c)
        .toList();
  }

  void removeClass(String id) {
    state = state.where((cls) => cls.id != id).toList();
  }
}

final academicClassesProvider =
    StateNotifierProvider<AcademicClassesNotifier, List<ClassEntity>>((ref) {
      return AcademicClassesNotifier();
    });

class AcademicSectionsNotifier extends StateNotifier<List<SectionEntity>> {
  AcademicSectionsNotifier() : super(_defaultSections);

  void addSection({
    required String classId,
    required String name,
    required String roomNumber,
    required String classTeacher,
    required int maxStudentsCapacity,
  }) {
    final newSection = SectionEntity(
      id: 'SEC-${DateTime.now().millisecondsSinceEpoch}',
      classId: classId,
      name: name,
      roomNumber: roomNumber,
      classTeacher: classTeacher,
      maxStudentsCapacity: maxStudentsCapacity,
    );
    state = [...state, newSection];
  }

  void toggleSectionStatus(String id) {
    state = state
        .map((s) => s.id == id ? s.copyWith(isActive: !s.isActive) : s)
        .toList();
  }

  void updateClassTeacher(String id, String teacherName) {
    state = state
        .map((s) => s.id == id ? s.copyWith(classTeacher: teacherName) : s)
        .toList();
  }

  void removeSection(String id) {
    state = state.where((sec) => sec.id != id).toList();
  }
}

final academicSectionsProvider =
    StateNotifierProvider<AcademicSectionsNotifier, List<SectionEntity>>((ref) {
      return AcademicSectionsNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Stream Configuration Model (e.g. Science, Commerce, Arts)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StreamEntity {
  final String id;
  final String branchId;
  final String name;

  const StreamEntity({
    required this.id,
    required this.branchId,
    required this.name,
  });
}

final List<StreamEntity> _defaultStreams = [
  const StreamEntity(id: 'STR-001', branchId: 'BR-001', name: 'Science Stream'),
  const StreamEntity(
    id: 'STR-002',
    branchId: 'BR-001',
    name: 'Commerce Stream',
  ),
  const StreamEntity(
    id: 'STR-003',
    branchId: 'BR-001',
    name: 'Humanities/Arts Stream',
  ),
];

class AcademicStreamsNotifier extends StateNotifier<List<StreamEntity>> {
  AcademicStreamsNotifier() : super(_defaultStreams);

  void addStream(String branchId, String name) {
    final newStream = StreamEntity(
      id: 'STR-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      name: name,
    );
    state = [...state, newStream];
  }

  void removeStream(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final academicStreamsProvider =
    StateNotifierProvider<AcademicStreamsNotifier, List<StreamEntity>>((ref) {
      return AcademicStreamsNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Batch / Academic Year Management Model (e.g. 2026-2027)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BatchEntity {
  final String id;
  final String branchId;
  final String name; // e.g. '2026 - 2027'
  final bool isActive;

  const BatchEntity({
    required this.id,
    required this.branchId,
    required this.name,
    this.isActive = true,
  });

  BatchEntity copyWith({bool? isActive}) {
    return BatchEntity(
      id: id,
      branchId: branchId,
      name: name,
      isActive: isActive ?? this.isActive,
    );
  }
}

final List<BatchEntity> _defaultBatches = [
  const BatchEntity(
    id: 'BAT-001',
    branchId: 'BR-001',
    name: 'Batch 2025 - 2026',
    isActive: false,
  ),
  const BatchEntity(
    id: 'BAT-002',
    branchId: 'BR-001',
    name: 'Batch 2026 - 2027',
    isActive: true,
  ),
];

class AcademicBatchesNotifier extends StateNotifier<List<BatchEntity>> {
  AcademicBatchesNotifier() : super(_defaultBatches);

  void addBatch(String branchId, String name) {
    final newBatch = BatchEntity(
      id: 'BAT-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      name: name,
    );
    state = [...state, newBatch];
  }

  void toggleBatch(String id) {
    state = [
      for (final b in state)
        if (b.id == id) b.copyWith(isActive: !b.isActive) else b,
    ];
  }

  void removeBatch(String id) {
    state = state.where((b) => b.id != id).toList();
  }
}

final academicBatchesProvider =
    StateNotifierProvider<AcademicBatchesNotifier, List<BatchEntity>>((ref) {
      return AcademicBatchesNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Elective Subject Group Configuration Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ElectiveGroupEntity {
  final String id;
  final String branchId;
  final String name; // e.g. 'Elective Group A'
  final List<String> subjects;

  const ElectiveGroupEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.subjects,
  });
}

final List<ElectiveGroupEntity> _defaultElectiveGroups = [
  const ElectiveGroupEntity(
    id: 'ELG-001',
    branchId: 'BR-001',
    name: 'Elective Group A (Class XI/XII)',
    subjects: [
      'Computer Science',
      'Informatics Practices',
      'Hindi Elective',
      'Physical Education',
    ],
  ),
  const ElectiveGroupEntity(
    id: 'ELG-002',
    branchId: 'BR-001',
    name: 'Elective Group B (Class XI/XII)',
    subjects: ['Economics', 'Psychology', 'Fine Arts', 'Mathematics'],
  ),
];

class AcademicElectivesNotifier
    extends StateNotifier<List<ElectiveGroupEntity>> {
  AcademicElectivesNotifier() : super(_defaultElectiveGroups);

  void addElectiveGroup(String branchId, String name, List<String> subjects) {
    final newGrp = ElectiveGroupEntity(
      id: 'ELG-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      name: name,
      subjects: subjects,
    );
    state = [...state, newGrp];
  }

  void removeElectiveGroup(String id) {
    state = state.where((g) => g.id != id).toList();
  }
}

final academicElectivesProvider =
    StateNotifierProvider<AcademicElectivesNotifier, List<ElectiveGroupEntity>>(
      (ref) {
        return AcademicElectivesNotifier();
      },
    );

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Subject Assignment Model (Class & Section Scoped)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SubjectAssignmentEntity {
  final String id;
  final String branchId;
  final String classId;
  final String sectionId; // 'ALL' or specific Section ID
  final String subjectName;
  final String assignedTeacher;

  const SubjectAssignmentEntity({
    required this.id,
    required this.branchId,
    required this.classId,
    required this.sectionId,
    required this.subjectName,
    required this.assignedTeacher,
  });
}

final List<SubjectAssignmentEntity> _defaultSubjectAssignments = [
  const SubjectAssignmentEntity(
    id: 'SUB-001',
    branchId: 'BR-001',
    classId: 'CLS-001',
    sectionId: 'SEC-A-001',
    subjectName: 'Mathematics',
    assignedTeacher: 'Mrs. Kavita Verma',
  ),
  const SubjectAssignmentEntity(
    id: 'SUB-002',
    branchId: 'BR-001',
    classId: 'CLS-001',
    sectionId: 'SEC-A-001',
    subjectName: 'English Literature',
    assignedTeacher: 'Ms. Pooja Sharma',
  ),
];

class SubjectAssignmentsNotifier
    extends StateNotifier<List<SubjectAssignmentEntity>> {
  SubjectAssignmentsNotifier() : super(_defaultSubjectAssignments);

  void assignSubject({
    required String branchId,
    required String classId,
    required String sectionId,
    required String subjectName,
    required String assignedTeacher,
  }) {
    final newAssign = SubjectAssignmentEntity(
      id: 'SUB-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      classId: classId,
      sectionId: sectionId,
      subjectName: subjectName,
      assignedTeacher: assignedTeacher,
    );
    state = [...state, newAssign];
  }

  void removeAssignment(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final subjectAssignmentsProvider =
    StateNotifierProvider<
      SubjectAssignmentsNotifier,
      List<SubjectAssignmentEntity>
    >((ref) {
      return SubjectAssignmentsNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Model for Branch-Scoped Directory & Transfers
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StudentEntity {
  final String id;
  final String branchId;
  final String classId;
  final String sectionId;
  final String name;
  final String admissionNumber;
  final String rollNumber;

  // Personal Profile
  final String gender;
  final String dateOfBirth;
  final String bloodGroup;
  final String guardianName;
  final String phone;
  final String email;
  final String address;
  final List<String> siblingIds;

  // Academic Profile
  final String admissionDate;
  final bool isActive;
  final String
  categorization; // 'Active', 'Inactive', 'Transferred', 'Graduated', 'Expelled', 'TC Issued'
  final bool isRepeatingYear;

  // Behavioral Profile
  final String behavioralRemarks;
  final double attendanceRate;
  final List<String> disciplinaryRecords;

  // Medical Profile
  final String allergies;
  final String medicalConditions;
  final String emergencyContact;

  // Document Storage (simulated file links)
  final List<String> uploadedDocuments;

  // Portfolio & Achievements
  final List<String> achievements;
  final String photoUrl;

  // RFID / Biometric Card Mappings
  final String rfidCardNumber;

  // Custom Fields per Branch
  final Map<String, String> customFields;

  const StudentEntity({
    required this.id,
    required this.branchId,
    required this.classId,
    required this.sectionId,
    required this.name,
    required this.admissionNumber,
    required this.rollNumber,
    this.gender = 'Male',
    this.dateOfBirth = '2015-05-10',
    this.bloodGroup = 'O+',
    this.guardianName = 'Parent Guardian',
    this.phone = '+91 99999 88888',
    this.email = 'student@example.com',
    this.address = '123 School Lane',
    this.siblingIds = const [],
    this.admissionDate = '2026-04-01',
    this.isActive = true,
    this.categorization = 'Active',
    this.isRepeatingYear = false,
    this.behavioralRemarks = 'Good discipline, active participant in class.',
    this.attendanceRate = 95.0,
    this.disciplinaryRecords = const [
      'Verbal warning for talking during class test.',
    ],
    this.allergies = 'None',
    this.medicalConditions = 'None',
    this.emergencyContact = '+91 99999 88888',
    this.uploadedDocuments = const [
      'Birth Certificate',
      'Photos',
      'Aadhar Card',
    ],
    this.achievements = const [
      'Class Representative election winner',
      '1st prize in drawing contest.',
    ],
    this.photoUrl =
        'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&q=80&w=200',
    this.rfidCardNumber = '',
    this.customFields = const {'Bus Route': 'Route 12B', 'Locker ID': 'LK-901'},
  });

  StudentEntity copyWith({
    String? id,
    String? branchId,
    String? classId,
    String? sectionId,
    String? name,
    String? admissionNumber,
    String? rollNumber,
    String? gender,
    String? dateOfBirth,
    String? bloodGroup,
    String? guardianName,
    String? phone,
    String? email,
    String? address,
    List<String>? siblingIds,
    String? admissionDate,
    bool? isActive,
    String? categorization,
    bool? isRepeatingYear,
    String? behavioralRemarks,
    double? attendanceRate,
    List<String>? disciplinaryRecords,
    String? allergies,
    String? medicalConditions,
    String? emergencyContact,
    List<String>? uploadedDocuments,
    List<String>? achievements,
    String? photoUrl,
    String? rfidCardNumber,
    Map<String, String>? customFields,
  }) {
    return StudentEntity(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      name: name ?? this.name,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      rollNumber: rollNumber ?? this.rollNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      guardianName: guardianName ?? this.guardianName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      siblingIds: siblingIds ?? this.siblingIds,
      admissionDate: admissionDate ?? this.admissionDate,
      isActive: isActive ?? this.isActive,
      categorization: categorization ?? this.categorization,
      isRepeatingYear: isRepeatingYear ?? this.isRepeatingYear,
      behavioralRemarks: behavioralRemarks ?? this.behavioralRemarks,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      disciplinaryRecords: disciplinaryRecords ?? this.disciplinaryRecords,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      achievements: achievements ?? this.achievements,
      photoUrl: photoUrl ?? this.photoUrl,
      rfidCardNumber: rfidCardNumber ?? this.rfidCardNumber,
      customFields: customFields ?? this.customFields,
    );
  }
}

final List<StudentEntity> _defaultStudents = [
  // Class 1 Delhi (CLS-001), Section A (SEC-A-001)
  const StudentEntity(
    id: 'STU-001',
    branchId: 'BR-001',
    classId: 'CLS-001',
    sectionId: 'SEC-A-001',
    name: 'Aarav Sharma',
    admissionNumber: 'ADM-2026-001',
    rollNumber: '101',
  ),
  const StudentEntity(
    id: 'STU-002',
    branchId: 'BR-001',
    classId: 'CLS-001',
    sectionId: 'SEC-A-001',
    name: 'Amit Singh',
    admissionNumber: 'ADM-2026-002',
    rollNumber: '102',
  ),
  const StudentEntity(
    id: 'STU-003',
    branchId: 'BR-001',
    classId: 'CLS-001',
    sectionId: 'SEC-A-001',
    name: 'Bhavna Joshi',
    admissionNumber: 'ADM-2026-003',
    rollNumber: '103',
  ),

  // Class 1 Delhi (CLS-001), Section B (SEC-B-001)
  const StudentEntity(
    id: 'STU-004',
    branchId: 'BR-001',
    classId: 'CLS-001',
    sectionId: 'SEC-B-001',
    name: 'Chitra Ranade',
    admissionNumber: 'ADM-2026-004',
    rollNumber: '101',
  ),
  const StudentEntity(
    id: 'STU-005',
    branchId: 'BR-001',
    classId: 'CLS-001',
    sectionId: 'SEC-B-001',
    name: 'Devendra Gowda',
    admissionNumber: 'ADM-2026-005',
    rollNumber: '102',
  ),

  // Class 10 Delhi (CLS-005), Section A (SEC-A-002)
  const StudentEntity(
    id: 'STU-006',
    branchId: 'BR-001',
    classId: 'CLS-005',
    sectionId: 'SEC-A-002',
    name: 'Eshwar Iyer',
    admissionNumber: 'ADM-2026-006',
    rollNumber: '201',
  ),
  const StudentEntity(
    id: 'STU-007',
    branchId: 'BR-001',
    classId: 'CLS-005',
    sectionId: 'SEC-A-002',
    name: 'Fatima Shaikh',
    admissionNumber: 'ADM-2026-007',
    rollNumber: '202',
  ),
];

class AcademicStudentsNotifier extends StateNotifier<List<StudentEntity>> {
  AcademicStudentsNotifier() : super(_defaultStudents);

  void addStudent({
    required String branchId,
    required String classId,
    required String sectionId,
    required String name,
    required String admissionNumber,
    required String rollNumber,
    String gender = 'Male',
    String dateOfBirth = '2015-05-10',
    String bloodGroup = 'O+',
    String guardianName = 'Parent Guardian',
    String phone = '+91 99999 88888',
    String email = 'student@example.com',
    String address = '123 School Lane',
    String admissionDate = '2026-04-01',
    bool isActive = true,
    String behavioralRemarks = 'Good discipline, active participant in class.',
    double attendanceRate = 95.0,
    String allergies = 'None',
    String medicalConditions = 'None',
    String emergencyContact = '+91 99999 88888',
  }) {
    final newStudent = StudentEntity(
      id: 'STU-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      classId: classId,
      sectionId: sectionId,
      name: name,
      admissionNumber: admissionNumber,
      rollNumber: rollNumber,
      gender: gender,
      dateOfBirth: dateOfBirth,
      bloodGroup: bloodGroup,
      guardianName: guardianName,
      phone: phone,
      email: email,
      address: address,
      admissionDate: admissionDate,
      isActive: isActive,
      behavioralRemarks: behavioralRemarks,
      attendanceRate: attendanceRate,
      allergies: allergies,
      medicalConditions: medicalConditions,
      emergencyContact: emergencyContact,
    );
    state = [...state, newStudent];
  }

  void updateStudentProfile(String studentId, StudentEntity updated) {
    state = state.map((s) => s.id == studentId ? updated : s).toList();
  }

  // Generate roll numbers alphabetically inside a specific section
  void autoGenerateRollNumbers(String classId, String sectionId) {
    // Get students in this specific class & section
    final sectionStudents = state
        .where((s) => s.classId == classId && s.sectionId == sectionId)
        .toList();
    // Sort them alphabetically by name
    sectionStudents.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    state = state.map((student) {
      if (student.classId == classId && student.sectionId == sectionId) {
        final idx = sectionStudents.indexWhere((s) => s.id == student.id);
        return student.copyWith(rollNumber: '${idx + 1}');
      }
      return student;
    }).toList();
  }

  // Transfer section within same class (branch internal)
  void transferSection(String studentId, String newSectionId) {
    state = [
      for (final s in state)
        if (s.id == studentId) s.copyWith(sectionId: newSectionId) else s,
    ];
  }

  // Promotion workflow from one class to next within same branch
  void promoteStudents({
    required String branchId,
    required String fromClassId,
    required String toClassId,
    required String defaultToSectionId,
  }) {
    state = state.map((s) {
      if (s.branchId == branchId && s.classId == fromClassId) {
        return s.copyWith(
          classId: toClassId,
          sectionId: defaultToSectionId,
          rollNumber:
              '', // Reset roll numbers for new class to allow fresh auto-generation
        );
      }
      return s;
    }).toList();
  }

  void removeStudent(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final academicStudentsProvider =
    StateNotifierProvider<AcademicStudentsNotifier, List<StudentEntity>>((ref) {
      return AcademicStudentsNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch Timetable Configuration & Break Models
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class BranchBreakEntity {
  final String id;
  final String name; // e.g. 'Recess', 'Lunch Break'
  final String startTime; // e.g. '10:15 AM'
  final String endTime; // e.g. '10:30 AM'
  final int afterPeriodNumber; // after which period this break occurs

  const BranchBreakEntity({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.afterPeriodNumber,
  });

  BranchBreakEntity copyWith({
    String? id,
    String? name,
    String? startTime,
    String? endTime,
    int? afterPeriodNumber,
  }) {
    return BranchBreakEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      afterPeriodNumber: afterPeriodNumber ?? this.afterPeriodNumber,
    );
  }
}

class BranchLabEntity {
  final String id;
  final String branchId;
  final String name;
  final String building;
  final int capacity;

  const BranchLabEntity({
    required this.id,
    required this.branchId,
    required this.name,
    this.building = 'Science Block',
    this.capacity = 35,
  });
}

class BranchTimetableSettingsEntity {
  final String branchId;
  final String activeShift; // 'Morning Shift', 'Afternoon Shift'
  final List<String> workingDays; // e.g. ['Monday', 'Tuesday', ...]
  final int periodDurationMinutes; // e.g. 45
  final String schoolStartTime; // e.g. '08:15 AM'
  final String assemblyName; // e.g. 'Morning Prayer Assembly'
  final String assemblyStartTime; // e.g. '08:00 AM'
  final String assemblyEndTime; // e.g. '08:15 AM'
  final String
  weekendPolicy; // 'All Saturdays On', '2nd & 4th Saturday Off', 'All Saturdays Off'
  final List<String> branchHolidays;
  final List<BranchBreakEntity> breaks;

  const BranchTimetableSettingsEntity({
    required this.branchId,
    this.activeShift = 'Morning Shift',
    required this.workingDays,
    required this.periodDurationMinutes,
    required this.schoolStartTime,
    this.assemblyName = 'Morning Assembly & Prayer',
    this.assemblyStartTime = '08:00 AM',
    this.assemblyEndTime = '08:15 AM',
    this.weekendPolicy = 'All Saturdays On',
    this.branchHolidays = const [
      'Independence Day (Aug 15)',
      'Diwali Trust Break (Nov 1-5)',
      'Winter Break (Dec 25 - Jan 2)',
    ],
    required this.breaks,
  });

  BranchTimetableSettingsEntity copyWith({
    String? branchId,
    String? activeShift,
    List<String>? workingDays,
    int? periodDurationMinutes,
    String? schoolStartTime,
    String? assemblyName,
    String? assemblyStartTime,
    String? assemblyEndTime,
    String? weekendPolicy,
    List<String>? branchHolidays,
    List<BranchBreakEntity>? breaks,
  }) {
    return BranchTimetableSettingsEntity(
      branchId: branchId ?? this.branchId,
      activeShift: activeShift ?? this.activeShift,
      workingDays: workingDays ?? this.workingDays,
      periodDurationMinutes:
          periodDurationMinutes ?? this.periodDurationMinutes,
      schoolStartTime: schoolStartTime ?? this.schoolStartTime,
      assemblyName: assemblyName ?? this.assemblyName,
      assemblyStartTime: assemblyStartTime ?? this.assemblyStartTime,
      assemblyEndTime: assemblyEndTime ?? this.assemblyEndTime,
      weekendPolicy: weekendPolicy ?? this.weekendPolicy,
      branchHolidays: branchHolidays ?? this.branchHolidays,
      breaks: breaks ?? this.breaks,
    );
  }

  // Parse time string like "08:30 AM" into a DateTime
  static DateTime parseTimeString(String timeStr) {
    try {
      return DateFormat("hh:mm a").parse(timeStr.trim());
    } catch (e) {
      final parts = timeStr.trim().split(' ');
      if (parts.length < 2) return DateTime(2026, 1, 1, 8, 0);
      final hm = parts[0].split(':');
      if (hm.length < 2) return DateTime(2026, 1, 1, 8, 0);
      int h = int.tryParse(hm[0]) ?? 8;
      int m = int.tryParse(hm[1]) ?? 0;
      final isPm = parts[1].toLowerCase() == 'pm';
      if (isPm && h != 12) h += 12;
      if (!isPm && h == 12) h = 0;
      return DateTime(2026, 1, 1, h, m);
    }
  }

  // Format DateTime into "hh:mm a"
  static String formatTimeString(DateTime dt) {
    return DateFormat("hh:mm a").format(dt);
  }

  // Compute calculated sequential time slots including Morning Assembly and inline breaks
  List<CalculatedTimeSlot> calculateTimeSlots(int maxPeriods) {
    final slots = <CalculatedTimeSlot>[];

    // 0. Include Morning Assembly if configured
    if (assemblyStartTime.isNotEmpty && assemblyEndTime.isNotEmpty) {
      slots.add(
        CalculatedTimeSlot(
          periodNumber: 0,
          startTime: assemblyStartTime,
          endTime: assemblyEndTime,
          isBreak: false,
          isAssembly: true,
          name: assemblyName,
        ),
      );
    }

    DateTime current = parseTimeString(schoolStartTime);

    for (int periodIndex = 1; periodIndex <= maxPeriods; periodIndex++) {
      // 1. Check if there are any breaks scheduled after the previous period (periodIndex - 1)
      final activeBreaks = breaks
          .where((b) => b.afterPeriodNumber == periodIndex - 1)
          .toList();
      if (activeBreaks.isNotEmpty) {
        for (final brk in activeBreaks) {
          final startStr = brk.startTime;
          final endStr = brk.endTime;
          current = parseTimeString(endStr);

          slots.add(
            CalculatedTimeSlot(
              periodNumber: 0,
              startTime: startStr,
              endTime: endStr,
              isBreak: true,
              isAssembly: false,
              name: brk.name,
            ),
          );
        }
      }

      // 2. Add the actual period slot
      final startStr = formatTimeString(current);
      current = current.add(Duration(minutes: periodDurationMinutes));
      final endStr = formatTimeString(current);

      slots.add(
        CalculatedTimeSlot(
          periodNumber: periodIndex,
          startTime: startStr,
          endTime: endStr,
          isBreak: false,
          isAssembly: false,
          name: 'Period $periodIndex',
        ),
      );
    }

    // Check for any breaks configured after the last period
    final activeBreaks = breaks
        .where((b) => b.afterPeriodNumber == maxPeriods)
        .toList();
    for (final brk in activeBreaks) {
      slots.add(
        CalculatedTimeSlot(
          periodNumber: 0,
          startTime: brk.startTime,
          endTime: brk.endTime,
          isBreak: true,
          isAssembly: false,
          name: brk.name,
        ),
      );
    }

    return slots;
  }
}

class CalculatedTimeSlot {
  final int periodNumber; // 0 for breaks & assembly
  final String startTime;
  final String endTime;
  final bool isBreak;
  final bool isAssembly;
  final String name; // e.g. 'Morning Assembly', 'Period 1' or 'Lunch Break'

  const CalculatedTimeSlot({
    required this.periodNumber,
    required this.startTime,
    required this.endTime,
    required this.isBreak,
    this.isAssembly = false,
    required this.name,
  });
}

final List<BranchLabEntity> _defaultBranchLabs = [
  const BranchLabEntity(
    id: 'LAB-001',
    branchId: 'BR-001',
    name: 'Physics Lab 1',
    building: 'Science Wing A',
    capacity: 40,
  ),
  const BranchLabEntity(
    id: 'LAB-002',
    branchId: 'BR-001',
    name: 'Chemistry Lab',
    building: 'Science Wing B',
    capacity: 40,
  ),
  const BranchLabEntity(
    id: 'LAB-003',
    branchId: 'BR-001',
    name: 'Computer Lab A',
    building: 'IT Block - 2nd Floor',
    capacity: 50,
  ),
  const BranchLabEntity(
    id: 'LAB-004',
    branchId: 'BR-002',
    name: 'Robotics & STEM Lab',
    building: 'Innovation Hall',
    capacity: 35,
  ),
];

class BranchLabsNotifier extends StateNotifier<List<BranchLabEntity>> {
  BranchLabsNotifier() : super(_defaultBranchLabs);

  void addLab({
    required String branchId,
    required String name,
    String building = 'Science Wing',
    int capacity = 35,
  }) {
    final newLab = BranchLabEntity(
      id: 'LAB-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      name: name,
      building: building,
      capacity: capacity,
    );
    state = [...state, newLab];
  }
}

final branchLabsProvider =
    StateNotifierProvider<BranchLabsNotifier, List<BranchLabEntity>>((ref) {
      return BranchLabsNotifier();
    });

class BranchClassroomEntity {
  final String id;
  final String branchId;
  final String name;
  final String building;
  final int capacity;

  const BranchClassroomEntity({
    required this.id,
    required this.branchId,
    required this.name,
    this.building = 'Main Block',
    this.capacity = 40,
  });
}

class BranchResourceEntity {
  final String id;
  final String branchId;
  final String name;
  final String type;
  final String status;

  const BranchResourceEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.type,
    this.status = 'Available',
  });

  BranchResourceEntity copyWith({
    String? id,
    String? branchId,
    String? name,
    String? type,
    String? status,
  }) {
    return BranchResourceEntity(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}

final List<BranchClassroomEntity> _defaultBranchClassrooms = [
  const BranchClassroomEntity(
    id: 'RM-001',
    branchId: 'BR-001',
    name: 'Room 101',
    building: 'Main Block - Ground Floor',
    capacity: 40,
  ),
  const BranchClassroomEntity(
    id: 'RM-002',
    branchId: 'BR-001',
    name: 'Room 102',
    building: 'Main Block - Ground Floor',
    capacity: 40,
  ),
  const BranchClassroomEntity(
    id: 'RM-003',
    branchId: 'BR-001',
    name: 'Room 201',
    building: 'Senior Wing - 1st Floor',
    capacity: 45,
  ),
  const BranchClassroomEntity(
    id: 'RM-004',
    branchId: 'BR-001',
    name: 'Room 202',
    building: 'Senior Wing - 1st Floor',
    capacity: 45,
  ),
  const BranchClassroomEntity(
    id: 'RM-005',
    branchId: 'BR-001',
    name: 'Seminar Hall A',
    building: 'Administrative Block',
    capacity: 120,
  ),
  const BranchClassroomEntity(
    id: 'RM-006',
    branchId: 'BR-002',
    name: 'Classroom A1',
    building: 'Junior Block',
    capacity: 35,
  ),
  const BranchClassroomEntity(
    id: 'RM-007',
    branchId: 'BR-002',
    name: 'Classroom B1',
    building: 'Junior Block',
    capacity: 35,
  ),
  const BranchClassroomEntity(
    id: 'RM-008',
    branchId: 'BR-002',
    name: 'Auditorium',
    building: 'Activity Wing',
    capacity: 200,
  ),
];

class BranchClassroomsNotifier
    extends StateNotifier<List<BranchClassroomEntity>> {
  BranchClassroomsNotifier() : super(_defaultBranchClassrooms);

  void addClassroom({
    required String branchId,
    required String name,
    String building = 'Main Block',
    int capacity = 40,
  }) {
    final newClassroom = BranchClassroomEntity(
      id: 'RM-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      name: name,
      building: building,
      capacity: capacity,
    );
    state = [...state, newClassroom];
  }

  void removeClassroom(String id) {
    state = state.where((rm) => rm.id != id).toList();
  }
}

final branchClassroomsProvider =
    StateNotifierProvider<
      BranchClassroomsNotifier,
      List<BranchClassroomEntity>
    >((ref) {
      return BranchClassroomsNotifier();
    });

final List<BranchResourceEntity> _defaultBranchResources = [
  const BranchResourceEntity(
    id: 'RES-001',
    branchId: 'BR-001',
    name: 'Epson Smart Projector A',
    type: 'Projector',
  ),
  const BranchResourceEntity(
    id: 'RES-002',
    branchId: 'BR-001',
    name: 'Sony PA Audio System 1',
    type: 'Audio',
  ),
  const BranchResourceEntity(
    id: 'RES-003',
    branchId: 'BR-001',
    name: 'iPad Tablet Cart (30 Units)',
    type: 'Computing',
  ),
  const BranchResourceEntity(
    id: 'RES-004',
    branchId: 'BR-001',
    name: 'Smart Board Display B',
    type: 'Smart Board',
  ),
  const BranchResourceEntity(
    id: 'RES-005',
    branchId: 'BR-002',
    name: 'BenQ Projector Mini 1',
    type: 'Projector',
  ),
  const BranchResourceEntity(
    id: 'RES-006',
    branchId: 'BR-002',
    name: 'JBL Audio Speaker',
    type: 'Audio',
  ),
];

class BranchResourcesNotifier
    extends StateNotifier<List<BranchResourceEntity>> {
  BranchResourcesNotifier() : super(_defaultBranchResources);

  void addResource({
    required String branchId,
    required String name,
    required String type,
    String status = 'Available',
  }) {
    final newResource = BranchResourceEntity(
      id: 'RES-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      name: name,
      type: type,
      status: status,
    );
    state = [...state, newResource];
  }

  void toggleResourceStatus(String id) {
    state = state.map((r) {
      if (r.id == id) {
        return r.copyWith(
          status: r.status == 'Available' ? 'Maintenance' : 'Available',
        );
      }
      return r;
    }).toList();
  }

  void removeResource(String id) {
    state = state.where((r) => r.id != id).toList();
  }
}

final branchResourcesProvider =
    StateNotifierProvider<BranchResourcesNotifier, List<BranchResourceEntity>>((
      ref,
    ) {
      return BranchResourcesNotifier();
    });

final List<BranchTimetableSettingsEntity> _defaultTimetableSettings = [
  const BranchTimetableSettingsEntity(
    branchId: 'BR-001',
    workingDays: [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ],
    periodDurationMinutes: 45,
    schoolStartTime: '08:00 AM',
    breaks: [
      BranchBreakEntity(
        id: 'BRK-001-1',
        name: 'Short Break',
        startTime: '10:15 AM',
        endTime: '10:30 AM',
        afterPeriodNumber: 3,
      ),
      BranchBreakEntity(
        id: 'BRK-001-2',
        name: 'Lunch Break',
        startTime: '12:00 PM',
        endTime: '12:45 PM',
        afterPeriodNumber: 5,
      ),
    ],
  ),
  const BranchTimetableSettingsEntity(
    branchId: 'BR-002',
    workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    periodDurationMinutes: 40,
    schoolStartTime: '08:30 AM',
    breaks: [
      BranchBreakEntity(
        id: 'BRK-002-1',
        name: 'Recess',
        startTime: '10:30 AM',
        endTime: '10:50 AM',
        afterPeriodNumber: 3,
      ),
      BranchBreakEntity(
        id: 'BRK-002-2',
        name: 'Lunch Break',
        startTime: '12:50 PM',
        endTime: '01:30 PM',
        afterPeriodNumber: 6,
      ),
    ],
  ),
  const BranchTimetableSettingsEntity(
    branchId: 'BR-003',
    workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    periodDurationMinutes: 50,
    schoolStartTime: '08:15 AM',
    breaks: [
      BranchBreakEntity(
        id: 'BRK-003-1',
        name: 'Snack Break',
        startTime: '09:55 AM',
        endTime: '10:10 AM',
        afterPeriodNumber: 2,
      ),
      BranchBreakEntity(
        id: 'BRK-003-2',
        name: 'Lunch Break',
        startTime: '11:50 AM',
        endTime: '12:35 PM',
        afterPeriodNumber: 4,
      ),
    ],
  ),
];

class BranchTimetableSettingsNotifier
    extends StateNotifier<List<BranchTimetableSettingsEntity>> {
  BranchTimetableSettingsNotifier() : super(_defaultTimetableSettings);

  void updateSettings(BranchTimetableSettingsEntity updated) {
    state = [
      for (final s in state)
        if (s.branchId == updated.branchId) updated else s,
    ];
  }

  void addBreak(String branchId, BranchBreakEntity breakEntity) {
    state = [
      for (final s in state)
        if (s.branchId == branchId)
          s.copyWith(breaks: [...s.breaks, breakEntity])
        else
          s,
    ];
  }

  void removeBreak(String branchId, String breakId) {
    state = [
      for (final s in state)
        if (s.branchId == branchId)
          s.copyWith(breaks: s.breaks.where((b) => b.id != breakId).toList())
        else
          s,
    ];
  }
}

final branchTimetableSettingsProvider =
    StateNotifierProvider<
      BranchTimetableSettingsNotifier,
      List<BranchTimetableSettingsEntity>
    >((ref) {
      return BranchTimetableSettingsNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Timetable Slot Configuration Model (Class & Section Scoped)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TimetableSlotEntity {
  final String id;
  final String branchId;
  final String classId;
  final String sectionId; // 'ALL' or specific section
  final String dayOfWeek; // e.g. 'Monday'
  final String periodName; // e.g. 'Period 1'
  final String startTime;
  final String endTime;
  final String subjectName;
  final String teacherName;
  final String roomNumber;
  final bool isLabSession;
  final bool isDoublePeriod;
  final String shiftName;
  final String electiveGroupName;
  final List<String> allocatedResourceIds;

  const TimetableSlotEntity({
    required this.id,
    required this.branchId,
    required this.classId,
    required this.sectionId,
    required this.dayOfWeek,
    required this.periodName,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    required this.teacherName,
    this.roomNumber = '',
    this.isLabSession = false,
    this.isDoublePeriod = false,
    this.shiftName = 'Morning Shift',
    this.electiveGroupName = '',
    this.allocatedResourceIds = const [],
  });

  TimetableSlotEntity copyWith({
    String? id,
    String? branchId,
    String? classId,
    String? sectionId,
    String? dayOfWeek,
    String? periodName,
    String? startTime,
    String? endTime,
    String? subjectName,
    String? teacherName,
    String? roomNumber,
    bool? isLabSession,
    bool? isDoublePeriod,
    String? shiftName,
    String? electiveGroupName,
    List<String>? allocatedResourceIds,
  }) {
    return TimetableSlotEntity(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      periodName: periodName ?? this.periodName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
      roomNumber: roomNumber ?? this.roomNumber,
      isLabSession: isLabSession ?? this.isLabSession,
      isDoublePeriod: isDoublePeriod ?? this.isDoublePeriod,
      shiftName: shiftName ?? this.shiftName,
      electiveGroupName: electiveGroupName ?? this.electiveGroupName,
      allocatedResourceIds: allocatedResourceIds ?? this.allocatedResourceIds,
    );
  }
}

final List<TimetableSlotEntity> _defaultTimetableSlots = [
  const TimetableSlotEntity(
    id: 'TS-001',
    branchId: 'BR-001',
    classId: 'CLS-001',
    sectionId: 'SEC-A-001',
    dayOfWeek: 'Monday',
    periodName: 'Period 1',
    startTime: '08:30 AM',
    endTime: '09:15 AM',
    subjectName: 'Mathematics',
    teacherName: 'Mrs. Kavita Verma',
    roomNumber: 'R101',
  ),
  const TimetableSlotEntity(
    id: 'TS-002',
    branchId: 'BR-001',
    classId: 'CLS-001',
    sectionId: 'SEC-A-001',
    dayOfWeek: 'Monday',
    periodName: 'Period 2',
    startTime: '09:15 AM',
    endTime: '10:00 AM',
    subjectName: 'English Literature',
    teacherName: 'Ms. Pooja Sharma',
    roomNumber: 'R101',
  ),
  const TimetableSlotEntity(
    id: 'TS-003',
    branchId: 'BR-001',
    classId: 'CLS-001',
    sectionId: 'SEC-A-001',
    dayOfWeek: 'Tuesday',
    periodName: 'Period 3',
    startTime: '10:30 AM',
    endTime: '12:00 PM',
    subjectName: 'Computer Practical Lab',
    teacherName: 'Vikram Malhotra',
    roomNumber: 'Computer Lab A',
    isLabSession: true,
    isDoublePeriod: true,
  ),
];

class TimetableSlotsNotifier extends StateNotifier<List<TimetableSlotEntity>> {
  TimetableSlotsNotifier() : super(_defaultTimetableSlots);

  void addSlot({
    required String branchId,
    required String classId,
    required String sectionId,
    required String dayOfWeek,
    required String periodName,
    required String startTime,
    required String endTime,
    required String subjectName,
    required String teacherName,
    String roomNumber = '',
    bool isLabSession = false,
    bool isDoublePeriod = false,
    String shiftName = 'Morning Shift',
    String electiveGroupName = '',
    List<String> allocatedResourceIds = const [],
  }) {
    final newSlot = TimetableSlotEntity(
      id: 'TS-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      classId: classId,
      sectionId: sectionId,
      dayOfWeek: dayOfWeek,
      periodName: periodName,
      startTime: startTime,
      endTime: endTime,
      subjectName: subjectName,
      teacherName: teacherName,
      roomNumber: roomNumber,
      isLabSession: isLabSession,
      isDoublePeriod: isDoublePeriod,
      shiftName: shiftName,
      electiveGroupName: electiveGroupName,
      allocatedResourceIds: allocatedResourceIds,
    );
    state = [...state, newSlot];
  }

  void removeSlot(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void replaceBranchSlots(String branchId, List<TimetableSlotEntity> newSlots) {
    final otherBranchSlots = state.where((s) => s.branchId != branchId).toList();
    final remapped = newSlots.map((s) => s.copyWith(
      id: 'TS-${DateTime.now().millisecondsSinceEpoch}-${s.id}',
      branchId: branchId,
    )).toList();
    state = [...otherBranchSlots, ...remapped];
  }

  void autoGenerateBranchTimetable({
    required String branchId,
    required List<ClassEntity> classes,
    required List<SectionEntity> sections,
    required List<SubjectAllocationEntity> allocations,
    required BranchTimetableSettingsEntity settings,
  }) {
    final otherBranchSlots = state
        .where((s) => s.branchId != branchId)
        .toList();
    final newBranchSlots = <TimetableSlotEntity>[];

    final workingDays = settings.workingDays;
    final timeSlots = settings
        .calculateTimeSlots(8)
        .where((ts) => !ts.isBreak)
        .toList();

    // Track assigned teacher per day and period to prevent double-booking: "Day_PeriodName" -> set of assigned teacher names
    final Map<String, Set<String>> teacherSchedule = {};

    int slotCounter = 1;

    for (final cls in classes) {
      final classSections = sections
          .where((sec) => sec.classId == cls.id)
          .toList();
      final classAllocations = allocations
          .where((a) => a.classId == cls.id)
          .toList();
      if (classAllocations.isEmpty) continue;

      for (final sec in classSections) {
        // Expand subject list according to periodsPerWeek
        final List<SubjectAllocationEntity> subjectPool = [];
        for (final alloc in classAllocations) {
          for (int p = 0; p < alloc.periodsPerWeek; p++) {
            subjectPool.add(alloc);
          }
        }

        int poolIndex = 0;
        for (final day in workingDays) {
          for (final period in timeSlots) {
            if (poolIndex >= subjectPool.length) break;

            final targetAlloc = subjectPool[poolIndex];
            final key = '${day}_${period.name}';
            teacherSchedule[key] ??= {};

            final teacherName = targetAlloc.assignedTeacherName;
            if (!teacherSchedule[key]!.contains(teacherName.toLowerCase())) {
              teacherSchedule[key]!.add(teacherName.toLowerCase());
              newBranchSlots.add(
                TimetableSlotEntity(
                  id: 'AUTO-$branchId-${DateTime.now().millisecondsSinceEpoch}-$slotCounter',
                  branchId: branchId,
                  classId: cls.id,
                  sectionId: sec.id,
                  dayOfWeek: day,
                  periodName: period.name,
                  startTime: period.startTime,
                  endTime: period.endTime,
                  subjectName: targetAlloc.subjectName,
                  teacherName: teacherName,
                  roomNumber: sec.roomNumber.isNotEmpty
                      ? sec.roomNumber
                      : 'R101',
                ),
              );
              slotCounter++;
              poolIndex++;
            }
          }
        }
      }
    }

    state = [...otherBranchSlots, ...newBranchSlots];
  }
}

final timetableSlotsProvider =
    StateNotifierProvider<TimetableSlotsNotifier, List<TimetableSlotEntity>>((
      ref,
    ) {
      return TimetableSlotsNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Class-Wise Fee Plan Assignment Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ClassFeePlanEntity {
  final String id;
  final String branchId;
  final String classId;
  final String feePlanName;
  final double totalAmount;

  const ClassFeePlanEntity({
    required this.id,
    required this.branchId,
    required this.classId,
    required this.feePlanName,
    required this.totalAmount,
  });
}

final List<ClassFeePlanEntity> _defaultFeePlans = [
  const ClassFeePlanEntity(
    id: 'FP-001',
    branchId: 'BR-001',
    classId: 'CLS-001',
    feePlanName: 'Grade 1 Term-1 Standard Fee Structure',
    totalAmount: 18500.0,
  ),
  const ClassFeePlanEntity(
    id: 'FP-002',
    branchId: 'BR-001',
    classId: 'CLS-005',
    feePlanName: 'Grade 10 Matriculation Board Fee Structure',
    totalAmount: 32000.0,
  ),
];

class ClassFeePlansNotifier extends StateNotifier<List<ClassFeePlanEntity>> {
  ClassFeePlansNotifier() : super(_defaultFeePlans);

  void assignFeePlan({
    required String branchId,
    required String classId,
    required String feePlanName,
    required double totalAmount,
  }) {
    final newPlan = ClassFeePlanEntity(
      id: 'FP-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      classId: classId,
      feePlanName: feePlanName,
      totalAmount: totalAmount,
    );
    state = [...state, newPlan];
  }

  void removeFeePlan(String id) {
    state = state.where((f) => f.id != id).toList();
  }
}

final classFeePlansProvider =
    StateNotifierProvider<ClassFeePlansNotifier, List<ClassFeePlanEntity>>((
      ref,
    ) {
      return ClassFeePlansNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Class-Wise Exam Schedule Setup Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ExamScheduleEntity {
  final String id;
  final String branchId;
  final String classId;
  final String examName;
  final String subjectName;
  final String examDate;
  final String startTime;
  final String endTime;

  const ExamScheduleEntity({
    required this.id,
    required this.branchId,
    required this.classId,
    required this.examName,
    required this.subjectName,
    required this.examDate,
    required this.startTime,
    required this.endTime,
  });
}

final List<ExamScheduleEntity> _defaultExamSchedules = [
  const ExamScheduleEntity(
    id: 'EX-001',
    branchId: 'BR-001',
    classId: 'CLS-005',
    examName: 'Mid-Term Board Mock Exam',
    subjectName: 'Mathematics',
    examDate: '2026-09-15',
    startTime: '09:00 AM',
    endTime: '12:00 PM',
  ),
];

class ExamSchedulesNotifier extends StateNotifier<List<ExamScheduleEntity>> {
  ExamSchedulesNotifier() : super(_defaultExamSchedules);

  void scheduleExam({
    required String branchId,
    required String classId,
    required String examName,
    required String subjectName,
    required String examDate,
    required String startTime,
    required String endTime,
  }) {
    final newSchedule = ExamScheduleEntity(
      id: 'EX-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      classId: classId,
      examName: examName,
      subjectName: subjectName,
      examDate: examDate,
      startTime: startTime,
      endTime: endTime,
    );
    state = [...state, newSchedule];
  }

  void removeExam(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final examSchedulesProvider =
    StateNotifierProvider<ExamSchedulesNotifier, List<ExamScheduleEntity>>((
      ref,
    ) {
      return ExamSchedulesNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Section-Wise Attendance Record Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AttendanceRecordEntity {
  final String id;
  final String branchId;
  final String studentId;
  final String date; // YYYY-MM-DD
  final String status; // 'Present' or 'Absent'

  const AttendanceRecordEntity({
    required this.id,
    required this.branchId,
    required this.studentId,
    required this.date,
    required this.status,
  });
}

final List<AttendanceRecordEntity> _defaultAttendance = [
  const AttendanceRecordEntity(
    id: 'ATT-001',
    branchId: 'BR-001',
    studentId: 'STU-001',
    date: '2026-08-13',
    status: 'Present',
  ),
  const AttendanceRecordEntity(
    id: 'ATT-002',
    branchId: 'BR-001',
    studentId: 'STU-002',
    date: '2026-08-13',
    status: 'Present',
  ),
];

class AttendanceRecordsNotifier
    extends StateNotifier<List<AttendanceRecordEntity>> {
  AttendanceRecordsNotifier() : super(_defaultAttendance);

  void saveAttendance({
    required String branchId,
    required String date,
    required Map<String, String>
    studentStatusMap, // Student ID -> Status ('Present'/'Absent')
  }) {
    // Filter out old records for the same date & branch to avoid duplicate lines
    final cleanState = state
        .where((att) => !(att.branchId == branchId && att.date == date))
        .toList();

    final List<AttendanceRecordEntity> newRecords = [];
    studentStatusMap.forEach((studentId, status) {
      newRecords.add(
        AttendanceRecordEntity(
          id: 'ATT-${DateTime.now().millisecondsSinceEpoch}-$studentId',
          branchId: branchId,
          studentId: studentId,
          date: date,
          status: status,
        ),
      );
    });

    state = [...cleanState, ...newRecords];
  }
}

final attendanceRecordsProvider =
    StateNotifierProvider<
      AttendanceRecordsNotifier,
      List<AttendanceRecordEntity>
    >((ref) {
      return AttendanceRecordsNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Parent-Teacher Meeting (PTM) Setup Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ParentTeacherMeetingEntity {
  final String id;
  final String branchId;
  final String classId;
  final String sectionId;
  final String title;
  final String meetingDate; // YYYY-MM-DD
  final String startTime;
  final String endTime;

  const ParentTeacherMeetingEntity({
    required this.id,
    required this.branchId,
    required this.classId,
    required this.sectionId,
    required this.title,
    required this.meetingDate,
    required this.startTime,
    required this.endTime,
  });
}

final List<ParentTeacherMeetingEntity> _defaultPTMs = [
  const ParentTeacherMeetingEntity(
    id: 'PTM-001',
    branchId: 'BR-001',
    classId: 'CLS-001',
    sectionId: 'SEC-A-001',
    title: 'Grade 1 Term-1 Performance Review PTM',
    meetingDate: '2026-08-20',
    startTime: '10:00 AM',
    endTime: '01:00 PM',
  ),
];

class ParentTeacherMeetingsNotifier
    extends StateNotifier<List<ParentTeacherMeetingEntity>> {
  ParentTeacherMeetingsNotifier() : super(_defaultPTMs);

  void scheduleMeeting({
    required String branchId,
    required String classId,
    required String sectionId,
    required String title,
    required String meetingDate,
    required String startTime,
    required String endTime,
  }) {
    final newMeeting = ParentTeacherMeetingEntity(
      id: 'PTM-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      classId: classId,
      sectionId: sectionId,
      title: title,
      meetingDate: meetingDate,
      startTime: startTime,
      endTime: endTime,
    );
    state = [...state, newMeeting];
  }

  void removeMeeting(String id) {
    state = state.where((m) => m.id != id).toList();
  }
}

final parentTeacherMeetingsProvider =
    StateNotifierProvider<
      ParentTeacherMeetingsNotifier,
      List<ParentTeacherMeetingEntity>
    >((ref) {
      return ParentTeacherMeetingsNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Inter-Branch Student Transfer Request Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class InterBranchTransferRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String sourceBranchId;
  final String destBranchId;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime createdAt;

  const InterBranchTransferRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.sourceBranchId,
    required this.destBranchId,
    required this.reason,
    this.status = 'Pending',
    required this.createdAt,
  });

  InterBranchTransferRequest copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? sourceBranchId,
    String? destBranchId,
    String? reason,
    String? status,
    DateTime? createdAt,
  }) {
    return InterBranchTransferRequest(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      sourceBranchId: sourceBranchId ?? this.sourceBranchId,
      destBranchId: destBranchId ?? this.destBranchId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class InterBranchTransfersNotifier
    extends StateNotifier<List<InterBranchTransferRequest>> {
  final Ref _ref;

  InterBranchTransfersNotifier(this._ref)
    : super([
        InterBranchTransferRequest(
          id: 'REQ-001',
          studentId: 'STU-001',
          studentName: 'Aarav Sharma',
          sourceBranchId: 'BR-001',
          destBranchId: 'BR-002',
          reason: 'Parents relocated due to job transfer.',
          status: 'Pending',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ]);

  void createRequest({
    required String studentId,
    required String studentName,
    required String sourceBranchId,
    required String destBranchId,
    required String reason,
  }) {
    final req = InterBranchTransferRequest(
      id: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      studentName: studentName,
      sourceBranchId: sourceBranchId,
      destBranchId: destBranchId,
      reason: reason,
      createdAt: DateTime.now(),
    );
    state = [...state, req];
  }

  void processRequest({required String requestId, required String newStatus}) {
    state = state.map((r) {
      if (r.id == requestId) {
        final updated = r.copyWith(status: newStatus);
        if (newStatus == 'Approved') {
          final list = _ref.read(academicStudentsProvider);
          final matchIdx = list.indexWhere((s) => s.id == r.studentId);
          if (matchIdx != -1) {
            final student = list[matchIdx];
            _ref
                .read(academicStudentsProvider.notifier)
                .updateStudentProfile(
                  student.id,
                  student.copyWith(
                    branchId: r.destBranchId,
                    categorization: 'Transferred',
                    isActive: false,
                  ),
                );
          }
        }
        return updated;
      }
      return r;
    }).toList();
  }
}

final interBranchTransfersProvider =
    StateNotifierProvider<
      InterBranchTransfersNotifier,
      List<InterBranchTransferRequest>
    >((ref) {
      return InterBranchTransfersNotifier(ref);
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch Subjects, Subject Allocations & Substitutions Models
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class BranchSubjectEntity {
  final String id;
  final String branchId;
  final String name;
  final String code;
  final String category; // 'Core', 'Elective', 'Lab', 'Activity'

  const BranchSubjectEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.code,
    this.category = 'Core',
  });

  BranchSubjectEntity copyWith({
    String? id,
    String? branchId,
    String? name,
    String? code,
    String? category,
  }) {
    return BranchSubjectEntity(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
    );
  }
}

class SubjectAllocationEntity {
  final String id;
  final String branchId;
  final String classId;
  final String subjectName;
  final int periodsPerWeek;
  final String assignedTeacherName;

  const SubjectAllocationEntity({
    required this.id,
    required this.branchId,
    required this.classId,
    required this.subjectName,
    required this.periodsPerWeek,
    required this.assignedTeacherName,
  });

  SubjectAllocationEntity copyWith({
    String? id,
    String? branchId,
    String? classId,
    String? subjectName,
    int? periodsPerWeek,
    String? assignedTeacherName,
  }) {
    return SubjectAllocationEntity(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      classId: classId ?? this.classId,
      subjectName: subjectName ?? this.subjectName,
      periodsPerWeek: periodsPerWeek ?? this.periodsPerWeek,
      assignedTeacherName: assignedTeacherName ?? this.assignedTeacherName,
    );
  }
}

class TimetableSubstitutionEntity {
  final String id;
  final String branchId;
  final String date; // YYYY-MM-DD
  final String dayOfWeek;
  final String periodName;
  final String classId;
  final String sectionId;
  final String originalTeacherName;
  final String substituteTeacherName;
  final String reason;
  final String status; // 'Assigned', 'Completed'

  const TimetableSubstitutionEntity({
    required this.id,
    required this.branchId,
    required this.date,
    required this.dayOfWeek,
    required this.periodName,
    required this.classId,
    required this.sectionId,
    required this.originalTeacherName,
    required this.substituteTeacherName,
    required this.reason,
    this.status = 'Assigned',
  });
}

// ─── Default Mock Data ───────────────────────────

final List<BranchSubjectEntity> _defaultBranchSubjects = [
  const BranchSubjectEntity(
    id: 'SUB-001',
    branchId: 'BR-001',
    name: 'Mathematics',
    code: 'MATH-101',
    category: 'Core',
  ),
  const BranchSubjectEntity(
    id: 'SUB-002',
    branchId: 'BR-001',
    name: 'English Literature',
    code: 'ENG-101',
    category: 'Core',
  ),
  const BranchSubjectEntity(
    id: 'SUB-003',
    branchId: 'BR-001',
    name: 'Physics Science',
    code: 'PHY-101',
    category: 'Core',
  ),
  const BranchSubjectEntity(
    id: 'SUB-004',
    branchId: 'BR-001',
    name: 'Chemistry',
    code: 'CHEM-101',
    category: 'Core',
  ),
  const BranchSubjectEntity(
    id: 'SUB-005',
    branchId: 'BR-001',
    name: 'History & Civics',
    code: 'HIS-101',
    category: 'Core',
  ),
  const BranchSubjectEntity(
    id: 'SUB-006',
    branchId: 'BR-001',
    name: 'Computer Applications',
    code: 'CS-101',
    category: 'Lab',
  ),
  // Mumbai Branch
  const BranchSubjectEntity(
    id: 'SUB-007',
    branchId: 'BR-002',
    name: 'Mathematics',
    code: 'MATH-201',
    category: 'Core',
  ),
  const BranchSubjectEntity(
    id: 'SUB-008',
    branchId: 'BR-002',
    name: 'English Language',
    code: 'ENG-201',
    category: 'Core',
  ),
  const BranchSubjectEntity(
    id: 'SUB-009',
    branchId: 'BR-002',
    name: 'Environmental Science',
    code: 'EVS-201',
    category: 'Core',
  ),
];

final List<SubjectAllocationEntity> _defaultSubjectAllocations = [
  const SubjectAllocationEntity(
    id: 'ALC-001',
    branchId: 'BR-001',
    classId: 'CLS-001',
    subjectName: 'Mathematics',
    periodsPerWeek: 6,
    assignedTeacherName: 'Mrs. Kavita Verma',
  ),
  const SubjectAllocationEntity(
    id: 'ALC-002',
    branchId: 'BR-001',
    classId: 'CLS-001',
    subjectName: 'English Literature',
    periodsPerWeek: 6,
    assignedTeacherName: 'Ms. Pooja Sharma',
  ),
  const SubjectAllocationEntity(
    id: 'ALC-003',
    branchId: 'BR-001',
    classId: 'CLS-001',
    subjectName: 'Physics Science',
    periodsPerWeek: 5,
    assignedTeacherName: 'Vikram Malhotra',
  ),
  const SubjectAllocationEntity(
    id: 'ALC-004',
    branchId: 'BR-001',
    classId: 'CLS-001',
    subjectName: 'History & Civics',
    periodsPerWeek: 4,
    assignedTeacherName: 'Sunita Sharma',
  ),
];

final List<TimetableSubstitutionEntity> _defaultSubstitutions = [
  const TimetableSubstitutionEntity(
    id: 'SUBST-001',
    branchId: 'BR-001',
    date: '2026-08-13',
    dayOfWeek: 'Thursday',
    periodName: 'Period 2',
    classId: 'CLS-001',
    sectionId: 'SEC-A-001',
    originalTeacherName: 'Ms. Pooja Sharma',
    substituteTeacherName: 'Sunita Sharma',
    reason: 'Sick Leave',
    status: 'Assigned',
  ),
];

// ─── State Notifiers ─────────────────────────────

class BranchSubjectsNotifier extends StateNotifier<List<BranchSubjectEntity>> {
  BranchSubjectsNotifier() : super(_defaultBranchSubjects);

  void addSubject({
    required String branchId,
    required String name,
    required String code,
    String category = 'Core',
  }) {
    final newSub = BranchSubjectEntity(
      id: 'SUB-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      name: name,
      code: code,
      category: category,
    );
    state = [...state, newSub];
  }

  void removeSubject(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final branchSubjectsProvider =
    StateNotifierProvider<BranchSubjectsNotifier, List<BranchSubjectEntity>>((
      ref,
    ) {
      return BranchSubjectsNotifier();
    });

class SubjectAllocationsNotifier
    extends StateNotifier<List<SubjectAllocationEntity>> {
  SubjectAllocationsNotifier() : super(_defaultSubjectAllocations);

  void setAllocation({
    required String branchId,
    required String classId,
    required String subjectName,
    required int periodsPerWeek,
    required String assignedTeacherName,
  }) {
    final existingIdx = state.indexWhere(
      (a) =>
          a.branchId == branchId &&
          a.classId == classId &&
          a.subjectName == subjectName,
    );
    if (existingIdx != -1) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIdx)
            state[i].copyWith(
              periodsPerWeek: periodsPerWeek,
              assignedTeacherName: assignedTeacherName,
            )
          else
            state[i],
      ];
    } else {
      final newAlloc = SubjectAllocationEntity(
        id: 'ALC-${DateTime.now().millisecondsSinceEpoch}',
        branchId: branchId,
        classId: classId,
        subjectName: subjectName,
        periodsPerWeek: periodsPerWeek,
        assignedTeacherName: assignedTeacherName,
      );
      state = [...state, newAlloc];
    }
  }
}

final subjectAllocationsProvider =
    StateNotifierProvider<
      SubjectAllocationsNotifier,
      List<SubjectAllocationEntity>
    >((ref) {
      return SubjectAllocationsNotifier();
    });

class TimetableSubstitutionsNotifier
    extends StateNotifier<List<TimetableSubstitutionEntity>> {
  TimetableSubstitutionsNotifier() : super(_defaultSubstitutions);

  void assignSubstitution({
    required String branchId,
    required String date,
    required String dayOfWeek,
    required String periodName,
    required String classId,
    required String sectionId,
    required String originalTeacherName,
    required String substituteTeacherName,
    required String reason,
  }) {
    final newSubst = TimetableSubstitutionEntity(
      id: 'SUBST-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      date: date,
      dayOfWeek: dayOfWeek,
      periodName: periodName,
      classId: classId,
      sectionId: sectionId,
      originalTeacherName: originalTeacherName,
      substituteTeacherName: substituteTeacherName,
      reason: reason,
      status: 'Assigned',
    );
    state = [newSubst, ...state];
  }
}

final timetableSubstitutionsProvider =
    StateNotifierProvider<
      TimetableSubstitutionsNotifier,
      List<TimetableSubstitutionEntity>
    >((ref) {
      return TimetableSubstitutionsNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Timetable Versioning & Snapshot History Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class TimetableVersionEntity {
  final String id;
  final String branchId;
  final String versionName;
  final String description;
  final DateTime createdAt;
  final String createdBy;
  final bool isPublished;
  final List<TimetableSlotEntity> slotsData;

  const TimetableVersionEntity({
    required this.id,
    required this.branchId,
    required this.versionName,
    required this.description,
    required this.createdAt,
    required this.createdBy,
    this.isPublished = false,
    required this.slotsData,
  });
}

class TimetableVersionsNotifier
    extends StateNotifier<List<TimetableVersionEntity>> {
  TimetableVersionsNotifier()
      : super([
          TimetableVersionEntity(
            id: 'VER-001',
            branchId: 'BR-001',
            versionName: 'v1.0 - Academic Launch Baseline',
            description: 'Original baseline schedule for Term 1',
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
            createdBy: 'Branch Principal',
            isPublished: true,
            slotsData: _defaultTimetableSlots,
          ),
        ]);

  void createSnapshot({
    required String branchId,
    required String versionName,
    required String description,
    required String createdBy,
    required List<TimetableSlotEntity> currentSlots,
  }) {
    final version = TimetableVersionEntity(
      id: 'VER-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      versionName: versionName,
      description: description,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      isPublished: true,
      slotsData: currentSlots,
    );
    state = [version, ...state];
  }
}

final timetableVersionsProvider =
    StateNotifierProvider<
      TimetableVersionsNotifier,
      List<TimetableVersionEntity>
    >((ref) {
      return TimetableVersionsNotifier();
    });

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Organization Master Timetable Template Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class OrganizationTimetableTemplateEntity {
  final String id;
  final String templateName;
  final String description;
  final int totalPeriodsPerDay;
  final DateTime createdAt;
  final List<TimetableSlotEntity> templateSlots;
  final List<String> appliedBranchIds;

  const OrganizationTimetableTemplateEntity({
    required this.id,
    required this.templateName,
    required this.description,
    this.totalPeriodsPerDay = 8,
    required this.createdAt,
    required this.templateSlots,
    this.appliedBranchIds = const [],
  });

  OrganizationTimetableTemplateEntity copyWith({
    String? id,
    String? templateName,
    String? description,
    int? totalPeriodsPerDay,
    DateTime? createdAt,
    List<TimetableSlotEntity>? templateSlots,
    List<String>? appliedBranchIds,
  }) {
    return OrganizationTimetableTemplateEntity(
      id: id ?? this.id,
      templateName: templateName ?? this.templateName,
      description: description ?? this.description,
      totalPeriodsPerDay: totalPeriodsPerDay ?? this.totalPeriodsPerDay,
      createdAt: createdAt ?? this.createdAt,
      templateSlots: templateSlots ?? this.templateSlots,
      appliedBranchIds: appliedBranchIds ?? this.appliedBranchIds,
    );
  }
}

class OrgTimetableTemplatesNotifier
    extends StateNotifier<List<OrganizationTimetableTemplateEntity>> {
  OrgTimetableTemplatesNotifier()
      : super([
          OrganizationTimetableTemplateEntity(
            id: 'TMPL-001',
            templateName: 'Standard CBSE High School 8-Period Model',
            description:
                'Recommended master template with core subjects, STEM lab blocks, and 45-min periods.',
            totalPeriodsPerDay: 8,
            createdAt: DateTime(2026, 1, 1),
            templateSlots: _defaultTimetableSlots,
            appliedBranchIds: const ['BR-001'],
          ),
        ]);

  void createTemplate({
    required String name,
    required String description,
    required List<TimetableSlotEntity> slots,
  }) {
    final newTemplate = OrganizationTimetableTemplateEntity(
      id: 'TMPL-${DateTime.now().millisecondsSinceEpoch}',
      templateName: name,
      description: description,
      createdAt: DateTime.now(),
      templateSlots: slots,
    );
    state = [newTemplate, ...state];
  }

  void markPushedToBranch(String templateId, String branchId) {
    state = [
      for (final t in state)
        if (t.id == templateId && !t.appliedBranchIds.contains(branchId))
          t.copyWith(appliedBranchIds: [...t.appliedBranchIds, branchId])
        else
          t,
    ];
  }
}

final orgTimetableTemplatesProvider = StateNotifierProvider<
  OrgTimetableTemplatesNotifier,
  List<OrganizationTimetableTemplateEntity>
>((ref) {
  return OrgTimetableTemplatesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// AI Substitute Recommendation Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class SubstituteRecommendation {
  final String teacherName;
  final String designation;
  final int dailyLecturesCount;
  final bool isSubjectExpert;
  final String matchReason;
  final int matchScore; // Higher score = better candidate

  const SubstituteRecommendation({
    required this.teacherName,
    required this.designation,
    required this.dailyLecturesCount,
    required this.isSubjectExpert,
    required this.matchReason,
    required this.matchScore,
  });
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Special Day Timetable Model (Exam day, event day)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class SpecialDaySlotEntity {
  final String id;
  final String classId;
  final String sectionId;
  final String startTime;
  final String endTime;
  final String activityOrExamName;
  final String supervisorOrTeacherName;
  final String roomNumber;

  const SpecialDaySlotEntity({
    required this.id,
    required this.classId,
    required this.sectionId,
    required this.startTime,
    required this.endTime,
    required this.activityOrExamName,
    required this.supervisorOrTeacherName,
    required this.roomNumber,
  });
}

class SpecialDayTimetableEntity {
  final String id;
  final String branchId;
  final DateTime date;
  final String name;
  final String type; // 'Exam Day', 'Event Day', 'Other'
  final String description;
  final List<SpecialDaySlotEntity> slots;

  const SpecialDayTimetableEntity({
    required this.id,
    required this.branchId,
    required this.date,
    required this.name,
    required this.type,
    required this.description,
    required this.slots,
  });

  SpecialDayTimetableEntity copyWith({
    String? id,
    String? branchId,
    DateTime? date,
    String? name,
    String? type,
    String? description,
    List<SpecialDaySlotEntity>? slots,
  }) {
    return SpecialDayTimetableEntity(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      date: date ?? this.date,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      slots: slots ?? this.slots,
    );
  }
}

class SpecialDayTimetableNotifier
    extends StateNotifier<List<SpecialDayTimetableEntity>> {
  SpecialDayTimetableNotifier()
    : super([
        SpecialDayTimetableEntity(
          id: 'SD-001',
          branchId: 'BR-001',
          date: DateTime(2026, 8, 20),
          name: 'Term 1 Mid-Term Examination (Day 1)',
          type: 'Exam Day',
          description:
              'Morning session for standard mid-term exams across high school classes.',
          slots: const [
            SpecialDaySlotEntity(
              id: 'SDS-001',
              classId: 'CL-001', // Class 10
              sectionId: 'SEC-001', // 10-A
              startTime: '08:30 AM',
              endTime: '11:30 AM',
              activityOrExamName: 'Mathematics Paper 1',
              supervisorOrTeacherName: 'Sunita Sharma',
              roomNumber: 'Room 201',
            ),
            SpecialDaySlotEntity(
              id: 'SDS-002',
              classId: 'CL-002', // Class 11
              sectionId: 'SEC-002', // 11-A
              startTime: '08:30 AM',
              endTime: '11:30 AM',
              activityOrExamName: 'Physics Exam',
              supervisorOrTeacherName: 'Anil Verma',
              roomNumber: 'Physics Lab',
            ),
          ],
        ),
        SpecialDayTimetableEntity(
          id: 'SD-002',
          branchId: 'BR-001',
          date: DateTime(2026, 8, 25),
          name: 'Inter-House Sports Meet & Athletics Day',
          type: 'Event Day',
          description:
              'All-day branch sports activities. Standard classes suspended.',
          slots: const [
            SpecialDaySlotEntity(
              id: 'SDS-003',
              classId: 'CL-001',
              sectionId: 'SEC-001',
              startTime: '09:00 AM',
              endTime: '12:00 PM',
              activityOrExamName: 'Track & Field Finals',
              supervisorOrTeacherName: 'Rajesh Kumar',
              roomNumber: 'Main Playground',
            ),
          ],
        ),
      ]);

  void addSpecialDay(SpecialDayTimetableEntity specialDay) {
    state = [...state, specialDay];
  }

  void removeSpecialDay(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void addSlotToSpecialDay(String specialDayId, SpecialDaySlotEntity slot) {
    state = [
      for (final sd in state)
        if (sd.id == specialDayId)
          sd.copyWith(slots: [...sd.slots, slot])
        else
          sd,
    ];
  }

  void removeSlotFromSpecialDay(String specialDayId, String slotId) {
    state = [
      for (final sd in state)
        if (sd.id == specialDayId)
          sd.copyWith(slots: sd.slots.where((s) => s.id != slotId).toList())
        else
          sd,
    ];
  }
}

final specialDayTimetableProvider = StateNotifierProvider<
  SpecialDayTimetableNotifier,
  List<SpecialDayTimetableEntity>
>((ref) {
  return SpecialDayTimetableNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Co-Curricular Activity Scheduling Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class CoCurricularActivityEntity {
  final String id;
  final String branchId;
  final String activityName;
  final String instructorName;
  final String dayOfWeek; // e.g. 'Wednesday'
  final String timeSlot; // e.g. '02:00 PM - 03:30 PM'
  final String venue; // e.g. 'Auditorium', 'Robotics Lab'
  final int maxCapacity;

  const CoCurricularActivityEntity({
    required this.id,
    required this.branchId,
    required this.activityName,
    required this.instructorName,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.venue,
    this.maxCapacity = 30,
  });

  CoCurricularActivityEntity copyWith({
    String? id,
    String? branchId,
    String? activityName,
    String? instructorName,
    String? dayOfWeek,
    String? timeSlot,
    String? venue,
    int? maxCapacity,
  }) {
    return CoCurricularActivityEntity(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      activityName: activityName ?? this.activityName,
      instructorName: instructorName ?? this.instructorName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      timeSlot: timeSlot ?? this.timeSlot,
      venue: venue ?? this.venue,
      maxCapacity: maxCapacity ?? this.maxCapacity,
    );
  }
}

class CoCurricularActivitiesNotifier
    extends StateNotifier<List<CoCurricularActivityEntity>> {
  CoCurricularActivitiesNotifier()
    : super([
        const CoCurricularActivityEntity(
          id: 'CC-001',
          branchId: 'BR-001',
          activityName: 'Robotics & STEM Club',
          instructorName: 'Manish Rawat',
          dayOfWeek: 'Wednesday',
          timeSlot: '02:00 PM - 03:30 PM',
          venue: 'Robotics Lab',
          maxCapacity: 25,
        ),
        const CoCurricularActivityEntity(
          id: 'CC-002',
          branchId: 'BR-001',
          activityName: 'Classical Fusion Music & Choir',
          instructorName: 'Nisha Mehta',
          dayOfWeek: 'Friday',
          timeSlot: '01:30 PM - 03:00 PM',
          venue: 'Music Room Block C',
          maxCapacity: 40,
        ),
        const CoCurricularActivityEntity(
          id: 'CC-003',
          branchId: 'BR-001',
          activityName: 'Visual Arts & Clay Modeling',
          instructorName: 'Ramesh Sen',
          dayOfWeek: 'Monday',
          timeSlot: '02:00 PM - 03:30 PM',
          venue: 'Art Studio',
          maxCapacity: 20,
        ),
      ]);

  void addActivity(CoCurricularActivityEntity activity) {
    state = [...state, activity];
  }

  void removeActivity(String id) {
    state = state.where((a) => a.id != id).toList();
  }
}

final coCurricularActivitiesProvider = StateNotifierProvider<
  CoCurricularActivitiesNotifier,
  List<CoCurricularActivityEntity>
>((ref) {
  return CoCurricularActivitiesNotifier();
});

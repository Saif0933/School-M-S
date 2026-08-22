import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../staff/providers.dart' as staff_prov;
import '../organization/providers.dart';
import '../organization/data/repositories/organization_repository.dart';

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

  // Mumbai Class Sections
  const SectionEntity(
    id: 'SEC-A-008',
    classId: 'CLS-008',
    name: 'A',
    roomNumber: 'M-101',
    classTeacher: 'Mrs. Rekha Rao',
    maxStudentsCapacity: 35,
  ),
  const SectionEntity(
    id: 'SEC-A-009',
    classId: 'CLS-009',
    name: 'A',
    roomNumber: 'M-201',
    classTeacher: 'Mr. Manoj Bajpayee',
    maxStudentsCapacity: 35,
  ),
  const SectionEntity(
    id: 'SEC-A-010',
    classId: 'CLS-010',
    name: 'A',
    roomNumber: 'M-301',
    classTeacher: 'Mrs. Madhuri Dixit',
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

  // Mumbai Class 1 Students
  const StudentEntity(
    id: 'STU-008',
    branchId: 'BR-002',
    classId: 'CLS-008',
    sectionId: 'SEC-A-008',
    name: 'Sachin Tendulkar',
    admissionNumber: 'ADM-MUM-001',
    rollNumber: '101',
  ),
  // Mumbai Class 10 Students
  const StudentEntity(
    id: 'STU-009',
    branchId: 'BR-002',
    classId: 'CLS-010',
    sectionId: 'SEC-A-010',
    name: 'Lata Mangeshkar',
    admissionNumber: 'ADM-MUM-002',
    rollNumber: '201',
  ),
];

class AcademicStudentsNotifier extends StateNotifier<List<StudentEntity>> {
  final OrganizationRepository _repository;

  AcademicStudentsNotifier(this._repository) : super(_defaultStudents);

  Future<void> fetchStudents(String branchId) async {
    try {
      final list = await _repository.fetchStudents(branchId);
      state = list.map((item) {
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item as Map);
        final String firstName = itemMap['firstName'] ?? 'Student';
        final String lastName = itemMap['lastName'] ?? '';
        final String name = lastName.isNotEmpty ? '$firstName $lastName' : firstName;
        
        final dobStr = itemMap['dob'];
        final dobParsed = dobStr != null ? DateTime.tryParse(dobStr.toString()) : null;
        final dobFormatted = dobParsed != null ? '${dobParsed.year}-${dobParsed.month.toString().padLeft(2, '0')}-${dobParsed.day.toString().padLeft(2, '0')}' : '2015-05-10';

        final admissionDateStr = itemMap['admissionDate'];
        final admissionDateParsed = admissionDateStr != null ? DateTime.tryParse(admissionDateStr.toString()) : null;
        final admissionDateFormatted = admissionDateParsed != null ? '${admissionDateParsed.year}-${admissionDateParsed.month.toString().padLeft(2, '0')}-${admissionDateParsed.day.toString().padLeft(2, '0')}' : '2026-04-01';

        String email = 'student@example.com';
        if (itemMap['users'] != null && (itemMap['users'] as List).isNotEmpty) {
          final usersList = itemMap['users'] as List;
          final userMap = Map<String, dynamic>.from(usersList[0] as Map);
          email = userMap['email'] ?? email;
        }

        return StudentEntity(
          id: itemMap['id'] ?? '',
          branchId: itemMap['branchId'] ?? branchId,
          classId: itemMap['classId'] ?? 'CLS-001',
          sectionId: itemMap['sectionId'] ?? 'SEC-A-001',
          name: name,
          admissionNumber: itemMap['admissionNumber'] ?? '',
          rollNumber: itemMap['rollNumber'] ?? '',
          gender: itemMap['gender']?.toString().toLowerCase() == 'female' ? 'Female' : 'Male',
          dateOfBirth: dobFormatted,
          bloodGroup: 'O+',
          guardianName: 'Parent Guardian',
          phone: itemMap['phone'] ?? '+91 99999 88888',
          email: email,
          address: itemMap['address'] ?? '123 School Lane',
          admissionDate: admissionDateFormatted,
          isActive: itemMap['status']?.toString().toUpperCase() == 'ACTIVE',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching students: $e');
    }
  }

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

  Future<void> updateStudentProfile(String studentId, StudentEntity updated) async {
    try {
      final Map<String, dynamic> updateData = {
        'firstName': updated.name.split(' ').first,
        'lastName': updated.name.split(' ').length > 1 ? updated.name.split(' ').sublist(1).join(' ') : 'Student',
        'admissionNumber': updated.admissionNumber,
        'rollNumber': updated.rollNumber,
        'dob': DateTime.tryParse(updated.dateOfBirth)?.toIso8601String() ?? DateTime(2015, 5, 10).toIso8601String(),
        'gender': updated.gender.toUpperCase() == 'FEMALE' ? 'FEMALE' : 'MALE',
        'category': 'General',
        'email': updated.email,
        'phone': updated.phone,
        'sectionId': updated.sectionId,
      };

      final success = await _repository.updateStudent(studentId, updateData);
      if (success) {
        state = state.map((s) => s.id == studentId ? updated : s).toList();
      }
    } catch (e) {
      debugPrint('Error updating student: $e');
    }
  }

  // Generate roll numbers alphabetically inside a specific section
  void autoGenerateRollNumbers(String classId, String sectionId) {
    final sectionStudents = state
        .where((s) => s.classId == classId && s.sectionId == sectionId)
        .toList();
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
          rollNumber: '',
        );
      }
      return s;
    }).toList();
  }

  Future<void> removeStudent(String id) async {
    try {
      final success = await _repository.deleteStudent(id);
      if (success) {
        state = state.where((s) => s.id != id).toList();
      }
    } catch (e) {
      debugPrint('Error removing student: $e');
    }
  }
}

final academicStudentsProvider =
    StateNotifierProvider<AcademicStudentsNotifier, List<StudentEntity>>((ref) {
      final repo = ref.read(organizationRepositoryProvider);
      return AcademicStudentsNotifier(repo);
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

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Biometric / RFID Device Model (Branch-Mapped)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BiometricDeviceEntity {
  final String id;
  final String branchId;
  final String name;
  final String type; // 'Biometric', 'RFID', 'Facial Recognition', 'Mobile App'
  final String location;
  final String serialNumber;
  final String status; // 'Online', 'Offline', 'Maintenance'
  final String lastSynced;

  const BiometricDeviceEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.type,
    required this.location,
    required this.serialNumber,
    required this.status,
    required this.lastSynced,
  });

  BiometricDeviceEntity copyWith({
    String? name,
    String? type,
    String? location,
    String? serialNumber,
    String? status,
    String? lastSynced,
  }) {
    return BiometricDeviceEntity(
      id: id,
      branchId: branchId,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }
}

final List<BiometricDeviceEntity> _defaultDevices = [
  const BiometricDeviceEntity(
    id: 'DEV-001', branchId: 'BR-001',
    name: 'Main Gate Fingerprint Scanner', type: 'Biometric',
    location: 'Main Entrance Gate', serialNumber: 'ZK-BIO-9821-A',
    status: 'Online', lastSynced: '2026-08-14T08:00:00',
  ),
  const BiometricDeviceEntity(
    id: 'DEV-002', branchId: 'BR-001',
    name: 'Staff Room RFID Reader', type: 'RFID',
    location: 'Staff Room — Block A', serialNumber: 'RFID-HID-4410-B',
    status: 'Online', lastSynced: '2026-08-14T07:55:00',
  ),
  const BiometricDeviceEntity(
    id: 'DEV-003', branchId: 'BR-001',
    name: 'Secondary Block Facial Scanner', type: 'Facial Recognition',
    location: 'Secondary Block Entry', serialNumber: 'FACE-AI-7730-C',
    status: 'Offline', lastSynced: '2026-08-13T15:30:00',
  ),
  const BiometricDeviceEntity(
    id: 'DEV-004', branchId: 'BR-002',
    name: 'Mumbai Gate Biometric', type: 'Biometric',
    location: 'Main Gate, Mumbai', serialNumber: 'ZK-BIO-5502-D',
    status: 'Online', lastSynced: '2026-08-14T08:05:00',
  ),
];

class BiometricDevicesNotifier extends StateNotifier<List<BiometricDeviceEntity>> {
  BiometricDevicesNotifier() : super(_defaultDevices);

  void addDevice(BiometricDeviceEntity device) => state = [...state, device];

  void updateDevice(String id, BiometricDeviceEntity updated) =>
      state = state.map((d) => d.id == id ? updated : d).toList();

  void removeDevice(String id) => state = state.where((d) => d.id != id).toList();

  void toggleDeviceStatus(String id) {
    state = state.map((d) {
      if (d.id == id) {
        return d.copyWith(status: d.status == 'Online' ? 'Offline' : 'Online');
      }
      return d;
    }).toList();
  }

  void syncDevice(String id) {
    final now = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
    state = state.map((d) => d.id == id ? d.copyWith(lastSynced: now, status: 'Online') : d).toList();
  }
}

final biometricDevicesProvider =
    StateNotifierProvider<BiometricDevicesNotifier, List<BiometricDeviceEntity>>((ref) {
  return BiometricDevicesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Attendance Record Model (Branch-Scoped)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StudentAttendanceRecordEntity {
  final String id;
  final String branchId;
  final String classId;
  final String sectionId;
  final String studentId;
  final String studentName;
  final String rollNumber;
  final DateTime date;
  final String period; // e.g. 'Period 1', 'All Day'
  final String subjectName;
  final String status; // 'Present', 'Absent', 'Late', 'HalfDay', 'EarlyDeparture'
  final String arrivalTime;
  final String departureTime;
  final String inputMethod; // 'Manual', 'Biometric', 'RFID', 'Facial', 'MobileApp'
  final String markedBy;
  final String remarks;

  const StudentAttendanceRecordEntity({
    required this.id,
    required this.branchId,
    required this.classId,
    required this.sectionId,
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.date,
    required this.period,
    required this.subjectName,
    required this.status,
    this.arrivalTime = '',
    this.departureTime = '',
    this.inputMethod = 'Manual',
    this.markedBy = 'Class Teacher',
    this.remarks = '',
  });

  StudentAttendanceRecordEntity copyWith({
    String? status,
    String? arrivalTime,
    String? departureTime,
    String? inputMethod,
    String? markedBy,
    String? remarks,
    String? period,
    String? subjectName,
  }) {
    return StudentAttendanceRecordEntity(
      id: id, branchId: branchId, classId: classId, sectionId: sectionId,
      studentId: studentId, studentName: studentName, rollNumber: rollNumber,
      date: date,
      period: period ?? this.period,
      subjectName: subjectName ?? this.subjectName,
      status: status ?? this.status,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      inputMethod: inputMethod ?? this.inputMethod,
      markedBy: markedBy ?? this.markedBy,
      remarks: remarks ?? this.remarks,
    );
  }
}

class _SampleStudent {
  final String id, name, rollNo, classId, sectionId, branchId;
  const _SampleStudent(this.id, this.name, this.rollNo, this.classId, this.sectionId, this.branchId);
}

const _sampleRoster = [
  _SampleStudent('STU-001', 'Aarav Sharma',  '01', 'CLS-001', 'SEC-001', 'BR-001'),
  _SampleStudent('STU-002', 'Priya Mehta',   '02', 'CLS-001', 'SEC-001', 'BR-001'),
  _SampleStudent('STU-003', 'Ravi Kumar',    '03', 'CLS-001', 'SEC-001', 'BR-001'),
  _SampleStudent('STU-004', 'Sneha Patel',   '04', 'CLS-001', 'SEC-001', 'BR-001'),
  _SampleStudent('STU-005', 'Arjun Singh',   '05', 'CLS-001', 'SEC-001', 'BR-001'),
  _SampleStudent('STU-006', 'Kavya Nair',    '06', 'CLS-001', 'SEC-001', 'BR-001'),
  _SampleStudent('STU-007', 'Farhan Ali',    '07', 'CLS-001', 'SEC-002', 'BR-001'),
  _SampleStudent('STU-008', 'Deepa Roy',     '08', 'CLS-001', 'SEC-002', 'BR-001'),
];

List<StudentAttendanceRecordEntity> _buildDefaultStudentAttendance() {
  final records = <StudentAttendanceRecordEntity>[];
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  const todayStatuses = ['Present', 'Present', 'Present', 'Late', 'Present', 'Absent', 'Present', 'Present'];

  for (int i = 0; i < _sampleRoster.length; i++) {
    final s = _sampleRoster[i];
    final status = todayStatuses[i];
    records.add(StudentAttendanceRecordEntity(
      id: 'ATT-T-$i', branchId: s.branchId, classId: s.classId, sectionId: s.sectionId,
      studentId: s.id, studentName: s.name, rollNumber: s.rollNo,
      date: today, period: 'All Day', subjectName: 'General',
      status: status,
      arrivalTime: status == 'Late' ? '08:45 AM' : '08:00 AM',
      departureTime: '03:30 PM',
      inputMethod: i % 3 == 0 ? 'Biometric' : (i % 3 == 1 ? 'RFID' : 'Manual'),
      markedBy: 'Mrs. Rupa Ganguly',
    ));
    records.add(StudentAttendanceRecordEntity(
      id: 'ATT-Y-$i', branchId: s.branchId, classId: s.classId, sectionId: s.sectionId,
      studentId: s.id, studentName: s.name, rollNumber: s.rollNo,
      date: yesterday, period: 'All Day', subjectName: 'General',
      status: i == 5 ? 'Absent' : 'Present',
      arrivalTime: '08:00 AM', departureTime: '03:30 PM',
      inputMethod: 'Manual', markedBy: 'Mrs. Rupa Ganguly',
    ));
  }
  return records;
}

class StudentAttendanceNotifier extends StateNotifier<List<StudentAttendanceRecordEntity>> {
  StudentAttendanceNotifier() : super(_buildDefaultStudentAttendance());

  void markAttendance(StudentAttendanceRecordEntity record) {
    final existing = state.indexWhere((r) =>
        r.studentId == record.studentId &&
        r.classId == record.classId &&
        r.sectionId == record.sectionId &&
        r.date.year == record.date.year &&
        r.date.month == record.date.month &&
        r.date.day == record.date.day &&
        r.period == record.period);
    if (existing >= 0) {
      final updated = List<StudentAttendanceRecordEntity>.from(state);
      updated[existing] = record;
      state = updated;
    } else {
      state = [...state, record];
    }
  }

  void markBulk(List<StudentAttendanceRecordEntity> records) {
    final updatedState = List<StudentAttendanceRecordEntity>.from(state);
    for (final record in records) {
      final idx = updatedState.indexWhere((r) =>
          r.studentId == record.studentId &&
          r.date.year == record.date.year &&
          r.date.month == record.date.month &&
          r.date.day == record.date.day &&
          r.period == record.period);
      if (idx >= 0) {
        updatedState[idx] = record;
      } else {
        updatedState.add(record);
      }
    }
    state = updatedState;
  }

  double getPercent(String studentId, String branchId) {
    final recs = state.where((r) => r.studentId == studentId && r.branchId == branchId).toList();
    if (recs.isEmpty) return 0;
    final present = recs.where((r) => r.status == 'Present' || r.status == 'Late' || r.status == 'HalfDay').length;
    return (present / recs.length) * 100;
  }
}

final studentAttendanceProvider =
    StateNotifierProvider<StudentAttendanceNotifier, List<StudentAttendanceRecordEntity>>((ref) {
  return StudentAttendanceNotifier();
});

final studentRosterProvider = Provider<List<_SampleStudent>>((ref) => _sampleRoster);

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Staff Attendance Record Model (Branch-Scoped)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StaffAttendanceRecordEntity {
  final String id;
  final String branchId;
  final String staffId;
  final String staffName;
  final String designation;
  final DateTime date;
  final String status; // 'Present', 'Absent', 'Late', 'HalfDay', 'OnLeave'
  final String arrivalTime;
  final String departureTime;
  final String inputMethod;
  final String markedBy;
  final String remarks;

  const StaffAttendanceRecordEntity({
    required this.id,
    required this.branchId,
    required this.staffId,
    required this.staffName,
    required this.designation,
    required this.date,
    required this.status,
    this.arrivalTime = '',
    this.departureTime = '',
    this.inputMethod = 'Biometric',
    this.markedBy = 'System',
    this.remarks = '',
  });

  StaffAttendanceRecordEntity copyWith({
    String? status,
    String? arrivalTime,
    String? departureTime,
    String? inputMethod,
    String? markedBy,
    String? remarks,
  }) {
    return StaffAttendanceRecordEntity(
      id: id, branchId: branchId, staffId: staffId, staffName: staffName,
      designation: designation, date: date,
      status: status ?? this.status,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      inputMethod: inputMethod ?? this.inputMethod,
      markedBy: markedBy ?? this.markedBy,
      remarks: remarks ?? this.remarks,
    );
  }
}

List<StaffAttendanceRecordEntity> _buildDefaultStaffAttendance() {
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  final seed = [
    ('STF-001', 'Mrs. Rupa Ganguly',   'Class Teacher',    'BR-001'),
    ('STF-002', 'Mr. Alok Nath',       'HOD Secondary',    'BR-001'),
    ('STF-004', 'Dr. Priya Sharma',    'Senior Teacher',   'BR-001'),
    ('STF-005', 'Mr. Vijay Rao',       'Lab Instructor',   'BR-001'),
  ];
  const todayS = ['Present', 'Present', 'Late', 'Absent'];
  const yestS  = ['Present', 'Present', 'Present', 'OnLeave'];
  final records = <StaffAttendanceRecordEntity>[];
  for (int i = 0; i < seed.length; i++) {
    final s = seed[i];
    records.add(StaffAttendanceRecordEntity(
      id: 'SAT-T-$i', branchId: s.$4, staffId: s.$1,
      staffName: s.$2, designation: s.$3, date: today,
      status: todayS[i],
      arrivalTime: todayS[i] == 'Late' ? '09:15 AM' : (todayS[i] == 'Absent' ? '' : '07:45 AM'),
      departureTime: todayS[i] == 'Absent' ? '' : '04:00 PM',
      inputMethod: i % 2 == 0 ? 'Biometric' : 'RFID',
    ));
    records.add(StaffAttendanceRecordEntity(
      id: 'SAT-Y-$i', branchId: s.$4, staffId: s.$1,
      staffName: s.$2, designation: s.$3, date: yesterday,
      status: yestS[i],
      arrivalTime: yestS[i] == 'OnLeave' ? '' : '07:45 AM',
      departureTime: yestS[i] == 'OnLeave' ? '' : '04:00 PM',
      inputMethod: 'Biometric',
    ));
  }
  return records;
}

class StaffAttendanceNotifier extends StateNotifier<List<StaffAttendanceRecordEntity>> {
  StaffAttendanceNotifier() : super(_buildDefaultStaffAttendance());

  void markAttendance(StaffAttendanceRecordEntity record) {
    final idx = state.indexWhere((r) =>
        r.staffId == record.staffId &&
        r.date.year == record.date.year &&
        r.date.month == record.date.month &&
        r.date.day == record.date.day);
    if (idx >= 0) {
      final updated = List<StaffAttendanceRecordEntity>.from(state);
      updated[idx] = record;
      state = updated;
    } else {
      state = [...state, record];
    }
  }

  void markBulk(List<StaffAttendanceRecordEntity> records) {
    final updatedState = List<StaffAttendanceRecordEntity>.from(state);
    for (final record in records) {
      final idx = updatedState.indexWhere((r) =>
          r.staffId == record.staffId &&
          r.date.year == record.date.year &&
          r.date.month == record.date.month &&
          r.date.day == record.date.day);
      if (idx >= 0) {
        updatedState[idx] = record;
      } else {
        updatedState.add(record);
      }
    }
    state = updatedState;
  }

  double getPercent(String staffId, String branchId) {
    final recs = state.where((r) => r.staffId == staffId && r.branchId == branchId).toList();
    if (recs.isEmpty) return 0;
    final present = recs.where((r) => r.status == 'Present' || r.status == 'Late' || r.status == 'HalfDay').length;
    return (present / recs.length) * 100;
  }
}

final staffAttendanceProvider =
    StateNotifierProvider<StaffAttendanceNotifier, List<StaffAttendanceRecordEntity>>((ref) {
  return StaffAttendanceNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Attendance Configuration Model (Branch-Scoped)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AttendanceConfigEntity {
  final String branchId;
  final int lateGraceMinutes;
  final String halfDayCutoffTime;
  final double minAttendancePercent;
  final bool autoNotifyParents;
  final bool periodWiseEnabled;
  final bool subjectWiseEnabled;
  final List<String> enabledInputMethods;

  const AttendanceConfigEntity({
    required this.branchId,
    this.lateGraceMinutes = 15,
    this.halfDayCutoffTime = '12:00 PM',
    this.minAttendancePercent = 75.0,
    this.autoNotifyParents = true,
    this.periodWiseEnabled = true,
    this.subjectWiseEnabled = false,
    this.enabledInputMethods = const ['Manual', 'Biometric', 'RFID'],
  });

  AttendanceConfigEntity copyWith({
    int? lateGraceMinutes,
    String? halfDayCutoffTime,
    double? minAttendancePercent,
    bool? autoNotifyParents,
    bool? periodWiseEnabled,
    bool? subjectWiseEnabled,
    List<String>? enabledInputMethods,
  }) {
    return AttendanceConfigEntity(
      branchId: branchId,
      lateGraceMinutes: lateGraceMinutes ?? this.lateGraceMinutes,
      halfDayCutoffTime: halfDayCutoffTime ?? this.halfDayCutoffTime,
      minAttendancePercent: minAttendancePercent ?? this.minAttendancePercent,
      autoNotifyParents: autoNotifyParents ?? this.autoNotifyParents,
      periodWiseEnabled: periodWiseEnabled ?? this.periodWiseEnabled,
      subjectWiseEnabled: subjectWiseEnabled ?? this.subjectWiseEnabled,
      enabledInputMethods: enabledInputMethods ?? this.enabledInputMethods,
    );
  }
}

class AttendanceConfigNotifier extends StateNotifier<List<AttendanceConfigEntity>> {
  AttendanceConfigNotifier() : super(const [
    AttendanceConfigEntity(branchId: 'BR-001', lateGraceMinutes: 15, minAttendancePercent: 75.0, autoNotifyParents: true),
    AttendanceConfigEntity(branchId: 'BR-002', lateGraceMinutes: 10, minAttendancePercent: 80.0, autoNotifyParents: false),
  ]);

  AttendanceConfigEntity getForBranch(String branchId) {
    return state.firstWhere(
      (c) => c.branchId == branchId,
      orElse: () => AttendanceConfigEntity(branchId: branchId),
    );
  }

  void updateConfig(AttendanceConfigEntity config) {
    final idx = state.indexWhere((c) => c.branchId == config.branchId);
    if (idx >= 0) {
      final updated = List<AttendanceConfigEntity>.from(state);
      updated[idx] = config;
      state = updated;
    } else {
      state = [...state, config];
    }
  }
}

final attendanceConfigProvider =
    StateNotifierProvider<AttendanceConfigNotifier, List<AttendanceConfigEntity>>((ref) {
  return AttendanceConfigNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Parent Attendance Notification Entity & Provider
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AttendanceNotificationEntity {
  final String id;
  final String studentId;
  final String studentName;
  final String parentName;
  final DateTime date;
  final String status; // 'Sent', 'Pending', 'Failed'
  final String channel; // 'SMS', 'Email', 'App'
  final String sentAt;

  const AttendanceNotificationEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.parentName,
    required this.date,
    required this.status,
    required this.channel,
    required this.sentAt,
  });
}

class AttendanceNotificationsNotifier
    extends StateNotifier<List<AttendanceNotificationEntity>> {
  AttendanceNotificationsNotifier() : super([
    AttendanceNotificationEntity(
      id: 'N-001',
      studentId: 'STU-001',
      studentName: 'Aarav Sharma',
      parentName: 'Mr. Sharma',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Sent',
      channel: 'SMS',
      sentAt: '09:30 AM',
    ),
    AttendanceNotificationEntity(
      id: 'N-002',
      studentId: 'STU-005',
      studentName: 'Devendra Gowda',
      parentName: 'Mr. Gowda',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Sent',
      channel: 'Email',
      sentAt: '09:35 AM',
    ),
  ]);

  void logNotification({
    required String studentId,
    required String studentName,
    required String parentName,
    required String channel,
    required String status,
  }) {
    state = [
      ...state,
      AttendanceNotificationEntity(
        id: 'N-${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        studentName: studentName,
        parentName: parentName,
        date: DateTime.now(),
        status: status,
        channel: channel,
        sentAt: DateFormat('hh:mm a').format(DateTime.now()),
      ),
    ];
  }
}

final attendanceNotificationsProvider =
    StateNotifierProvider<AttendanceNotificationsNotifier, List<AttendanceNotificationEntity>>((ref) {
  return AttendanceNotificationsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Attendance Correction Request Entity & Provider
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AttendanceCorrectionRequestEntity {
  final String id;
  final String branchId;
  final String recordId;
  final String personId;
  final String personName;
  final String role; // 'Student', 'Staff'
  final DateTime date;
  final String period;
  final String requestedStatus;
  final String reason;
  final String requestedBy;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String reviewedBy;

  const AttendanceCorrectionRequestEntity({
    required this.id,
    required this.branchId,
    required this.recordId,
    required this.personId,
    required this.personName,
    required this.role,
    required this.date,
    required this.period,
    required this.requestedStatus,
    required this.reason,
    required this.requestedBy,
    required this.status,
    this.reviewedBy = '',
  });

  AttendanceCorrectionRequestEntity copyWith({
    String? status,
    String? reviewedBy,
  }) {
    return AttendanceCorrectionRequestEntity(
      id: id,
      branchId: branchId,
      recordId: recordId,
      personId: personId,
      personName: personName,
      role: role,
      date: date,
      period: period,
      requestedStatus: requestedStatus,
      reason: reason,
      requestedBy: requestedBy,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }
}

class AttendanceCorrectionRequestsNotifier
    extends StateNotifier<List<AttendanceCorrectionRequestEntity>> {
  final Ref ref;

  AttendanceCorrectionRequestsNotifier(this.ref) : super([
    AttendanceCorrectionRequestEntity(
      id: 'CR-001',
      branchId: 'BR-001',
      recordId: 'ATT-T-5',
      personId: 'STU-006',
      personName: 'Eshwar Iyer',
      role: 'Student',
      date: DateTime.now(),
      period: 'All Day',
      requestedStatus: 'Present',
      reason: 'Medical certificate submitted, was in clinic',
      requestedBy: 'Mrs. Rupa Ganguly',
      status: 'Pending',
    ),
    AttendanceCorrectionRequestEntity(
      id: 'CR-002',
      branchId: 'BR-001',
      recordId: 'SAT-T-2',
      personId: 'STF-004',
      personName: 'Dr. Priya Sharma',
      role: 'Staff',
      date: DateTime.now(),
      period: 'All Day',
      requestedStatus: 'Present',
      reason: 'Forgot to scan RFID card upon entry',
      requestedBy: 'Dr. Priya Sharma',
      status: 'Pending',
    ),
  ]);

  void requestCorrection({
    required String branchId,
    required String recordId,
    required String personId,
    required String personName,
    required String role,
    required DateTime date,
    required String period,
    required String requestedStatus,
    required String reason,
    required String requestedBy,
  }) {
    state = [
      ...state,
      AttendanceCorrectionRequestEntity(
        id: 'CR-${DateTime.now().millisecondsSinceEpoch}',
        branchId: branchId,
        recordId: recordId,
        personId: personId,
        personName: personName,
        role: role,
        date: date,
        period: period,
        requestedStatus: requestedStatus,
        reason: reason,
        requestedBy: requestedBy,
        status: 'Pending',
      ),
    ];
  }

  void approveRequest(String id, String reviewer) {
    state = state.map((r) {
      if (r.id == id && r.status == 'Pending') {
        final updated = r.copyWith(status: 'Approved', reviewedBy: reviewer);

        if (r.role == 'Student') {
          final students = ref.read(academicStudentsProvider);
          final student = students.firstWhere(
            (s) => s.id == r.personId,
            orElse: () => StudentEntity(
              id: r.personId,
              branchId: r.branchId,
              classId: '',
              sectionId: '',
              name: r.personName,
              admissionNumber: '',
              rollNumber: '',
            ),
          );

          ref.read(studentAttendanceProvider.notifier).markAttendance(
            StudentAttendanceRecordEntity(
              id: r.recordId.isNotEmpty ? r.recordId : 'ATT-CORR-${DateTime.now().millisecondsSinceEpoch}',
              branchId: r.branchId,
              classId: student.classId,
              sectionId: student.sectionId,
              studentId: r.personId,
              studentName: r.personName,
              rollNumber: student.rollNumber,
              date: r.date,
              period: r.period,
              subjectName: 'General',
              status: r.requestedStatus,
              inputMethod: 'Manual',
              markedBy: reviewer,
              remarks: 'Approved correction: ${r.reason}',
            ),
          );
        } else {
          final staffList = ref.read(staff_prov.staffProvider);
          final staff = staffList.firstWhere(
            (s) => s.id == r.personId,
            orElse: () => staff_prov.StaffEntity(
              id: r.personId,
              branchId: r.branchId,
              employeeId: '',
              name: r.personName,
              designation: 'Teacher',
              role: 'Teacher',
              dateOfJoining: '',
            ),
          );

          ref.read(staffAttendanceProvider.notifier).markAttendance(
            StaffAttendanceRecordEntity(
              id: r.recordId.isNotEmpty ? r.recordId : 'SAT-CORR-${DateTime.now().millisecondsSinceEpoch}',
              branchId: r.branchId,
              staffId: r.personId,
              staffName: r.personName,
              designation: staff.designation,
              date: r.date,
              status: r.requestedStatus,
              inputMethod: 'Manual',
              markedBy: reviewer,
              remarks: 'Approved correction: ${r.reason}',
            ),
          );
        }

        return updated;
      }
      return r;
    }).toList();
  }

  void rejectRequest(String id, String reviewer) {
    state = state.map((r) {
      if (r.id == id && r.status == 'Pending') {
        return r.copyWith(status: 'Rejected', reviewedBy: reviewer);
      }
      return r;
    }).toList();
  }
}

final attendanceCorrectionRequestsProvider =
    StateNotifierProvider<AttendanceCorrectionRequestsNotifier, List<AttendanceCorrectionRequestEntity>>((ref) {
  return AttendanceCorrectionRequestsNotifier(ref);
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Holiday Rule Entity & Provider
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HolidayRuleEntity {
  final String id;
  final String branchId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isAcademicDay; // e.g. true for sports day (attendance mandatory), false for holidays

  const HolidayRuleEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isAcademicDay,
  });
}

class HolidayRulesNotifier extends StateNotifier<List<HolidayRuleEntity>> {
  HolidayRulesNotifier() : super([
    HolidayRuleEntity(
      id: 'H-001',
      branchId: 'BR-001',
      name: 'Independence Day',
      startDate: DateTime(2026, 8, 15),
      endDate: DateTime(2026, 8, 15),
      isAcademicDay: false,
    ),
    HolidayRuleEntity(
      id: 'H-002',
      branchId: 'BR-001',
      name: 'Annual Sports Meet',
      startDate: DateTime(2026, 11, 20),
      endDate: DateTime(2026, 11, 21),
      isAcademicDay: true,
    ),
  ]);

  void addHolidayRule(HolidayRuleEntity rule) {
    state = [...state, rule];
  }

  void removeHolidayRule(String id) {
    state = state.where((h) => h.id != id).toList();
  }
}

final holidayRulesProvider =
    StateNotifierProvider<HolidayRulesNotifier, List<HolidayRuleEntity>>((ref) {
  return HolidayRulesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Leave Entity & Provider
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StudentLeaveEntity {
  final String id;
  final String studentId;
  final String branchId;
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'

  const StudentLeaveEntity({
    required this.id,
    required this.studentId,
    required this.branchId,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
  });
}

class StudentLeavesNotifier extends StateNotifier<List<StudentLeaveEntity>> {
  StudentLeavesNotifier() : super([
    StudentLeaveEntity(
      id: 'SL-001',
      studentId: 'STU-001',
      branchId: 'BR-001',
      leaveType: 'Medical',
      fromDate: DateTime.now().subtract(const Duration(days: 2)),
      toDate: DateTime.now().add(const Duration(days: 2)),
      reason: 'Recovering from Dengue fever',
      status: 'Approved',
    ),
    StudentLeaveEntity(
      id: 'SL-002',
      studentId: 'STU-003',
      branchId: 'BR-001',
      leaveType: 'Casual',
      fromDate: DateTime.now(),
      toDate: DateTime.now(),
      reason: 'Attending sibling\'s wedding',
      status: 'Approved',
    ),
  ]);

  void applyLeave(StudentLeaveEntity leave) {
    state = [...state, leave];
  }
}

final studentLeavesProvider =
    StateNotifierProvider<StudentLeavesNotifier, List<StudentLeaveEntity>>((ref) {
  return StudentLeavesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Fee Head Entity & Provider
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FeeHeadEntity {
  final String id;
  final String branchId;
  final String name;
  final String description;
  final double amount;
  final String category; // 'Admission', 'Tuition', 'Exam', 'Transport', 'Hostel', 'Other'

  const FeeHeadEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.description,
    required this.amount,
    required this.category,
  });

  FeeHeadEntity copyWith({
    String? name,
    String? description,
    double? amount,
    String? category,
  }) {
    return FeeHeadEntity(
      id: id,
      branchId: branchId,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
    );
  }
}

class FeeHeadsNotifier extends StateNotifier<List<FeeHeadEntity>> {
  FeeHeadsNotifier() : super([
    const FeeHeadEntity(
      id: 'FH-001',
      branchId: 'BR-001',
      name: 'Admission Fee',
      description: 'One-time admission registration fee',
      amount: 15000,
      category: 'Admission',
    ),
    const FeeHeadEntity(
      id: 'FH-002',
      branchId: 'BR-001',
      name: 'Tuition Fee (Q1)',
      description: 'Quarterly tuition fee charges',
      amount: 25000,
      category: 'Tuition',
    ),
    const FeeHeadEntity(
      id: 'FH-003',
      branchId: 'BR-001',
      name: 'Exam Fee',
      description: 'Annual term exam charges',
      amount: 3000,
      category: 'Exam',
    ),
    const FeeHeadEntity(
      id: 'FH-004',
      branchId: 'BR-001',
      name: 'Bus Transport',
      description: 'Monthly school bus charges',
      amount: 2500,
      category: 'Transport',
    ),

    // Mumbai branch Fee Heads
    const FeeHeadEntity(
      id: 'FH-005',
      branchId: 'BR-002',
      name: 'Admission Fee',
      description: 'One-time admission registration fee',
      amount: 12000,
      category: 'Admission',
    ),
    const FeeHeadEntity(
      id: 'FH-006',
      branchId: 'BR-002',
      name: 'Tuition Fee (Q1)',
      description: 'Quarterly tuition fee charges',
      amount: 22000,
      category: 'Tuition',
    ),
    const FeeHeadEntity(
      id: 'FH-007',
      branchId: 'BR-002',
      name: 'Hostel Fee',
      description: 'Monthly school hostel & boarding charges',
      amount: 8000,
      category: 'Hostel',
    ),
  ]);

  void addFeeHead(FeeHeadEntity head) {
    state = [...state, head];
  }

  void removeFeeHead(String id) {
    state = state.where((h) => h.id != id).toList();
  }
}

final feeHeadsProvider =
    StateNotifierProvider<FeeHeadsNotifier, List<FeeHeadEntity>>((ref) {
  return FeeHeadsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Fee Installment Plan Entity & Provider
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FeeInstallmentPlanEntity {
  final String id;
  final String branchId;
  final String name;
  final int installmentsCount;
  final String frequency; // 'Monthly', 'Quarterly', 'Half-Yearly', 'Annually'
  final double lateFeePercentage;
  final int graceDays;

  const FeeInstallmentPlanEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.installmentsCount,
    required this.frequency,
    required this.lateFeePercentage,
    required this.graceDays,
  });
}

class FeeInstallmentPlansNotifier
    extends StateNotifier<List<FeeInstallmentPlanEntity>> {
  FeeInstallmentPlansNotifier() : super([
    const FeeInstallmentPlanEntity(
      id: 'IP-001',
      branchId: 'BR-001',
      name: 'Monthly Standard',
      installmentsCount: 12,
      frequency: 'Monthly',
      lateFeePercentage: 2,
      graceDays: 5,
    ),
    const FeeInstallmentPlanEntity(
      id: 'IP-002',
      branchId: 'BR-001',
      name: 'Quarterly Saver',
      installmentsCount: 4,
      frequency: 'Quarterly',
      lateFeePercentage: 5,
      graceDays: 10,
    ),

    // Mumbai branch plans
    const FeeInstallmentPlanEntity(
      id: 'IP-003',
      branchId: 'BR-002',
      name: 'Monthly Flexi',
      installmentsCount: 12,
      frequency: 'Monthly',
      lateFeePercentage: 1.5,
      graceDays: 7,
    ),
    const FeeInstallmentPlanEntity(
      id: 'IP-004',
      branchId: 'BR-002',
      name: 'Half-Yearly Saver',
      installmentsCount: 2,
      frequency: 'Half-Yearly',
      lateFeePercentage: 4,
      graceDays: 15,
    ),
  ]);

  void addInstallmentPlan(FeeInstallmentPlanEntity plan) {
    state = [...state, plan];
  }
}

final feeInstallmentPlansProvider =
    StateNotifierProvider<FeeInstallmentPlansNotifier, List<FeeInstallmentPlanEntity>>((ref) {
  return FeeInstallmentPlansNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Fee Concession / Waiver Entity & Provider
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FeeConcessionEntity {
  final String id;
  final String branchId;
  final String name;
  final String type; // 'Percentage', 'FixedAmount'
  final double value;
  final String description;

  const FeeConcessionEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.type,
    required this.value,
    required this.description,
  });
}

class FeeConcessionsNotifier extends StateNotifier<List<FeeConcessionEntity>> {
  FeeConcessionsNotifier() : super([
    const FeeConcessionEntity(
      id: 'FC-001',
      branchId: 'BR-001',
      name: 'Merit Scholarship',
      type: 'Percentage',
      value: 50,
      description: '50% tuition waiver for academic top rankers',
    ),
    const FeeConcessionEntity(
      id: 'FC-002',
      branchId: 'BR-001',
      name: 'Staff Child Waiver',
      type: 'FixedAmount',
      value: 10000,
      description: 'Flat 10,000 INR waiver for wards of school staff',
    ),

    // Mumbai branch concessions
    const FeeConcessionEntity(
      id: 'FC-003',
      branchId: 'BR-002',
      name: 'Sports Scholarship',
      type: 'Percentage',
      value: 30,
      description: '30% tuition waiver for state-level athletes',
    ),
    const FeeConcessionEntity(
      id: 'FC-004',
      branchId: 'BR-002',
      name: 'Sibling Waiver',
      type: 'FixedAmount',
      value: 5000,
      description: 'Flat 5,000 INR waiver for second/subsequent sibling',
    ),
  ]);

  void addConcession(FeeConcessionEntity concession) {
    state = [...state, concession];
  }
}

final feeConcessionsProvider =
    StateNotifierProvider<FeeConcessionsNotifier, List<FeeConcessionEntity>>((ref) {
  return FeeConcessionsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Fee Assignment Entity & Provider
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StudentFeeAssignmentEntity {
  final String id;
  final String studentId;
  final String studentName;
  final String branchId;
  final String feeHeadId;
  final String feeHeadName;
  final String installmentPlanId;
  final String installmentPlanName;
  final double assignedAmount;
  final double discountAmount;
  final String concessionReason;
  final double paidAmount;
  final DateTime dueDate;
  final String status; // 'Paid', 'Unpaid', 'PartiallyPaid'

  const StudentFeeAssignmentEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.branchId,
    required this.feeHeadId,
    required this.feeHeadName,
    required this.installmentPlanId,
    required this.installmentPlanName,
    required this.assignedAmount,
    required this.discountAmount,
    required this.concessionReason,
    required this.paidAmount,
    required this.dueDate,
    required this.status,
  });

  StudentFeeAssignmentEntity copyWith({
    double? paidAmount,
    String? status,
  }) {
    return StudentFeeAssignmentEntity(
      id: id,
      studentId: studentId,
      studentName: studentName,
      branchId: branchId,
      feeHeadId: feeHeadId,
      feeHeadName: feeHeadName,
      installmentPlanId: installmentPlanId,
      installmentPlanName: installmentPlanName,
      assignedAmount: assignedAmount,
      discountAmount: discountAmount,
      concessionReason: concessionReason,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate,
      status: status ?? this.status,
    );
  }
}

class StudentFeeAssignmentsNotifier
    extends StateNotifier<List<StudentFeeAssignmentEntity>> {
  StudentFeeAssignmentsNotifier() : super([
    StudentFeeAssignmentEntity(
      id: 'FA-001',
      studentId: 'STU-001',
      studentName: 'Aarav Sharma',
      branchId: 'BR-001',
      feeHeadId: 'FH-002',
      feeHeadName: 'Tuition Fee (Q1)',
      installmentPlanId: 'IP-002',
      installmentPlanName: 'Quarterly Saver',
      assignedAmount: 25000,
      discountAmount: 12500,
      concessionReason: 'Merit Scholarship (50%)',
      paidAmount: 12500,
      dueDate: DateTime.now().add(const Duration(days: 15)),
      status: 'Paid',
    ),
    StudentFeeAssignmentEntity(
      id: 'FA-002',
      studentId: 'STU-003',
      studentName: 'Chaitra Gowda',
      branchId: 'BR-001',
      feeHeadId: 'FH-002',
      feeHeadName: 'Tuition Fee (Q1)',
      installmentPlanId: 'IP-001',
      installmentPlanName: 'Monthly Standard',
      assignedAmount: 25000,
      discountAmount: 0,
      concessionReason: 'None',
      paidAmount: 5000,
      dueDate: DateTime.now().subtract(const Duration(days: 4)),
      status: 'PartiallyPaid',
    ),
    StudentFeeAssignmentEntity(
      id: 'FA-003',
      studentId: 'STU-005',
      studentName: 'Devendra Gowda',
      branchId: 'BR-001',
      feeHeadId: 'FH-001',
      feeHeadName: 'Admission Fee',
      installmentPlanId: 'IP-001',
      installmentPlanName: 'Monthly Standard',
      assignedAmount: 15000,
      discountAmount: 0,
      concessionReason: 'None',
      paidAmount: 0,
      dueDate: DateTime.now().subtract(const Duration(days: 10)),
      status: 'Unpaid',
    ),

    // Mumbai branch assignments
    StudentFeeAssignmentEntity(
      id: 'FA-004',
      studentId: 'STU-008',
      studentName: 'Sachin Tendulkar',
      branchId: 'BR-002',
      feeHeadId: 'FH-006',
      feeHeadName: 'Tuition Fee (Q1)',
      installmentPlanId: 'IP-003',
      installmentPlanName: 'Monthly Flexi',
      assignedAmount: 22000,
      discountAmount: 6600,
      concessionReason: 'Sports Scholarship (30%)',
      paidAmount: 0,
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Unpaid',
    ),
    StudentFeeAssignmentEntity(
      id: 'FA-005',
      studentId: 'STU-009',
      studentName: 'Lata Mangeshkar',
      branchId: 'BR-002',
      feeHeadId: 'FH-005',
      feeHeadName: 'Admission Fee',
      installmentPlanId: 'IP-004',
      installmentPlanName: 'Half-Yearly Saver',
      assignedAmount: 12000,
      discountAmount: 0,
      concessionReason: 'None',
      paidAmount: 12000,
      dueDate: DateTime.now().subtract(const Duration(days: 20)),
      status: 'Paid',
    ),
  ]);

  void assignFee(StudentFeeAssignmentEntity assignment) {
    state = [...state, assignment];
  }

  void recordPayment(String assignmentId, double paymentAmount) {
    state = state.map((fa) {
      if (fa.id == assignmentId) {
        final netPayable = fa.assignedAmount - fa.discountAmount;
        final newPaid = fa.paidAmount + paymentAmount;
        final newStatus = newPaid >= netPayable
            ? 'Paid'
            : (newPaid > 0 ? 'PartiallyPaid' : 'Unpaid');
        return fa.copyWith(
          paidAmount: newPaid > netPayable ? netPayable : newPaid,
          status: newStatus,
        );
      }
      return fa;
    }).toList();
  }
}

final studentFeeAssignmentsProvider =
    StateNotifierProvider<StudentFeeAssignmentsNotifier, List<StudentFeeAssignmentEntity>>((ref) {
  return StudentFeeAssignmentsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Payment Gateway configuration per branch
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class GatewayConfigEntity {
  final String branchId;
  final String gatewayName; // 'Razorpay', 'Stripe', 'Paytm'
  final String merchantAccountId;
  final String publicKey;
  final bool isActive;

  const GatewayConfigEntity({
    required this.branchId,
    required this.gatewayName,
    required this.merchantAccountId,
    required this.publicKey,
    required this.isActive,
  });

  GatewayConfigEntity copyWith({
    String? gatewayName,
    String? merchantAccountId,
    String? publicKey,
    bool? isActive,
  }) {
    return GatewayConfigEntity(
      branchId: branchId,
      gatewayName: gatewayName ?? this.gatewayName,
      merchantAccountId: merchantAccountId ?? this.merchantAccountId,
      publicKey: publicKey ?? this.publicKey,
      isActive: isActive ?? this.isActive,
    );
  }
}

class GatewayConfigsNotifier extends StateNotifier<List<GatewayConfigEntity>> {
  GatewayConfigsNotifier() : super([
    const GatewayConfigEntity(
      branchId: 'BR-001',
      gatewayName: 'Razorpay',
      merchantAccountId: 'merch_delhi_01',
      publicKey: 'rzp_live_delhi12345',
      isActive: true,
    ),
    const GatewayConfigEntity(
      branchId: 'BR-002',
      gatewayName: 'Stripe',
      merchantAccountId: 'acct_mumbai_02',
      publicKey: 'pk_live_mumbai54321',
      isActive: true,
    ),
  ]);

  void updateGateway(GatewayConfigEntity config) {
    state = [
      for (final cfg in state)
        if (cfg.branchId == config.branchId) config else cfg
    ];
    if (!state.any((cfg) => cfg.branchId == config.branchId)) {
      state = [...state, config];
    }
  }
}

final gatewayConfigsProvider =
    StateNotifierProvider<GatewayConfigsNotifier, List<GatewayConfigEntity>>((ref) {
  return GatewayConfigsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Fee Receipt Entity & Provider
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FeeReceiptEntity {
  final String id;
  final String receiptNumber;
  final String branchId;
  final String studentId;
  final String studentName;
  final String feeHeadId;
  final String feeHeadName;
  final double amountPaid;
  final String paymentMode; // 'Cash', 'Cheque', 'DD', 'Online', 'UPI', 'Card'
  final String transactionReference;
  final DateTime paymentDate;
  final String status; // 'Active', 'Refunded'

  const FeeReceiptEntity({
    required this.id,
    required this.receiptNumber,
    required this.branchId,
    required this.studentId,
    required this.studentName,
    required this.feeHeadId,
    required this.feeHeadName,
    required this.amountPaid,
    required this.paymentMode,
    required this.transactionReference,
    required this.paymentDate,
    required this.status,
  });

  FeeReceiptEntity copyWith({
    String? status,
  }) {
    return FeeReceiptEntity(
      id: id,
      receiptNumber: receiptNumber,
      branchId: branchId,
      studentId: studentId,
      studentName: studentName,
      feeHeadId: feeHeadId,
      feeHeadName: feeHeadName,
      amountPaid: amountPaid,
      paymentMode: paymentMode,
      transactionReference: transactionReference,
      paymentDate: paymentDate,
      status: status ?? this.status,
    );
  }
}

class FeeReceiptsNotifier extends StateNotifier<List<FeeReceiptEntity>> {
  FeeReceiptsNotifier() : super([
    FeeReceiptEntity(
      id: 'REC-001',
      receiptNumber: 'BR001-2026-0001',
      branchId: 'BR-001',
      studentId: 'STU-001',
      studentName: 'Aarav Sharma',
      feeHeadId: 'FH-002',
      feeHeadName: 'Tuition Fee (Q1)',
      amountPaid: 12500,
      paymentMode: 'Online',
      transactionReference: 'TXN-982348274',
      paymentDate: DateTime.now().subtract(const Duration(days: 15)),
      status: 'Active',
    ),
    FeeReceiptEntity(
      id: 'REC-002',
      receiptNumber: 'BR001-2026-0002',
      branchId: 'BR-001',
      studentId: 'STU-003',
      studentName: 'Chaitra Gowda',
      feeHeadId: 'FH-002',
      feeHeadName: 'Tuition Fee (Q1)',
      amountPaid: 5000,
      paymentMode: 'Cash',
      transactionReference: 'CASH-COUNTER-1',
      paymentDate: DateTime.now().subtract(const Duration(days: 4)),
      status: 'Active',
    ),

    // Mumbai branch receipts
    FeeReceiptEntity(
      id: 'REC-003',
      receiptNumber: 'BR002-2026-0001',
      branchId: 'BR-002',
      studentId: 'STU-009',
      studentName: 'Lata Mangeshkar',
      feeHeadId: 'FH-005',
      feeHeadName: 'Admission Fee',
      amountPaid: 12000,
      paymentMode: 'Online',
      transactionReference: 'TXN-88223399',
      paymentDate: DateTime.now().subtract(const Duration(days: 20)),
      status: 'Active',
    ),
  ]);

  void generateReceipt(FeeReceiptEntity receipt) {
    state = [...state, receipt];
  }

  void markRefunded(String receiptId) {
    state = state.map((r) {
      if (r.id == receiptId) {
        return r.copyWith(status: 'Refunded');
      }
      return r;
    }).toList();
  }
}

final feeReceiptsProvider =
    StateNotifierProvider<FeeReceiptsNotifier, List<FeeReceiptEntity>>((ref) {
  return FeeReceiptsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Fee Refund Entity & Provider
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FeeRefundEntity {
  final String id;
  final String branchId;
  final String studentId;
  final String studentName;
  final String receiptId;
  final double refundAmount;
  final String reason;
  final DateTime refundDate;
  final String refundMode;
  final String status; // 'Approved', 'Pending'

  const FeeRefundEntity({
    required this.id,
    required this.branchId,
    required this.studentId,
    required this.studentName,
    required this.receiptId,
    required this.refundAmount,
    required this.reason,
    required this.refundDate,
    required this.refundMode,
    required this.status,
  });
}

class FeeRefundsNotifier extends StateNotifier<List<FeeRefundEntity>> {
  FeeRefundsNotifier() : super([]);

  void addRefund(FeeRefundEntity refund) {
    state = [...state, refund];
  }
}

final feeRefundsProvider =
    StateNotifierProvider<FeeRefundsNotifier, List<FeeRefundEntity>>((ref) {
  return FeeRefundsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Fee Daybook Counter Entity & Provider
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FeeDaybookEntryEntity {
  final String id;
  final String branchId;
  final String counterName; // e.g. 'Counter 1', 'Online Gate'
  final DateTime date;
  final String type; // 'Collection', 'Refund'
  final double amount;
  final String paymentMode;
  final String studentName;
  final String description;

  const FeeDaybookEntryEntity({
    required this.id,
    required this.branchId,
    required this.counterName,
    required this.date,
    required this.type,
    required this.amount,
    required this.paymentMode,
    required this.studentName,
    required this.description,
  });
}

class FeeDaybookNotifier extends StateNotifier<List<FeeDaybookEntryEntity>> {
  FeeDaybookNotifier() : super([
    FeeDaybookEntryEntity(
      id: 'DB-001',
      branchId: 'BR-001',
      counterName: 'Online Gate',
      date: DateTime.now().subtract(const Duration(days: 15)),
      type: 'Collection',
      amount: 12500,
      paymentMode: 'Online',
      studentName: 'Aarav Sharma',
      description: 'Tuition Fee (Q1) Payment',
    ),
    FeeDaybookEntryEntity(
      id: 'DB-002',
      branchId: 'BR-001',
      counterName: 'Counter A',
      date: DateTime.now().subtract(const Duration(days: 4)),
      type: 'Collection',
      amount: 5000,
      paymentMode: 'Cash',
      studentName: 'Chaitra Gowda',
      description: 'Tuition Fee (Q1) Installment',
    ),

    // Mumbai branch daybook entries
    FeeDaybookEntryEntity(
      id: 'DB-003',
      branchId: 'BR-002',
      counterName: 'Online Gate',
      date: DateTime.now().subtract(const Duration(days: 20)),
      type: 'Collection',
      amount: 12000,
      paymentMode: 'Online',
      studentName: 'Lata Mangeshkar',
      description: 'Admission Fee Payment',
    ),
  ]);

  void logEntry(FeeDaybookEntryEntity entry) {
    state = [...state, entry];
  }
}

final feeDaybookProvider =
    StateNotifierProvider<FeeDaybookNotifier, List<FeeDaybookEntryEntity>>((ref) {
  return FeeDaybookNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Advance Fee Balances per branch
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StudentAdvanceBalanceEntity {
  final String studentId;
  final String studentName;
  final String branchId;
  final double balance;
  final DateTime lastUpdated;

  const StudentAdvanceBalanceEntity({
    required this.studentId,
    required this.studentName,
    required this.branchId,
    required this.balance,
    required this.lastUpdated,
  });

  StudentAdvanceBalanceEntity copyWith({
    double? balance,
    DateTime? lastUpdated,
  }) {
    return StudentAdvanceBalanceEntity(
      studentId: studentId,
      studentName: studentName,
      branchId: branchId,
      balance: balance ?? this.balance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class StudentAdvanceBalancesNotifier
    extends StateNotifier<List<StudentAdvanceBalanceEntity>> {
  StudentAdvanceBalancesNotifier() : super([
    StudentAdvanceBalanceEntity(
      studentId: 'STU-001',
      studentName: 'Aarav Sharma',
      branchId: 'BR-001',
      balance: 1500.0,
      lastUpdated: DateTime.now(),
    ),
    StudentAdvanceBalanceEntity(
      studentId: 'STU-003',
      studentName: 'Chaitra Gowda',
      branchId: 'BR-001',
      balance: 0.0,
      lastUpdated: DateTime.now(),
    ),
    StudentAdvanceBalanceEntity(
      studentId: 'STU-008',
      studentName: 'Sachin Tendulkar',
      branchId: 'BR-002',
      balance: 3500.0,
      lastUpdated: DateTime.now(),
    ),
  ]);

  void addAdvance(String studentId, String studentName, String branchId, double amount) {
    state = [
      for (final ab in state)
        if (ab.studentId == studentId)
          ab.copyWith(balance: ab.balance + amount, lastUpdated: DateTime.now())
        else
          ab
    ];
    if (!state.any((ab) => ab.studentId == studentId)) {
      state = [
        ...state,
        StudentAdvanceBalanceEntity(
          studentId: studentId,
          studentName: studentName,
          branchId: branchId,
          balance: amount,
          lastUpdated: DateTime.now(),
        ),
      ];
    }
  }

  void deductAdvance(String studentId, double amount) {
    state = [
      for (final ab in state)
        if (ab.studentId == studentId)
          ab.copyWith(balance: (ab.balance - amount) < 0 ? 0.0 : (ab.balance - amount), lastUpdated: DateTime.now())
        else
          ab
    ];
  }
}

final studentAdvanceBalancesProvider = StateNotifierProvider<
    StudentAdvanceBalancesNotifier, List<StudentAdvanceBalanceEntity>>((ref) {
  return StudentAdvanceBalancesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch Financial Year Management
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FinancialYearEntity {
  final String id;
  final String branchId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isLocked;
  final bool isCurrent;

  const FinancialYearEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isLocked,
    required this.isCurrent,
  });

  FinancialYearEntity copyWith({
    bool? isLocked,
    bool? isCurrent,
  }) {
    return FinancialYearEntity(
      id: id,
      branchId: branchId,
      name: name,
      startDate: startDate,
      endDate: endDate,
      isLocked: isLocked ?? this.isLocked,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}

class FinancialYearsNotifier extends StateNotifier<List<FinancialYearEntity>> {
  FinancialYearsNotifier() : super([
    FinancialYearEntity(
      id: 'FY-001',
      branchId: 'BR-001',
      name: 'FY 2025-26',
      startDate: DateTime(2025, 4, 1),
      endDate: DateTime(2026, 3, 31),
      isLocked: true,
      isCurrent: false,
    ),
    FinancialYearEntity(
      id: 'FY-002',
      branchId: 'BR-001',
      name: 'FY 2026-27',
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2027, 3, 31),
      isLocked: false,
      isCurrent: true,
    ),
    FinancialYearEntity(
      id: 'FY-003',
      branchId: 'BR-002',
      name: 'FY 2026-27',
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2027, 3, 31),
      isLocked: false,
      isCurrent: true,
    ),
  ]);

  void addFinancialYear(FinancialYearEntity fy) {
    if (fy.isCurrent) {
      state = state.map((y) => y.copyWith(isCurrent: false)).toList();
    }
    state = [...state, fy];
  }

  void toggleLock(String id) {
    state = state.map((y) => y.id == id ? y.copyWith(isLocked: !y.isLocked) : y).toList();
  }
}

final financialYearsProvider =
    StateNotifierProvider<FinancialYearsNotifier, List<FinancialYearEntity>>((ref) {
  return FinancialYearsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Budget Planning
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BudgetPlanEntity {
  final String id;
  final String branchId;
  final String financialYearId;
  final String category; // 'Academics', 'Administration', 'Infrastructure', 'Staff Salaries', 'Marketing', 'Other'
  final double allocatedAmount;
  final double spentAmount;

  const BudgetPlanEntity({
    required this.id,
    required this.branchId,
    required this.financialYearId,
    required this.category,
    required this.allocatedAmount,
    required this.spentAmount,
  });

  BudgetPlanEntity copyWith({
    double? allocatedAmount,
    double? spentAmount,
  }) {
    return BudgetPlanEntity(
      id: id,
      branchId: branchId,
      financialYearId: financialYearId,
      category: category,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }
}

class BudgetPlansNotifier extends StateNotifier<List<BudgetPlanEntity>> {
  BudgetPlansNotifier() : super([
    const BudgetPlanEntity(
      id: 'B-001',
      branchId: 'BR-001',
      financialYearId: 'FY-002',
      category: 'Academics',
      allocatedAmount: 1500000.0,
      spentAmount: 450000.0,
    ),
    const BudgetPlanEntity(
      id: 'B-002',
      branchId: 'BR-001',
      financialYearId: 'FY-002',
      category: 'Staff Salaries',
      allocatedAmount: 5000000.0,
      spentAmount: 1650000.0,
    ),
    const BudgetPlanEntity(
      id: 'B-003',
      branchId: 'BR-001',
      financialYearId: 'FY-002',
      category: 'Infrastructure',
      allocatedAmount: 2000000.0,
      spentAmount: 850000.0,
    ),

    // Mumbai branch budgets
    const BudgetPlanEntity(
      id: 'B-004',
      branchId: 'BR-002',
      financialYearId: 'FY-003',
      category: 'Academics',
      allocatedAmount: 1800000.0,
      spentAmount: 500000.0,
    ),
    const BudgetPlanEntity(
      id: 'B-005',
      branchId: 'BR-002',
      financialYearId: 'FY-003',
      category: 'Staff Salaries',
      allocatedAmount: 5500000.0,
      spentAmount: 1500000.0,
    ),
  ]);

  void addBudget(BudgetPlanEntity budget) {
    state = [...state, budget];
  }

  void updateSpentAmount(String budgetId, double extraSpent) {
    state = state.map((b) => b.id == budgetId ? b.copyWith(spentAmount: b.spentAmount + extraSpent) : b).toList();
  }
}

final budgetPlansProvider =
    StateNotifierProvider<BudgetPlansNotifier, List<BudgetPlanEntity>>((ref) {
  return BudgetPlansNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Voucher Management (Receipt, Payment, Journal, Contra)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FinancialVoucherEntity {
  final String id;
  final String voucherNumber;
  final String branchId;
  final String type; // 'Receipt', 'Payment', 'Journal', 'Contra'
  final DateTime date;
  final String debitAccount; // Account code or head
  final String creditAccount; // Account code or head
  final double amount;
  final String narration;
  final String postedBy;

  const FinancialVoucherEntity({
    required this.id,
    required this.voucherNumber,
    required this.branchId,
    required this.type,
    required this.date,
    required this.debitAccount,
    required this.creditAccount,
    required this.amount,
    required this.narration,
    required this.postedBy,
  });
}

class FinancialVouchersNotifier extends StateNotifier<List<FinancialVoucherEntity>> {
  FinancialVouchersNotifier() : super([
    FinancialVoucherEntity(
      id: 'VOU-001',
      voucherNumber: 'VOU-BR001-2026-0001',
      branchId: 'BR-001',
      type: 'Receipt',
      date: DateTime.now().subtract(const Duration(days: 10)),
      debitAccount: 'Cash at Bank',
      creditAccount: 'Student Tuition Fee Account',
      amount: 45000.0,
      narration: 'Bulk tuition fee collections receipted',
      postedBy: 'Head Accountant',
    ),
    FinancialVoucherEntity(
      id: 'VOU-002',
      voucherNumber: 'VOU-BR001-2026-0002',
      branchId: 'BR-001',
      type: 'Payment',
      date: DateTime.now().subtract(const Duration(days: 8)),
      debitAccount: 'Academics Expenses Account',
      creditAccount: 'Cash in Hand',
      amount: 12000.0,
      narration: 'Paid for classroom whiteboards & stationery',
      postedBy: 'Admin Assistant',
    ),
    FinancialVoucherEntity(
      id: 'VOU-003',
      voucherNumber: 'VOU-BR001-2026-0003',
      branchId: 'BR-001',
      type: 'Contra',
      date: DateTime.now().subtract(const Duration(days: 5)),
      debitAccount: 'Cash at Bank',
      creditAccount: 'Cash in Hand',
      amount: 30000.0,
      narration: 'Excess cash deposited in bank account',
      postedBy: 'Cashier',
    ),

    // Mumbai branch vouchers
    FinancialVoucherEntity(
      id: 'VOU-004',
      voucherNumber: 'VOU-BR002-2026-0001',
      branchId: 'BR-002',
      type: 'Receipt',
      date: DateTime.now().subtract(const Duration(days: 20)),
      debitAccount: 'Cash at Bank',
      creditAccount: 'Student Tuition Fee Account',
      amount: 12000.0,
      narration: 'Admission fee collected online',
      postedBy: 'Parent portal checkout',
    ),
    FinancialVoucherEntity(
      id: 'VOU-005',
      voucherNumber: 'VOU-BR002-2026-0002',
      branchId: 'BR-002',
      type: 'Payment',
      date: DateTime.now().subtract(const Duration(days: 15)),
      debitAccount: 'Academics Expenses Account',
      creditAccount: 'Cash in Hand',
      amount: 8000.0,
      narration: 'MUM classroom repair expenses',
      postedBy: 'MUM Administrator',
    ),
  ]);

  void addVoucher(FinancialVoucherEntity voucher) {
    state = [...state, voucher];
  }
}

final financialVouchersProvider =
    StateNotifierProvider<FinancialVouchersNotifier, List<FinancialVoucherEntity>>((ref) {
  return FinancialVouchersNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Bank Reconciliation per branch
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BankReconciliationEntity {
  final String id;
  final String branchId;
  final String bankName;
  final String accountNumber;
  final DateTime statementDate;
  final double statementBalance;
  final double ledgerBalance;
  final double clearedAmount;
  final double unclearedAmount;
  final bool isReconciled;

  const BankReconciliationEntity({
    required this.id,
    required this.branchId,
    required this.bankName,
    required this.accountNumber,
    required this.statementDate,
    required this.statementBalance,
    required this.ledgerBalance,
    required this.clearedAmount,
    required this.unclearedAmount,
    required this.isReconciled,
  });

  BankReconciliationEntity copyWith({
    double? statementBalance,
    double? ledgerBalance,
    double? clearedAmount,
    double? unclearedAmount,
    bool? isReconciled,
  }) {
    return BankReconciliationEntity(
      id: id,
      branchId: branchId,
      bankName: bankName,
      accountNumber: accountNumber,
      statementDate: statementDate,
      statementBalance: statementBalance ?? this.statementBalance,
      ledgerBalance: ledgerBalance ?? this.ledgerBalance,
      clearedAmount: clearedAmount ?? this.clearedAmount,
      unclearedAmount: unclearedAmount ?? this.unclearedAmount,
      isReconciled: isReconciled ?? this.isReconciled,
    );
  }
}

class BankReconciliationsNotifier extends StateNotifier<List<BankReconciliationEntity>> {
  BankReconciliationsNotifier() : super([
    BankReconciliationEntity(
      id: 'REC-B-01',
      branchId: 'BR-001',
      bankName: 'HDFC School Main Account',
      accountNumber: 'XXXX-XXXX-9901',
      statementDate: DateTime.now().subtract(const Duration(days: 2)),
      statementBalance: 1245000.0,
      ledgerBalance: 1245000.0,
      clearedAmount: 85000.0,
      unclearedAmount: 0.0,
      isReconciled: true,
    ),
    BankReconciliationEntity(
      id: 'REC-B-02',
      branchId: 'BR-001',
      bankName: 'ICICI Petty Cash Account',
      accountNumber: 'XXXX-XXXX-4422',
      statementDate: DateTime.now().subtract(const Duration(days: 1)),
      statementBalance: 25000.0,
      ledgerBalance: 27500.0,
      clearedAmount: 15000.0,
      unclearedAmount: 2500.0,
      isReconciled: false,
    ),
    BankReconciliationEntity(
      id: 'REC-B-03',
      branchId: 'BR-002',
      bankName: 'SBI Mumbai Branch Account',
      accountNumber: 'XXXX-XXXX-1122',
      statementDate: DateTime.now().subtract(const Duration(days: 2)),
      statementBalance: 980000.0,
      ledgerBalance: 980000.0,
      clearedAmount: 42000.0,
      unclearedAmount: 0.0,
      isReconciled: true,
    ),
  ]);

  void addReconciliation(BankReconciliationEntity recon) {
    state = [...state, recon];
  }

  void reconcile(String id, double statementBal, double clearedAmt, double unclearedAmt) {
    state = state.map((r) {
      if (r.id == id) {
        final reconciled = statementBal == (r.ledgerBalance + clearedAmt - unclearedAmt);
        return r.copyWith(
          statementBalance: statementBal,
          clearedAmount: clearedAmt,
          unclearedAmount: unclearedAmt,
          isReconciled: reconciled,
        );
      }
      return r;
    }).toList();
  }
}

final bankReconciliationsProvider =
    StateNotifierProvider<BankReconciliationsNotifier, List<BankReconciliationEntity>>((ref) {
  return BankReconciliationsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Financial Transaction Audit Trail per branch
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FinancialAuditTrailEntity {
  final String id;
  final String branchId;
  final DateTime timestamp;
  final String actionType; // 'VoucherPosted', 'PaymentCollected', 'RefundProcessed', 'BudgetUpdated'
  final String description;
  final String performedBy;
  final String ipAddress;

  const FinancialAuditTrailEntity({
    required this.id,
    required this.branchId,
    required this.timestamp,
    required this.actionType,
    required this.description,
    required this.performedBy,
    required this.ipAddress,
  });
}

class FinancialAuditTrailNotifier extends StateNotifier<List<FinancialAuditTrailEntity>> {
  FinancialAuditTrailNotifier() : super([
    FinancialAuditTrailEntity(
      id: 'AUD-001',
      branchId: 'BR-001',
      timestamp: DateTime.now().subtract(const Duration(days: 10)),
      actionType: 'VoucherPosted',
      description: 'General Voucher VOU-BR001-2026-0001 posted of amount ₹45,000',
      performedBy: 'Head Accountant',
      ipAddress: '192.168.1.15',
    ),
    FinancialAuditTrailEntity(
      id: 'AUD-002',
      branchId: 'BR-001',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      actionType: 'PaymentCollected',
      description: 'Fee collection receipt BR001-2026-0002 generated of amount ₹5,000',
      performedBy: 'Counter cashier',
      ipAddress: '192.168.1.42',
    ),
    FinancialAuditTrailEntity(
      id: 'AUD-003',
      branchId: 'BR-002',
      timestamp: DateTime.now().subtract(const Duration(days: 20)),
      actionType: 'PaymentCollected',
      description: 'Fee collection receipt BR002-2026-0001 generated of amount ₹12,000',
      performedBy: 'Parent (Self Portal)',
      ipAddress: '192.168.1.199',
    ),
  ]);

  void logAudit(FinancialAuditTrailEntity log) {
    state = [...state, log];
  }
}

final financialAuditTrailProvider = StateNotifierProvider<
    FinancialAuditTrailNotifier, List<FinancialAuditTrailEntity>>((ref) {
  return FinancialAuditTrailNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Auto-generated Fee Reminders Log
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FeeReminderLogEntity {
  final String id;
  final String branchId;
  final String studentId;
  final String studentName;
  final String channel; // 'SMS', 'Email', 'WhatsApp'
  final double amountDue;
  final DateTime sentAt;
  final String status; // 'Sent', 'Pending'

  const FeeReminderLogEntity({
    required this.id,
    required this.branchId,
    required this.studentId,
    required this.studentName,
    required this.channel,
    required this.amountDue,
    required this.sentAt,
    required this.status,
  });
}

class FeeReminderLogsNotifier extends StateNotifier<List<FeeReminderLogEntity>> {
  FeeReminderLogsNotifier() : super([
    FeeReminderLogEntity(
      id: 'REM-001',
      branchId: 'BR-001',
      studentId: 'STU-005',
      studentName: 'Devendra Gowda',
      channel: 'WhatsApp',
      amountDue: 15000.0,
      sentAt: DateTime.now().subtract(const Duration(days: 2)),
      status: 'Sent',
    ),
    FeeReminderLogEntity(
      id: 'REM-002',
      branchId: 'BR-001',
      studentId: 'STU-003',
      studentName: 'Chaitra Gowda',
      channel: 'SMS',
      amountDue: 20000.0,
      sentAt: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'Sent',
    ),
    FeeReminderLogEntity(
      id: 'REM-003',
      branchId: 'BR-002',
      studentId: 'STU-008',
      studentName: 'Sachin Tendulkar',
      channel: 'Email',
      amountDue: 15400.0,
      sentAt: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Sent',
    ),
  ]);

  void logReminder(FeeReminderLogEntity log) {
    state = [...state, log];
  }
}

final feeReminderLogsProvider = StateNotifierProvider<
    FeeReminderLogsNotifier, List<FeeReminderLogEntity>>((ref) {
  return FeeReminderLogsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch Exam Types (Unit Test, Half-Yearly, Final, Entrance)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ExamTypeEntity {
  final String id;
  final String branchId;
  final String name;
  final String description;

  const ExamTypeEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.description,
  });
}

class ExamTypesNotifier extends StateNotifier<List<ExamTypeEntity>> {
  ExamTypesNotifier() : super([
    const ExamTypeEntity(
      id: 'ET-001',
      branchId: 'BR-001',
      name: 'Unit Test I',
      description: 'First quarterly unit testing assessment',
    ),
    const ExamTypeEntity(
      id: 'ET-002',
      branchId: 'BR-001',
      name: 'Half-Yearly Examination',
      description: 'Mid-term comprehensive exams',
    ),
    const ExamTypeEntity(
      id: 'ET-003',
      branchId: 'BR-001',
      name: 'Final Examination',
      description: 'End-of-term board exams',
    ),
    const ExamTypeEntity(
      id: 'ET-004',
      branchId: 'BR-002',
      name: 'Semester Test I',
      description: 'First semester assessment cycle',
    ),
    const ExamTypeEntity(
      id: 'ET-005',
      branchId: 'BR-002',
      name: 'Annual Final Term',
      description: 'Annual comprehensive exams',
    ),
  ]);

  void addExamType(ExamTypeEntity type) {
    state = [...state, type];
  }

  void removeExamType(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final examTypesProvider = StateNotifierProvider<ExamTypesNotifier, List<ExamTypeEntity>>((ref) {
  return ExamTypesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch Exam Patterns (Theory, Practical, Oral, Project weightages)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ExamPatternEntity {
  final String id;
  final String branchId;
  final String name;
  final double theoryWeight;
  final double practicalWeight;
  final double oralWeight;
  final double projectWeight;

  const ExamPatternEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.theoryWeight,
    required this.practicalWeight,
    required this.oralWeight,
    required this.projectWeight,
  });
}

class ExamPatternsNotifier extends StateNotifier<List<ExamPatternEntity>> {
  ExamPatternsNotifier() : super([
    const ExamPatternEntity(
      id: 'EP-001',
      branchId: 'BR-001',
      name: 'Pure Theory (100-0)',
      theoryWeight: 100.0,
      practicalWeight: 0.0,
      oralWeight: 0.0,
      projectWeight: 0.0,
    ),
    const ExamPatternEntity(
      id: 'EP-002',
      branchId: 'BR-001',
      name: 'Science Standard (70-30)',
      theoryWeight: 70.0,
      practicalWeight: 30.0,
      oralWeight: 0.0,
      projectWeight: 0.0,
    ),
    const ExamPatternEntity(
      id: 'EP-003',
      branchId: 'BR-001',
      name: 'Modern Project-Based (50-20-30)',
      theoryWeight: 50.0,
      practicalWeight: 0.0,
      oralWeight: 20.0,
      projectWeight: 30.0,
    ),
    const ExamPatternEntity(
      id: 'EP-004',
      branchId: 'BR-002',
      name: 'Oral & Practical Weighted (40-60)',
      theoryWeight: 0.0,
      practicalWeight: 60.0,
      oralWeight: 40.0,
      projectWeight: 0.0,
    ),
    const ExamPatternEntity(
      id: 'EP-005',
      branchId: 'BR-002',
      name: 'CBSE Standard Pattern (80-20)',
      theoryWeight: 80.0,
      practicalWeight: 0.0,
      oralWeight: 0.0,
      projectWeight: 20.0,
    ),
  ]);

  void addExamPattern(ExamPatternEntity pattern) {
    state = [...state, pattern];
  }

  void removeExamPattern(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

final examPatternsProvider = StateNotifierProvider<ExamPatternsNotifier, List<ExamPatternEntity>>((ref) {
  return ExamPatternsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch Exam Schedule/Timetable Creation
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BranchExamScheduleEntity {
  final String id;
  final String branchId;
  final String examTypeId;
  final String examTypeName;
  final String classId;
  final String className;
  final String subjectId;
  final String subjectName;
  final String patternId;
  final String patternName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double maxMarks;
  final double passingMarks;
  final String roomNo;

  const BranchExamScheduleEntity({
    required this.id,
    required this.branchId,
    required this.examTypeId,
    required this.examTypeName,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.patternId,
    required this.patternName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.maxMarks,
    required this.passingMarks,
    required this.roomNo,
  });
}

class BranchExamSchedulesNotifier extends StateNotifier<List<BranchExamScheduleEntity>> {
  BranchExamSchedulesNotifier() : super([
    BranchExamScheduleEntity(
      id: 'ES-001',
      branchId: 'BR-001',
      examTypeId: 'ET-002',
      examTypeName: 'Half-Yearly Examination',
      classId: 'CL-001',
      className: 'Grade 10 - Sec A',
      subjectId: 'SUB-001',
      subjectName: 'Mathematics',
      patternId: 'EP-001',
      patternName: 'Pure Theory (100-0)',
      date: DateTime.now().add(const Duration(days: 15)),
      startTime: '09:00 AM',
      endTime: '12:00 PM',
      maxMarks: 100.0,
      passingMarks: 35.0,
      roomNo: 'Exam Hall 2',
    ),
    BranchExamScheduleEntity(
      id: 'ES-002',
      branchId: 'BR-001',
      examTypeId: 'ET-002',
      examTypeName: 'Half-Yearly Examination',
      classId: 'CL-001',
      className: 'Grade 10 - Sec A',
      subjectId: 'SUB-002',
      subjectName: 'Science',
      patternId: 'EP-002',
      patternName: 'Science Standard (70-30)',
      date: DateTime.now().add(const Duration(days: 17)),
      startTime: '09:00 AM',
      endTime: '12:00 PM',
      maxMarks: 100.0,
      passingMarks: 35.0,
      roomNo: 'Exam Lab B',
    ),
    BranchExamScheduleEntity(
      id: 'ES-003',
      branchId: 'BR-002',
      examTypeId: 'ET-005',
      examTypeName: 'Annual Final Term',
      classId: 'CLS-008',
      className: 'Class 11 Science - Sec A',
      subjectId: 'SUB-001',
      subjectName: 'Mathematics',
      patternId: 'EP-005',
      patternName: 'CBSE Standard Pattern (80-20)',
      date: DateTime.now().add(const Duration(days: 12)),
      startTime: '10:00 AM',
      endTime: '01:00 PM',
      maxMarks: 100.0,
      passingMarks: 33.0,
      roomNo: 'Mumbai Exam Hall 1',
    ),
    BranchExamScheduleEntity(
      id: 'ES-004',
      branchId: 'BR-002',
      examTypeId: 'ET-005',
      examTypeName: 'Annual Final Term',
      classId: 'CLS-008',
      className: 'Class 11 Science - Sec A',
      subjectId: 'SUB-002',
      subjectName: 'Science',
      patternId: 'EP-004',
      patternName: 'Oral & Practical Weighted (40-60)',
      date: DateTime.now().add(const Duration(days: 14)),
      startTime: '10:00 AM',
      endTime: '01:00 PM',
      maxMarks: 100.0,
      passingMarks: 33.0,
      roomNo: 'Mumbai Main Lab',
    ),
  ]);

  void addExamSchedule(BranchExamScheduleEntity schedule) {
    state = [...state, schedule];
  }

  void removeExamSchedule(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final branchExamSchedulesProvider = StateNotifierProvider<BranchExamSchedulesNotifier, List<BranchExamScheduleEntity>>((ref) {
  return BranchExamSchedulesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch grading scales (Percentage, CGPA, GPA, Letter Grades)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class GradingScaleEntity {
  final String id;
  final String branchId;
  final String letter;
  final double minPercentage;
  final double maxPercentage;
  final double gpaPoint;
  final String remarks;

  const GradingScaleEntity({
    required this.id,
    required this.branchId,
    required this.letter,
    required this.minPercentage,
    required this.maxPercentage,
    required this.gpaPoint,
    required this.remarks,
  });
}

class GradingScalesNotifier extends StateNotifier<List<GradingScaleEntity>> {
  GradingScalesNotifier() : super([
    const GradingScaleEntity(
      id: 'GS-001',
      branchId: 'BR-001',
      letter: 'A+',
      minPercentage: 90.0,
      maxPercentage: 100.0,
      gpaPoint: 10.0,
      remarks: 'Outstanding',
    ),
    const GradingScaleEntity(
      id: 'GS-002',
      branchId: 'BR-001',
      letter: 'A',
      minPercentage: 80.0,
      maxPercentage: 89.9,
      gpaPoint: 9.0,
      remarks: 'Excellent',
    ),
    const GradingScaleEntity(
      id: 'GS-003',
      branchId: 'BR-001',
      letter: 'B',
      minPercentage: 70.0,
      maxPercentage: 79.9,
      gpaPoint: 8.0,
      remarks: 'Very Good',
    ),
    const GradingScaleEntity(
      id: 'GS-004',
      branchId: 'BR-001',
      letter: 'C',
      minPercentage: 50.0,
      maxPercentage: 69.9,
      gpaPoint: 6.0,
      remarks: 'Good',
    ),
    const GradingScaleEntity(
      id: 'GS-005',
      branchId: 'BR-001',
      letter: 'D',
      minPercentage: 35.0,
      maxPercentage: 49.9,
      gpaPoint: 4.0,
      remarks: 'Pass',
    ),
    const GradingScaleEntity(
      id: 'GS-006',
      branchId: 'BR-001',
      letter: 'F',
      minPercentage: 0.0,
      maxPercentage: 34.9,
      gpaPoint: 0.0,
      remarks: 'Fail',
    ),
    const GradingScaleEntity(
      id: 'GS-007',
      branchId: 'BR-002',
      letter: 'O',
      minPercentage: 90.0,
      maxPercentage: 100.0,
      gpaPoint: 10.0,
      remarks: 'Outstanding',
    ),
    const GradingScaleEntity(
      id: 'GS-008',
      branchId: 'BR-002',
      letter: 'A',
      minPercentage: 80.0,
      maxPercentage: 89.9,
      gpaPoint: 9.0,
      remarks: 'Very Good',
    ),
    const GradingScaleEntity(
      id: 'GS-009',
      branchId: 'BR-002',
      letter: 'B',
      minPercentage: 70.0,
      maxPercentage: 79.9,
      gpaPoint: 8.0,
      remarks: 'Good',
    ),
    const GradingScaleEntity(
      id: 'GS-010',
      branchId: 'BR-002',
      letter: 'C',
      minPercentage: 60.0,
      maxPercentage: 69.9,
      gpaPoint: 7.0,
      remarks: 'Average',
    ),
    const GradingScaleEntity(
      id: 'GS-011',
      branchId: 'BR-002',
      letter: 'P',
      minPercentage: 33.0,
      maxPercentage: 59.9,
      gpaPoint: 5.0,
      remarks: 'Pass',
    ),
    const GradingScaleEntity(
      id: 'GS-012',
      branchId: 'BR-002',
      letter: 'F',
      minPercentage: 0.0,
      maxPercentage: 32.9,
      gpaPoint: 0.0,
      remarks: 'Fail',
    ),
  ]);

  void addGradingScale(GradingScaleEntity scale) {
    state = [...state, scale];
  }
}

final gradingScalesProvider = StateNotifierProvider<GradingScalesNotifier, List<GradingScaleEntity>>((ref) {
  return GradingScalesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Marks Entry & Moderation per branch
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StudentExamMarksEntity {
  final String id;
  final String branchId;
  final String scheduleId;
  final String studentId;
  final String studentName;
  final double theoryMarks;
  final double practicalMarks;
  final double oralMarks;
  final double projectMarks;
  final double totalMarks;
  final double moderatedMarks;
  final bool isApproved;
  final String grade;
  final String status; // 'Passed', 'Failed', 'ATKT'
  final String remarks;

  const StudentExamMarksEntity({
    required this.id,
    required this.branchId,
    required this.scheduleId,
    required this.studentId,
    required this.studentName,
    required this.theoryMarks,
    required this.practicalMarks,
    required this.oralMarks,
    required this.projectMarks,
    required this.totalMarks,
    required this.moderatedMarks,
    required this.isApproved,
    required this.grade,
    required this.status,
    required this.remarks,
  });

  StudentExamMarksEntity copyWith({
    double? theoryMarks,
    double? practicalMarks,
    double? oralMarks,
    double? projectMarks,
    double? totalMarks,
    double? moderatedMarks,
    bool? isApproved,
    String? grade,
    String? status,
    String? remarks,
  }) {
    return StudentExamMarksEntity(
      id: id,
      branchId: branchId,
      scheduleId: scheduleId,
      studentId: studentId,
      studentName: studentName,
      theoryMarks: theoryMarks ?? this.theoryMarks,
      practicalMarks: practicalMarks ?? this.practicalMarks,
      oralMarks: oralMarks ?? this.oralMarks,
      projectMarks: projectMarks ?? this.projectMarks,
      totalMarks: totalMarks ?? this.totalMarks,
      moderatedMarks: moderatedMarks ?? this.moderatedMarks,
      isApproved: isApproved ?? this.isApproved,
      grade: grade ?? this.grade,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }
}

class StudentExamMarksNotifier extends StateNotifier<List<StudentExamMarksEntity>> {
  StudentExamMarksNotifier() : super([
    const StudentExamMarksEntity(
      id: 'SM-001',
      branchId: 'BR-001',
      scheduleId: 'ES-001',
      studentId: 'STU-001',
      studentName: 'Aarav Sharma',
      theoryMarks: 85.0,
      practicalMarks: 0.0,
      oralMarks: 0.0,
      projectMarks: 0.0,
      totalMarks: 85.0,
      moderatedMarks: 85.0,
      isApproved: false,
      grade: 'A',
      status: 'Passed',
      remarks: 'Outstanding logic skills',
    ),
    const StudentExamMarksEntity(
      id: 'SM-002',
      branchId: 'BR-001',
      scheduleId: 'ES-001',
      studentId: 'STU-002',
      studentName: 'Bhumika Gowda',
      theoryMarks: 55.0,
      practicalMarks: 0.0,
      oralMarks: 0.0,
      projectMarks: 0.0,
      totalMarks: 55.0,
      moderatedMarks: 55.0,
      isApproved: false,
      grade: 'C',
      status: 'Passed',
      remarks: 'Needs practice in algebra',
    ),
    const StudentExamMarksEntity(
      id: 'SM-003',
      branchId: 'BR-001',
      scheduleId: 'ES-001',
      studentId: 'STU-003',
      studentName: 'Chaitra Gowda',
      theoryMarks: 25.0,
      practicalMarks: 0.0,
      oralMarks: 0.0,
      projectMarks: 0.0,
      totalMarks: 25.0,
      moderatedMarks: 25.0,
      isApproved: false,
      grade: 'F',
      status: 'Failed',
      remarks: 'Incomplete preparation',
    ),
    const StudentExamMarksEntity(
      id: 'SM-004',
      branchId: 'BR-002',
      scheduleId: 'ES-003',
      studentId: 'STU-008',
      studentName: 'Sachin Tendulkar',
      theoryMarks: 88.0,
      practicalMarks: 0.0,
      oralMarks: 0.0,
      projectMarks: 0.0,
      totalMarks: 88.0,
      moderatedMarks: 88.0,
      isApproved: false,
      grade: 'A',
      status: 'Passed',
      remarks: 'Excellent calculation skills',
    ),
    const StudentExamMarksEntity(
      id: 'SM-005',
      branchId: 'BR-002',
      scheduleId: 'ES-003',
      studentId: 'STU-009',
      studentName: 'Lata Mangeshkar',
      theoryMarks: 94.0,
      practicalMarks: 0.0,
      oralMarks: 0.0,
      projectMarks: 0.0,
      totalMarks: 94.0,
      moderatedMarks: 94.0,
      isApproved: false,
      grade: 'O',
      status: 'Passed',
      remarks: 'Flawless scoring',
    ),
  ]);

  void enterMarks(StudentExamMarksEntity marks) {
    state = [
      for (final m in state)
        if (m.scheduleId == marks.scheduleId && m.studentId == marks.studentId)
          marks
        else
          m
    ];
    if (!state.any((m) => m.scheduleId == marks.scheduleId && m.studentId == marks.studentId)) {
      state = [...state, marks];
    }
  }

  void importBulkMarks(List<StudentExamMarksEntity> list) {
    // Merge new imports
    final List<StudentExamMarksEntity> newState = List.from(state);
    for (final newItem in list) {
      final index = newState.indexWhere((m) => m.scheduleId == newItem.scheduleId && m.studentId == newItem.studentId);
      if (index != -1) {
        newState[index] = newItem;
      } else {
        newState.add(newItem);
      }
    }
    state = newState;
  }

  void applyModeration(String scheduleId, double scalingFactor) {
    state = state.map((m) {
      if (m.scheduleId == scheduleId && !m.isApproved) {
        final newModMarks = (m.totalMarks + scalingFactor) > 100.0 ? 100.0 : (m.totalMarks + scalingFactor);
        return m.copyWith(moderatedMarks: newModMarks < 0.0 ? 0.0 : newModMarks);
      }
      return m;
    }).toList();
  }

  void approveMarks(String scheduleId) {
    state = state.map((m) {
      if (m.scheduleId == scheduleId) {
        return m.copyWith(isApproved: true);
      }
      return m;
    }).toList();
  }
}

final studentExamMarksProvider = StateNotifierProvider<
    StudentExamMarksNotifier, List<StudentExamMarksEntity>>((ref) {
  return StudentExamMarksNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Re-evaluation & Rechecking Requests per branch
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class RecheckRequestEntity {
  final String id;
  final String branchId;
  final String marksId;
  final String studentName;
  final String subjectName;
  final String requestType; // 'Recheck', 'Re-evaluation'
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final DateTime date;

  const RecheckRequestEntity({
    required this.id,
    required this.branchId,
    required this.marksId,
    required this.studentName,
    required this.subjectName,
    required this.requestType,
    required this.reason,
    required this.status,
    required this.date,
  });

  RecheckRequestEntity copyWith({String? status}) {
    return RecheckRequestEntity(
      id: id,
      branchId: branchId,
      marksId: marksId,
      studentName: studentName,
      subjectName: subjectName,
      requestType: requestType,
      reason: reason,
      status: status ?? this.status,
      date: date,
    );
  }
}

class RecheckRequestsNotifier extends StateNotifier<List<RecheckRequestEntity>> {
  RecheckRequestsNotifier() : super([
    RecheckRequestEntity(
      id: 'REQ-001',
      branchId: 'BR-001',
      marksId: 'SM-002',
      studentName: 'Bhumika Gowda',
      subjectName: 'Mathematics',
      requestType: 'Re-evaluation',
      reason: 'Score is lower than expected in section B',
      status: 'Pending',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RecheckRequestEntity(
      id: 'REQ-002',
      branchId: 'BR-002',
      marksId: 'SM-004',
      studentName: 'Sachin Tendulkar',
      subjectName: 'Mathematics',
      requestType: 'Recheck',
      reason: 'Recounting error in main sheet',
      status: 'Pending',
      date: DateTime.now(),
    ),
  ]);

  void addRequest(RecheckRequestEntity req) {
    state = [...state, req];
  }

  void updateStatus(String id, String status) {
    state = state.map((r) => r.id == id ? r.copyWith(status: status) : r).toList();
  }
}

final recheckRequestsProvider =
    StateNotifierProvider<RecheckRequestsNotifier, List<RecheckRequestEntity>>((ref) {
  return RecheckRequestsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Supplementary Exam Management per branch
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SupplementaryExamEntity {
  final String id;
  final String branchId;
  final String studentId;
  final String studentName;
  final String subjectName;
  final DateTime examDate;
  final String status; // 'Scheduled', 'Passed', 'Failed'

  const SupplementaryExamEntity({
    required this.id,
    required this.branchId,
    required this.studentId,
    required this.studentName,
    required this.subjectName,
    required this.examDate,
    required this.status,
  });

  SupplementaryExamEntity copyWith({String? status}) {
    return SupplementaryExamEntity(
      id: id,
      branchId: branchId,
      studentId: studentId,
      studentName: studentName,
      subjectName: subjectName,
      examDate: examDate,
      status: status ?? this.status,
    );
  }
}

class SupplementaryExamsNotifier extends StateNotifier<List<SupplementaryExamEntity>> {
  SupplementaryExamsNotifier() : super([
    SupplementaryExamEntity(
      id: 'SUP-001',
      branchId: 'BR-001',
      studentId: 'STU-003',
      studentName: 'Chaitra Gowda',
      subjectName: 'Mathematics',
      examDate: DateTime.now().add(const Duration(days: 20)),
      status: 'Scheduled',
    ),
    SupplementaryExamEntity(
      id: 'SUP-002',
      branchId: 'BR-002',
      studentId: 'STU-009',
      studentName: 'Lata Mangeshkar',
      subjectName: 'Music Theory',
      examDate: DateTime.now().add(const Duration(days: 22)),
      status: 'Scheduled',
    ),
  ]);

  void addSupplementary(SupplementaryExamEntity exam) {
    state = [...state, exam];
  }

  void updateStatus(String id, String status) {
    state = state.map((e) => e.id == id ? e.copyWith(status: status) : e).toList();
  }
}

final supplementaryExamsProvider =
    StateNotifierProvider<SupplementaryExamsNotifier, List<SupplementaryExamEntity>>((ref) {
  return SupplementaryExamsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Seating Arrangements & Invigilator Mappings
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SeatingArrangementEntity {
  final String id;
  final String branchId;
  final String scheduleId;
  final String studentId;
  final String studentName;
  final String roomNo;
  final String deskNo;
  final String invigilatorName;

  const SeatingArrangementEntity({
    required this.id,
    required this.branchId,
    required this.scheduleId,
    required this.studentId,
    required this.studentName,
    required this.roomNo,
    required this.deskNo,
    required this.invigilatorName,
  });
}

class SeatingArrangementsNotifier extends StateNotifier<List<SeatingArrangementEntity>> {
  SeatingArrangementsNotifier() : super([
    const SeatingArrangementEntity(
      id: 'SEAT-001',
      branchId: 'BR-001',
      scheduleId: 'ES-001',
      studentId: 'STU-001',
      studentName: 'Aarav Sharma',
      roomNo: 'Room 301 (Building A)',
      deskNo: 'A-12',
      invigilatorName: 'Mr. Harish Sen',
    ),
    const SeatingArrangementEntity(
      id: 'SEAT-002',
      branchId: 'BR-001',
      scheduleId: 'ES-001',
      studentId: 'STU-002',
      studentName: 'Bhumika Gowda',
      roomNo: 'Room 301 (Building A)',
      deskNo: 'A-13',
      invigilatorName: 'Mr. Harish Sen',
    ),
    const SeatingArrangementEntity(
      id: 'SEAT-003',
      branchId: 'BR-002',
      scheduleId: 'ES-003',
      studentId: 'STU-008',
      studentName: 'Sachin Tendulkar',
      roomNo: 'Room 101 (Mumbai South)',
      deskNo: 'M-05',
      invigilatorName: 'Mrs. Rekha Joshi',
    ),
    const SeatingArrangementEntity(
      id: 'SEAT-004',
      branchId: 'BR-002',
      scheduleId: 'ES-003',
      studentId: 'STU-009',
      studentName: 'Lata Mangeshkar',
      roomNo: 'Room 101 (Mumbai South)',
      deskNo: 'M-06',
      invigilatorName: 'Mrs. Rekha Joshi',
    ),
  ]);

  void generateArrangement(List<SeatingArrangementEntity> list) {
    state = [...state, ...list];
  }
}

final seatingArrangementsProvider =
    StateNotifierProvider<SeatingArrangementsNotifier, List<SeatingArrangementEntity>>((ref) {
  return SeatingArrangementsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Question Papers Management per branch
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class QuestionPaperEntity {
  final String id;
  final String branchId;
  final String title;
  final String subjectName;
  final String status; // 'Draft', 'Approved'
  final String uploadedBy;

  const QuestionPaperEntity({
    required this.id,
    required this.branchId,
    required this.title,
    required this.subjectName,
    required this.status,
    required this.uploadedBy,
  });

  QuestionPaperEntity copyWith({String? status}) {
    return QuestionPaperEntity(
      id: id,
      branchId: branchId,
      title: title,
      subjectName: subjectName,
      status: status ?? this.status,
      uploadedBy: uploadedBy,
    );
  }
}

class QuestionPapersNotifier extends StateNotifier<List<QuestionPaperEntity>> {
  QuestionPapersNotifier() : super([
    const QuestionPaperEntity(
      id: 'QP-001',
      branchId: 'BR-001',
      title: 'Class 10 Algebra Final Mock',
      subjectName: 'Mathematics',
      status: 'Approved',
      uploadedBy: 'Mrs. Kavita Verma',
    ),
    const QuestionPaperEntity(
      id: 'QP-002',
      branchId: 'BR-001',
      title: 'Class 10 Physics Lab Practicals',
      subjectName: 'Science',
      status: 'Draft',
      uploadedBy: 'Mr. Harish Sen',
    ),
    const QuestionPaperEntity(
      id: 'QP-003',
      branchId: 'BR-002',
      title: 'Mumbai Term II Algebra Main',
      subjectName: 'Mathematics',
      status: 'Draft',
      uploadedBy: 'Mrs. Rekha Joshi',
    ),
  ]);

  void uploadPaper(QuestionPaperEntity paper) {
    state = [...state, paper];
  }

  void approvePaper(String id) {
    state = state.map((p) => p.id == id ? p.copyWith(status: 'Approved') : p).toList();
  }
}

final questionPapersProvider =
    StateNotifierProvider<QuestionPapersNotifier, List<QuestionPaperEntity>>((ref) {
  return QuestionPapersNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Online Exam Configurations per branch
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OnlineExamConfigEntity {
  final String id;
  final String branchId;
  final String title;
  final String subjectName;
  final int durationMinutes;
  final int totalQuestions;
  final bool isActive;

  const OnlineExamConfigEntity({
    required this.id,
    required this.branchId,
    required this.title,
    required this.subjectName,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.isActive,
  });

  OnlineExamConfigEntity copyWith({bool? isActive}) {
    return OnlineExamConfigEntity(
      id: id,
      branchId: branchId,
      title: title,
      subjectName: subjectName,
      durationMinutes: durationMinutes,
      totalQuestions: totalQuestions,
      isActive: isActive ?? this.isActive,
    );
  }
}

class OnlineExamConfigsNotifier extends StateNotifier<List<OnlineExamConfigEntity>> {
  OnlineExamConfigsNotifier() : super([
    const OnlineExamConfigEntity(
      id: 'ON-001',
      branchId: 'BR-001',
      title: 'Online Algebra MCQ Assessment',
      subjectName: 'Mathematics',
      durationMinutes: 45,
      totalQuestions: 30,
      isActive: true,
    ),
    const OnlineExamConfigEntity(
      id: 'ON-002',
      branchId: 'BR-002',
      title: 'Mumbai Geometry Midterm MCQ',
      subjectName: 'Mathematics',
      durationMinutes: 60,
      totalQuestions: 40,
      isActive: true,
    ),
  ]);

  void addOnlineExam(OnlineExamConfigEntity config) {
    state = [...state, config];
  }

  void toggleStatus(String id) {
    state = state.map((c) => c.id == id ? c.copyWith(isActive: !c.isActive) : c).toList();
  }
}

final onlineExamConfigsProvider =
    StateNotifierProvider<OnlineExamConfigsNotifier, List<OnlineExamConfigEntity>>((ref) {
  return OnlineExamConfigsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Consolidated Certificate Requests (Migration / Consolidated Marksheet)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class CertificateRequestEntity {
  final String id;
  final String branchId;
  final String studentId;
  final String studentName;
  final String type; // 'Consolidated Marksheet', 'Migration Certificate', 'CCE Report'
  final DateTime dateGenerated;
  final String status; // 'Generated', 'Shared'

  const CertificateRequestEntity({
    required this.id,
    required this.branchId,
    required this.studentId,
    required this.studentName,
    required this.type,
    required this.dateGenerated,
    required this.status,
  });

  CertificateRequestEntity copyWith({String? status}) {
    return CertificateRequestEntity(
      id: id,
      branchId: branchId,
      studentId: studentId,
      studentName: studentName,
      type: type,
      dateGenerated: dateGenerated,
      status: status ?? this.status,
    );
  }
}

class CertificateRequestsNotifier extends StateNotifier<List<CertificateRequestEntity>> {
  CertificateRequestsNotifier() : super([
    CertificateRequestEntity(
      id: 'CERT-001',
      branchId: 'BR-001',
      studentId: 'STU-001',
      studentName: 'Aarav Sharma',
      type: 'Migration Certificate',
      dateGenerated: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Shared',
    ),
    CertificateRequestEntity(
      id: 'CERT-002',
      branchId: 'BR-002',
      studentId: 'STU-008',
      studentName: 'Sachin Tendulkar',
      type: 'Consolidated Marksheet',
      dateGenerated: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Generated',
    ),
  ]);

  void addRequest(CertificateRequestEntity cert) {
    state = [...state, cert];
  }

  void updateStatus(String id, String status) {
    state = state.map((c) => c.id == id ? c.copyWith(status: status) : c).toList();
  }
}

final certificateRequestsProvider =
    StateNotifierProvider<CertificateRequestsNotifier, List<CertificateRequestEntity>>((ref) {
  return CertificateRequestsNotifier();
});

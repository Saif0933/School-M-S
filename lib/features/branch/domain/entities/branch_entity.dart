import 'package:equatable/equatable.dart';
import '../../../../core/enums/enums.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch Entity — Individual school under organization
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BranchEntity extends Equatable {
  final String id;
  final String organizationId;
  final String code;
  final String name;
  final String affiliationBoard; // CBSE, ICSE, State Board, IB
  final String recognitionNumber;
  final String principalName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final BranchStatus status;
  final int maxStudentCapacity;
  final int maxStaffCapacity;
  final int activeStudentCount;
  final int activeStaffCount;
  final String currentAcademicYear;
  final String academicYearConfig; // e.g. '2026-2027 (Apr - Mar)'
  final List<String> sessionTerms; // e.g. ['Term 1 (Apr-Aug)', 'Term 2 (Sep-Dec)']
  final String branchAdminRole; // e.g. 'Principal / Branch Manager'
  final String planType; // Basic, Standard, Premium
  final Set<ModuleType> enabledModules;
  final Map<String, bool> customFields;
  final Map<String, String> brandingOverride; // 'primaryColor', 'customDomain'
  final List<String> branchHolidays;
  final Map<String, String> workingDaysAndHours; // 'days', 'hours', 'saturday'
  final DateTime createdAt;

  const BranchEntity({
    required this.id,
    required this.organizationId,
    required this.code,
    required this.name,
    required this.affiliationBoard,
    required this.recognitionNumber,
    required this.principalName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.status = BranchStatus.active,
    required this.maxStudentCapacity,
    required this.maxStaffCapacity,
    required this.activeStudentCount,
    required this.activeStaffCount,
    required this.currentAcademicYear,
    this.academicYearConfig = '2026-2027 (April - March)',
    this.sessionTerms = const [
      'Term 1 (Apr - Aug)',
      'Term 2 (Sep - Dec)',
      'Term 3 (Jan - Mar)'
    ],
    this.branchAdminRole = 'Principal & School Director',
    required this.planType,
    required this.enabledModules,
    this.customFields = const {
      'Student Blood Group Required': true,
      'Parent Alternate Emergency Contact': true,
      'Bus Route Assignment': true,
      'Hostel Room Choice': false,
    },
    this.brandingOverride = const {
      'primaryColor': '#6366F1',
      'customDomain': 'delhi.sunrisetrust.edu.in',
      'branchBadgeTitle': 'Delhi Campus',
    },
    this.branchHolidays = const [
      'Delhi Statehood Holiday (Jan 26)',
      'Independence Day (Aug 15)',
      'Diwali Trust Vacation (Nov 1-5)',
      'Winter Break (Dec 25 - Jan 2)',
    ],
    this.workingDaysAndHours = const {
      'workingDays': 'Monday - Saturday',
      'workingHours': '08:00 AM - 02:30 PM',
      'saturdayHours': '08:00 AM - 12:30 PM (Half Day)',
    },
    required this.createdAt,
  });

  BranchEntity copyWith({
    String? id,
    String? organizationId,
    String? code,
    String? name,
    String? affiliationBoard,
    String? recognitionNumber,
    String? principalName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    BranchStatus? status,
    int? maxStudentCapacity,
    int? maxStaffCapacity,
    int? activeStudentCount,
    int? activeStaffCount,
    String? currentAcademicYear,
    String? academicYearConfig,
    List<String>? sessionTerms,
    String? branchAdminRole,
    String? planType,
    Set<ModuleType>? enabledModules,
    Map<String, bool>? customFields,
    Map<String, String>? brandingOverride,
    List<String>? branchHolidays,
    Map<String, String>? workingDaysAndHours,
    DateTime? createdAt,
  }) {
    return BranchEntity(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      code: code ?? this.code,
      name: name ?? this.name,
      affiliationBoard: affiliationBoard ?? this.affiliationBoard,
      recognitionNumber: recognitionNumber ?? this.recognitionNumber,
      principalName: principalName ?? this.principalName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      status: status ?? this.status,
      maxStudentCapacity: maxStudentCapacity ?? this.maxStudentCapacity,
      maxStaffCapacity: maxStaffCapacity ?? this.maxStaffCapacity,
      activeStudentCount: activeStudentCount ?? this.activeStudentCount,
      activeStaffCount: activeStaffCount ?? this.activeStaffCount,
      currentAcademicYear: currentAcademicYear ?? this.currentAcademicYear,
      academicYearConfig: academicYearConfig ?? this.academicYearConfig,
      sessionTerms: sessionTerms ?? this.sessionTerms,
      branchAdminRole: branchAdminRole ?? this.branchAdminRole,
      planType: planType ?? this.planType,
      enabledModules: enabledModules ?? this.enabledModules,
      customFields: customFields ?? this.customFields,
      brandingOverride: brandingOverride ?? this.brandingOverride,
      branchHolidays: branchHolidays ?? this.branchHolidays,
      workingDaysAndHours: workingDaysAndHours ?? this.workingDaysAndHours,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, organizationId, code, name, status];
}

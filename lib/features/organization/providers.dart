import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/enums.dart';
import '../branch/domain/entities/branch_entity.dart';
import 'domain/entities/organization_entity.dart';

/// Default Master Organization for Sunrise Education Trust
final OrganizationEntity _defaultOrganization = OrganizationEntity(
  id: 'ORG-001',
  name: 'Sunrise Education Trust',
  registrationNumber: 'REG-2018-SET-8849',
  taxRegistrationNumber: 'GSTIN-07AAATS8849K1Z5',
  logoUrl: null,
  email: 'info@sunrisetrust.edu.in',
  phone: '+91 11 4567 8900',
  address: '12, Education Hub, Institutional Area, Vasant Kunj, New Delhi - 110070',
  website: 'https://sunrisetrust.edu.in',
  subdomain: 'sunrise.symbosys.com',
  superAdminName: 'Rajesh Kumar Sharma',
  superAdminEmail: 'superadmin@symbosys.com',
  superAdminPhone: '+91 9876543210',
  billingContactEmail: 'billing@sunrisetrust.edu.in',
  technicalContactEmail: 'tech@sunrisetrust.edu.in',
  subscriptionPlan: 'Enterprise Plan',
  maxBranches: 10,
  maxTotalStudents: 10000,
  smsCreditPool: 150000,
  emailCreditPool: 500000,
  brandPrimaryColorHex: '#6366F1',
  createdAt: DateTime(2018, 4, 1),
  auditLogs: [
    {
      'action': 'ORGANIZATION_PROVISIONED',
      'user': 'System Super Admin',
      'timestamp': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'details': 'Sunrise Education Trust onboarded with Enterprise Plan.',
    },
    {
      'action': 'BRANCH_ADDED',
      'user': 'Rajesh Kumar Sharma',
      'timestamp': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      'details': 'Sunrise Academy Bangalore branch provisioned (SA-BLR).',
    },
    {
      'action': 'CREDIT_POOL_RECHARGED',
      'user': 'Rajesh Kumar Sharma',
      'timestamp': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'details': 'Recharged 50,000 SMS credits for all branches.',
    },
  ],
);

/// Default Branches for Sunrise Education Trust
final List<BranchEntity> _defaultBranches = [
  BranchEntity(
    id: 'BR-001',
    organizationId: 'ORG-001',
    code: 'SIS-DEL',
    name: 'Sunrise International School - Delhi',
    affiliationBoard: 'CBSE',
    recognitionNumber: 'CBSE/AFF/2020/1104',
    principalName: 'Dr. Meenakshi Sundaram',
    email: 'delhi@sunrisetrust.edu.in',
    phone: '+91 11 2612 3456',
    address: 'Plot 4, Vasant Kunj Sector C',
    city: 'New Delhi',
    state: 'Delhi',
    pincode: '110070',
    status: BranchStatus.active,
    maxStudentCapacity: 3000,
    maxStaffCapacity: 200,
    activeStudentCount: 2847,
    activeStaffCount: 186,
    currentAcademicYear: '2026-2027',
    planType: 'Premium',
    enabledModules: ModuleType.values.toSet(),
    createdAt: DateTime(2018, 6, 1),
  ),
  BranchEntity(
    id: 'BR-002',
    organizationId: 'ORG-001',
    code: 'SPS-MUM',
    name: 'Sunrise Public School - Mumbai',
    affiliationBoard: 'ICSE',
    recognitionNumber: 'ICSE/MAH/2021/883',
    principalName: 'Mr. Rajeshwar Rao',
    email: 'mumbai@sunrisetrust.edu.in',
    phone: '+91 22 6789 1234',
    address: 'Bandra-Kurla Complex, Bandra East',
    city: 'Mumbai',
    state: 'Maharashtra',
    pincode: '400051',
    status: BranchStatus.active,
    maxStudentCapacity: 2500,
    maxStaffCapacity: 150,
    activeStudentCount: 2150,
    activeStaffCount: 142,
    currentAcademicYear: '2026-2027',
    planType: 'Premium',
    enabledModules: ModuleType.values.toSet(),
    createdAt: DateTime(2020, 8, 15),
  ),
  BranchEntity(
    id: 'BR-003',
    organizationId: 'ORG-001',
    code: 'SA-BLR',
    name: 'Sunrise Academy - Bangalore',
    affiliationBoard: 'IB World School',
    recognitionNumber: 'IB/IND/2022/990',
    principalName: 'Mrs. Sarah Williams',
    email: 'bangalore@sunrisetrust.edu.in',
    phone: '+91 80 4123 5678',
    address: 'Whitefield Main Road, Near ITPL',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560066',
    status: BranchStatus.active,
    maxStudentCapacity: 1500,
    maxStaffCapacity: 100,
    activeStudentCount: 1280,
    activeStaffCount: 94,
    currentAcademicYear: '2026-2027',
    planType: 'Standard',
    enabledModules: ModuleType.values.where((m) => m != ModuleType.hostel).toSet(),
    createdAt: DateTime(2022, 3, 10),
  ),
];

/// Cross-Branch Transfer Log entity
class CrossBranchTransferLog {
  final String id;
  final String entityType; // 'student' or 'staff'
  final String entityName;
  final String entityCode;
  final String fromBranchName;
  final String toBranchName;
  final String reason;
  final String status; // 'approved', 'pending', 'migrated'
  final DateTime date;

  const CrossBranchTransferLog({
    required this.id,
    required this.entityType,
    required this.entityName,
    required this.entityCode,
    required this.fromBranchName,
    required this.toBranchName,
    required this.reason,
    required this.status,
    required this.date,
  });
}

final List<CrossBranchTransferLog> _initialTransferLogs = [
  CrossBranchTransferLog(
    id: 'TRF-001',
    entityType: 'student',
    entityName: 'Rohan Verma',
    entityCode: 'STU-2024-089',
    fromBranchName: 'Sunrise International School - Delhi',
    toBranchName: 'Sunrise Public School - Mumbai',
    reason: 'Parent relocated to Mumbai headquarters',
    status: 'migrated',
    date: DateTime.now().subtract(const Duration(days: 12)),
  ),
  CrossBranchTransferLog(
    id: 'TRF-002',
    entityType: 'staff',
    entityName: 'Anita Desai (Senior Physics Teacher)',
    entityCode: 'TCH-2021-042',
    fromBranchName: 'Sunrise Public School - Mumbai',
    toBranchName: 'Sunrise Academy - Bangalore',
    reason: 'Promoted to HOD Sciences in Bangalore branch',
    status: 'approved',
    date: DateTime.now().subtract(const Duration(days: 4)),
  ),
];

/// StateNotifier for Organization Entity
class OrganizationNotifier extends StateNotifier<OrganizationEntity> {
  OrganizationNotifier() : super(_defaultOrganization);

  void updateOrganizationProfile({
    required String name,
    required String regNo,
    required String taxNo,
    required String email,
    required String phone,
    required String address,
    required String website,
    required String subdomain,
    required String superAdminName,
    required String superAdminEmail,
  }) {
    state = state.copyWith(
      name: name,
      registrationNumber: regNo,
      taxRegistrationNumber: taxNo,
      email: email,
      phone: phone,
      address: address,
      website: website,
      subdomain: subdomain,
      superAdminName: superAdminName,
      superAdminEmail: superAdminEmail,
    );
    addAuditLog('PROFILE_UPDATED', 'Organization profile & tax info updated.');
  }

  void addMasterSubject(String subject) {
    if (!state.masterSubjects.contains(subject)) {
      state = state.copyWith(
        masterSubjects: [...state.masterSubjects, subject],
      );
      addAuditLog('MASTER_SUBJECT_ADDED', 'Added master subject: $subject.');
    }
  }

  void removeMasterSubject(String subject) {
    state = state.copyWith(
      masterSubjects: state.masterSubjects.where((s) => s != subject).toList(),
    );
    addAuditLog('MASTER_SUBJECT_REMOVED', 'Removed master subject: $subject.');
  }

  void addMasterFeeHead(String feeHead) {
    if (!state.masterFeeHeads.contains(feeHead)) {
      state = state.copyWith(
        masterFeeHeads: [...state.masterFeeHeads, feeHead],
      );
      addAuditLog('MASTER_FEE_HEAD_ADDED', 'Added fee head: $feeHead.');
    }
  }

  void removeMasterFeeHead(String feeHead) {
    state = state.copyWith(
      masterFeeHeads: state.masterFeeHeads.where((f) => f != feeHead).toList(),
    );
    addAuditLog('MASTER_FEE_HEAD_REMOVED', 'Removed fee head: $feeHead.');
  }

  void addMasterDesignation(String designation) {
    if (!state.masterDesignations.contains(designation)) {
      state = state.copyWith(
        masterDesignations: [...state.masterDesignations, designation],
      );
      addAuditLog('MASTER_DESIGNATION_ADDED', 'Added designation: $designation.');
    }
  }

  void removeMasterDesignation(String designation) {
    state = state.copyWith(
      masterDesignations:
          state.masterDesignations.where((d) => d != designation).toList(),
    );
    addAuditLog('MASTER_DESIGNATION_REMOVED', 'Removed designation: $designation.');
  }

  void updateMasterSettings(Map<String, dynamic> newSettings) {
    final updated = Map<String, dynamic>.from(state.masterSettings)..addAll(newSettings);
    state = state.copyWith(masterSettings: updated);
    addAuditLog('MASTER_SETTINGS_UPDATED', 'Updated organization-wide settings & policies.');
  }

  void updateCredits({required int smsCount, required int emailCount}) {
    state = state.copyWith(
      smsCreditPool: state.smsCreditPool + smsCount,
      emailCreditPool: state.emailCreditPool + emailCount,
    );
    addAuditLog('CREDITS_RECHARGED', 'Recharged $smsCount SMS and $emailCount Email credits.');
  }

  void updatePrimaryColor(String hexColor) {
    state = state.copyWith(brandPrimaryColorHex: hexColor);
    addAuditLog('BRANDING_UPDATED', 'Updated primary brand color to $hexColor.');
  }

  void addAuditLog(String action, String details) {
    final newEntry = {
      'action': action,
      'user': state.superAdminName,
      'timestamp': DateTime.now().toIso8601String(),
      'details': details,
    };
    state = state.copyWith(auditLogs: [newEntry, ...state.auditLogs]);
  }
}

/// Provider for Organization Entity
final organizationProvider =
    StateNotifierProvider<OrganizationNotifier, OrganizationEntity>((ref) {
  return OrganizationNotifier();
});

/// StateNotifier for Branches under the Organization
class OrganizationBranchesNotifier extends StateNotifier<List<BranchEntity>> {
  OrganizationBranchesNotifier() : super(_defaultBranches);

  void onboardBranch({
    required String code,
    required String name,
    required String affiliationBoard,
    required String principalName,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String stateName,
    required int maxStudents,
    required int maxStaff,
  }) {
    final newBranch = BranchEntity(
      id: 'BR-00${state.length + 1}',
      organizationId: 'ORG-001',
      code: code.toUpperCase(),
      name: name,
      affiliationBoard: affiliationBoard,
      recognitionNumber: 'REC/2026/${state.length + 101}',
      principalName: principalName,
      email: email,
      phone: phone,
      address: address,
      city: city,
      state: stateName,
      pincode: '110001',
      status: BranchStatus.active,
      maxStudentCapacity: maxStudents,
      maxStaffCapacity: maxStaff,
      activeStudentCount: 0,
      activeStaffCount: 0,
      currentAcademicYear: '2026-2027',
      planType: 'Standard',
      enabledModules: ModuleType.values.toSet(),
      createdAt: DateTime.now(),
    );

    state = [...state, newBranch];
  }

  void updateBranchProfile(BranchEntity updatedBranch) {
    state = [
      for (final b in state)
        if (b.id == updatedBranch.id) updatedBranch else b,
    ];
  }

  void toggleBranchStatus(String branchId) {
    state = [
      for (final b in state)
        if (b.id == branchId)
          b.copyWith(
            status: b.status == BranchStatus.active
                ? BranchStatus.inactive
                : BranchStatus.active,
          )
        else
          b,
    ];
  }

  void updateBranchPlan({required String branchId, required String newPlan}) {
    state = [
      for (final b in state)
        if (b.id == branchId) b.copyWith(planType: newPlan) else b,
    ];
  }

  void updateBranchCapacities({
    required String branchId,
    required int maxStudents,
    required int maxStaff,
  }) {
    state = [
      for (final b in state)
        if (b.id == branchId)
          b.copyWith(
            maxStudentCapacity: maxStudents,
            maxStaffCapacity: maxStaff,
          )
        else
          b,
    ];
  }
}

/// Provider for Organization Branches
final organizationBranchesProvider =
    StateNotifierProvider<OrganizationBranchesNotifier, List<BranchEntity>>(
        (ref) {
  return OrganizationBranchesNotifier();
});

/// StateNotifier for Cross-Branch Transfers
class CrossBranchTransferNotifier
    extends StateNotifier<List<CrossBranchTransferLog>> {
  CrossBranchTransferNotifier() : super(_initialTransferLogs);

  void requestTransfer({
    required String entityType,
    required String entityName,
    required String entityCode,
    required String fromBranchName,
    required String toBranchName,
    required String reason,
  }) {
    final newLog = CrossBranchTransferLog(
      id: 'TRF-00${state.length + 1}',
      entityType: entityType,
      entityName: entityName,
      entityCode: entityCode,
      fromBranchName: fromBranchName,
      toBranchName: toBranchName,
      reason: reason,
      status: 'migrated',
      date: DateTime.now(),
    );
    state = [newLog, ...state];
  }
}

/// Provider for Cross-Branch Transfers
final crossBranchTransferProvider = StateNotifierProvider<
    CrossBranchTransferNotifier, List<CrossBranchTransferLog>>((ref) {
  return CrossBranchTransferNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Organization Admin Entity (Level 1 Admin Roles)
/// Super Admin, Billing Admin, Support Admin, Compliance Admin
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OrgAdminEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'Super Admin', 'Billing Admin', 'Support Admin', 'Compliance Admin'
  final String branchScope; // 'ALL' or specific branch name
  final List<String> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const OrgAdminEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.branchScope = 'ALL (Global Trust Scope)',
    required this.permissions,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
  });

  OrgAdminEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? branchScope,
    List<String>? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return OrgAdminEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      branchScope: branchScope ?? this.branchScope,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

final List<OrgAdminEntity> _initialOrgAdmins = [
  OrgAdminEntity(
    id: 'ADM-ORG-001',
    name: 'Dr. Rajesh Kumar Sharma',
    email: 'superadmin@symbosys.com',
    phone: '+91 9876543210',
    role: 'Super Admin',
    branchScope: 'ALL (Global Trust Scope)',
    permissions: const [
      'Full Organization Control',
      'Branch Onboarding & Deactivation',
      'Cross-Branch Migration Approval',
      'Subscription Billing',
      'Master Data Configuration',
    ],
    isActive: true,
    createdAt: DateTime(2018, 4, 1),
    lastLoginAt: DateTime.now(),
  ),
  OrgAdminEntity(
    id: 'ADM-ORG-002',
    name: 'Siddharth Varma',
    email: 'billing@sunrisetrust.edu.in',
    phone: '+91 9811223344',
    role: 'Billing Admin',
    branchScope: 'ALL (Global Trust Scope)',
    permissions: const [
      'Subscription Renewal',
      'Invoices & Payments',
      'SMS & Email Credit Recharges',
      'Financial Analytics',
    ],
    isActive: true,
    createdAt: DateTime(2021, 6, 15),
    lastLoginAt: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  OrgAdminEntity(
    id: 'ADM-ORG-003',
    name: 'Priyanka Sen',
    email: 'support@sunrisetrust.edu.in',
    phone: '+91 9877665544',
    role: 'Support Admin',
    branchScope: 'ALL (Global Trust Scope)',
    permissions: const [
      'Cross-Branch Helpdesk',
      'Password Resets',
      'Branch Diagnostic Logs',
      'User License Audits',
    ],
    isActive: true,
    createdAt: DateTime(2023, 1, 10),
    lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

class OrgAdminNotifier extends StateNotifier<List<OrgAdminEntity>> {
  OrgAdminNotifier() : super(_initialOrgAdmins);

  void createAdmin({
    required String name,
    required String email,
    required String phone,
    required String role,
    required String branchScope,
    required List<String> permissions,
  }) {
    final newAdmin = OrgAdminEntity(
      id: 'ADM-ORG-00${state.length + 1}',
      name: name,
      email: email,
      phone: phone,
      role: role,
      branchScope: branchScope,
      permissions: permissions,
      isActive: true,
      createdAt: DateTime.now(),
    );
    state = [newAdmin, ...state];
  }

  void toggleAdminStatus(String adminId) {
    state = [
      for (final a in state)
        if (a.id == adminId) a.copyWith(isActive: !a.isActive) else a,
    ];
  }

  void deleteAdmin(String adminId) {
    state = state.where((a) => a.id != adminId).toList();
  }
}

final orgAdminsProvider =
    StateNotifierProvider<OrgAdminNotifier, List<OrgAdminEntity>>((ref) {
  return OrgAdminNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Organization-Wide Broadcast Announcement Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BroadcastAnnouncementLog {
  final String id;
  final String title;
  final String content;
  final String priority; // 'Normal', 'Urgent', 'Emergency'
  final String targetBranches; // 'ALL' or specific branches
  final DateTime broadcastAt;
  final String sentBy;

  const BroadcastAnnouncementLog({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.targetBranches,
    required this.broadcastAt,
    required this.sentBy,
  });
}

final List<BroadcastAnnouncementLog> _initialAnnouncements = [
  BroadcastAnnouncementLog(
    id: 'BCAST-001',
    title: 'Annual CBSE & ICSE Board Exam Master Schedule Released',
    content:
        'All branch principals and academic heads must synchronize preliminary timetables by September 15th.',
    priority: 'Urgent',
    targetBranches: 'ALL Branches (Delhi, Mumbai, Bangalore)',
    broadcastAt: DateTime.now().subtract(const Duration(days: 2)),
    sentBy: 'Super Admin (Dr. Rajesh Sharma)',
  ),
  BroadcastAnnouncementLog(
    id: 'BCAST-002',
    title: 'System Maintenance Window & Term Fee Refund Policy Update',
    content:
        'ERP cloud servers will undergo scheduled security upgrades on Sunday midnight. Please review revised refund policies in Master Templates.',
    priority: 'Normal',
    targetBranches: 'ALL Branches',
    broadcastAt: DateTime.now().subtract(const Duration(days: 6)),
    sentBy: 'Compliance Admin (Kavita Iyer)',
  ),
];

class OrganizationAnnouncementsNotifier
    extends StateNotifier<List<BroadcastAnnouncementLog>> {
  OrganizationAnnouncementsNotifier() : super(_initialAnnouncements);

  void broadcastAnnouncement({
    required String title,
    required String content,
    required String priority,
    required String targetBranches,
    required String sentBy,
  }) {
    final newBcast = BroadcastAnnouncementLog(
      id: 'BCAST-00${state.length + 1}',
      title: title,
      content: content,
      priority: priority,
      targetBranches: targetBranches,
      broadcastAt: DateTime.now(),
      sentBy: sentBy,
    );
    state = [newBcast, ...state];
  }
}

final organizationAnnouncementsProvider = StateNotifierProvider<
    OrganizationAnnouncementsNotifier,
    List<BroadcastAnnouncementLog>>((ref) {
  return OrganizationAnnouncementsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Master Organization Calendar Event Entity
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OrganizationEventEntity {
  final String id;
  final String title;
  final String eventType; // 'Academic', 'Exam', 'Holiday', 'Sports', 'Staff'
  final String branchScope; // 'ALL' or specific branch name
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final String description;

  const OrganizationEventEntity({
    required this.id,
    required this.title,
    required this.eventType,
    required this.branchScope,
    required this.startDate,
    required this.endDate,
    required this.venue,
    required this.description,
  });
}

final List<OrganizationEventEntity> _initialEvents = [
  OrganizationEventEntity(
    id: 'EVT-001',
    title: 'Inter-Branch Sports & Athletics Meet 2026',
    eventType: 'Sports',
    branchScope: 'ALL Branches',
    startDate: DateTime(2026, 9, 20),
    endDate: DateTime(2026, 9, 22),
    venue: 'Sunrise International Stadium, Delhi',
    description:
        'Annual multi-branch athletics tournament across football, swimming and track events.',
  ),
  OrganizationEventEntity(
    id: 'EVT-002',
    title: 'Mid-Term Board Examination 2026',
    eventType: 'Exam',
    branchScope: 'ALL Branches',
    startDate: DateTime(2026, 10, 5),
    endDate: DateTime(2026, 10, 18),
    venue: 'All Branch Campuses',
    description:
        'Centralized mid-term examinations for Classes IX, X, XI and XII.',
  ),
  OrganizationEventEntity(
    id: 'EVT-003',
    title: 'Parent-Teacher Executive Conference',
    eventType: 'Academic',
    branchScope: 'Sunrise Public School - Mumbai',
    startDate: DateTime(2026, 8, 28),
    endDate: DateTime(2026, 8, 28),
    venue: 'Mumbai Branch Auditorium',
    description: 'Quarterly academic progress discussion and career counselling session.',
  ),
  OrganizationEventEntity(
    id: 'EVT-004',
    title: 'Faculty Pedagogy & Technology Workshop',
    eventType: 'Staff',
    branchScope: 'ALL Branches',
    startDate: DateTime(2026, 9, 2),
    endDate: DateTime(2026, 9, 3),
    venue: 'Virtual ERP Training Portal',
    description: 'Professional development workshop on AI-assisted teaching tools.',
  ),
  OrganizationEventEntity(
    id: 'EVT-005',
    title: 'Gandhi Jayanti Trust Holiday',
    eventType: 'Holiday',
    branchScope: 'ALL Branches',
    startDate: DateTime(2026, 10, 2),
    endDate: DateTime(2026, 10, 2),
    venue: 'All Campuses Closed',
    description: 'National holiday observed across all organization institutions.',
  ),
];

class OrganizationEventsNotifier
    extends StateNotifier<List<OrganizationEventEntity>> {
  OrganizationEventsNotifier() : super(_initialEvents);

  void addEvent({
    required String title,
    required String eventType,
    required String branchScope,
    required DateTime startDate,
    required DateTime endDate,
    required String venue,
    required String description,
  }) {
    final newEvt = OrganizationEventEntity(
      id: 'EVT-00${state.length + 1}',
      title: title,
      eventType: eventType,
      branchScope: branchScope,
      startDate: startDate,
      endDate: endDate,
      venue: venue,
      description: description,
    );
    state = [newEvt, ...state];
  }
}

final organizationEventsProvider = StateNotifierProvider<
    OrganizationEventsNotifier, List<OrganizationEventEntity>>((ref) {
  return OrganizationEventsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch Credit Pool Allocation Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BranchCreditAllocation {
  final String branchId;
  final String branchName;
  final int allocatedSms;
  final int usedSms;
  final int allocatedEmail;
  final int usedEmail;

  const BranchCreditAllocation({
    required this.branchId,
    required this.branchName,
    required this.allocatedSms,
    required this.usedSms,
    required this.allocatedEmail,
    required this.usedEmail,
  });

  BranchCreditAllocation copyWith({
    int? allocatedSms,
    int? usedSms,
    int? allocatedEmail,
    int? usedEmail,
  }) {
    return BranchCreditAllocation(
      branchId: branchId,
      branchName: branchName,
      allocatedSms: allocatedSms ?? this.allocatedSms,
      usedSms: usedSms ?? this.usedSms,
      allocatedEmail: allocatedEmail ?? this.allocatedEmail,
      usedEmail: usedEmail ?? this.usedEmail,
    );
  }
}

final List<BranchCreditAllocation> _initialCreditAllocations = [
  const BranchCreditAllocation(
    branchId: 'BR-001',
    branchName: 'Sunrise International School - Delhi',
    allocatedSms: 25000,
    usedSms: 18420,
    allocatedEmail: 100000,
    usedEmail: 74200,
  ),
  const BranchCreditAllocation(
    branchId: 'BR-002',
    branchName: 'Sunrise Public School - Mumbai',
    allocatedSms: 15000,
    usedSms: 11200,
    allocatedEmail: 60000,
    usedEmail: 41800,
  ),
  const BranchCreditAllocation(
    branchId: 'BR-003',
    branchName: 'Sunrise Academy - Bangalore',
    allocatedSms: 10000,
    usedSms: 6150,
    allocatedEmail: 40000,
    usedEmail: 28900,
  ),
];

class BranchCreditAllocationsNotifier
    extends StateNotifier<List<BranchCreditAllocation>> {
  BranchCreditAllocationsNotifier() : super(_initialCreditAllocations);

  void allocateCredits({
    required String branchId,
    required int additionalSms,
    required int additionalEmail,
  }) {
    state = [
      for (final alloc in state)
        if (alloc.branchId == branchId)
          alloc.copyWith(
            allocatedSms: alloc.allocatedSms + additionalSms,
            allocatedEmail: alloc.allocatedEmail + additionalEmail,
          )
        else
          alloc,
    ];
  }
}

final branchCreditAllocationsProvider = StateNotifierProvider<
    BranchCreditAllocationsNotifier, List<BranchCreditAllocation>>((ref) {
  return BranchCreditAllocationsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Organization API Key & Webhook Entity Models
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OrgApiKey {
  final String id;
  final String keyName;
  final String apiKey;
  final String scope; // 'Read-Only', 'Write', 'Full Admin'
  final bool isActive;
  final DateTime createdAt;

  const OrgApiKey({
    required this.id,
    required this.keyName,
    required this.apiKey,
    required this.scope,
    this.isActive = true,
    required this.createdAt,
  });

  OrgApiKey copyWith({bool? isActive}) {
    return OrgApiKey(
      id: id,
      keyName: keyName,
      apiKey: apiKey,
      scope: scope,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}

final List<OrgApiKey> _initialApiKeys = [
  OrgApiKey(
    id: 'KEY-001',
    keyName: 'Production Accounting Gateway Key',
    apiKey: 'key_prod_99f82a1b7c3d4e5f6g7h8i9j',
    scope: 'Full Admin',
    createdAt: DateTime(2026, 1, 15),
  ),
  OrgApiKey(
    id: 'KEY-002',
    keyName: 'Mobile App Diagnostic Staging Key',
    apiKey: 'key_test_44e55f66g77h88i99j00k11l',
    scope: 'Read-Only',
    createdAt: DateTime(2026, 4, 10),
  ),
];

class OrgApiKeysNotifier extends StateNotifier<List<OrgApiKey>> {
  OrgApiKeysNotifier() : super(_initialApiKeys);

  void generateKey(String name, String scope) {
    final newKey = OrgApiKey(
      id: 'KEY-00${state.length + 1}',
      keyName: name,
      apiKey: 'key_live_${DateTime.now().millisecondsSinceEpoch}x99',
      scope: scope,
      createdAt: DateTime.now(),
    );
    state = [newKey, ...state];
  }

  void toggleKeyStatus(String keyId) {
    state = [
      for (final k in state)
        if (k.id == keyId) k.copyWith(isActive: !k.isActive) else k,
    ];
  }

  void revokeKey(String keyId) {
    state = state.where((k) => k.id != keyId).toList();
  }
}

final orgApiKeysProvider =
    StateNotifierProvider<OrgApiKeysNotifier, List<OrgApiKey>>((ref) {
  return OrgApiKeysNotifier();
});

class OrgWebhook {
  final String id;
  final String targetUrl;
  final String events; // 'fee.paid, student.transferred'
  final bool isActive;
  final DateTime createdAt;

  const OrgWebhook({
    required this.id,
    required this.targetUrl,
    required this.events,
    this.isActive = true,
    required this.createdAt,
  });

  OrgWebhook copyWith({bool? isActive}) {
    return OrgWebhook(
      id: id,
      targetUrl: targetUrl,
      events: events,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}

final List<OrgWebhook> _initialWebhooks = [
  OrgWebhook(
    id: 'HOOK-001',
    targetUrl: 'https://api.sunrisetrust.edu.in/webhooks/student-events',
    events: 'student.transferred, fee.paid',
    createdAt: DateTime(2026, 2, 1),
  ),
  OrgWebhook(
    id: 'HOOK-002',
    targetUrl: 'https://security.sunrisetrust.edu.in/webhooks/audit-logs',
    events: 'admin.created, policy.updated',
    createdAt: DateTime(2026, 5, 12),
  ),
];

class OrgWebhooksNotifier extends StateNotifier<List<OrgWebhook>> {
  OrgWebhooksNotifier() : super(_initialWebhooks);

  void addWebhook(String url, String events) {
    final newHook = OrgWebhook(
      id: 'HOOK-00${state.length + 1}',
      targetUrl: url,
      events: events,
      createdAt: DateTime.now(),
    );
    state = [newHook, ...state];
  }

  void toggleWebhook(String hookId) {
    state = [
      for (final h in state)
        if (h.id == hookId) h.copyWith(isActive: !h.isActive) else h,
    ];
  }

  void deleteWebhook(String hookId) {
    state = state.where((h) => h.id != hookId).toList();
  }
}

final orgWebhooksProvider =
    StateNotifierProvider<OrgWebhooksNotifier, List<OrgWebhook>>((ref) {
  return OrgWebhooksNotifier();
});


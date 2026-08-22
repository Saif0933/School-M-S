import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/enums.dart';
import '../../core/network/api_client.dart';
import '../auth/providers.dart';
import '../branch/domain/entities/branch_entity.dart';
import 'data/repositories/organization_repository.dart';
import 'domain/entities/organization_entity.dart';

export 'org_admin_providers.dart';
export 'cross_branch_transfer_providers.dart';

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



/// StateNotifier for Organization Entity
class OrganizationNotifier extends StateNotifier<OrganizationEntity> {
  final OrganizationRepository _repository;

  OrganizationNotifier(this._repository) : super(_defaultOrganization);

  Future<void> fetchOrganization() async {
    try {
      final result = await _repository.fetchOrganizationDetails();
      if (result != null) {
        state = result['organization'] as OrganizationEntity;
      }
    } catch (e) {
      debugPrint('Error fetching organization details: $e');
    }
  }

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

  Future<void> addMasterSubject(String subject) async {
    if (!state.masterSubjects.contains(subject)) {
      try {
        final success = await _repository.addMasterItem(type: 'SUBJECT', name: subject);
        if (success) {
          state = state.copyWith(
            masterSubjects: [...state.masterSubjects, subject],
          );
          addAuditLog('MASTER_SUBJECT_ADDED', 'Added master subject: $subject.');
        }
      } catch (e) {
        debugPrint('Error adding master subject: $e');
      }
    }
  }

  Future<void> removeMasterSubject(String subject) async {
    try {
      final success = await _repository.removeMasterItem(type: 'SUBJECT', name: subject);
      if (success) {
        state = state.copyWith(
          masterSubjects: state.masterSubjects.where((s) => s != subject).toList(),
        );
        addAuditLog('MASTER_SUBJECT_REMOVED', 'Removed master subject: $subject.');
      }
    } catch (e) {
      debugPrint('Error removing master subject: $e');
    }
  }

  Future<void> addMasterFeeHead(String feeHead) async {
    if (!state.masterFeeHeads.contains(feeHead)) {
      try {
        final success = await _repository.addMasterItem(type: 'FEE_HEAD', name: feeHead);
        if (success) {
          state = state.copyWith(
            masterFeeHeads: [...state.masterFeeHeads, feeHead],
          );
          addAuditLog('MASTER_FEE_HEAD_ADDED', 'Added fee head: $feeHead.');
        }
      } catch (e) {
        debugPrint('Error adding master fee head: $e');
      }
    }
  }

  Future<void> removeMasterFeeHead(String feeHead) async {
    try {
      final success = await _repository.removeMasterItem(type: 'FEE_HEAD', name: feeHead);
      if (success) {
        state = state.copyWith(
          masterFeeHeads: state.masterFeeHeads.where((f) => f != feeHead).toList(),
        );
        addAuditLog('MASTER_FEE_HEAD_REMOVED', 'Removed fee head: $feeHead.');
      }
    } catch (e) {
      debugPrint('Error removing master fee head: $e');
    }
  }

  Future<void> addMasterDesignation(String designation) async {
    if (!state.masterDesignations.contains(designation)) {
      try {
        final success = await _repository.addMasterItem(type: 'DESIGNATION', name: designation);
        if (success) {
          state = state.copyWith(
            masterDesignations: [...state.masterDesignations, designation],
          );
          addAuditLog('MASTER_DESIGNATION_ADDED', 'Added designation: $designation.');
        }
      } catch (e) {
        debugPrint('Error adding master designation: $e');
      }
    }
  }

  Future<void> removeMasterDesignation(String designation) async {
    try {
      final success = await _repository.removeMasterItem(type: 'DESIGNATION', name: designation);
      if (success) {
        state = state.copyWith(
          masterDesignations:
              state.masterDesignations.where((d) => d != designation).toList(),
        );
        addAuditLog('MASTER_DESIGNATION_REMOVED', 'Removed designation: $designation.');
      }
    } catch (e) {
      debugPrint('Error removing master designation: $e');
    }
  }

  Future<void> updateMasterSettings(Map<String, dynamic> newSettings) async {
    final updated = Map<String, dynamic>.from(state.masterSettings)..addAll(newSettings);
    try {
      final success = await _repository.updateMasterSettings(updated);
      if (success) {
        state = state.copyWith(masterSettings: updated);
        await fetchOrganization();
      }
    } catch (e) {
      debugPrint('Error updating master settings: $e');
    }
  }

  Future<void> updateCredits({required int smsCount, required int emailCount}) async {
    try {
      final success = await _repository.updateCredits(smsCount: smsCount, emailCount: emailCount);
      if (success) {
        state = state.copyWith(
          smsCreditPool: state.smsCreditPool + smsCount,
          emailCreditPool: state.emailCreditPool + emailCount,
        );
        await fetchOrganization();
      }
    } catch (e) {
      debugPrint('Error recharging credits: $e');
    }
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

/// Organization repository provider
final organizationRepositoryProvider = Provider<OrganizationRepository>(
  (ref) => OrganizationRepository(ref.read(apiClientProvider)),
);

/// Provider for Organization Entity
final organizationProvider =
    StateNotifierProvider<OrganizationNotifier, OrganizationEntity>((ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);
  final repo = ref.read(organizationRepositoryProvider);
  final notifier = OrganizationNotifier(repo);
  if (isLoggedIn) {
    notifier.fetchOrganization();
  }
  return notifier;
});

/// StateNotifier for Branches under the Organization
class OrganizationBranchesNotifier extends StateNotifier<List<BranchEntity>> {
  final OrganizationRepository _repository;

  OrganizationBranchesNotifier(this._repository) : super(const []);

  Future<void> fetchBranches() async {
    try {
      final result = await _repository.fetchOrganizationDetails();
      if (result != null && result['branches'] != null) {
        state = List<BranchEntity>.from(result['branches'] as Iterable);
      }
    } catch (e) {
      debugPrint('Error fetching branches: $e');
    }
  }

  Future<bool> onboardBranch({
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
    required String password,
  }) async {
    try {
      final branch = await _repository.createBranch(
        code: code,
        name: name,
        address: address,
        phone: phone,
        email: email,
        affiliationBoard: affiliationBoard,
        recognitionNumber: 'REC/2026/${state.length + 101}',
        principalName: principalName,
        password: password,
      );
      if (branch != null) {
        state = [...state, branch];
        return true;
      }
    } catch (e) {
      debugPrint('Error onboarding branch: $e');
    }
    return false;
  }

  Future<bool> onboardTeacher(Map<String, dynamic> teacherData) async {
    try {
      final success = await _repository.onboardTeacher(teacherData);
      if (success) {
        state = [
          for (final b in state)
            if (b.id == teacherData['branchId'])
              b.copyWith(activeStaffCount: b.activeStaffCount + 1)
            else
              b,
        ];
        return true;
      }
    } catch (e) {
      debugPrint('Error onboarding teacher: $e');
    }
    return false;
  }

  Future<bool> onboardAccountant(Map<String, dynamic> accountantData) async {
    try {
      final success = await _repository.onboardAccountant(accountantData);
      if (success) {
        state = [
          for (final b in state)
            if (b.id == accountantData['branchId'])
              b.copyWith(activeStaffCount: b.activeStaffCount + 1)
            else
              b,
        ];
        return true;
      }
    } catch (e) {
      debugPrint('Error onboarding accountant: $e');
    }
    return false;
  }

  Future<bool> onboardStudent(Map<String, dynamic> studentData) async {
    try {
      final success = await _repository.onboardStudent(studentData);
      if (success) {
        state = [
          for (final b in state)
            if (b.id == studentData['branchId'])
              b.copyWith(activeStudentCount: b.activeStudentCount + 1)
            else
              b,
        ];
        return true;
      }
    } catch (e) {
      debugPrint('Error onboarding student: $e');
    }
    return false;
  }

  Future<bool> onboardParent(Map<String, dynamic> parentData) async {
    try {
      return await _repository.onboardParent(parentData);
    } catch (e) {
      debugPrint('Error onboarding parent: $e');
    }
    return false;
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
  final isLoggedIn = ref.watch(isLoggedInProvider);
  final repo = ref.read(organizationRepositoryProvider);
  final notifier = OrganizationBranchesNotifier(repo);
  if (isLoggedIn) {
    notifier.fetchBranches();
  }
  return notifier;
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

class RbacRole {
  final String id;
  final String? organizationId;
  final String name;
  final String scope;
  final bool isSystem;
  final List<String> permissionCodes;

  const RbacRole({
    required this.id,
    this.organizationId,
    required this.name,
    required this.scope,
    required this.isSystem,
    required this.permissionCodes,
  });

  RbacRole copyWith({
    String? id,
    String? organizationId,
    String? name,
    String? scope,
    bool? isSystem,
    List<String>? permissionCodes,
  }) {
    return RbacRole(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      scope: scope ?? this.scope,
      isSystem: isSystem ?? this.isSystem,
      permissionCodes: permissionCodes ?? this.permissionCodes,
    );
  }
}

class RbacPermission {
  final String id;
  final String code;
  final String? description;
  final String? module;

  const RbacPermission({
    required this.id,
    required this.code,
    this.description,
    this.module,
  });
}

class RbacRolesNotifier extends StateNotifier<List<RbacRole>> {
  final OrganizationRepository _repository;
  RbacRolesNotifier(this._repository) : super(const []);

  Future<void> fetchRoles() async {
    try {
      final list = await _repository.fetchRoles();
      state = list.map((item) {
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item as Map);
        final List<String> permissionCodes = [];
        if (itemMap['permissions'] != null) {
          for (final rp in itemMap['permissions'] as List) {
            final rpMap = Map<String, dynamic>.from(rp as Map);
            if (rpMap['permission'] != null) {
              final pMap = Map<String, dynamic>.from(rpMap['permission'] as Map);
              permissionCodes.add(pMap['code'] ?? '');
            }
          }
        }

        return RbacRole(
          id: itemMap['id'] ?? '',
          organizationId: itemMap['organizationId'],
          name: itemMap['name'] ?? '',
          scope: itemMap['scope'] ?? 'BRANCH',
          isSystem: itemMap['isSystem'] ?? false,
          permissionCodes: permissionCodes,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching RBAC roles: $e');
    }
  }

  Future<bool> createRole(String name, String scope) async {
    try {
      final success = await _repository.createRbacRole(name, scope);
      if (success) {
        await fetchRoles();
        return true;
      }
    } catch (e) {
      debugPrint('Error creating RBAC role: $e');
    }
    return false;
  }

  Future<bool> assignPermissions(String roleId, List<String> permissionIds) async {
    try {
      final success = await _repository.assignPermissions(roleId, permissionIds);
      if (success) {
        await fetchRoles();
        return true;
      }
    } catch (e) {
      debugPrint('Error assigning permissions: $e');
    }
    return false;
  }

  Future<bool> deleteRole(String roleId) async {
    try {
      final success = await _repository.deleteRbacRole(roleId);
      if (success) {
        await fetchRoles();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting RBAC role: $e');
    }
    return false;
  }
}

class RbacPermissionsNotifier extends StateNotifier<List<RbacPermission>> {
  final OrganizationRepository _repository;
  RbacPermissionsNotifier(this._repository) : super(const []);

  Future<void> fetchPermissions() async {
    try {
      final list = await _repository.fetchPermissions();
      state = list.map((item) {
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item as Map);
        return RbacPermission(
          id: itemMap['id'] ?? '',
          code: itemMap['code'] ?? '',
          description: itemMap['description'],
          module: itemMap['module'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching RBAC permissions: $e');
    }
  }
}

final rbacRolesProvider =
    StateNotifierProvider<RbacRolesNotifier, List<RbacRole>>((ref) {
  final repo = ref.read(organizationRepositoryProvider);
  final notifier = RbacRolesNotifier(repo);
  notifier.fetchRoles();
  return notifier;
});

final rbacPermissionsProvider =
    StateNotifierProvider<RbacPermissionsNotifier, List<RbacPermission>>((ref) {
  final repo = ref.read(organizationRepositoryProvider);
  final notifier = RbacPermissionsNotifier(repo);
  notifier.fetchPermissions();
  return notifier;
});


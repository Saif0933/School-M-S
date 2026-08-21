import 'package:dio/dio.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/network/api_client.dart';
import '../../../branch/domain/entities/branch_entity.dart';
import '../../domain/entities/organization_entity.dart';
import '../../providers.dart';

class OrganizationRepository {
  final ApiClient _apiClient;

  OrganizationRepository(this._apiClient);

  /// Fetch organization details including branches and admins
  Future<Map<String, dynamic>?> fetchOrganizationDetails() async {
    try {
      final response = await _apiClient.dio.get('/organization');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        
        final orgEntity = _mapToOrganizationEntity(data);
        
        final branchesList = data['branches'] as List<dynamic>? ?? [];
        final branches = branchesList.map((b) => _mapToBranchEntity(b)).toList();

        return {
          'organization': orgEntity,
          'branches': branches,
        };
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
    return null;
  }

  /// Create a new branch under organization
  Future<BranchEntity?> createBranch({
    required String code,
    required String name,
    String? address,
    String? phone,
    String? email,
    String? affiliationBoard,
    String? recognitionNumber,
    String? principalName,
    String? password,
  }) async {
    try {
      final response = await _apiClient.dio.post('/organization/branch', data: {
        'code': code,
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'affiliationBoard': affiliationBoard,
        'recognitionNumber': recognitionNumber,
        'principalName': principalName,
        'password': password,
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return _mapToBranchEntity(data);
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
    return null;
  }

  OrganizationEntity _mapToOrganizationEntity(Map<String, dynamic> data) {
    final admins = data['admins'] as List<dynamic>? ?? [];
    String superAdminName = 'Rajesh Kumar Sharma';
    String superAdminEmail = 'superadmin@symbosys.com';
    String superAdminPhone = '+91 9876543210';

    if (admins.isNotEmpty) {
      final firstAdmin = admins.first as Map<String, dynamic>;
      superAdminName = firstAdmin['name'] as String? ?? superAdminName;
      superAdminEmail = firstAdmin['email'] as String? ?? superAdminEmail;
      superAdminPhone = firstAdmin['phone'] as String? ?? superAdminPhone;
    }

    final masterItemsList = data['masterDataItems'] as List<dynamic>?;
    List<String>? masterSubjects;
    List<String>? masterFeeHeads;
    List<String>? masterDesignations;

    if (masterItemsList != null) {
      masterSubjects = masterItemsList
          .where((x) => x['type'] == 'SUBJECT')
          .map((x) => x['name'] as String)
          .toList();
      masterFeeHeads = masterItemsList
          .where((x) => x['type'] == 'FEE_HEAD')
          .map((x) => x['name'] as String)
          .toList();
      masterDesignations = masterItemsList
          .where((x) => x['type'] == 'DESIGNATION')
          .map((x) => x['name'] as String)
          .toList();
    }

    final settingsMap = data['settings'] as Map<String, dynamic>? ?? {};
    final auditLogsList = data['auditLogs'] as List<dynamic>? ?? [];
    final auditLogs = auditLogsList.map((x) {
      final map = x as Map<dynamic, dynamic>;
      final metadata = map['metadata'] as Map<dynamic, dynamic>? ?? {};
      final createdAtStr = map['createdAt'] as String? ?? DateTime.now().toIso8601String();
      
      return {
        'action': map['action'] as String? ?? 'UNKNOWN_ACTION',
        'user': metadata['updatedBy'] as String? ?? map['actorId'] as String? ?? 'System',
        'timestamp': createdAtStr,
        'details': metadata['details'] as String? ?? 'No details available.',
      };
    }).toList();

    return OrganizationEntity(
      id: data['id'] as String,
      name: data['name'] as String,
      registrationNumber: data['registrationNumber'] as String? ?? 'N/A',
      taxRegistrationNumber: 'GSTIN-9900112233',
      logoUrl: data['logoUrl'] as String?,
      email: data['contactEmail'] as String? ?? '',
      phone: data['contactPhone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      website: 'https://sunrisetrust.edu.in',
      subdomain: 'sunrise.symbosys.com',
      superAdminName: superAdminName,
      superAdminEmail: superAdminEmail,
      superAdminPhone: superAdminPhone,
      subscriptionPlan: 'Enterprise Plan',
      maxBranches: 10,
      maxTotalStudents: 10000,
      isActive: data['status'] == 'ACTIVE',
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
      masterSettings: settingsMap,
      auditLogs: auditLogs,
      masterSubjects: masterSubjects ?? const [
        'Mathematics',
        'Physics',
        'Chemistry',
        'Biology',
        'English Literature',
        'Computer Science & AI',
        'Social Studies',
        'Hindi Language',
      ],
      masterFeeHeads: masterFeeHeads ?? const [
        'Tuition Fee',
        'Admission Fee',
        'Annual Maintenance Charges',
        'Transport Fee',
        'Laboratory & STEM Fee',
        'Library Deposit',
        'Examination & Evaluation Fee',
      ],
      masterDesignations: masterDesignations ?? const [
        'Principal',
        'Vice Principal',
        'Head of Department (HOD)',
        'Senior PGT Teacher',
        'TGT Teacher',
        'PRT Teacher',
        'Chief Accountant',
        'Sports Instructor',
      ],
    );
  }

  BranchEntity _mapToBranchEntity(Map<String, dynamic> b) {
    BranchStatus status = BranchStatus.active;
    if (b['status'] == 'INACTIVE') status = BranchStatus.inactive;
    if (b['status'] == 'TRIAL') status = BranchStatus.trial;
    if (b['status'] == 'SUSPENDED') status = BranchStatus.suspended;

    return BranchEntity(
      id: b['id'] as String,
      organizationId: b['organizationId'] as String,
      code: b['code'] as String,
      name: b['name'] as String,
      affiliationBoard: b['affiliationBoard'] as String? ?? 'CBSE',
      recognitionNumber: b['recognitionNumber'] as String? ?? 'N/A',
      principalName: b['principalName'] as String? ?? 'School Director',
      email: b['email'] as String? ?? '',
      phone: b['phone'] as String? ?? '',
      address: b['address'] as String? ?? '',
      city: b['city'] as String? ?? 'City',
      state: b['state'] as String? ?? 'State',
      pincode: b['pincode'] as String? ?? '110001',
      status: status,
      maxStudentCapacity: b['maxStudentCapacity'] as int? ?? 1000,
      maxStaffCapacity: b['maxStaffCapacity'] as int? ?? 100,
      activeStudentCount: b['activeStudentCount'] as int? ?? 0,
      activeStaffCount: b['activeStaffCount'] as int? ?? 0,
      currentAcademicYear: b['currentAcademicYear'] as String? ?? '2026-2027',
      planType: b['planType'] as String? ?? 'Standard',
      enabledModules: ModuleType.values.toSet(),
      createdAt: DateTime.tryParse(b['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Fetch organization admins (RBAC)
  Future<List<OrgAdminEntity>> fetchOrgAdmins() async {
    try {
      final response = await _apiClient.dio.get('/organization/admin');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((a) => _mapToOrgAdminEntity(a)).toList();
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
    return [];
  }

  /// Create a new organization admin
  Future<OrgAdminEntity?> createOrgAdmin({
    required String name,
    required String email,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await _apiClient.dio.post('/organization/admin', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return _mapToOrgAdminEntity(data);
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
    return null;
  }

  /// Toggle active/inactive status of an admin
  Future<bool> toggleOrgAdminStatus(String adminId) async {
    try {
      final response = await _apiClient.dio.patch('/organization/admin/$adminId/status');
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
  }

  /// Delete an organization admin
  Future<bool> deleteOrgAdmin(String adminId) async {
    try {
      final response = await _apiClient.dio.delete('/organization/admin/$adminId');
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
  }

  OrgAdminEntity _mapToOrgAdminEntity(Map<String, dynamic> adminMap) {
    final roleStr = adminMap['role'] as String? ?? 'SUPPORT_ADMIN';
    
    // Map backend roles to UI roles
    String uiRole = 'Support Admin';
    List<String> permissions = [];
    
    if (roleStr == 'SUPER_ADMIN') {
      uiRole = 'Super Admin';
      permissions = [
        'Full Organization Control',
        'Branch Onboarding & Deactivation',
        'Cross-Branch Migration Approval',
        'Subscription Billing',
        'Master Data Configuration',
      ];
    } else if (roleStr == 'BILLING_ADMIN') {
      uiRole = 'Billing Admin';
      permissions = [
        'Subscription Renewal & Upgrades',
        'Invoices & Payment Records',
        'SMS & Email Credit Recharges',
        'Financial Revenue Analytics',
      ];
    } else {
      uiRole = 'Support Admin';
      permissions = [
        'Cross-Branch Helpdesk Tickets',
        'Staff & Branch Password Resets',
        'Branch Diagnostic Logs',
        'User License Audits',
      ];
    }

    final users = adminMap['users'] as List<dynamic>? ?? [];
    bool isActive = true;
    if (users.isNotEmpty) {
      isActive = users.first['isActive'] as bool? ?? true;
    }

    return OrgAdminEntity(
      id: adminMap['id'] as String,
      name: adminMap['name'] as String,
      email: adminMap['email'] as String,
      phone: adminMap['phone'] as String? ?? '',
      role: uiRole,
      branchScope: 'ALL (Global Trust Scope)',
      permissions: permissions,
      isActive: isActive,
      createdAt: DateTime.tryParse(adminMap['createdAt'] as String? ?? '') ?? DateTime.now(),
      lastLoginAt: adminMap['lastLoginAt'] != null 
          ? DateTime.tryParse(adminMap['lastLoginAt'] as String) 
          : null,
    );
  }

  /// Add a master data item (subject, fee head, designation)
  Future<bool> addMasterItem({
    required String type,
    required String name,
    String? code,
  }) async {
    try {
      final response = await _apiClient.dio.post('/organization/master/item', data: {
        'type': type,
        'name': name,
        'code': code,
      });
      return response.statusCode == 201 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
  }

  /// Remove a master data item (subject, fee head, designation)
  Future<bool> removeMasterItem({
    required String type,
    required String name,
  }) async {
    try {
      final response = await _apiClient.dio.delete('/organization/master/item', data: {
        'type': type,
        'name': name,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
  }

  /// Register a new policy document
  Future<bool> addPolicyDocument({
    required String title,
    required String fileUrl,
    String? category,
  }) async {
    try {
      final response = await _apiClient.dio.post('/organization/master/policy', data: {
        'title': title,
        'fileUrl': fileUrl,
        'category': category,
      });
      return response.statusCode == 201 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
  }

  /// Revoke/delete a policy document
  Future<bool> removePolicyDocument(String policyId) async {
    try {
      final response = await _apiClient.dio.delete('/organization/master/policy/$policyId');
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
  }

  /// Update organization master settings
  Future<bool> updateMasterSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _apiClient.dio.patch('/organization/settings', data: {
        'settings': settings,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
  }

  /// Recharge SMS/Email global credit pool
  Future<bool> updateCredits({
    required int smsCount,
    required int emailCount,
  }) async {
    try {
      final response = await _apiClient.dio.post('/organization/settings/credits', data: {
        'smsCount': smsCount,
        'emailCount': emailCount,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception(errorMessage);
    }
  }
}

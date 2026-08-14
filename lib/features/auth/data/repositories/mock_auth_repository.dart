import '../../domain/entities/user_entity.dart';
import '../../../../core/enums/enums.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Mock Auth Repository
/// Simulates authentication with pre-defined users
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class MockAuthRepository {
  /// Simulated login with demo credentials
  Future<UserEntity?> login(String email, String password) async {
    // Fast mock response delay
    await Future.delayed(const Duration(milliseconds: 150));

    final cleanEmail = email.trim().toLowerCase();

    var user = _demoUsers[cleanEmail];
    if (user == null) {
      if (cleanEmail.contains('platform')) {
        user = _demoUsers['platformadmin@symbosys.com'];
      } else if (cleanEmail.contains('super')) {
        user = _demoUsers['superadmin@symbosys.com'];
      } else if (cleanEmail.contains('branch')) {
        user = _demoUsers['branchadmin@symbosys.com'];
      } else if (cleanEmail.contains('teacher')) {
        user = _demoUsers['teacher@symbosys.com'];
      } else if (cleanEmail.contains('student')) {
        user = _demoUsers['student@symbosys.com'];
      } else if (cleanEmail.contains('parent')) {
        user = _demoUsers['parent@symbosys.com'];
      } else if (cleanEmail.contains('account')) {
        user = _demoUsers['accountant@symbosys.com'];
      }
    }

    if (user != null) {
      return user.copyWith(lastLoginAt: DateTime.now());
    }
    return null;
  }

  /// Demo user accounts for all roles
  static final Map<String, UserEntity> _demoUsers = {
    // ─── Platform SaaS Admin (Owner) ───────────
    'platformadmin@symbosys.com': UserEntity(
      id: 'USR-PLAT-001',
      name: 'Symbosys SaaS Platform Owner',
      email: 'platformadmin@symbosys.com',
      phone: '+91 9999900000',
      role: UserRole.platformAdmin,
      organizationId: 'SAAS-PLATFORM',
      organizationName: 'Symbosys SaaS HQ',
      branchAccess: const [
        BranchAccess(
          branchId: 'ALL',
          branchName: 'Global SaaS Control Hub',
          branchCode: 'SAAS-HQ',
          role: UserRole.platformAdmin,
        ),
      ],
      activeBranchId: 'ALL',
      createdAt: DateTime(2024, 1, 1),
    ),

    // ─── School Super Admin ───────────────────────────
    'superadmin@symbosys.com': UserEntity(
      id: 'USR-001',
      name: 'Rajesh Kumar Sharma',
      email: 'superadmin@symbosys.com',
      phone: '+91 9876543210',
      role: UserRole.superAdmin,
      organizationId: 'ORG-001',
      organizationName: 'Sunrise Education Trust',
      branchAccess: const [
        BranchAccess(branchId: 'BR-001', branchName: 'Sunrise International School - Delhi', branchCode: 'SIS-DEL', role: UserRole.superAdmin),
        BranchAccess(branchId: 'BR-002', branchName: 'Sunrise Public School - Mumbai', branchCode: 'SPS-MUM', role: UserRole.superAdmin),
        BranchAccess(branchId: 'BR-003', branchName: 'Sunrise Academy - Bangalore', branchCode: 'SA-BLR', role: UserRole.superAdmin),
      ],
      activeBranchId: 'BR-001',
      createdAt: DateTime(2024, 1, 1),
    ),

    // ─── Branch Admin ──────────────────────────
    'branchadmin@symbosys.com': UserEntity(
      id: 'USR-002',
      name: 'Priya Patel',
      email: 'branchadmin@symbosys.com',
      phone: '+91 9876543211',
      role: UserRole.branchAdmin,
      organizationId: 'ORG-001',
      organizationName: 'Sunrise Education Trust',
      branchAccess: const [
        BranchAccess(branchId: 'BR-001', branchName: 'Sunrise International School - Delhi', branchCode: 'SIS-DEL', role: UserRole.branchAdmin),
      ],
      activeBranchId: 'BR-001',
      createdAt: DateTime(2024, 3, 15),
    ),

    // ─── Teacher ───────────────────────────────
    'teacher@symbosys.com': UserEntity(
      id: 'USR-003',
      name: 'Anita Desai',
      email: 'teacher@symbosys.com',
      phone: '+91 9876543212',
      role: UserRole.teacher,
      organizationId: 'ORG-001',
      organizationName: 'Sunrise Education Trust',
      branchAccess: const [
        BranchAccess(branchId: 'BR-001', branchName: 'Sunrise International School - Delhi', branchCode: 'SIS-DEL', role: UserRole.teacher),
      ],
      activeBranchId: 'BR-001',
      createdAt: DateTime(2024, 6, 1),
    ),

    // ─── Parent ────────────────────────────────
    'parent@symbosys.com': UserEntity(
      id: 'USR-004',
      name: 'Vikram Singh',
      email: 'parent@symbosys.com',
      phone: '+91 9876543213',
      role: UserRole.parent,
      organizationId: 'ORG-001',
      organizationName: 'Sunrise Education Trust',
      branchAccess: const [
        BranchAccess(branchId: 'BR-001', branchName: 'Sunrise International School - Delhi', branchCode: 'SIS-DEL', role: UserRole.parent),
      ],
      activeBranchId: 'BR-001',
      createdAt: DateTime(2025, 1, 10),
    ),

    // ─── Student ───────────────────────────────
    'student@symbosys.com': UserEntity(
      id: 'USR-005',
      name: 'Aarav Mehta',
      email: 'student@symbosys.com',
      phone: '+91 9876543214',
      role: UserRole.student,
      organizationId: 'ORG-001',
      organizationName: 'Sunrise Education Trust',
      branchAccess: const [
        BranchAccess(branchId: 'BR-001', branchName: 'Sunrise International School - Delhi', branchCode: 'SIS-DEL', role: UserRole.student),
      ],
      activeBranchId: 'BR-001',
      createdAt: DateTime(2025, 4, 1),
    ),

    // ─── Accountant ────────────────────────────
    'accountant@symbosys.com': UserEntity(
      id: 'USR-006',
      name: 'Suresh Gupta',
      email: 'accountant@symbosys.com',
      phone: '+91 9876543215',
      role: UserRole.accountant,
      organizationId: 'ORG-001',
      organizationName: 'Sunrise Education Trust',
      branchAccess: const [
        BranchAccess(branchId: 'BR-001', branchName: 'Sunrise International School - Delhi', branchCode: 'SIS-DEL', role: UserRole.accountant),
      ],
      activeBranchId: 'BR-001',
      createdAt: DateTime(2024, 8, 1),
    ),
  };

  /// Platform Owner Account
  static Map<String, String> get platformAccount => {
        'role': 'Platform Admin',
        'email': 'platformadmin@symbosys.com',
        'password': 'admin123',
      };

  /// Get list of school demo accounts for ERP login display
  static List<Map<String, String>> get demoAccounts => [
        {'role': 'School Admin', 'email': 'superadmin@symbosys.com', 'password': 'demo123'},
        {'role': 'Branch Admin', 'email': 'branchadmin@symbosys.com', 'password': 'demo123'},
        {'role': 'Teacher', 'email': 'teacher@symbosys.com', 'password': 'demo123'},
        {'role': 'Parent', 'email': 'parent@symbosys.com', 'password': 'demo123'},
        {'role': 'Student', 'email': 'student@symbosys.com', 'password': 'demo123'},
        {'role': 'Accountant', 'email': 'accountant@symbosys.com', 'password': 'demo123'},
      ];
}

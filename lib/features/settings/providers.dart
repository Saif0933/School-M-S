import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Security Policy Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SecurityPolicy {
  final bool mfaEnabled;
  final bool ssoEnabled;
  final int sessionTimeoutMins;
  final bool restrictConcurrentLogins;
  final int minPasswordLength;
  final List<String> whitelistedIps;
  final bool dbEncryptionActive;

  const SecurityPolicy({
    required this.mfaEnabled,
    required this.ssoEnabled,
    required this.sessionTimeoutMins,
    required this.restrictConcurrentLogins,
    required this.minPasswordLength,
    required this.whitelistedIps,
    required this.dbEncryptionActive,
  });

  SecurityPolicy copyWith({
    bool? mfaEnabled,
    bool? ssoEnabled,
    int? sessionTimeoutMins,
    bool? restrictConcurrentLogins,
    int? minPasswordLength,
    List<String>? whitelistedIps,
    bool? dbEncryptionActive,
  }) {
    return SecurityPolicy(
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      ssoEnabled: ssoEnabled ?? this.ssoEnabled,
      sessionTimeoutMins: sessionTimeoutMins ?? this.sessionTimeoutMins,
      restrictConcurrentLogins: restrictConcurrentLogins ?? this.restrictConcurrentLogins,
      minPasswordLength: minPasswordLength ?? this.minPasswordLength,
      whitelistedIps: whitelistedIps ?? this.whitelistedIps,
      dbEncryptionActive: dbEncryptionActive ?? this.dbEncryptionActive,
    );
  }
}

class SecurityPolicyNotifier extends StateNotifier<SecurityPolicy> {
  SecurityPolicyNotifier() : super(
    const SecurityPolicy(
      mfaEnabled: true,
      ssoEnabled: false,
      sessionTimeoutMins: 30,
      restrictConcurrentLogins: true,
      minPasswordLength: 10,
      whitelistedIps: ['192.168.1.1', '10.0.0.45'],
      dbEncryptionActive: true,
    ),
  );

  void updatePolicy(SecurityPolicy updated) {
    state = updated;
  }

  void addIp(String ip) {
    state = state.copyWith(whitelistedIps: [...state.whitelistedIps, ip]);
  }

  void removeIp(String ip) {
    state = state.copyWith(whitelistedIps: state.whitelistedIps.where((x) => x != ip).toList());
  }
}

final securityPolicyProvider = StateNotifierProvider<SecurityPolicyNotifier, SecurityPolicy>((ref) {
  return SecurityPolicyNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Audit Log Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SecurityAuditLog {
  final String id;
  final String user;
  final String action;
  final String branchId; // 'BR-001', 'BR-002' or 'ALL'
  final String ipAddress;
  final String time;

  const SecurityAuditLog({
    required this.id,
    required this.user,
    required this.action,
    required this.branchId,
    required this.ipAddress,
    required this.time,
  });
}

class AuditLogsNotifier extends StateNotifier<List<SecurityAuditLog>> {
  AuditLogsNotifier() : super([
    const SecurityAuditLog(
      id: 'AUD-9023',
      user: 'Meenakshi Sundaram',
      action: 'APPROVED_STUDENT_LEAVE',
      branchId: 'BR-001',
      ipAddress: '192.168.1.1',
      time: '2026-08-19 12:15 PM',
    ),
    const SecurityAuditLog(
      id: 'AUD-9024',
      user: 'Dr. Rajeshwar Sharma',
      action: 'ASSIGNED_BRANCH_PLAN_UPGRADE',
      branchId: 'ALL',
      ipAddress: '10.0.0.45',
      time: '2026-08-19 12:47 PM',
    ),
  ]);

  void logAction(SecurityAuditLog log) {
    state = [log, ...state];
  }
}

final securityAuditLogsProvider = StateNotifierProvider<AuditLogsNotifier, List<SecurityAuditLog>>((ref) {
  return AuditLogsNotifier();
});

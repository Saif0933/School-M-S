import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers.dart';
import 'data/repositories/organization_repository.dart';
import 'providers.dart';

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

class OrgAdminNotifier extends StateNotifier<List<OrgAdminEntity>> {
  final OrganizationRepository _repository;

  OrgAdminNotifier(this._repository) : super(const []);

  Future<void> fetchAdmins() async {
    try {
      final list = await _repository.fetchOrgAdmins();
      state = list;
    } catch (e) {
      debugPrint('Error fetching org admins: $e');
    }
  }

  Future<bool> createAdmin({
    required String name,
    required String email,
    required String phone,
    required String role,
    required String branchScope,
    required List<String> permissions,
  }) async {
    try {
      final newAdmin = await _repository.createOrgAdmin(
        name: name,
        email: email,
        phone: phone,
        role: role,
      );
      if (newAdmin != null) {
        state = [newAdmin, ...state];
        return true;
      }
    } catch (e) {
      debugPrint('Error creating org admin: $e');
    }
    return false;
  }

  Future<void> toggleAdminStatus(String adminId) async {
    try {
      final success = await _repository.toggleOrgAdminStatus(adminId);
      if (success) {
        state = [
          for (final a in state)
            if (a.id == adminId) a.copyWith(isActive: !a.isActive) else a,
        ];
      }
    } catch (e) {
      debugPrint('Error toggling admin status: $e');
    }
  }

  Future<void> deleteAdmin(String adminId) async {
    try {
      final success = await _repository.deleteOrgAdmin(adminId);
      if (success) {
        state = state.where((a) => a.id != adminId).toList();
      }
    } catch (e) {
      debugPrint('Error deleting admin: $e');
    }
  }
}

final orgAdminsProvider =
    StateNotifierProvider<OrgAdminNotifier, List<OrgAdminEntity>>((ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);
  final repo = ref.read(organizationRepositoryProvider);
  final notifier = OrgAdminNotifier(repo);
  if (isLoggedIn) {
    notifier.fetchAdmins();
  }
  return notifier;
});

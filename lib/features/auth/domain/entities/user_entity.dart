import 'package:equatable/equatable.dart';
import '../../../../core/enums/enums.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// User Entity — Core domain entity for authentication
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final UserRole role;
  final String? organizationId;
  final String? organizationName;
  final List<BranchAccess> branchAccess;
  final String? activeBranchId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    required this.role,
    this.organizationId,
    this.organizationName,
    this.branchAccess = const [],
    this.activeBranchId,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Get the currently active branch
  BranchAccess? get activeBranch {
    if (activeBranchId == null) return branchAccess.isNotEmpty ? branchAccess.first : null;
    return branchAccess.where((b) => b.branchId == activeBranchId).firstOrNull;
  }

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    UserRole? role,
    String? organizationId,
    String? organizationName,
    List<BranchAccess>? branchAccess,
    String? activeBranchId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      branchAccess: branchAccess ?? this.branchAccess,
      activeBranchId: activeBranchId ?? this.activeBranchId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [id, email, role, activeBranchId];
}

/// Branch access entry for a user
class BranchAccess extends Equatable {
  final String branchId;
  final String branchName;
  final String branchCode;
  final UserRole role;

  const BranchAccess({
    required this.branchId,
    required this.branchName,
    required this.branchCode,
    required this.role,
  });

  @override
  List<Object?> get props => [branchId, role];
}

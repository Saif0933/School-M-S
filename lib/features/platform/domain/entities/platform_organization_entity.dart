import '../../../../core/enums/enums.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Platform Organization Entity — SaaS Tenant Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class PlatformOrganizationEntity {
  final String id;
  final String name;
  final String code;
  final String superAdminName;
  final String superAdminEmail;
  final String contactPhone;
  final SubscriptionTier subscriptionTier;
  final String status; // 'active', 'trial', 'suspended', 'expiring'
  final double monthlyFee;
  final String billingCycle; // 'monthly', 'yearly'
  final DateTime startDate;
  final DateTime renewalDate;
  final int branchCount;
  final int maxBranches;
  final int studentCount;
  final int maxStudents;
  final String address;

  const PlatformOrganizationEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.superAdminName,
    required this.superAdminEmail,
    required this.contactPhone,
    required this.subscriptionTier,
    required this.status,
    required this.monthlyFee,
    required this.billingCycle,
    required this.startDate,
    required this.renewalDate,
    required this.branchCount,
    required this.maxBranches,
    required this.studentCount,
    required this.maxStudents,
    required this.address,
  });

  PlatformOrganizationEntity copyWith({
    String? id,
    String? name,
    String? code,
    String? superAdminName,
    String? superAdminEmail,
    String? contactPhone,
    SubscriptionTier? subscriptionTier,
    String? status,
    double? monthlyFee,
    String? billingCycle,
    DateTime? startDate,
    DateTime? renewalDate,
    int? branchCount,
    int? maxBranches,
    int? studentCount,
    int? maxStudents,
    String? address,
  }) {
    return PlatformOrganizationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      superAdminName: superAdminName ?? this.superAdminName,
      superAdminEmail: superAdminEmail ?? this.superAdminEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      status: status ?? this.status,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      billingCycle: billingCycle ?? this.billingCycle,
      startDate: startDate ?? this.startDate,
      renewalDate: renewalDate ?? this.renewalDate,
      branchCount: branchCount ?? this.branchCount,
      maxBranches: maxBranches ?? this.maxBranches,
      studentCount: studentCount ?? this.studentCount,
      maxStudents: maxStudents ?? this.maxStudents,
      address: address ?? this.address,
    );
  }
}

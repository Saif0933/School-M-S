import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/enums.dart';
import 'domain/entities/platform_organization_entity.dart';

/// Initial mock SaaS platform organizations
final List<PlatformOrganizationEntity> _initialPlatformOrganizations = [
  PlatformOrganizationEntity(
    id: 'ORG-001',
    name: 'Sunrise Education Trust',
    code: 'SET-MAIN',
    superAdminName: 'Rajesh Kumar Sharma',
    superAdminEmail: 'superadmin@symbosys.com',
    contactPhone: '+91 9876543210',
    subscriptionTier: SubscriptionTier.premium,
    status: 'active',
    monthlyFee: 1199.0,
    billingCycle: 'yearly',
    startDate: DateTime(2024, 1, 1),
    renewalDate: DateTime(2027, 1, 1),
    branchCount: 3,
    maxBranches: 10,
    studentCount: 2850,
    maxStudents: 10000,
    address: 'Connaught Place, New Delhi, India',
  ),
  PlatformOrganizationEntity(
    id: 'ORG-002',
    name: 'Zenith Global Schools',
    code: 'ZGS-GLOBAL',
    superAdminName: 'Dr. Alok Verma',
    superAdminEmail: 'alok.verma@zenith.edu',
    contactPhone: '+91 9811223344',
    subscriptionTier: SubscriptionTier.enterprise,
    status: 'active',
    monthlyFee: 2499.0,
    billingCycle: 'yearly',
    startDate: DateTime(2024, 3, 15),
    renewalDate: DateTime(2027, 3, 15),
    branchCount: 5,
    maxBranches: 99,
    studentCount: 6200,
    maxStudents: 100000,
    address: 'Bandra West, Mumbai, India',
  ),
  PlatformOrganizationEntity(
    id: 'ORG-003',
    name: 'Apex Learning Foundation',
    code: 'ALF-SOUTH',
    superAdminName: 'Meera Nambiar',
    superAdminEmail: 'meera@apexlearning.org',
    contactPhone: '+91 9445566778',
    subscriptionTier: SubscriptionTier.standard,
    status: 'active',
    monthlyFee: 599.0,
    billingCycle: 'monthly',
    startDate: DateTime(2024, 6, 1),
    renewalDate: DateTime(2026, 9, 1),
    branchCount: 2,
    maxBranches: 3,
    studentCount: 1400,
    maxStudents: 2000,
    address: 'Koramangala, Bangalore, India',
  ),
  PlatformOrganizationEntity(
    id: 'ORG-004',
    name: 'St. Jude International Trust',
    code: 'SJIT-NORTH',
    superAdminName: 'Father Joseph Thomas',
    superAdminEmail: 'contact@stjude.edu.in',
    contactPhone: '+91 9778899001',
    subscriptionTier: SubscriptionTier.basic,
    status: 'active',
    monthlyFee: 299.0,
    billingCycle: 'monthly',
    startDate: DateTime(2025, 1, 10),
    renewalDate: DateTime(2026, 8, 30),
    branchCount: 1,
    maxBranches: 1,
    studentCount: 450,
    maxStudents: 500,
    address: 'Civil Lines, Jaipur, India',
  ),
  PlatformOrganizationEntity(
    id: 'ORG-005',
    name: 'Vidya Niketan Academy',
    code: 'VNA-CENTRAL',
    superAdminName: 'Sanjay Deshmukh',
    superAdminEmail: 'admin@vidyaniketan.ac.in',
    contactPhone: '+91 9334455667',
    subscriptionTier: SubscriptionTier.basic,
    status: 'active',
    monthlyFee: 299.0,
    billingCycle: 'yearly',
    startDate: DateTime(2025, 2, 20),
    renewalDate: DateTime(2027, 2, 20),
    branchCount: 1,
    maxBranches: 1,
    studentCount: 320,
    maxStudents: 500,
    address: 'FC Road, Pune, India',
  ),
  PlatformOrganizationEntity(
    id: 'ORG-006',
    name: 'Harmony Public School Trust',
    code: 'HPST-WEST',
    superAdminName: 'Ramesh Kulkarni',
    superAdminEmail: 'ramesh@harmonyschool.edu',
    contactPhone: '+91 9223344556',
    subscriptionTier: SubscriptionTier.basic,
    status: 'trial',
    monthlyFee: 299.0,
    billingCycle: 'monthly',
    startDate: DateTime(2026, 8, 1),
    renewalDate: DateTime(2026, 8, 31),
    branchCount: 1,
    maxBranches: 1,
    studentCount: 180,
    maxStudents: 500,
    address: 'Satellite, Ahmedabad, India',
  ),
];

/// StateNotifier for SaaS Platform Organizations
class PlatformOrganizationsNotifier
    extends StateNotifier<List<PlatformOrganizationEntity>> {
  PlatformOrganizationsNotifier() : super(_initialPlatformOrganizations);

  /// Onboard a brand new organization onto the SaaS platform
  void onboardOrganization({
    required String name,
    required String code,
    required String superAdminName,
    required String superAdminEmail,
    required String contactPhone,
    required SubscriptionTier subscriptionTier,
    required String billingCycle,
    required int maxBranches,
    required int maxStudents,
    required String address,
  }) {
    final newOrgId = 'ORG-00${state.length + 1}';
    final newOrg = PlatformOrganizationEntity(
      id: newOrgId,
      name: name,
      code: code.toUpperCase(),
      superAdminName: superAdminName,
      superAdminEmail: superAdminEmail,
      contactPhone: contactPhone,
      subscriptionTier: subscriptionTier,
      status: 'active',
      monthlyFee: subscriptionTier.monthlyPrice,
      billingCycle: billingCycle,
      startDate: DateTime.now(),
      renewalDate: billingCycle == 'yearly'
          ? DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 30)),
      branchCount: 1,
      maxBranches: maxBranches,
      studentCount: 0,
      maxStudents: maxStudents,
      address: address,
    );

    state = [newOrg, ...state];
  }

  /// Change subscription tier plan for an existing organization
  void updateSubscriptionPlan(String orgId, SubscriptionTier newTier) {
    state = [
      for (final org in state)
        if (org.id == orgId)
          org.copyWith(
            subscriptionTier: newTier,
            monthlyFee: newTier.monthlyPrice,
            maxBranches: newTier.maxBranches,
            maxStudents: newTier.maxStudents,
          )
        else
          org,
    ];
  }

  /// Change organization operational status (Active / Suspended / Trial)
  void updateOrganizationStatus(String orgId, String newStatus) {
    state = [
      for (final org in state)
        if (org.id == orgId) org.copyWith(status: newStatus) else org,
    ];
  }

  /// Extend subscription validity date
  void extendSubscriptionValidity(String orgId, int additionalMonths) {
    state = [
      for (final org in state)
        if (org.id == orgId)
          org.copyWith(
            renewalDate: DateTime(
              org.renewalDate.year,
              org.renewalDate.month + additionalMonths,
              org.renewalDate.day,
            ),
          )
        else
          org,
    ];
  }
}

/// Riverpod provider for SaaS Platform Organizations
final platformOrganizationsProvider = StateNotifierProvider<
    PlatformOrganizationsNotifier, List<PlatformOrganizationEntity>>((ref) {
  return PlatformOrganizationsNotifier();
});

/// Filter provider for Platform Organizations by search or subscription tier
final platformSearchQueryProvider = StateProvider<String>((ref) => '');
final platformTierFilterProvider = StateProvider<SubscriptionTier?>((ref) => null);

/// Derived filtered organizations list
final filteredPlatformOrganizationsProvider =
    Provider<List<PlatformOrganizationEntity>>((ref) {
  final orgs = ref.watch(platformOrganizationsProvider);
  final query = ref.watch(platformSearchQueryProvider).toLowerCase();
  final tierFilter = ref.watch(platformTierFilterProvider);

  return orgs.where((org) {
    final matchesQuery = query.isEmpty ||
        org.name.toLowerCase().contains(query) ||
        org.code.toLowerCase().contains(query) ||
        org.superAdminEmail.toLowerCase().contains(query) ||
        org.superAdminName.toLowerCase().contains(query);

    final matchesTier = tierFilter == null || org.subscriptionTier == tierFilter;

    return matchesQuery && matchesTier;
  }).toList();
});

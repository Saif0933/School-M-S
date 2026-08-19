import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Subscription Plan Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SubscriptionPlan {
  final String name;
  final double basePrice;
  final List<String> modules;
  final String description;

  const SubscriptionPlan({required this.name, required this.basePrice, required this.modules, required this.description});
}

final subscriptionPlansProvider = Provider<List<SubscriptionPlan>>((ref) {
  return const [
    SubscriptionPlan(
      name: 'Basic',
      basePrice: 99.0,
      modules: ['Dashboard', 'Academics', 'Attendance'],
      description: 'Essential management tools for single branches.',
    ),
    SubscriptionPlan(
      name: 'Standard',
      basePrice: 199.0,
      modules: ['Dashboard', 'Academics', 'Attendance', 'Finance', 'Library'],
      description: 'Ideal for small-to-medium double campus setups.',
    ),
    SubscriptionPlan(
      name: 'Premium',
      basePrice: 399.0,
      modules: ['Dashboard', 'Academics', 'Attendance', 'Finance', 'Library', 'LMS', 'Mobile features', 'Security', 'Leave'],
      description: 'Complete cross-branch consolidated system.',
    ),
  ];
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Custom Branding & Onboarding Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OrgBrandingConfig {
  final String whiteLabelDomain;
  final String primaryColorHex;
  final String logoUrl;
  final String billingCycle; // 'Monthly', 'Quarterly', 'Yearly'
  final Map<String, String> branchPlanAssignments; // branchId -> PlanName

  const OrgBrandingConfig({
    required this.whiteLabelDomain,
    required this.primaryColorHex,
    required this.logoUrl,
    required this.billingCycle,
    required this.branchPlanAssignments,
  });

  OrgBrandingConfig copyWith({
    String? whiteLabelDomain,
    String? primaryColorHex,
    String? billingCycle,
    Map<String, String>? branchPlanAssignments,
  }) {
    return OrgBrandingConfig(
      whiteLabelDomain: whiteLabelDomain ?? this.whiteLabelDomain,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      logoUrl: logoUrl,
      billingCycle: billingCycle ?? this.billingCycle,
      branchPlanAssignments: branchPlanAssignments ?? this.branchPlanAssignments,
    );
  }
}

class BrandingNotifier extends StateNotifier<OrgBrandingConfig> {
  BrandingNotifier() : super(
    const OrgBrandingConfig(
      whiteLabelDomain: 'sunrise.symbosys.edu',
      primaryColorHex: '#4F46E5',
      logoUrl: '',
      billingCycle: 'Monthly',
      branchPlanAssignments: {
        'BR-001': 'Premium',
        'BR-002': 'Standard',
      },
    ),
  );

  void updateConfig(OrgBrandingConfig config) {
    state = config;
  }

  void assignBranchPlan(String branchId, String plan) {
    final updated = Map<String, String>.from(state.branchPlanAssignments);
    updated[branchId] = plan;
    state = state.copyWith(branchPlanAssignments: updated);
  }
}

final orgBrandingProvider = StateNotifierProvider<BrandingNotifier, OrgBrandingConfig>((ref) {
  return BrandingNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Invoice Registry Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OrgInvoice {
  final String id;
  final String date;
  final double baseAmt;
  final double userAmt;
  final String cycle;
  final String status; // 'Paid', 'Failed (Grace Period Active)', 'Suspended'

  const OrgInvoice({
    required this.id,
    required this.date,
    required this.baseAmt,
    required this.userAmt,
    required this.cycle,
    required this.status,
  });

  OrgInvoice copyWith({String? status}) {
    return OrgInvoice(
      id: id,
      date: date,
      baseAmt: baseAmt,
      userAmt: userAmt,
      cycle: cycle,
      status: status ?? this.status,
    );
  }
}

class InvoicesNotifier extends StateNotifier<List<OrgInvoice>> {
  InvoicesNotifier() : super([
    const OrgInvoice(
      id: 'INV-ORG-2026-001',
      date: '2026-08-01',
      baseAmt: 399.0,
      userAmt: 145.50,
      cycle: 'Monthly',
      status: 'Paid',
    ),
    const OrgInvoice(
      id: 'INV-ORG-2026-002',
      date: '2026-08-19',
      baseAmt: 399.0,
      userAmt: 152.00,
      cycle: 'Monthly',
      status: 'Failed (Grace Period Active)',
    ),
  ]);

  void payInvoice(String id) {
    state = state.map((inv) => inv.id == id ? inv.copyWith(status: 'Paid') : inv).toList();
  }
}

final orgInvoicesProvider = StateNotifierProvider<InvoicesNotifier, List<OrgInvoice>>((ref) {
  return InvoicesNotifier();
});

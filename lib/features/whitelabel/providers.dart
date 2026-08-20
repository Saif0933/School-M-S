import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch White-Label Config Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BranchWhiteLabelConfig {
  final String branchId;
  final String subDomain;
  final String logoOverride;
  final String smsSenderId;
  final String primaryColorHex;
  final String terminology; // 'Class/Teacher' or 'Grade/Educator'
  final List<String> hiddenMenuIds;

  const BranchWhiteLabelConfig({
    required this.branchId,
    required this.subDomain,
    required this.logoOverride,
    required this.smsSenderId,
    required this.primaryColorHex,
    required this.terminology,
    required this.hiddenMenuIds,
  });

  BranchWhiteLabelConfig copyWith({
    String? subDomain,
    String? logoOverride,
    String? smsSenderId,
    String? primaryColorHex,
    String? terminology,
    List<String>? hiddenMenuIds,
  }) {
    return BranchWhiteLabelConfig(
      branchId: branchId,
      subDomain: subDomain ?? this.subDomain,
      logoOverride: logoOverride ?? this.logoOverride,
      smsSenderId: smsSenderId ?? this.smsSenderId,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      terminology: terminology ?? this.terminology,
      hiddenMenuIds: hiddenMenuIds ?? this.hiddenMenuIds,
    );
  }
}

class WhiteLabelNotifier extends StateNotifier<List<BranchWhiteLabelConfig>> {
  WhiteLabelNotifier() : super([
    const BranchWhiteLabelConfig(
      branchId: 'BR-001',
      subDomain: 'delhi.sunrise.edu.in',
      logoOverride: 'delhi_shield_logo.png',
      smsSenderId: 'SUNIND',
      primaryColorHex: '#4F46E5',
      terminology: 'Class/Teacher',
      hiddenMenuIds: [],
    ),
    const BranchWhiteLabelConfig(
      branchId: 'BR-002',
      subDomain: 'mumbai.sunrise.edu.in',
      logoOverride: 'mumbai_marine_logo.png',
      smsSenderId: 'SUNMUM',
      primaryColorHex: '#0D9488',
      terminology: 'Grade/Educator',
      hiddenMenuIds: [],
    ),
  ]);

  void updateConfig(String branchId, BranchWhiteLabelConfig updated) {
    state = state.map((c) => c.branchId == branchId ? updated : c).toList();
  }
}

final branchWhiteLabelProvider = StateNotifierProvider<WhiteLabelNotifier, List<BranchWhiteLabelConfig>>((ref) {
  return WhiteLabelNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branded Email Template Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BrandedEmailTemplate {
  final String id;
  final String branchId;
  final String subject;
  final String body;

  const BrandedEmailTemplate({required this.id, required this.branchId, required this.subject, required this.body});
}

class EmailTemplatesNotifier extends StateNotifier<List<BrandedEmailTemplate>> {
  EmailTemplatesNotifier() : super([
    const BrandedEmailTemplate(
      id: 'FEE-ALERT',
      branchId: 'BR-001',
      subject: 'Sunrise Delhi Campus: Term 2 Fee Payment Due Alert',
      body: 'Dear Parent, the second semester fee invoice is now payable for your ward. Please complete payment using Razorpay gateway.',
    ),
  ]);

  void updateTemplate(String id, String branchId, String subject, String body) {
    state = state.map((t) => (t.id == id && t.branchId == branchId) ? BrandedEmailTemplate(id: id, branchId: branchId, subject: subject, body: body) : t).toList();
  }
}

final emailTemplatesProvider = StateNotifierProvider<EmailTemplatesNotifier, List<BrandedEmailTemplate>>((ref) {
  return EmailTemplatesNotifier();
});

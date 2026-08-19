import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Certificate Template Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class CertificateTemplateEntity {
  final String id;
  final String name;
  final String category; // 'Academics', 'Sports', 'Extracurricular'
  final String designTheme; // 'Classic Gold', 'Modern Blue', 'Sports Crimson'

  const CertificateTemplateEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.designTheme,
  });
}

class CertificateTemplatesNotifier extends StateNotifier<List<CertificateTemplateEntity>> {
  CertificateTemplatesNotifier() : super([
    // Academics (20 designs represented by categories)
    const CertificateTemplateEntity(id: 'TPL-AC-01', name: 'Transfer Certificate (Standard)', category: 'Academics', designTheme: 'Classic Gold'),
    const CertificateTemplateEntity(id: 'TPL-AC-02', name: 'Character Certificate (Standard)', category: 'Academics', designTheme: 'Classic Gold'),
    const CertificateTemplateEntity(id: 'TPL-AC-03', name: 'Bonafide Student Certificate', category: 'Academics', designTheme: 'Modern Blue'),
    const CertificateTemplateEntity(id: 'TPL-AC-04', name: 'Course Completion Certificate', category: 'Academics', designTheme: 'Modern Blue'),
    const CertificateTemplateEntity(id: 'TPL-AC-05', name: 'Academic Achievement Topper Honor', category: 'Academics', designTheme: 'Classic Gold'),
    
    // Sports (15 designs)
    const CertificateTemplateEntity(id: 'TPL-SP-01', name: 'Annual Sports Meet Winner Roll', category: 'Sports', designTheme: 'Sports Crimson'),
    const CertificateTemplateEntity(id: 'TPL-SP-02', name: 'Best Sportsmanship Award', category: 'Sports', designTheme: 'Sports Crimson'),
    
    // Extracurricular (15 designs)
    const CertificateTemplateEntity(id: 'TPL-EX-01', name: 'Science Exhibition Winner', category: 'Extracurricular', designTheme: 'Modern Blue'),
    const CertificateTemplateEntity(id: 'TPL-EX-02', name: 'Inter-School Debate Championship', category: 'Extracurricular', designTheme: 'Classic Gold'),
  ]);

  void addCustomTemplate(CertificateTemplateEntity template) {
    state = [...state, template];
  }
}

final certificateTemplatesProvider = StateNotifierProvider<CertificateTemplatesNotifier, List<CertificateTemplateEntity>>((ref) {
  return CertificateTemplatesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Generated Certificate Registry Record
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class GeneratedCertificateRecord {
  final String id;
  final String branchId;
  final String studentName;
  final String certificateType;
  final String serialNumber; // SECURE SERIAL: CERT-DEL-2026-004
  final String issuedDate;
  final String status; // 'Active', 'Revoked', 'Reissued'

  const GeneratedCertificateRecord({
    required this.id,
    required this.branchId,
    required this.studentName,
    required this.certificateType,
    required this.serialNumber,
    required this.issuedDate,
    required this.status,
  });

  GeneratedCertificateRecord copyWith({String? status}) {
    return GeneratedCertificateRecord(
      id: id,
      branchId: branchId,
      studentName: studentName,
      certificateType: certificateType,
      serialNumber: serialNumber,
      issuedDate: issuedDate,
      status: status ?? this.status,
    );
  }
}

class GeneratedCertificatesNotifier extends StateNotifier<List<GeneratedCertificateRecord>> {
  GeneratedCertificatesNotifier() : super([
    const GeneratedCertificateRecord(
      id: 'CRT-DEL-001',
      branchId: 'BR-001',
      studentName: 'Aarav Sharma',
      certificateType: 'Bonafide Student Certificate',
      serialNumber: 'CERT-DEL-2026-001',
      issuedDate: '2026-08-10',
      status: 'Active',
    ),
    const GeneratedCertificateRecord(
      id: 'CRT-MUM-001',
      branchId: 'BR-002',
      studentName: 'Sachin Tendulkar',
      certificateType: 'Course Completion Certificate',
      serialNumber: 'CERT-MUM-2026-101',
      issuedDate: '2026-08-12',
      status: 'Active',
    ),
  ]);

  void issueCertificate(GeneratedCertificateRecord record) {
    state = [record, ...state];
  }

  void reissueCertificate(String id) {
    state = state.map((r) => r.id == id ? r.copyWith(status: 'Reissued') : r).toList();
  }
}

final generatedCertificatesProvider = StateNotifierProvider<GeneratedCertificatesNotifier, List<GeneratedCertificateRecord>>((ref) {
  return GeneratedCertificatesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// ID Card Designer Settings
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class IDCardDesignConfig {
  final String layoutStyle; // 'Vertical', 'Horizontal'
  final String cardColorTheme; // 'Ocean Blue', 'Charcoal', 'Forest Green'
  final bool showBarcode;
  final bool showQrCode;

  const IDCardDesignConfig({
    required this.layoutStyle,
    required this.cardColorTheme,
    required this.showBarcode,
    required this.showQrCode,
  });

  IDCardDesignConfig copyWith({
    String? layoutStyle,
    String? cardColorTheme,
    bool? showBarcode,
    bool? showQrCode,
  }) {
    return IDCardDesignConfig(
      layoutStyle: layoutStyle ?? this.layoutStyle,
      cardColorTheme: cardColorTheme ?? this.cardColorTheme,
      showBarcode: showBarcode ?? this.showBarcode,
      showQrCode: showQrCode ?? this.showQrCode,
    );
  }
}

class IDCardDesignerNotifier extends StateNotifier<IDCardDesignConfig> {
  IDCardDesignerNotifier() : super(const IDCardDesignConfig(
    layoutStyle: 'Vertical',
    cardColorTheme: 'Ocean Blue',
    showBarcode: true,
    showQrCode: true,
  ));

  void updateConfig({
    String? layoutStyle,
    String? cardColorTheme,
    bool? showBarcode,
    bool? showQrCode,
  }) {
    state = state.copyWith(
      layoutStyle: layoutStyle,
      cardColorTheme: cardColorTheme,
      showBarcode: showBarcode,
      showQrCode: showQrCode,
    );
  }
}

final idCardDesignerProvider = StateNotifierProvider<IDCardDesignerNotifier, IDCardDesignConfig>((ref) {
  return IDCardDesignerNotifier();
});

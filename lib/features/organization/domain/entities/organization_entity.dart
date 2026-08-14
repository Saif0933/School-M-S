import 'package:equatable/equatable.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Organization Entity — Top-level trust/chain model (Level 1)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OrganizationEntity extends Equatable {
  final String id;
  final String name;
  final String registrationNumber;
  final String taxRegistrationNumber; // PAN / GSTIN / EIN
  final String? logoUrl;
  final String email;
  final String phone;
  final String address;
  final String website;
  final String subdomain; // e.g. sunrise.symbosys.com
  final String superAdminName;
  final String superAdminEmail;
  final String superAdminPhone;
  final String billingContactEmail;
  final String technicalContactEmail;
  final String subscriptionPlan; // Basic, Standard, Premium, Enterprise
  final int maxBranches;
  final int maxTotalStudents;
  final int smsCreditPool;
  final int emailCreditPool;
  final String brandPrimaryColorHex;
  final List<String> masterSubjects;
  final List<String> masterFeeHeads;
  final List<String> masterDesignations;
  final List<Map<String, dynamic>> auditLogs;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, dynamic> masterSettings;

  const OrganizationEntity({
    required this.id,
    required this.name,
    required this.registrationNumber,
    this.taxRegistrationNumber = 'GSTIN-9900112233',
    this.logoUrl,
    required this.email,
    required this.phone,
    required this.address,
    required this.website,
    this.subdomain = 'sunrise.symbosys.com',
    this.superAdminName = 'Rajesh Kumar Sharma',
    this.superAdminEmail = 'superadmin@symbosys.com',
    this.superAdminPhone = '+91 9876543210',
    this.billingContactEmail = 'billing@sunrisetrust.edu.in',
    this.technicalContactEmail = 'tech@sunrisetrust.edu.in',
    required this.subscriptionPlan,
    required this.maxBranches,
    required this.maxTotalStudents,
    this.smsCreditPool = 50000,
    this.emailCreditPool = 200000,
    this.brandPrimaryColorHex = '#6366F1',
    this.masterSubjects = const [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Biology',
      'English Literature',
      'Computer Science & AI',
      'Social Studies',
      'Hindi Language',
    ],
    this.masterFeeHeads = const [
      'Tuition Fee',
      'Admission Fee',
      'Annual Maintenance Charges',
      'Transport Fee',
      'Laboratory & STEM Fee',
      'Library Deposit',
      'Examination & Evaluation Fee',
    ],
    this.masterDesignations = const [
      'Principal',
      'Vice Principal',
      'Head of Department (HOD)',
      'Senior PGT Teacher',
      'TGT Teacher',
      'PRT Teacher',
      'Chief Accountant',
      'Sports Instructor',
    ],
    this.auditLogs = const [],
    this.isActive = true,
    required this.createdAt,
    this.masterSettings = const {},
  });

  OrganizationEntity copyWith({
    String? id,
    String? name,
    String? registrationNumber,
    String? taxRegistrationNumber,
    String? logoUrl,
    String? email,
    String? phone,
    String? address,
    String? website,
    String? subdomain,
    String? superAdminName,
    String? superAdminEmail,
    String? superAdminPhone,
    String? billingContactEmail,
    String? technicalContactEmail,
    String? subscriptionPlan,
    int? maxBranches,
    int? maxTotalStudents,
    int? smsCreditPool,
    int? emailCreditPool,
    String? brandPrimaryColorHex,
    List<String>? masterSubjects,
    List<String>? masterFeeHeads,
    List<String>? masterDesignations,
    List<Map<String, dynamic>>? auditLogs,
    bool? isActive,
    DateTime? createdAt,
    Map<String, dynamic>? masterSettings,
  }) {
    return OrganizationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      taxRegistrationNumber: taxRegistrationNumber ?? this.taxRegistrationNumber,
      logoUrl: logoUrl ?? this.logoUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      website: website ?? this.website,
      subdomain: subdomain ?? this.subdomain,
      superAdminName: superAdminName ?? this.superAdminName,
      superAdminEmail: superAdminEmail ?? this.superAdminEmail,
      superAdminPhone: superAdminPhone ?? this.superAdminPhone,
      billingContactEmail: billingContactEmail ?? this.billingContactEmail,
      technicalContactEmail: technicalContactEmail ?? this.technicalContactEmail,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      maxBranches: maxBranches ?? this.maxBranches,
      maxTotalStudents: maxTotalStudents ?? this.maxTotalStudents,
      smsCreditPool: smsCreditPool ?? this.smsCreditPool,
      emailCreditPool: emailCreditPool ?? this.emailCreditPool,
      brandPrimaryColorHex: brandPrimaryColorHex ?? this.brandPrimaryColorHex,
      masterSubjects: masterSubjects ?? this.masterSubjects,
      masterFeeHeads: masterFeeHeads ?? this.masterFeeHeads,
      masterDesignations: masterDesignations ?? this.masterDesignations,
      auditLogs: auditLogs ?? this.auditLogs,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      masterSettings: masterSettings ?? this.masterSettings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        registrationNumber,
        subscriptionPlan,
        subdomain,
        smsCreditPool,
        emailCreditPool,
      ];
}

import '../../domain/entities/organization_entity.dart';
import '../../../branch/domain/entities/branch_entity.dart';
import '../../../../core/enums/enums.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Mock Organization & Branch Repository
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class MockOrganizationRepository {
  static final OrganizationEntity _demoOrg = OrganizationEntity(
    id: 'ORG-001',
    name: 'Sunrise Education Trust',
    registrationNumber: 'REG-2018-SET-8849',
    logoUrl: null,
    email: 'info@sunrisetrust.edu.in',
    phone: '+91 11 4567 8900',
    address: '12, Education Hub, Institutional Area, Vasant Kunj, New Delhi - 110070',
    website: 'https://sunrisetrust.edu.in',
    subscriptionPlan: 'Enterprise Plan',
    maxBranches: 10,
    maxTotalStudents: 10000,
    createdAt: DateTime(2018, 4, 1),
    masterSettings: const {
      'currency': 'INR',
      'timezone': 'Asia/Kolkata',
      'language': 'en',
    },
  );

  static final List<BranchEntity> _demoBranches = [
    BranchEntity(
      id: 'BR-001',
      organizationId: 'ORG-001',
      code: 'SIS-DEL',
      name: 'Sunrise International School - Delhi',
      affiliationBoard: 'CBSE',
      recognitionNumber: 'CBSE/AFF/2020/1104',
      principalName: 'Dr. Meenakshi Sundaram',
      email: 'delhi@sunrisetrust.edu.in',
      phone: '+91 11 2612 3456',
      address: 'Plot 4, Vasant Kunj Sector C',
      city: 'New Delhi',
      state: 'Delhi',
      pincode: '110070',
      status: BranchStatus.active,
      maxStudentCapacity: 3000,
      maxStaffCapacity: 200,
      activeStudentCount: 2847,
      activeStaffCount: 186,
      currentAcademicYear: '2026-2027',
      planType: 'Premium',
      enabledModules: ModuleType.values.toSet(),
      createdAt: DateTime(2018, 6, 1),
    ),
    BranchEntity(
      id: 'BR-002',
      organizationId: 'ORG-001',
      code: 'SPS-MUM',
      name: 'Sunrise Public School - Mumbai',
      affiliationBoard: 'ICSE',
      recognitionNumber: 'ICSE/MAH/2021/883',
      principalName: 'Mr. Rajeshwar Rao',
      email: 'mumbai@sunrisetrust.edu.in',
      phone: '+91 22 6789 1234',
      address: 'Bandr-Kurla Complex, Bandra East',
      city: 'Mumbai',
      state: 'Maharashtra',
      pincode: '400051',
      status: BranchStatus.active,
      maxStudentCapacity: 2500,
      maxStaffCapacity: 150,
      activeStudentCount: 2150,
      activeStaffCount: 142,
      currentAcademicYear: '2026-2027',
      planType: 'Premium',
      enabledModules: ModuleType.values.toSet(),
      createdAt: DateTime(2020, 8, 15),
    ),
    BranchEntity(
      id: 'BR-003',
      organizationId: 'ORG-001',
      code: 'SA-BLR',
      name: 'Sunrise Academy - Bangalore',
      affiliationBoard: 'IB World School',
      recognitionNumber: 'IB/IND/2022/990',
      principalName: 'Mrs. Sarah Williams',
      email: 'bangalore@sunrisetrust.edu.in',
      phone: '+91 80 4123 5678',
      address: 'Whitefield Main Road, Near ITPL',
      city: 'Bengaluru',
      state: 'Karnataka',
      pincode: '560066',
      status: BranchStatus.active,
      maxStudentCapacity: 1500,
      maxStaffCapacity: 100,
      activeStudentCount: 1280,
      activeStaffCount: 94,
      currentAcademicYear: '2026-2027',
      planType: 'Standard',
      enabledModules: ModuleType.values.where((m) => m != ModuleType.hostel).toSet(),
      createdAt: DateTime(2022, 3, 10),
    ),
  ];

  Future<OrganizationEntity> getOrganizationDetails(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoOrg;
  }

  Future<List<BranchEntity>> getBranches(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _demoBranches;
  }
}

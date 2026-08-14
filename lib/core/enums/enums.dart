library;

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Symbosys SMS — Enumerations
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// User roles in the system hierarchy
enum UserRole {
  platformAdmin('Platform Admin', 'SaaS Platform Owner & Super Administrator'),
  superAdmin('Super Admin', 'Organization-level administrator'),
  orgAdmin('Org Admin', 'Organization billing/support admin'),
  branchAdmin('Branch Admin', 'Branch principal/manager'),
  hod('HOD', 'Department head'),
  teacher('Teacher', 'Teaching staff'),
  classTeacher('Class Teacher', 'Class teacher with section access'),
  accountant('Accountant', 'Finance/accounting staff'),
  librarian('Librarian', 'Library management staff'),
  receptionist('Receptionist', 'Front desk staff'),
  transportManager('Transport Manager', 'Transport fleet management'),
  hostelWarden('Hostel Warden', 'Hostel management'),
  parent('Parent', 'Parent/Guardian'),
  student('Student', 'Student');

  const UserRole(this.label, this.description);
  final String label;
  final String description;

  bool get isPlatformLevel => this == platformAdmin;

  bool get isOrgLevel =>
      this == superAdmin || this == orgAdmin;

  bool get isBranchLevel =>
      this == branchAdmin ||
      this == hod ||
      this == teacher ||
      this == classTeacher ||
      this == accountant ||
      this == librarian ||
      this == receptionist ||
      this == transportManager ||
      this == hostelWarden;

  bool get isEndUser => this == parent || this == student;
}

/// SaaS Subscription Tier Plan
enum SubscriptionTier {
  basic('Basic', 'Essential School ERP Features', 299, 1, 500),
  standard('Standard', 'Multi-Branch & Core Automation', 599, 3, 2000),
  premium('Premium', 'Advanced Analytics, LMS & Mobile App', 1199, 10, 10000),
  enterprise('Enterprise', 'Unlimited Custom Multi-Branch Suite', 2499, 99, 100000);

  const SubscriptionTier(
    this.label,
    this.description,
    this.monthlyPrice,
    this.maxBranches,
    this.maxStudents,
  );

  final String label;
  final String description;
  final double monthlyPrice;
  final int maxBranches;
  final int maxStudents;
}

/// Branch operational status
enum BranchStatus {
  active('Active'),
  inactive('Inactive'),
  trial('Trial'),
  suspended('Suspended'),
  archived('Archived');

  const BranchStatus(this.label);
  final String label;
}

/// Module types available per branch
enum ModuleType {
  organization('Organization Management', 'iconsax.building_4'),
  branch('Branch Management', 'iconsax.buildings'),
  department('Departments & Classes', 'iconsax.category_2'),
  students('Student Management', 'iconsax.people'),
  staff('Staff & Teachers', 'iconsax.teacher'),
  timetable('Timetable & Scheduling', 'iconsax.calendar_1'),
  attendance('Attendance', 'iconsax.tick_circle'),
  fees('Fees & Finance', 'iconsax.wallet_3'),
  examinations('Examinations', 'iconsax.document_text_1'),
  library('Library', 'iconsax.book_1'),
  transport('Transport', 'iconsax.bus'),
  hostel('Hostel', 'iconsax.house_2'),
  communication('Communication', 'iconsax.message_text_1'),
  parentPortal('Parent Portal', 'iconsax.profile_2user'),
  admissions('Admissions', 'iconsax.add_circle'),
  hrPayroll('HR & Payroll', 'iconsax.money_recive'),
  inventory('Inventory & Assets', 'iconsax.box_1'),
  reports('Reports & Analytics', 'iconsax.chart_2'),
  lms('Online Classes & LMS', 'iconsax.video_play'),
  certificates('Certificates & ID Cards', 'iconsax.card'),
  events('Events & Calendar', 'iconsax.calendar_tick'),
  homework('Homework & Assignments', 'iconsax.task_square'),
  noticeBoard('Notice Board', 'iconsax.note_text'),
  visitorSecurity('Visitor & Security', 'iconsax.shield_tick'),
  leaveManagement('Leave & Gate Pass', 'iconsax.logout'),
  canteen('Canteen', 'iconsax.coffee'),
  alumni('Alumni', 'iconsax.award'),
  healthRecords('Health & Medical', 'iconsax.health'),
  subscription('Subscription & Billing', 'iconsax.receipt_item'),
  settings('Settings', 'iconsax.setting_2');

  const ModuleType(this.label, this.iconName);
  final String label;
  final String iconName;
}

/// Academic session terms
enum AcademicTerm {
  term1('Term 1'),
  term2('Term 2'),
  term3('Term 3'),
  halfYearly('Half Yearly'),
  annual('Annual');

  const AcademicTerm(this.label);
  final String label;
}

/// Student statuses
enum StudentStatus {
  active('Active'),
  inactive('Inactive'),
  transferred('Transferred'),
  graduated('Graduated'),
  expelled('Expelled'),
  tcIssued('TC Issued'),
  dropout('Dropout');

  const StudentStatus(this.label);
  final String label;
}

/// Staff statuses
enum StaffStatus {
  active('Active'),
  inactive('Inactive'),
  onLeave('On Leave'),
  resigned('Resigned'),
  terminated('Terminated'),
  retired('Retired');

  const StaffStatus(this.label);
  final String label;
}

/// Fee payment modes
enum PaymentMode {
  cash('Cash'),
  cheque('Cheque'),
  dd('Demand Draft'),
  online('Online'),
  upi('UPI'),
  card('Card'),
  bankTransfer('Bank Transfer');

  const PaymentMode(this.label);
  final String label;
}

/// Gender
enum Gender {
  male('Male'),
  female('Female'),
  other('Other');

  const Gender(this.label);
  final String label;
}

/// Attendance status
enum AttendanceStatus {
  present('Present'),
  absent('Absent'),
  late('Late'),
  halfDay('Half Day'),
  holiday('Holiday'),
  leave('On Leave');

  const AttendanceStatus(this.label);
  final String label;
}

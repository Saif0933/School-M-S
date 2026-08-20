import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/enums.dart';
import '../../providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// 6-Step Organization & Branch Onboarding Wizard Modal
/// Section 1 Specification: Level 1 Organization Provisioning
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OrganizationOnboardingWizardModal extends ConsumerStatefulWidget {
  const OrganizationOnboardingWizardModal({super.key});

  @override
  ConsumerState<OrganizationOnboardingWizardModal> createState() =>
      _OrganizationOnboardingWizardModalState();
}

class _OrganizationOnboardingWizardModalState
    extends ConsumerState<OrganizationOnboardingWizardModal> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1 Controllers
  final _orgNameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _taxNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _subdomainController = TextEditingController();

  // Step 2 Controllers
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPhoneController = TextEditingController();
  final _billingEmailController = TextEditingController();
  final _techEmailController = TextEditingController();

  // Step 3 Controllers
  SubscriptionTier _selectedTier = SubscriptionTier.premium;
  final _maxBranchesController = TextEditingController(text: '10');
  final _maxStudentsController = TextEditingController(text: '5000');
  final _smsCreditsController = TextEditingController(text: '50000');
  final _emailCreditsController = TextEditingController(text: '200000');

  // Step 4 Controllers
  final _branchNameController = TextEditingController();
  final _branchCodeController = TextEditingController();
  final _branchBoardController = TextEditingController(text: 'CBSE');
  final _principalNameController = TextEditingController();
  final _branchAddressController = TextEditingController();

  // Step 5 Controllers
  final List<String> _subjects = [
    'Mathematics',
    'Science & Physics',
    'Chemistry & Biology',
    'English Language',
    'Computer Science & AI',
  ];
  final List<String> _feeHeads = [
    'Tuition Fee',
    'Admission Fee',
    'Transport Fee',
    'Library Fee',
    'Examination Fee',
  ];
  final List<String> _designations = [
    'Principal',
    'HOD',
    'Senior Teacher',
    'Teacher',
    'Accountant',
  ];
  final _customSubjectController = TextEditingController();

  // Step 6 Controllers
  String _primaryColorHex = '#6366F1';
  bool _enableApiKey = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _orgNameController.dispose();
    _regNoController.dispose();
    _taxNoController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _subdomainController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
    _billingEmailController.dispose();
    _techEmailController.dispose();
    _maxBranchesController.dispose();
    _maxStudentsController.dispose();
    _smsCreditsController.dispose();
    _emailCreditsController.dispose();
    _branchNameController.dispose();
    _branchCodeController.dispose();
    _branchBoardController.dispose();
    _principalNameController.dispose();
    _branchAddressController.dispose();
    _customSubjectController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _submitWizard();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitWizard() {
    setState(() => _isSubmitting = true);

    // Onboard Branch into State
    ref.read(organizationBranchesProvider.notifier).onboardBranch(
          code: _branchCodeController.text.trim().isEmpty
              ? 'BR-NEW'
              : _branchCodeController.text.trim(),
          name: _branchNameController.text.trim().isEmpty
              ? 'Main Campus Branch'
              : _branchNameController.text.trim(),
          affiliationBoard: _branchBoardController.text.trim(),
          principalName: _principalNameController.text.trim().isEmpty
              ? 'Dr. Principal'
              : _principalNameController.text.trim(),
          email: _adminEmailController.text.trim().isEmpty
              ? 'principal@school.edu.in'
              : _adminEmailController.text.trim(),
          phone: _adminPhoneController.text.trim(),
          address: _branchAddressController.text.trim().isEmpty
              ? 'Main Campus Address'
              : _branchAddressController.text.trim(),
          city: 'Central City',
          stateName: 'State',
          maxStudents: int.tryParse(_maxStudentsController.text.trim()) ?? 2000,
          maxStaff: 150,
        );

    // Update Profile
    ref.read(organizationProvider.notifier).updateOrganizationProfile(
          name: _orgNameController.text.trim().isEmpty
              ? 'New Education Trust'
              : _orgNameController.text.trim(),
          regNo: _regNoController.text.trim().isEmpty
              ? 'REG-2026-NEW'
              : _regNoController.text.trim(),
          taxNo: _taxNoController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          website: _websiteController.text.trim(),
          subdomain: _subdomainController.text.trim(),
          superAdminName: _adminNameController.text.trim(),
          superAdminEmail: _adminEmailController.text.trim(),
        );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Organization "${_orgNameController.text.trim().isEmpty ? 'New Trust' : _orgNameController.text.trim()}" onboarded & initial branch provisioned!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 650;
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880, maxHeight: 820),
            child: Column(
              children: [
                // Modal Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.domain_add_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '6-Step Onboarding Wizard',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 18,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Level 1 Trust Registration → Branch Isolation → Master Setup',
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Step Progress Indicator Bar
                _buildStepIndicator(isDark, isMobile),

                // Modal Body Step Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: _buildCurrentStepView(isDark, isMobile),
                    ),
                  ),
                ),

                // Modal Footer Actions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                  ),
                  child: isMobile
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                if (_currentStep > 0)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _prevStep,
                                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                                      label: const Text('Previous'),
                                    ),
                                  ),
                                if (_currentStep > 0) const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _nextStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: Icon(
                                  _currentStep == 5
                                      ? Icons.verified_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  _currentStep == 5
                                      ? 'Provision & Activate Trust'
                                      : 'Next Step',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentStep > 0)
                              OutlinedButton.icon(
                                onPressed: _prevStep,
                                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                                label: const Text('Previous Step'),
                              )
                            else
                              const SizedBox.shrink(),

                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _isSubmitting ? null : _nextStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: Icon(
                                    _currentStep == 5
                                        ? Icons.verified_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _currentStep == 5
                                        ? 'Provision & Activate Trust'
                                        : 'Next Step',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark, bool isMobile) {
    final stepLabels = [
      'Trust Profile',
      'Super Admin',
      'Subscription',
      'Initial Branch',
      'Master Data',
      'Branding & API',
    ];

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${_currentStep + 1} of 6',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  stepLabels[_currentStep],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 6,
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                color: AppColors.primary,
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: List.generate(6, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : (isCompleted
                              ? AppColors.secondary.withValues(alpha: 0.15)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : (isCompleted
                                ? AppColors.secondary
                                : Colors.transparent),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'STEP ${index + 1}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isActive
                                ? AppColors.primary
                                : (isCompleted
                                    ? AppColors.secondary
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary)),
                          ),
                        ),
                        Text(
                          stepLabels[index],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < 5)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 14, color: Colors.grey),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildResponsiveFieldsRow({
    required bool isMobile,
    required Widget left,
    required Widget right,
    double spacing = 14,
    int leftFlex = 1,
    int rightFlex = 1,
  }) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          SizedBox(height: spacing),
          right,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex, child: left),
        SizedBox(width: spacing),
        Expanded(flex: rightFlex, child: right),
      ],
    );
  }

  Widget _buildCurrentStepView(bool isDark, bool isMobile) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Profile(isDark, isMobile);
      case 1:
        return _buildStep2SuperAdmin(isDark, isMobile);
      case 2:
        return _buildStep3Subscription(isDark, isMobile);
      case 3:
        return _buildStep4InitialBranch(isDark, isMobile);
      case 4:
        return _buildStep5MasterData(isDark, isMobile);
      case 5:
      default:
        return _buildStep6Branding(isDark, isMobile);
    }
  }

  // STEP 1: TRUST / ORGANIZATION PROFILE
  Widget _buildStep1Profile(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 1: Trust / Chain Profile Information', isDark),
        const SizedBox(height: 16),
        _buildResponsiveFieldsRow(
          isMobile: isMobile,
          leftFlex: 2,
          rightFlex: 1,
          left: _buildTextField(
            controller: _orgNameController,
            label: 'Trust / Group Name *',
            hint: 'e.g. Sunrise Education Trust',
            icon: Icons.account_balance_rounded,
            isDark: isDark,
          ),
          right: _buildTextField(
            controller: _regNoController,
            label: 'Registration Number',
            hint: 'e.g. REG-2018-SET-8849',
            icon: Icons.assignment_turned_in_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 14),
        _buildResponsiveFieldsRow(
          isMobile: isMobile,
          left: _buildTextField(
            controller: _taxNoController,
            label: 'Tax ID / PAN / GSTIN',
            hint: 'e.g. GSTIN-07AAATS8849K1Z5',
            icon: Icons.receipt_long_rounded,
            isDark: isDark,
          ),
          right: _buildTextField(
            controller: _subdomainController,
            label: 'Dedicated SaaS Subdomain',
            hint: 'e.g. sunrise (sunrise.symbosys.com)',
            icon: Icons.language_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 14),
        _buildResponsiveFieldsRow(
          isMobile: isMobile,
          left: _buildTextField(
            controller: _emailController,
            label: 'Official Corporate Email *',
            hint: 'info@sunrisetrust.edu.in',
            icon: Icons.email_outlined,
            isDark: isDark,
          ),
          right: _buildTextField(
            controller: _phoneController,
            label: 'Contact Phone Number',
            hint: '+91 11 4567 8900',
            icon: Icons.phone_outlined,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _addressController,
          label: 'HQ Corporate Address',
          hint: '12, Education Hub, Institutional Area, New Delhi - 110070',
          icon: Icons.location_on_outlined,
          isDark: isDark,
        ),
      ],
    );
  }

  // STEP 2: SUPER ADMIN & ROLES
  Widget _buildStep2SuperAdmin(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 2: Organization Super Admin Credentials', isDark),
        const SizedBox(height: 16),
        _buildResponsiveFieldsRow(
          isMobile: isMobile,
          left: _buildTextField(
            controller: _adminNameController,
            label: 'Super Admin Full Name *',
            hint: 'Dr. Rajesh Kumar Sharma',
            icon: Icons.person_rounded,
            isDark: isDark,
          ),
          right: _buildTextField(
            controller: _adminEmailController,
            label: 'Super Admin Email (Login ID) *',
            hint: 'superadmin@symbosys.com',
            icon: Icons.mark_email_read_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 14),
        _buildResponsiveFieldsRow(
          isMobile: isMobile,
          left: _buildTextField(
            controller: _adminPhoneController,
            label: 'Super Admin Mobile',
            hint: '+91 9876543210',
            icon: Icons.smartphone_rounded,
            isDark: isDark,
          ),
          right: _buildTextField(
            controller: _billingEmailController,
            label: 'Billing Contact Email',
            hint: 'billing@sunrisetrust.edu.in',
            icon: Icons.payment_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _techEmailController,
          label: 'Technical Admin Email (DevOps / Integration)',
          hint: 'tech@sunrisetrust.edu.in',
          icon: Icons.code_rounded,
          isDark: isDark,
        ),
      ],
    );
  }

  // STEP 3: SUBSCRIPTION & CREDITS
  Widget _buildStep3Subscription(bool isDark, bool isMobile) {
    final planSelector = isMobile
        ? Column(
            children: SubscriptionTier.values.map((tier) {
              final isSelected = _selectedTier == tier;
              return GestureDetector(
                onTap: () => setState(() => _selectedTier = tier),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDark ? AppColors.darkCard : AppColors.lightBg),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        tier.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        '\$${tier.monthlyPrice.toInt()}/mo',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        : Row(
            children: SubscriptionTier.values.map((tier) {
              final isSelected = _selectedTier == tier;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTier = tier),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : (isDark ? AppColors.darkCard : AppColors.lightBg),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          tier.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '\$${tier.monthlyPrice.toInt()}/mo',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 3: SaaS Subscription & Credit Pools', isDark),
        const SizedBox(height: 16),
        planSelector,
        const SizedBox(height: 20),
        _buildResponsiveFieldsRow(
          isMobile: isMobile,
          left: _buildTextField(
            controller: _maxBranchesController,
            label: 'Max Branch Limit',
            hint: '10',
            icon: Icons.account_tree_rounded,
            isDark: isDark,
          ),
          right: _buildTextField(
            controller: _maxStudentsController,
            label: 'Max Student License Pool',
            hint: '5000',
            icon: Icons.groups_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 14),
        _buildResponsiveFieldsRow(
          isMobile: isMobile,
          left: _buildTextField(
            controller: _smsCreditsController,
            label: 'Initial SMS Credit Pool',
            hint: '50000',
            icon: Icons.sms_rounded,
            isDark: isDark,
          ),
          right: _buildTextField(
            controller: _emailCreditsController,
            label: 'Initial Email Credit Pool',
            hint: '200000',
            icon: Icons.email_rounded,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  // STEP 4: INITIAL BRANCH PROVISIONING
  Widget _buildStep4InitialBranch(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 4: Provision Initial Branch (School)', isDark),
        const SizedBox(height: 16),
        _buildResponsiveFieldsRow(
          isMobile: isMobile,
          leftFlex: 2,
          rightFlex: 1,
          left: _buildTextField(
            controller: _branchNameController,
            label: 'First Branch Name *',
            hint: 'e.g. Sunrise International School - Delhi',
            icon: Icons.school_rounded,
            isDark: isDark,
          ),
          right: _buildTextField(
            controller: _branchCodeController,
            label: 'Branch Code',
            hint: 'e.g. SIS-DEL',
            icon: Icons.tag_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 14),
        _buildResponsiveFieldsRow(
          isMobile: isMobile,
          left: _buildTextField(
            controller: _branchBoardController,
            label: 'Affiliation Board',
            hint: 'CBSE / ICSE / IB / State Board',
            icon: Icons.workspace_premium_rounded,
            isDark: isDark,
          ),
          right: _buildTextField(
            controller: _principalNameController,
            label: 'Branch Principal Name',
            hint: 'Dr. Meenakshi Sundaram',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _branchAddressController,
          label: 'Branch Campus Address',
          hint: 'Plot 4, Vasant Kunj Sector C, New Delhi - 110070',
          icon: Icons.location_on_outlined,
          isDark: isDark,
        ),
      ],
    );
  }

  // STEP 5: MASTER DATA SETUP
  Widget _buildStep5MasterData(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 5: Master Data & Global Templates', isDark),
        const SizedBox(height: 14),

        Text(
          'Global Master Subjects across All Branches',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _subjects.map((sub) {
            return Chip(
              label: Text(sub, style: const TextStyle(fontSize: 12)),
              onDeleted: () {
                setState(() => _subjects.remove(sub));
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        Text(
          'Global Master Fee Heads',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _feeHeads.map((fee) {
            return Chip(
              avatar: const Icon(Icons.payments_rounded, size: 14),
              label: Text(fee, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        Text(
          'Global Master Staff Designations',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _designations.map((des) {
            return Chip(
              avatar: const Icon(Icons.badge_rounded, size: 14),
              label: Text(des, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 6: WHITE-LABEL BRANDING & ACTIVATION
  Widget _buildStep6Branding(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 6: White-Label Branding & Provisioning', isDark),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primary Theme Color',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final color in [
                          '#6366F1',
                          '#3B82F6',
                          '#10B981',
                          '#8B5CF6',
                          '#F59E0B'
                        ])
                          GestureDetector(
                            onTap: () => setState(() => _primaryColorHex = color),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _hexToColor(color),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _primaryColorHex == color
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        SwitchListTile(
          value: _enableApiKey,
          onChanged: (val) => setState(() => _enableApiKey = val),
          title: const Text('Generate API Keys & Webhooks for Integration'),
          subtitle: const Text('Enable REST APIs for ERP data sync'),
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.primaryLight : AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            prefixIcon: Icon(icon, size: 18),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

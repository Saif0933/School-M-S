import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/enums.dart';
import '../../providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Organization Onboarding Modal — Platform Owner
/// Complete workflow to register new SaaS School Tenants
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OrganizationOnboardingModal extends ConsumerStatefulWidget {
  const OrganizationOnboardingModal({super.key});

  @override
  ConsumerState<OrganizationOnboardingModal> createState() =>
      _OrganizationOnboardingModalState();
}

class _OrganizationOnboardingModalState
    extends ConsumerState<OrganizationOnboardingModal> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _superAdminNameController = TextEditingController();
  final _superAdminEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _maxBranchesController = TextEditingController(text: '1');
  final _maxStudentsController = TextEditingController(text: '500');

  SubscriptionTier _selectedTier = SubscriptionTier.basic;
  String _billingCycle = 'yearly';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _superAdminNameController.dispose();
    _superAdminEmailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _maxBranchesController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  void _onTierSelected(SubscriptionTier tier) {
    setState(() {
      _selectedTier = tier;
      _maxBranchesController.text = tier.maxBranches.toString();
      _maxStudentsController.text = tier.maxStudents.toString();
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    ref.read(platformOrganizationsProvider.notifier).onboardOrganization(
          name: _nameController.text.trim(),
          code: _codeController.text.trim().isEmpty
              ? _nameController.text.trim().substring(0, 3).toUpperCase()
              : _codeController.text.trim(),
          superAdminName: _superAdminNameController.text.trim(),
          superAdminEmail: _superAdminEmailController.text.trim(),
          contactPhone: _phoneController.text.trim(),
          subscriptionTier: _selectedTier,
          billingCycle: _billingCycle,
          maxBranches: int.tryParse(_maxBranchesController.text.trim()) ??
              _selectedTier.maxBranches,
          maxStudents: int.tryParse(_maxStudentsController.text.trim()) ??
              _selectedTier.maxStudents,
          address: _addressController.text.trim().isEmpty
              ? 'Main Headquarters'
              : _addressController.text.trim(),
        );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Organization "${_nameController.text.trim()}" onboarded successfully on ${_selectedTier.label} Plan!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 780),
            child: Column(
              children: [
                // ─── Modal Header ────────────────────
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.domain_add_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Onboard New School',
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Register new tenant, allocate subscription plan & provisions',
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 13,
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

                // ─── Modal Body ──────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Subscription Tier Selection
                          _buildSectionTitle('1. Select SaaS Subscription Plan', isDark),
                          const SizedBox(height: 12),
                          _buildTierSelector(isDark, isMobile),
                          const SizedBox(height: 24),

                          // Section 2: Organization Details
                          _buildSectionTitle('2. Organization & Super Admin Details', isDark),
                          const SizedBox(height: 14),
                          _buildResponsiveFieldsRow(
                            isMobile: isMobile,
                            leftFlex: 2,
                            rightFlex: 1,
                            left: _buildTextField(
                              controller: _nameController,
                              label: 'Organization Name *',
                              hint: 'e.g. Cambridge International Trust',
                              icon: Icons.business_rounded,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Organization name is required'
                                  : null,
                              isDark: isDark,
                            ),
                            right: _buildTextField(
                              controller: _codeController,
                              label: 'Org Code',
                              hint: 'e.g. CIT-MAIN',
                              icon: Icons.tag_rounded,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildResponsiveFieldsRow(
                            isMobile: isMobile,
                            left: _buildTextField(
                              controller: _superAdminNameController,
                              label: 'Super Admin Full Name *',
                              hint: 'e.g. Dr. Rajesh Sharma',
                              icon: Icons.person_outline_rounded,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Super Admin name is required'
                                  : null,
                              isDark: isDark,
                            ),
                            right: _buildTextField(
                              controller: _superAdminEmailController,
                              label: 'Super Admin Email *',
                              hint: 'e.g. admin@cambridge.edu',
                              icon: Icons.email_outlined,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!v.contains('@')) return 'Enter a valid email';
                                return null;
                              },
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildResponsiveFieldsRow(
                            isMobile: isMobile,
                            left: _buildTextField(
                              controller: _phoneController,
                              label: 'Contact Phone Number',
                              hint: 'e.g. +91 9876543210',
                              icon: Icons.phone_outlined,
                              isDark: isDark,
                            ),
                            right: _buildTextField(
                              controller: _addressController,
                              label: 'HQ Address / City',
                              hint: 'e.g. New Delhi, India',
                              icon: Icons.location_on_outlined,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section 3: Billing & Capacity Limits
                          _buildSectionTitle('3. Billing & Allocation Limits', isDark),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Billing Cycle',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    isMobile
                                        ? Column(
                                            children: [
                                              _buildRadioOption(
                                                title: 'Yearly (Save 20%)',
                                                value: 'yearly',
                                                groupValue: _billingCycle,
                                                onChanged: (val) =>
                                                    setState(() => _billingCycle = val!),
                                                isDark: isDark,
                                              ),
                                              const SizedBox(height: 10),
                                              _buildRadioOption(
                                                title: 'Monthly',
                                                value: 'monthly',
                                                groupValue: _billingCycle,
                                                onChanged: (val) =>
                                                    setState(() => _billingCycle = val!),
                                                isDark: isDark,
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Expanded(
                                                child: _buildRadioOption(
                                                  title: 'Yearly (Save 20%)',
                                                  value: 'yearly',
                                                  groupValue: _billingCycle,
                                                  onChanged: (val) =>
                                                      setState(() => _billingCycle = val!),
                                                  isDark: isDark,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: _buildRadioOption(
                                                  title: 'Monthly',
                                                  value: 'monthly',
                                                  groupValue: _billingCycle,
                                                  onChanged: (val) =>
                                                      setState(() => _billingCycle = val!),
                                                  isDark: isDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildResponsiveFieldsRow(
                            isMobile: isMobile,
                            left: _buildTextField(
                              controller: _maxBranchesController,
                              label: 'Max Branches Allowed',
                              hint: '1',
                              icon: Icons.account_tree_outlined,
                              keyboardType: TextInputType.number,
                              isDark: isDark,
                            ),
                            right: _buildTextField(
                              controller: _maxStudentsController,
                              label: 'Max Students Allowed',
                              hint: '500',
                              icon: Icons.groups_outlined,
                              keyboardType: TextInputType.number,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── Modal Footer / Actions ──────────
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
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 14),
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.check_rounded, size: 18, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'Onboard Organization',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      children: const [
                                        Icon(Icons.check_rounded, size: 18, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Onboard Organization',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.primaryLight : AppColors.primary,
      ),
    );
  }

  Widget _buildTierSelector(bool isDark, bool isMobile) {
    Color getTierColor(SubscriptionTier tier) {
      switch (tier) {
        case SubscriptionTier.basic:
          return const Color(0xFF3B82F6);
        case SubscriptionTier.standard:
          return const Color(0xFF10B981);
        case SubscriptionTier.premium:
          return const Color(0xFF8B5CF6);
        case SubscriptionTier.enterprise:
          return const Color(0xFFF59E0B);
      }
    }

    final children = SubscriptionTier.values.map((tier) {
      final isSelected = _selectedTier == tier;
      final tierColor = getTierColor(tier);

      return GestureDetector(
        onTap: () => _onTierSelected(tier),
        child: Container(
          margin: isMobile
              ? const EdgeInsets.symmetric(vertical: 4)
              : const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? tierColor.withValues(alpha: 0.12)
                : (isDark ? AppColors.darkCard : AppColors.lightBg),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? tierColor
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tier.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: tierColor,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded,
                        color: tierColor, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$${tier.monthlyPrice.toInt()}/mo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Up to ${tier.maxBranches} Branch • ${tier.maxStudents} Students',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    if (isMobile) {
      return Column(
        children: children,
      );
    }

    return Row(
      children: children.map((c) => Expanded(child: c)).toList(),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkCard : AppColors.lightBg),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
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
          validator: validator,
          keyboardType: keyboardType,
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
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

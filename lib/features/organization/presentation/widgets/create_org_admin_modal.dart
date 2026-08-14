import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Create Organization-Level Admin Modal Widget
/// Roles: Super Admin, Billing Admin, Support Admin, Compliance Admin
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class CreateOrgAdminModal extends ConsumerStatefulWidget {
  const CreateOrgAdminModal({super.key});

  @override
  ConsumerState<CreateOrgAdminModal> createState() =>
      _CreateOrgAdminModalState();
}

class _CreateOrgAdminModalState extends ConsumerState<CreateOrgAdminModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedRole = 'Billing Admin';
  String _selectedBranchScope = 'ALL (Global Trust Scope)';

  final Map<String, List<String>> _rolePermissions = {
    'Super Admin': [
      'Full Organization Control',
      'Branch Onboarding & Deactivation',
      'Cross-Branch Migration Approval',
      'Subscription Billing',
      'Master Data Configuration',
    ],
    'Billing Admin': [
      'Subscription Renewal & Upgrades',
      'Invoices & Payment Records',
      'SMS & Email Credit Recharges',
      'Financial Revenue Analytics',
    ],
    'Support Admin': [
      'Cross-Branch Helpdesk Tickets',
      'Staff & Branch Password Resets',
      'Branch Diagnostic Logs',
      'User License Audits',
    ],
    'Compliance Admin': [
      'System Audit Logs',
      'Security Policy Enforcement',
      'Data Privacy Exports',
      'Role Permission Audits',
    ],
  };

  late List<String> _activePermissions;

  @override
  void initState() {
    super.initState();
    _activePermissions = List.from(_rolePermissions[_selectedRole]!);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onRoleChanged(String role) {
    setState(() {
      _selectedRole = role;
      _activePermissions = List.from(_rolePermissions[role] ?? []);
    });
  }

  void _submit() {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    ref.read(orgAdminsProvider.notifier).createAdmin(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
          branchScope: _selectedBranchScope,
          permissions: _activePermissions,
        );

    ref.read(organizationProvider.notifier).addAuditLog(
          'ORGANIZATION_ADMIN_CREATED',
          'Created $_selectedRole for ${_nameController.text.trim()} (${_emailController.text.trim()}).',
        );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Organization $_selectedRole "${_nameController.text.trim()}" created successfully!',
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
    final branches = ref.watch(organizationBranchesProvider);

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
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
                      Icons.admin_panel_settings_rounded,
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
                          'Create Organization-Level Admin Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Provision Super Admin, Billing Admin, Support Admin, or Compliance Admin',
                          style: TextStyle(
                            fontSize: 12,
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

            // Modal Body Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role Selection Cards
                      Text(
                        'Select Organization Administrative Role *',
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
                          _buildRoleCard(
                            role: 'Super Admin',
                            desc: 'Full Trust & Branch Control',
                            icon: Icons.shield_rounded,
                            color: const Color(0xFF6366F1),
                            isDark: isDark,
                          ),
                          _buildRoleCard(
                            role: 'Billing Admin',
                            desc: 'Invoices, Plans & Credits',
                            icon: Icons.payments_rounded,
                            color: const Color(0xFF10B981),
                            isDark: isDark,
                          ),
                          _buildRoleCard(
                            role: 'Support Admin',
                            desc: 'Helpdesk & User Resets',
                            icon: Icons.headset_mic_rounded,
                            color: const Color(0xFF3B82F6),
                            isDark: isDark,
                          ),
                          _buildRoleCard(
                            role: 'Compliance Admin',
                            desc: 'Audits & Security Policies',
                            icon: Icons.gavel_rounded,
                            color: const Color(0xFFF59E0B),
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Admin Personal Details
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Admin Full Name *',
                                hintText: 'e.g. Siddharth Varma',
                                prefixIcon:
                                    const Icon(Icons.person_rounded, size: 18),
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Name is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Official Email (Login ID) *',
                                hintText: 'billing@sunrisetrust.edu.in',
                                prefixIcon:
                                    const Icon(Icons.email_rounded, size: 18),
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Email is required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: '+91 9811223344',
                                prefixIcon:
                                    const Icon(Icons.phone_rounded, size: 18),
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedBranchScope,
                              decoration: InputDecoration(
                                labelText: 'Branch Scope',
                                prefixIcon: const Icon(
                                    Icons.account_tree_rounded,
                                    size: 18),
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'ALL (Global Trust Scope)',
                                  child: Text('ALL (Global Trust Scope)',
                                      style: TextStyle(fontSize: 12)),
                                ),
                                for (final b in branches)
                                  DropdownMenuItem(
                                    value: b.name,
                                    child: Text(b.name,
                                        style: const TextStyle(fontSize: 12)),
                                  ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedBranchScope = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Permissions Checklist
                      Text(
                        'Assigned Granular Permissions for $_selectedRole',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBg : AppColors.lightBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        ),
                        child: Column(
                          children: [
                            for (final perm
                                in _rolePermissions[_selectedRole] ?? []) ...[
                              CheckboxListTile(
                                value: _activePermissions.contains(perm),
                                dense: true,
                                title: Text(perm,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                activeColor: AppColors.primary,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _activePermissions.add(perm);
                                    } else {
                                      _activePermissions.remove(perm);
                                    }
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon:
                        const Icon(Icons.admin_panel_settings_rounded, size: 18),
                    label: const Text(
                      'Create Admin Account',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String desc,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => _onRoleChanged(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkCard : AppColors.lightBg),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              role,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            Text(
              desc,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../organization/providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Onboard Branch Modal Dialog
/// Allows creation / onboarding of a new school branch
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OnboardBranchModal extends ConsumerStatefulWidget {
  const OnboardBranchModal({super.key});

  @override
  ConsumerState<OnboardBranchModal> createState() => _OnboardBranchModalState();
}

class _OnboardBranchModalState extends ConsumerState<OnboardBranchModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _boardController = TextEditingController(text: 'CBSE');
  final _principalController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'New Delhi');
  final _stateController = TextEditingController(text: 'Delhi');
  final _maxStudentsController = TextEditingController(text: '1000');
  final _maxStaffController = TextEditingController(text: '100');
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    _boardController.dispose();
    _principalController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _maxStudentsController.dispose();
    _maxStaffController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await ref.read(organizationBranchesProvider.notifier).onboardBranch(
            code: _codeController.text.trim(),
            name: _nameController.text.trim(),
            affiliationBoard: _boardController.text.trim(),
            principalName: _principalController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            city: _cityController.text.trim(),
            stateName: _stateController.text.trim(),
            maxStudents: int.tryParse(_maxStudentsController.text.trim()) ?? 1000,
            maxStaff: int.tryParse(_maxStaffController.text.trim()) ?? 100,
            password: _passwordController.text,
          );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Branch "${_nameController.text.trim()}" onboarded successfully!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to onboard branch. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_business_rounded,
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
                          'Onboard New Branch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Provision an independent school campus with capacity limits',
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
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow([
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _nameController,
                              labelText: 'Branch Name *',
                              hintText: 'e.g. Sunrise Academy Bangalore',
                              icon: Icons.school_rounded,
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _codeController,
                              labelText: 'Unique Code *',
                              hintText: 'SA-BLR',
                              icon: Icons.qr_code_rounded,
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        _buildRow([
                          Expanded(
                            child: _buildTextField(
                              controller: _boardController,
                              labelText: 'Affiliation Board *',
                              hintText: 'e.g. CBSE / ICSE / IB',
                              icon: Icons.workspace_premium_rounded,
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _principalController,
                              labelText: 'Principal Name *',
                              hintText: 'Sarah Williams',
                              icon: Icons.person_rounded,
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        _buildRow([
                          Expanded(
                            child: _buildTextField(
                              controller: _emailController,
                              labelText: 'Official Email *',
                              hintText: 'bangalore@sunrisetrust.edu.in',
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Required';
                                if (!val.contains('@')) return 'Invalid Email';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              labelText: 'Contact Phone *',
                              hintText: '+91 80 4123 5678',
                              icon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _passwordController,
                          labelText: 'Branch Admin Password *',
                          hintText: 'Minimum 6 characters',
                          icon: Icons.lock_rounded,
                          obscureText: true,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Required';
                            if (val.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _addressController,
                          labelText: 'Campus Address *',
                          hintText: 'Whitefield Main Road, Near ITPL',
                          icon: Icons.location_on_rounded,
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        _buildRow([
                          Expanded(
                            child: _buildTextField(
                              controller: _cityController,
                              labelText: 'City *',
                              hintText: 'Bengaluru',
                              icon: Icons.location_city_rounded,
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _stateController,
                              labelText: 'State *',
                              hintText: 'Karnataka',
                              icon: Icons.map_rounded,
                              validator: (val) =>
                                  val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        _buildRow([
                          Expanded(
                            child: _buildTextField(
                              controller: _maxStudentsController,
                              labelText: 'Max Student Capacity *',
                              hintText: '1500',
                              icon: Icons.groups_rounded,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Required';
                                if (int.tryParse(val) == null) return 'Invalid Number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _maxStaffController,
                              labelText: 'Max Staff Capacity *',
                              hintText: '100',
                              icon: Icons.badge_rounded,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Required';
                                if (int.tryParse(val) == null) return 'Invalid Number';
                                return null;
                              },
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 24),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      _isSubmitting ? 'Onboarding...' : 'Onboard Branch',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            prefixIcon: Icon(icon, size: 18),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              borderSide: const BorderSide(
                color: AppColors.primary,
              ),
            ),
            errorStyle: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}

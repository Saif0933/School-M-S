import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../organization/providers.dart';
import '../../domain/entities/branch_entity.dart';

class OnboardBranchMemberModal extends ConsumerStatefulWidget {
  final BranchEntity branch;

  const OnboardBranchMemberModal({super.key, required this.branch});

  @override
  ConsumerState<OnboardBranchMemberModal> createState() => _OnboardBranchMemberModalState();
}

class _OnboardBranchMemberModalState extends ConsumerState<OnboardBranchMemberModal> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedRole = 'Teacher'; // 'Teacher', 'Student', 'Parent', 'Accountant'
  bool _isSubmitting = false;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Staff specific
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();

  // Student specific
  final _admissionNumController = TextEditingController();
  final _rollNumController = TextEditingController();
  final _categoryController = TextEditingController();
  String _selectedGender = 'MALE';
  DateTime? _dob;

  // Parent specific
  String _selectedRelation = 'FATHER';
  final _studentAdmissionController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _admissionNumController.dispose();
    _rollNumController.dispose();
    _categoryController.dispose();
    _studentAdmissionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'Student' && _dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Date of Birth for the student'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      bool success = false;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      if (_selectedRole == 'Teacher' || _selectedRole == 'Accountant') {
        final Map<String, dynamic> staffData = {
          'branchId': widget.branch.id,
          'employeeId': _employeeIdController.text.trim(),
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          'designation': _selectedRole,
          'department': _departmentController.text.trim().isEmpty ? null : _departmentController.text.trim(),
          'qualification': _qualificationController.text.trim().isEmpty ? null : _qualificationController.text.trim(),
          'experienceYears': _experienceController.text.trim().isEmpty ? 0 : int.tryParse(_experienceController.text.trim()) ?? 0,
          'password': _passwordController.text,
        };

        if (_selectedRole == 'Teacher') {
          success = await ref.read(organizationBranchesProvider.notifier).onboardTeacher(staffData);
        } else {
          success = await ref.read(organizationBranchesProvider.notifier).onboardAccountant(staffData);
        }
      } else if (_selectedRole == 'Student') {
        final Map<String, dynamic> studentData = {
          'branchId': widget.branch.id,
          'admissionNumber': _admissionNumController.text.trim(),
          'rollNumber': _rollNumController.text.trim().isEmpty ? null : _rollNumController.text.trim(),
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'dob': _dob!.toIso8601String(),
          'gender': _selectedGender,
          'category': _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          'password': _passwordController.text,
        };

        success = await ref.read(organizationBranchesProvider.notifier).onboardStudent(studentData);
      } else if (_selectedRole == 'Parent') {
        final Map<String, dynamic> parentData = {
          'branchId': widget.branch.id,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'relation': _selectedRelation,
          'password': _passwordController.text,
          'studentAdmissionNumber': _studentAdmissionController.text.trim().isEmpty ? null : _studentAdmissionController.text.trim(),
        };

        success = await ref.read(organizationBranchesProvider.notifier).onboardParent(parentData);
      }

      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Successfully onboarded $_selectedRole: ${_firstNameController.text.trim()}'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Onboarding failed. Please verify unique email / IDs.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Title & Branch badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Onboard Operational Member',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Onboard directly to: ${widget.branch.name}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Role Selector Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Select Role to Onboard',
                  isDense: true,
                  prefixIcon: const Icon(Icons.person_add_rounded, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Teacher', child: Text('Teacher (Staff Portal)')),
                  DropdownMenuItem(value: 'Student', child: Text('Student (Student Dashboard)')),
                  DropdownMenuItem(value: 'Parent', child: Text('Parent / Guardian')),
                  DropdownMenuItem(value: 'Accountant', child: Text('Accountant (Finance Desk)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedRole = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Scrollable Fields Form
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic User Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address (Used for login)',
                          isDense: true,
                          prefixIcon: const Icon(Icons.email_rounded, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: _selectedRole == 'Parent' ? 'Phone Number (Required)' : 'Phone Number (Optional)',
                          isDense: true,
                          prefixIcon: const Icon(Icons.phone_rounded, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (_selectedRole == 'Parent' && (v == null || v.trim().isEmpty)) {
                            return 'Required for guardians';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password (Used for login)',
                          isDense: true,
                          prefixIcon: const Icon(Icons.lock_rounded, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        obscureText: true,
                        validator: (v) => v == null || v.length < 6 ? 'Password must be >= 6 characters' : null,
                      ),
                      const SizedBox(height: 20),

                      // Dynamic Fields Header
                      Row(
                        children: [
                          const Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            '$_selectedRole-Specific Details',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      // Dynamic Role-Specific Fields
                      if (_selectedRole == 'Teacher' || _selectedRole == 'Accountant') ...[
                        TextFormField(
                          controller: _employeeIdController,
                          decoration: InputDecoration(
                            labelText: 'Employee ID (Unique)',
                            isDense: true,
                            prefixIcon: const Icon(Icons.badge_rounded, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _departmentController,
                                decoration: InputDecoration(
                                  labelText: 'Department (e.g. Science)',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _qualificationController,
                                decoration: InputDecoration(
                                  labelText: 'Qualification (e.g. B.Ed)',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _experienceController,
                          decoration: InputDecoration(
                            labelText: 'Experience (Years)',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.isNotEmpty && int.tryParse(v) == null) {
                              return 'Must be an integer';
                            }
                            return null;
                          },
                        ),
                      ] else if (_selectedRole == 'Student') ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _admissionNumController,
                                decoration: InputDecoration(
                                  labelText: 'Admission Number (Unique)',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _rollNumController,
                                decoration: InputDecoration(
                                  labelText: 'Roll Number (Optional)',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectDateOfBirth(context),
                                icon: const Icon(Icons.calendar_month_rounded, size: 16),
                                label: Text(
                                  _dob == null
                                      ? 'Select Date of Birth'
                                      : 'DOB: ${_dob!.day}/${_dob!.month}/${_dob!.year}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'MALE', child: Text('Male')),
                                  DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                                  DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedGender = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            labelText: 'Category (e.g. General, OBC, SC, ST)',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ] else if (_selectedRole == 'Parent') ...[
                        DropdownButtonFormField<String>(
                          value: _selectedRelation,
                          decoration: InputDecoration(
                            labelText: 'Relation to Student',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'FATHER', child: Text('Father')),
                            DropdownMenuItem(value: 'MOTHER', child: Text('Mother')),
                            DropdownMenuItem(value: 'GUARDIAN', child: Text('Other Legal Guardian')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedRelation = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _studentAdmissionController,
                          decoration: InputDecoration(
                            labelText: 'Student Admission Number (Optional - to link accounts)',
                            isDense: true,
                            prefixIcon: const Icon(Icons.link_rounded, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Onboard $_selectedRole'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

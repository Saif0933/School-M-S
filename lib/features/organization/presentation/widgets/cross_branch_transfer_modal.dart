import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Cross-Branch Transfer Request Modal (Level 1 Approval Workflow)
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class CrossBranchTransferModal extends ConsumerStatefulWidget {
  const CrossBranchTransferModal({super.key});

  @override
  ConsumerState<CrossBranchTransferModal> createState() =>
      _CrossBranchTransferModalState();
}

class _CrossBranchTransferModalState
    extends ConsumerState<CrossBranchTransferModal> {
  String _entityType = 'student'; // 'student' or 'staff'
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _reasonController = TextEditingController();

  String _fromBranch = 'Sunrise International School - Delhi';
  String _toBranch = 'Sunrise Public School - Mumbai';

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submitTransfer() {
    if (_nameController.text.trim().isEmpty) return;

    ref.read(crossBranchTransferProvider.notifier).requestTransfer(
          entityType: _entityType,
          entityName: _nameController.text.trim(),
          entityCode: _codeController.text.trim().isEmpty
              ? 'ID-2026-99'
              : _codeController.text.trim(),
          fromBranchName: _fromBranch,
          toBranchName: _toBranch,
          reason: _reasonController.text.trim().isEmpty
              ? 'Organization Level Transfer Request'
              : _reasonController.text.trim(),
        );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_entityType.toUpperCase()} transfer for "${_nameController.text.trim()}" initiated successfully with data migration!',
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
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      Icons.swap_horizontal_circle_rounded,
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
                          'Cross-Branch Transfer Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Migrate Student or Staff data across branches',
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
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Entity Type Selector (Student vs Staff)
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Student Transfer'),
                    selected: _entityType == 'student',
                    onSelected: (selected) {
                      if (selected) setState(() => _entityType = 'student');
                    },
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Staff Transfer'),
                    selected: _entityType == 'staff',
                    onSelected: (selected) {
                      if (selected) setState(() => _entityType = 'staff');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Name & Code
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: '${_entityType == 'student' ? 'Student' : 'Staff'} Full Name *',
                        hintText: 'e.g. Rohan Verma',
                        prefixIcon: const Icon(Icons.person_rounded, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _codeController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'ID / Admission No',
                        hintText: 'STU-2024-089',
                        prefixIcon: const Icon(Icons.badge_rounded, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // From Branch Dropdown
              DropdownButtonFormField<String>(
                initialValue: _fromBranch,
                decoration: InputDecoration(
                  labelText: 'Source Branch (From)',
                  prefixIcon: const Icon(Icons.call_made_rounded, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: branches
                    .map((b) => DropdownMenuItem(
                          value: b.name,
                          child: Text(b.name, style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _fromBranch = val);
                },
              ),
              const SizedBox(height: 14),

              // To Branch Dropdown
              DropdownButtonFormField<String>(
                initialValue: _toBranch,
                decoration: InputDecoration(
                  labelText: 'Target Branch (To)',
                  prefixIcon: const Icon(Icons.call_received_rounded, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: branches
                    .map((b) => DropdownMenuItem(
                          value: b.name,
                          child: Text(b.name, style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _toBranch = val);
                },
              ),
              const SizedBox(height: 14),

              // Transfer Reason
              TextField(
                controller: _reasonController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Transfer Reason & Approval Notes',
                  hintText: 'Parent relocation / Promotion / Administrative transfer...',
                  prefixIcon: const Icon(Icons.note_alt_outlined, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _submitTransfer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: const Text('Initiate Migration Transfer',
                        style: TextStyle(fontWeight: FontWeight.w700)),
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

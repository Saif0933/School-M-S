import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Organization-Wide Report Export Modal Widget
/// Generates consolidated Excel & PDF executive reports
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OrganizationReportExportModal extends ConsumerStatefulWidget {
  const OrganizationReportExportModal({super.key});

  @override
  ConsumerState<OrganizationReportExportModal> createState() =>
      _OrganizationReportExportModalState();
}

class _OrganizationReportExportModalState
    extends ConsumerState<OrganizationReportExportModal> {
  String _format = 'excel'; // 'excel' or 'pdf'
  String _branchFilter = 'ALL Branches';
  String _reportType = 'Comprehensive Executive Audit';

  bool _includeFinancials = true;
  bool _includeAcademicMarks = true;
  bool _includeAttendance = true;
  bool _includeStaffHr = true;

  void _triggerExport() {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Generating ${_format.toUpperCase()} Report...',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '$_reportType for $_branchFilter is ready for download.',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
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
        constraints: const BoxConstraints(maxWidth: 540),
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
                      Icons.file_download_rounded,
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
                          'Export Organization-Wide Consolidated Report',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Generate executive summaries & raw datasets in Excel or PDF',
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
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 14),

              // Format Selector (Excel vs PDF)
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      avatar: const Icon(Icons.table_chart_rounded, size: 16),
                      label: const Text('Excel Sheet (.xlsx)'),
                      selected: _format == 'excel',
                      onSelected: (val) {
                        if (val) setState(() => _format = 'excel');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      avatar: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                      label: const Text('Executive PDF (.pdf)'),
                      selected: _format == 'pdf',
                      onSelected: (val) {
                        if (val) setState(() => _format = 'pdf');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Report Type & Branch Filter Dropdowns
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _reportType,
                      decoration: InputDecoration(
                        labelText: 'Report Category',
                        prefixIcon: const Icon(Icons.category_rounded, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Comprehensive Executive Audit',
                            child: Text('Comprehensive Executive Audit',
                                style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(
                            value: 'Financial Revenue & Fee Collections',
                            child: Text('Financial Revenue & Fees',
                                style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(
                            value: 'Academic & Examination Performance',
                            child: Text('Academic & Exam Marks',
                                style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(
                            value: 'Attendance & Workforce Retention',
                            child: Text('Attendance & HR Workforce',
                                style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _reportType = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _branchFilter,
                      decoration: InputDecoration(
                        labelText: 'Branch Tenant Scope',
                        prefixIcon: const Icon(Icons.domain_rounded, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: 'ALL Branches',
                            child: Text('ALL Branches (Consolidated)',
                                style: TextStyle(fontSize: 12))),
                        ...branches.map((b) => DropdownMenuItem(
                              value: b.name,
                              child: Text(b.name,
                                  style: const TextStyle(fontSize: 12)),
                            )),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _branchFilter = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Included Data Modules Checkboxes
              Text(
                'Include Data Sections:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  FilterChip(
                    label: const Text('Financial Revenue'),
                    selected: _includeFinancials,
                    onSelected: (val) =>
                        setState(() => _includeFinancials = val),
                  ),
                  FilterChip(
                    label: const Text('Academic Marks'),
                    selected: _includeAcademicMarks,
                    onSelected: (val) =>
                        setState(() => _includeAcademicMarks = val),
                  ),
                  FilterChip(
                    label: const Text('Attendance Summary'),
                    selected: _includeAttendance,
                    onSelected: (val) =>
                        setState(() => _includeAttendance = val),
                  ),
                  FilterChip(
                    label: const Text('Staff & HR Roster'),
                    selected: _includeStaffHr,
                    onSelected: (val) => setState(() => _includeStaffHr = val),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _triggerExport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                      'Download ${_format.toUpperCase()} Report',
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
}

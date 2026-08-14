import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Broadcast Organization Announcement Modal Widget
/// Sends real-time announcements across all school branches
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BroadcastAnnouncementModal extends ConsumerStatefulWidget {
  const BroadcastAnnouncementModal({super.key});

  @override
  ConsumerState<BroadcastAnnouncementModal> createState() =>
      _BroadcastAnnouncementModalState();
}

class _BroadcastAnnouncementModalState
    extends ConsumerState<BroadcastAnnouncementModal> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _priority = 'Normal'; // 'Normal', 'Urgent', 'Emergency'
  String _targetBranches = 'ALL Branches (Global Broadcast)';

  bool _sendAppBanner = true;
  bool _sendPushNotif = true;
  bool _sendSmsAlert = false;
  bool _sendEmailAlert = true;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitBroadcast() {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and message.')),
      );
      return;
    }

    final org = ref.read(organizationProvider);

    ref.read(organizationAnnouncementsProvider.notifier).broadcastAnnouncement(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          priority: _priority,
          targetBranches: _targetBranches,
          sentBy: '${org.superAdminName} (Super Admin)',
        );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.campaign_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Announcement "${_titleController.text.trim()}" broadcasted to $_targetBranches!',
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
        constraints: const BoxConstraints(maxWidth: 580),
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
                      Icons.campaign_rounded,
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
                          'Organization Broadcast Announcement',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Send organization-wide directives & alerts across all branch tenants',
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
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 14),

              // Title Input
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Announcement Title *',
                  hintText: 'e.g. CBSE Master Exam Schedule 2026',
                  prefixIcon: const Icon(Icons.title_rounded, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Content / Body Input
              TextField(
                controller: _contentController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Broadcast Message Content *',
                  hintText: 'Detailed directive, guidelines or policy change...',
                  prefixIcon: const Icon(Icons.description_rounded, size: 18),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Target Branches & Priority Level Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _targetBranches,
                      decoration: InputDecoration(
                        labelText: 'Target Branch Scope',
                        prefixIcon: const Icon(Icons.domain_rounded, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'ALL Branches (Global Broadcast)',
                          child: Text('ALL Branches (Global Broadcast)',
                              style: TextStyle(fontSize: 12)),
                        ),
                        ...branches.map((b) => DropdownMenuItem(
                              value: b.name,
                              child: Text(b.name,
                                  style: const TextStyle(fontSize: 12)),
                            )),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _targetBranches = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _priority,
                      decoration: InputDecoration(
                        labelText: 'Priority Level',
                        prefixIcon: const Icon(Icons.flag_rounded, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Normal',
                            child: Text('Normal Priority',
                                style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(
                            value: 'Urgent',
                            child: Text('Urgent Directive',
                                style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(
                            value: 'Emergency',
                            child: Text('Emergency Alert',
                                style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _priority = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Distribution Channels Checkboxes
              Text(
                'Broadcast Channels:',
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
                spacing: 14,
                runSpacing: 6,
                children: [
                  FilterChip(
                    label: const Text('App Banner'),
                    selected: _sendAppBanner,
                    onSelected: (val) => setState(() => _sendAppBanner = val),
                  ),
                  FilterChip(
                    label: const Text('Push Notif'),
                    selected: _sendPushNotif,
                    onSelected: (val) => setState(() => _sendPushNotif = val),
                  ),
                  FilterChip(
                    label: const Text('SMS Alert'),
                    selected: _sendSmsAlert,
                    onSelected: (val) => setState(() => _sendSmsAlert = val),
                  ),
                  FilterChip(
                    label: const Text('Email Alert'),
                    selected: _sendEmailAlert,
                    onSelected: (val) => setState(() => _sendEmailAlert = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                    onPressed: _submitBroadcast,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Dispatch Broadcast Now',
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

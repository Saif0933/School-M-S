import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/enums.dart';
import '../../../auth/providers.dart';
import '../../../organization/providers.dart';

class RolesPermissionsPage extends ConsumerStatefulWidget {
  const RolesPermissionsPage({super.key});

  @override
  ConsumerState<RolesPermissionsPage> createState() => _RolesPermissionsPageState();
}

class _RolesPermissionsPageState extends ConsumerState<RolesPermissionsPage> {
  RbacRole? _selectedRole;
  final List<String> _selectedPermissionCodes = [];
  bool _saving = false;

  final _roleNameController = TextEditingController();
  String _roleScope = 'BRANCH';

  @override
  void dispose() {
    _roleNameController.dispose();
    super.dispose();
  }

  void _onRoleSelected(RbacRole role) {
    setState(() {
      _selectedRole = role;
      _selectedPermissionCodes.clear();
      _selectedPermissionCodes.addAll(role.permissionCodes);
    });
  }

  void _togglePermission(String code) {
    setState(() {
      if (_selectedPermissionCodes.contains(code)) {
        _selectedPermissionCodes.remove(code);
      } else {
        _selectedPermissionCodes.add(code);
      }
    });
  }

  Future<void> _savePermissions() async {
    if (_selectedRole == null) return;
    setState(() => _saving = true);

    try {
      final permissions = ref.read(rbacPermissionsProvider);
      final idsToAssign = permissions
          .where((p) => _selectedPermissionCodes.contains(p.code))
          .map((p) => p.id)
          .toList();

      final success = await ref
          .read(rbacRolesProvider.notifier)
          .assignPermissions(_selectedRole!.id, idsToAssign);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: success ? Colors.green : Colors.red,
            content: Text(success
                ? 'Permissions updated successfully!'
                : 'Failed to update permissions.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _deleteRole() async {
    if (_selectedRole == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete the role "${_selectedRole!.name}"? This action will remove all user assignments and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _saving = true);

    try {
      final success = await ref
          .read(rbacRolesProvider.notifier)
          .deleteRole(_selectedRole!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: success ? Colors.green : Colors.red,
            content: Text(success
                ? 'Role deleted successfully!'
                : 'Failed to delete role.'),
          ),
        );
        if (success) {
          setState(() {
            _selectedRole = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _showCreateRoleDialog(bool isDark) async {
    _roleNameController.clear();
    _roleScope = 'BRANCH';

    final currentUser = ref.read(currentUserProvider);
    final isOrgOrSuperAdmin = currentUser?.role == UserRole.superAdmin ||
        currentUser?.role == UserRole.orgAdmin;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              title: const Text('Create Custom Role', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _roleNameController,
                    decoration: const InputDecoration(
                      labelText: 'Role Name *',
                      hintText: 'e.g. INVENTORY_MANAGER',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  if (isOrgOrSuperAdmin) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _roleScope,
                      decoration: const InputDecoration(
                        labelText: 'Scope',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'BRANCH', child: Text('Branch Scope')),
                        DropdownMenuItem(value: 'ORGANIZATION', child: Text('Organization Scope')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => _roleScope = val);
                        }
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () async {
                    final name = _roleNameController.text.trim().toUpperCase();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Role name is required')),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    final success = await ref
                        .read(rbacRolesProvider.notifier)
                        .createRole(name, _roleScope);

                    if (mounted) {
                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          backgroundColor: success ? Colors.green : Colors.red,
                          content: Text(success
                              ? 'Role created successfully!'
                              : 'Failed to create role.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Create', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final roles = ref.watch(rbacRolesProvider);
    final permissions = ref.watch(rbacPermissionsProvider);

    // Auto-select first role if none is selected
    if (_selectedRole == null && roles.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onRoleSelected(roles.first);
      });
    }

    // Group permissions by module
    final groupedPermissions = <String, List<RbacPermission>>{};
    for (final p in permissions) {
      final mod = p.module ?? 'GENERAL';
      groupedPermissions.putIfAbsent(mod, () => []).add(p);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // Left Sidebar: Roles List
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Roles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showCreateRoleDialog(isDark),
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        tooltip: 'Create custom role',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: roles.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: roles.length,
                          itemBuilder: (context, index) {
                            final role = roles[index];
                            final isSelected = _selectedRole?.id == role.id;
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: isDark ? Colors.white10 : Colors.black12,
                              leading: Icon(
                                role.isSystem
                                    ? Icons.lock_outline
                                    : Icons.admin_panel_settings_outlined,
                                color: isSelected ? AppColors.primary : Colors.grey,
                              ),
                              title: Text(
                                role.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                role.isSystem ? 'System Managed' : 'Custom Role',
                                style: const TextStyle(fontSize: 10),
                              ),
                              onTap: () => _onRoleSelected(role),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Right Pane: Permissions Assign Checkboxes
          Expanded(
            child: _selectedRole == null
                ? const Center(child: Text('Please select a role to configure permissions.'))
                : Column(
                    children: [
                      // Selected Role Subheader
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: isDark ? Colors.white10 : Colors.grey[100],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Configure Permissions for: ${_selectedRole!.name}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Scope: ${_selectedRole!.scope} | Type: ${_selectedRole!.isSystem ? "System (Global)" : "Custom"}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      final allCodes = permissions.map((p) => p.code).toList();
                                      final isAllSelected = _selectedPermissionCodes.length == allCodes.length;
                                      _selectedPermissionCodes.clear();
                                      if (!isAllSelected) {
                                        _selectedPermissionCodes.addAll(allCodes);
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    _selectedPermissionCodes.length == permissions.length
                                        ? Icons.deselect_outlined
                                        : Icons.select_all_outlined,
                                    size: 16,
                                  ),
                                  label: Text(
                                    _selectedPermissionCodes.length == permissions.length
                                        ? 'Deselect All'
                                        : 'Select All',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (!_selectedRole!.isSystem) ...[
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    ),
                                    onPressed: _saving ? null : _deleteRole,
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: const Text(
                                      'Delete Role',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                  onPressed: _saving ? null : _savePermissions,
                                  icon: _saving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save, color: Colors.white, size: 16),
                                  label: const Text(
                                    'Save Permissions',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Permissions List Scrollable
                      Expanded(
                        child: permissions.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView(
                                padding: const EdgeInsets.all(16),
                                children: groupedPermissions.entries.map((entry) {
                                  final moduleName = entry.key;
                                  final modulePerms = entry.value;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      title: Text(
                                        moduleName.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      children: modulePerms.map((perm) {
                                        final isChecked = _selectedPermissionCodes.contains(perm.code);
                                        return CheckboxListTile(
                                          title: Text(
                                            perm.code,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: perm.description != null
                                              ? Text(perm.description!, style: const TextStyle(fontSize: 11))
                                              : null,
                                          value: isChecked,
                                          activeColor: AppColors.primary,
                                          onChanged: (val) => _togglePermission(perm.code),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/enums/enums.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Sidebar Navigation — Collapsible sidebar for
/// desktop/tablet with module-based navigation
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class SidebarItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String? badge;
  final List<SidebarItem>? children;

  const SidebarItem({
    required this.id,
    required this.label,
    required this.icon,
    this.activeIcon,
    this.badge,
    this.children,
  });
}

class SidebarNavigation extends StatefulWidget {
  final List<SidebarItem> items;
  final String selectedId;
  final ValueChanged<String> onItemSelected;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final String organizationName;
  final String branchName;
  final String? userAvatar;
  final String userName;
  final UserRole userRole;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogout;

  const SidebarNavigation({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onItemSelected,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.organizationName,
    required this.branchName,
    this.userAvatar,
    required this.userName,
    required this.userRole,
    this.onProfileTap,
    this.onLogout,
  });

  @override
  State<SidebarNavigation> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final Set<String> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppSpacing.animNormal,
    );
    if (!widget.isCollapsed) _animController.forward();
  }

  @override
  void didUpdateWidget(SidebarNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      widget.isCollapsed ? _animController.reverse() : _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final width = widget.isCollapsed
        ? AppSpacing.sidebarCollapsedWidth
        : AppSpacing.sidebarWidth;

    return AnimatedContainer(
      duration: AppSpacing.animNormal,
      curve: Curves.easeOutCubic,
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // ─── Logo / Brand ────────────────────
          _buildHeader(isDark),

          const Divider(height: 1),

          // ─── Navigation Items ────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              children: widget.items.map((item) {
                if (item.children != null && item.children!.isNotEmpty) {
                  return _buildExpandableItem(item, isDark);
                }
                return _buildNavItem(item, isDark);
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // ─── User Profile ────────────────────
          _buildUserSection(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      height: AppSpacing.topBarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 12 : 16,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (!widget.isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Symbosys SMS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    widget.branchName,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          _buildCollapseButton(isDark),
        ],
      ),
    );
  }

  Widget _buildCollapseButton(bool isDark) {
    return IconButton(
      onPressed: widget.onToggleCollapse,
      icon: AnimatedRotation(
        duration: AppSpacing.animNormal,
        turns: widget.isCollapsed ? 0.5 : 0,
        child: Icon(
          Icons.chevron_left_rounded,
          size: 20,
          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        ),
      ),
      tooltip: widget.isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
      splashRadius: 18,
      style: IconButton.styleFrom(
        fixedSize: const Size(32, 32),
      ),
    );
  }

  Widget _buildNavItem(SidebarItem item, bool isDark) {
    final isSelected = widget.selectedId == item.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onItemSelected(item.id),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: AppSpacing.animFast,
            height: AppSpacing.sidebarItemHeight,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 0 : 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primarySurface
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: widget.isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableItem(SidebarItem item, bool isDark) {
    final isExpanded = _expandedGroups.contains(item.id);
    final hasActiveChild = item.children?.any((c) => c.id == widget.selectedId) ?? false;

    if (widget.isCollapsed) {
      return _buildNavItem(item, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedGroups.remove(item.id);
                  } else {
                    _expandedGroups.add(item.id);
                  }
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: AppSpacing.sidebarItemHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: hasActiveChild
                      ? AppColors.primarySurface.withValues(alpha: 0.5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: hasActiveChild
                          ? AppColors.primary
                          : isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                              hasActiveChild ? FontWeight.w600 : FontWeight.w500,
                          color: hasActiveChild
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: AppSpacing.animFast,
                      turns: isExpanded ? 0.25 : 0,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: AppSpacing.animFast,
          firstChild: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: item.children!.map((child) {
                return _buildNavItem(child, isDark);
              }).toList(),
            ),
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState:
              isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ],
    );
  }

  Widget _buildUserSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(widget.isCollapsed ? 10 : 14),
      child: widget.isCollapsed
          ? Center(
              child: GestureDetector(
                onTap: widget.onProfileTap,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    widget.userName.isNotEmpty
                        ? widget.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    widget.userName.isNotEmpty
                        ? widget.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.userRole.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onLogout,
                  icon: Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  tooltip: 'Logout',
                  splashRadius: 16,
                ),
              ],
            ),
    );
  }
}

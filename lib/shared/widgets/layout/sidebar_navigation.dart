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

          // ─── Collapse / Expand Toggle Action ──
          _buildCollapseToggleFooter(isDark),

          const Divider(height: 1),

          // ─── User Profile ────────────────────
          _buildUserSection(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    if (widget.isCollapsed) {
      return Container(
        height: AppSpacing.topBarHeight,
        alignment: Alignment.center,
        child: Tooltip(
          message: 'Expand sidebar',
          child: InkWell(
            onTap: widget.onToggleCollapse,
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 12,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: AppSpacing.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 4),
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
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  Widget _buildCollapseToggleFooter(bool isDark) {
    if (widget.isCollapsed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Tooltip(
          message: 'Expand sidebar',
          preferBelow: false,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onToggleCollapse,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 44,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard.withValues(alpha: 0.6)
                      : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: const Icon(
                  Icons.keyboard_double_arrow_right_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onToggleCollapse,
        hoverColor: isDark ? AppColors.darkCardHover : AppColors.lightCardHover,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Icon(
                  Icons.keyboard_double_arrow_left_rounded,
                  size: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Collapse Sidebar',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard
                      : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  'Ctrl+B',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(SidebarItem item, bool isDark) {
    final isSelected = widget.selectedId == item.id;

    Widget navItemContent = AnimatedContainer(
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
    );

    if (widget.isCollapsed) {
      navItemContent = Tooltip(
        message: item.label,
        waitDuration: const Duration(milliseconds: 200),
        child: navItemContent,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onItemSelected(item.id),
          borderRadius: BorderRadius.circular(10),
          child: navItemContent,
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
              child: Tooltip(
                message: '${widget.userName} (${widget.userRole.label})',
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

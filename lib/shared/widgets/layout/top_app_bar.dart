import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../features/auth/domain/entities/user_entity.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Top App Bar — Global top bar with search, branch
/// selector, notifications, and user menu
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TopAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<String> breadcrumbs;
  final UserEntity? user;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onThemeToggle;
  final ValueChanged<String>? onBranchChanged;
  final bool isDarkMode;

  const TopAppBarWidget({
    super.key,
    required this.title,
    this.breadcrumbs = const [],
    this.user,
    this.onMenuTap,
    this.onNotificationTap,
    this.onThemeToggle,
    this.onBranchChanged,
    this.isDarkMode = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.topBarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isMobile = context.isMobile;

    return Container(
      height: AppSpacing.topBarHeight,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Menu button (mobile only)
          if (isMobile)
            IconButton(
              onPressed: onMenuTap,
              icon: Icon(
                Icons.menu_rounded,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),

          // Title & Breadcrumbs
          if (!isMobile) ...[
            if (breadcrumbs.isNotEmpty)
              _buildBreadcrumbs(isDark)
            else
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
          ],

          const Spacer(),

          // ─── Search Bar ────────────────────────
          if (!isMobile)
            Container(
              width: 260,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search anything...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '⌘K',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 12),

          // ─── Branch Selector ───────────────────
          if (user != null && user!.branchAccess.length > 1 && !isMobile)
            _buildBranchSelector(isDark),

          const SizedBox(width: 4),

          // ─── Theme Toggle ──────────────────────
          IconButton(
            onPressed: onThemeToggle,
            icon: AnimatedSwitcher(
              duration: AppSpacing.animFast,
              child: Icon(
                isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                key: ValueKey(isDarkMode),
                size: 20,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            tooltip: isDarkMode ? 'Light mode' : 'Dark mode',
            splashRadius: 18,
          ),

          // ─── Notifications ─────────────────────
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationTap,
                icon: Icon(
                  Icons.notifications_none_rounded,
                  size: 22,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                tooltip: 'Notifications',
                splashRadius: 18,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs(bool isDark) {
    return Row(
      children: [
        for (int i = 0; i < breadcrumbs.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          Text(
            breadcrumbs[i],
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  i == breadcrumbs.length - 1 ? FontWeight.w600 : FontWeight.w400,
              color: i == breadcrumbs.length - 1
                  ? (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary)
                  : (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBranchSelector(bool isDark) {
    return PopupMenuButton<String>(
      tooltip: 'Switch branch',
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: onBranchChanged,
      itemBuilder: (context) {
        return user!.branchAccess.map((branch) {
          final isActive = branch.branchId == user!.activeBranchId;
          return PopupMenuItem<String>(
            value: branch.branchId,
            child: Row(
              children: [
                Icon(
                  isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: isActive
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.branchName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      Text(
                        branch.branchCode,
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
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                user?.activeBranch?.branchCode ?? 'Select Branch',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

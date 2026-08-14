import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/enums/enums.dart';
import '../../../features/auth/domain/entities/user_entity.dart';
import 'sidebar_navigation.dart';
import 'top_app_bar.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Responsive Scaffold — Adapts layout to screen size
/// Desktop: Sidebar + Content
/// Tablet: Collapsible sidebar + Content
/// Mobile: Drawer + Bottom nav + Content
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ResponsiveScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final List<String> breadcrumbs;
  final List<SidebarItem> sidebarItems;
  final String selectedItemId;
  final ValueChanged<String> onItemSelected;
  final UserEntity? user;
  final VoidCallback? onLogout;
  final VoidCallback? onThemeToggle;
  final ValueChanged<String>? onBranchChanged;
  final bool isDarkMode;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.breadcrumbs = const [],
    required this.sidebarItems,
    required this.selectedItemId,
    required this.onItemSelected,
    this.user,
    this.onLogout,
    this.onThemeToggle,
    this.onBranchChanged,
    this.isDarkMode = true,
    this.floatingActionButton,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  bool _sidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    if (isMobile) {
      return _buildMobileLayout();
    }

    return _buildDesktopLayout(isTablet);
  }

  Widget _buildDesktopLayout(bool isTablet) {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          // ─── Sidebar ─────────────────────────
          SidebarNavigation(
            items: widget.sidebarItems,
            selectedId: widget.selectedItemId,
            onItemSelected: widget.onItemSelected,
            isCollapsed: _sidebarCollapsed || isTablet,
            onToggleCollapse: () {
              setState(() => _sidebarCollapsed = !_sidebarCollapsed);
            },
            organizationName:
                widget.user?.organizationName ?? 'Organization',
            branchName:
                widget.user?.activeBranch?.branchName ?? 'Select Branch',
            userName: widget.user?.name ?? 'User',
            userRole: widget.user?.role ?? UserRole.branchAdmin,
            onLogout: widget.onLogout,
          ),

          // ─── Main Content ────────────────────
          Expanded(
            child: Column(
              children: [
                TopAppBarWidget(
                  title: widget.title,
                  breadcrumbs: widget.breadcrumbs,
                  user: widget.user,
                  onThemeToggle: widget.onThemeToggle,
                  onBranchChanged: widget.onBranchChanged,
                  isDarkMode: widget.isDarkMode,
                  onNotificationTap: () {},
                ),
                Expanded(
                  child: widget.body,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: TopAppBarWidget(
        title: widget.title,
        user: widget.user,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onThemeToggle: widget.onThemeToggle,
        onBranchChanged: widget.onBranchChanged,
        isDarkMode: widget.isDarkMode,
        onNotificationTap: () {},
      ),
      drawer: SizedBox(
        width: AppSpacing.sidebarWidth,
        child: Drawer(
          child: SidebarNavigation(
            items: widget.sidebarItems,
            selectedId: widget.selectedItemId,
            onItemSelected: (id) {
              widget.onItemSelected(id);
              Navigator.of(context).pop(); // close drawer
            },
            isCollapsed: false,
            onToggleCollapse: () {},
            organizationName:
                widget.user?.organizationName ?? 'Organization',
            branchName:
                widget.user?.activeBranch?.branchName ?? 'Select Branch',
            userName: widget.user?.name ?? 'User',
            userRole: widget.user?.role ?? UserRole.branchAdmin,
            onLogout: () {
              Navigator.of(context).pop();
              widget.onLogout?.call();
            },
          ),
        ),
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

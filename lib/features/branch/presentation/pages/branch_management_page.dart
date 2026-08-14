import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../organization/data/repositories/mock_organization_repository.dart';
import '../../domain/entities/branch_entity.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Branch Management Page (School Operational View)
/// Manages school branches, module toggles, capacities
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BranchManagementPage extends StatefulWidget {
  const BranchManagementPage({super.key});

  @override
  State<BranchManagementPage> createState() => _BranchManagementPageState();
}

class _BranchManagementPageState extends State<BranchManagementPage> {
  final _repo = MockOrganizationRepository();
  List<BranchEntity> _branches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    final branches = await _repo.getBranches('ORG-001');
    if (mounted) {
      setState(() {
        _branches = branches;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Branch Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure independent school branches, module access, and staff/student limits.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                label: const Text('Add Branch'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ─── Branch Cards Grid ────────────────
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive(mobile: 1, desktop: 3),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: context.responsive(mobile: 1.2, desktop: 1.1),
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _branches.length,
            itemBuilder: (context, index) {
              final branch = _branches[index];
              return _buildBranchCard(branch, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(BranchEntity branch, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Code: ${branch.code} • ${branch.affiliationBoard}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  branch.status.label,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow('Principal', branch.principalName, isDark),
          const SizedBox(height: 8),
          _buildInfoRow('Location', '${branch.city}, ${branch.state}', isDark),
          const SizedBox(height: 8),
          _buildInfoRow('Academic Year', branch.currentAcademicYear, isDark),
          const SizedBox(height: 16),
          Text(
            'Capacity Usage',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: branch.activeStudentCount / branch.maxStudentCapacity,
            backgroundColor:
                isDark ? AppColors.darkBorder : AppColors.lightBorder,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${branch.activeStudentCount} / ${branch.maxStudentCapacity} Students',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
              Text(
                '${((branch.activeStudentCount / branch.maxStudentCapacity) * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Configure Modules'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}

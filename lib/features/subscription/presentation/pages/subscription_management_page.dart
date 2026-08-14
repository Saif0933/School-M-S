import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/cards/glass_card.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SaaS Subscription & Billing Dashboard Page
/// Platform Super Admin view for subscriptions, MRR,
/// billing cycles, tenant plans, and usage limits.
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({super.key});

  @override
  State<SubscriptionManagementPage> createState() =>
      _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState
    extends State<SubscriptionManagementPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header Card ───────────────────────
          _buildPlatformHeader(isDark),
          const SizedBox(height: 24),

          // ─── Metric Cards ──────────────────────
          _buildMetricCards(isDark),
          const SizedBox(height: 24),

          // ─── SaaS Plans Breakdown ──────────────
          _buildSaaSPlans(isDark),
          const SizedBox(height: 24),

          // ─── Active Subscriptions & Invoices ───
          _buildBillingHistoryTable(isDark),
        ],
      ),
    );
  }

  Widget _buildPlatformHeader(bool isDark) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SaaS Subscription & Billing Master',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'System Active • Auto-Renewal On',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage organization plans, track Monthly Recurring Revenue (MRR), and view automated billing invoices.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_card_rounded, size: 18),
            label: const Text('Upgrade Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Monthly Recurring Revenue',
            value: '₹14.2L',
            subtitle: '+18.5% from last month',
            icon: Icons.trending_up_rounded,
            gradient: AppColors.statRevenue,
            trend: '+18.5%',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: 'Active Organizations',
            value: '42 Trusts',
            subtitle: '128 total branches',
            icon: Icons.business_rounded,
            gradient: AppColors.statStudents,
            trend: '+4 New',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: 'Licensed User Seats',
            value: '84,500',
            subtitle: '89.2% capacity filled',
            icon: Icons.groups_rounded,
            gradient: AppColors.statStaff,
            trend: '+5.2%',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: 'Platform Health & SLA',
            value: '99.98%',
            subtitle: 'Zero downtime past 90 days',
            icon: Icons.verified_user_rounded,
            gradient: AppColors.statAttendance,
            trend: 'Optimal',
            trendUp: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSaaSPlans(bool isDark) {
    final plans = [
      _PlanTier('Basic', '₹9,999/mo', 'Up to 2 Branches', '500 Students/branch',
          AppColors.primary, 14),
      _PlanTier('Standard', '₹24,999/mo', 'Up to 5 Branches',
          '1,500 Students/branch', AppColors.accentCyan, 18),
      _PlanTier('Premium', '₹49,999/mo', 'Up to 10 Branches',
          '3,000 Students/branch', AppColors.secondary, 8),
      _PlanTier('Enterprise', 'Custom Tier', 'Unlimited Branches',
          'Custom Limits + White-Label', AppColors.accentAmber, 2),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SaaS Subscription Tiers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: plans.map((plan) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: plan.color,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: plan.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${plan.activeOrgs} Orgs',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: plan.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        plan.price,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• ${plan.branches}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• ${plan.students}',
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
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBillingHistoryTable(bool isDark) {
    final invoices = [
      _Invoice('INV-2026-0891', 'Sunrise Education Trust', 'Enterprise Plan',
          '₹1,49,997', '10 Aug 2026', 'Paid', AppColors.secondary),
      _Invoice('INV-2026-0890', 'St. Xavier Group of Schools', 'Premium Plan',
          '₹49,999', '08 Aug 2026', 'Paid', AppColors.secondary),
      _Invoice('INV-2026-0889', 'DPS Educational Society', 'Premium Plan',
          '₹49,999', '05 Aug 2026', 'Paid', AppColors.secondary),
      _Invoice('INV-2026-0888', 'Modern Public Schools Chain', 'Standard Plan',
          '₹24,999', '01 Aug 2026', 'Pending', AppColors.warning),
      _Invoice('INV-2026-0887', 'Global Heritage Academy', 'Basic Plan',
          '₹9,999', '28 Jul 2026', 'Paid', AppColors.secondary),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Billing Invoices & Payouts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Export GST Statement'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Invoice ID')),
                DataColumn(label: Text('Organization')),
                DataColumn(label: Text('Plan Tier')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Billing Date')),
                DataColumn(label: Text('Payment Status')),
                DataColumn(label: Text('Action')),
              ],
              rows: invoices.map((inv) {
                return DataRow(
                  cells: [
                    DataCell(Text(inv.id,
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(inv.org)),
                    DataCell(Text(inv.plan)),
                    DataCell(Text(inv.amount,
                        style: const TextStyle(fontWeight: FontWeight.w700))),
                    DataCell(Text(inv.date)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: inv.statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          inv.status,
                          style: TextStyle(
                            color: inv.statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf_rounded,
                            size: 18, color: AppColors.primary),
                        onPressed: () {},
                        tooltip: 'Download Invoice PDF',
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanTier {
  final String name;
  final String price;
  final String branches;
  final String students;
  final Color color;
  final int activeOrgs;

  _PlanTier(this.name, this.price, this.branches, this.students, this.color,
      this.activeOrgs);
}

class _Invoice {
  final String id;
  final String org;
  final String plan;
  final String amount;
  final String date;
  final String status;
  final Color statusColor;

  _Invoice(this.id, this.org, this.plan, this.amount, this.date, this.status,
      this.statusColor);
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../../academic/providers.dart';
import '../../../staff/providers.dart';
import '../../../organization/providers.dart';
import '../../providers.dart';

class SubscriptionBillingPage extends ConsumerStatefulWidget {
  const SubscriptionBillingPage({super.key});

  @override
  ConsumerState<SubscriptionBillingPage> createState() => _SubscriptionBillingPageState();
}

class _SubscriptionBillingPageState extends ConsumerState<SubscriptionBillingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Branding Controllers
  final _domainCtrl = TextEditingController(text: 'sunrise.symbosys.edu');
  String _selectedCycle = 'Monthly';
  String _selectedColor = '#4F46E5';

  // Gateway choice
  String _selectedGateway = 'Stripe';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _domainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final branchesList = ref.watch(organizationBranchesProvider);

    // Count students and staff across ALL branches for consolidated billing
    final allStudentsCount = ref.watch(academicStudentsProvider).length;
    final allStaffCount = ref.watch(staffProvider).length;
    final userChargedAmt = (allStudentsCount * 0.50) + (allStaffCount * 1.00);

    final plans = ref.watch(subscriptionPlansProvider);
    final config = ref.watch(orgBrandingProvider);
    final invoices = ref.watch(orgInvoicesProvider);

    // Identify if there is a failed invoice in grace period
    final hasFailedInvoice = invoices.any((inv) => inv.status.contains('Failed'));

    return Scaffold(
      body: Column(
        children: [
          // Subheader
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SaaS Subscription & Invoices: ${user?.organizationName ?? "Consolidated Org"}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Billing status: ${hasFailedInvoice ? "Dunning active (Grace period)" : "All active plans fully paid"}',
                        style: TextStyle(fontSize: 11, color: hasFailedInvoice ? Colors.red : Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  'White-label: ${config.whiteLabelDomain}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 11),
                ),
              ],
            ),
          ),

          // Grace period alert box
          if (hasFailedInvoice)
            Container(
              width: double.infinity,
              color: Colors.red.shade900,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '⚠️ DUNNING SUSPENSION ALERT: Org invoice INV-ORG-2026-002 payment failed. Grace period active for 5 days. Delhi & Mumbai campus domains face automatic lockouts on 2026-08-24.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),

          // Tab Bar
          Container(
            color: isDark ? Colors.black12 : Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_customize_rounded, size: 16), text: 'Mix-and-Match Plans & Pricing'),
                Tab(icon: Icon(Icons.auto_awesome_rounded, size: 16), text: 'Onboarding & White-label setup'),
                Tab(icon: Icon(Icons.payment_rounded, size: 16), text: 'Payment Gateways & Invoices'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlansTab(plans, config, allStudentsCount, allStaffCount, userChargedAmt, branchesList),
                _buildBrandingTab(config),
                _buildInvoicesTab(invoices),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Mix-and-match Plans & user charging
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPlansTab(
    List<SubscriptionPlan> plans,
    OrgBrandingConfig config,
    int studentsCount,
    int staffCount,
    double userCharge,
    List<dynamic> branches,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub plans pricing grid
          const Text('🏢 Select Organization-wide base plans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: plans.map((p) {
              return Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
                        const SizedBox(height: 6),
                        Text('\$${p.basePrice}/mo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
                        Text(p.description, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        const Divider(height: 20),
                        const Text('Modules Included:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
                        ...p.modules.map((m) => Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, size: 10, color: Colors.teal),
                                const SizedBox(width: 4),
                                Text(m, style: const TextStyle(fontSize: 8)),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 36),

          // User count calculation
          const Text('📊 Dynamic Consolidated User Count Pricing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Students across all campuses: $studentsCount (\$0.50/student)', style: const TextStyle(fontSize: 11)),
                      Text('Total Staff across all campuses: $staffCount (\$1.00/staff)', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Consolidated User Charge:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('\$${userCharge.toStringAsFixed(2)} / month', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 36),

          // Mix and match branch configuration
          const Text('🔀 Branch Mix-and-Match Plan Assignment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final br = branches[index];
              final currentPlan = config.branchPlanAssignments[br.id] ?? 'Standard';

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.domain_rounded, color: Colors.indigo),
                  title: Text(br.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: Text('Campus code: ${br.code} | City: ${br.city}'),
                  trailing: DropdownButton<String>(
                    value: currentPlan,
                    style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(value: 'Basic', child: Text('Basic Plan')),
                      DropdownMenuItem(value: 'Standard', child: Text('Standard Plan')),
                      DropdownMenuItem(value: 'Premium', child: Text('Premium Plan')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(orgBrandingProvider.notifier).assignBranchPlan(br.id, val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✓ Delhi/Mumbai plan assignment updated to $val.')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Custom Branding & Onboarding Wizard
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildBrandingTab(OrgBrandingConfig config) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✏️ White-Label Settings & Branding Wizard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: _domainCtrl,
            decoration: const InputDecoration(labelText: 'Custom Domain (e.g. school.edu)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCycle,
            decoration: const InputDecoration(labelText: 'Billing Cycle selection'),
            items: const [
              DropdownMenuItem(value: 'Monthly', child: Text('Monthly billing cycle')),
              DropdownMenuItem(value: 'Quarterly', child: Text('Quarterly cycle (5% Discount)')),
              DropdownMenuItem(value: 'Yearly', child: Text('Yearly cycle (15% Discount)')),
            ],
            onChanged: (val) => setState(() => _selectedCycle = val ?? 'Monthly'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedColor,
            decoration: const InputDecoration(labelText: 'Dashboard Primary Color Brand'),
            items: const [
              DropdownMenuItem(value: '#4F46E5', child: Text('Classic Indigo Blue (#4F46E5)')),
              DropdownMenuItem(value: '#0D9488', child: Text('Infirmary Emerald Teal (#0D9488)')),
              DropdownMenuItem(value: '#D97706', child: Text('Amber Gold (#D97706)')),
            ],
            onChanged: (val) => setState(() => _selectedColor = val ?? '#4F46E5'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final updated = config.copyWith(
                  whiteLabelDomain: _domainCtrl.text,
                  billingCycle: _selectedCycle,
                  primaryColorHex: _selectedColor,
                );
                ref.read(orgBrandingProvider.notifier).updateConfig(updated);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ White-label domain mapped. Custom theme applied!')),
                );
              },
              child: const Text('Save Custom Branding', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Payment Gateways & Invoices
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildInvoicesTab(List<OrgInvoice> invoices) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment gateway simulator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💳 Payment Gateway Integration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGateway,
                  decoration: const InputDecoration(labelText: 'Payment Gateway Processor'),
                  items: const [
                    DropdownMenuItem(value: 'Stripe', child: Text('Stripe Gateway')),
                    DropdownMenuItem(value: 'Razorpay', child: Text('Razorpay (UPI / Cards)')),
                    DropdownMenuItem(value: 'PayPal', child: Text('PayPal Checkout')),
                  ],
                  onChanged: (val) => setState(() => _selectedGateway = val ?? 'Stripe'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () {
                      final failed = invoices.firstWhere((inv) => inv.status.contains('Failed'));
                      ref.read(orgInvoicesProvider.notifier).payInvoice(failed.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✓ Payment of \$${(failed.baseAmt + failed.userAmt).toStringAsFixed(2)} completed successfully via $_selectedGateway!')),
                      );
                    },
                    child: const Text('Process Delinquent Invoice Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Org Invoices logs list
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📋 Consolidated Organization Invoices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                ...invoices.map((inv) {
                  final totalAmt = inv.baseAmt + inv.userAmt;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        inv.status == 'Paid' ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                        color: inv.status == 'Paid' ? Colors.green : Colors.red,
                      ),
                      title: Text(inv.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      subtitle: Text('Billing Period: ${inv.date} | Cycle: ${inv.cycle}\nBase: \$${inv.baseAmt} + Users: \$${inv.userAmt}\nStatus: ${inv.status}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\$${totalAmt.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.download_rounded, size: 16, color: Colors.teal),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✓ Starting invoice PDF compilation download...')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

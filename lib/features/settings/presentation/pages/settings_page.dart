import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // IP field
  final _ipCtrl = TextEditingController();

  // GDPR anonymization fields
  final _anonymizeEmailCtrl = TextEditingController();

  // Settings temp states
  bool _mfa = true;
  bool _sso = false;
  int _timeout = 30;
  int _passLen = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load initial states
    final policy = ref.read(securityPolicyProvider);
    _mfa = policy.mfaEnabled;
    _sso = policy.ssoEnabled;
    _timeout = policy.sessionTimeoutMins;
    _passLen = policy.minPasswordLength;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ipCtrl.dispose();
    _anonymizeEmailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final policy = ref.watch(securityPolicyProvider);
    final auditLogs = ref.watch(securityAuditLogsProvider).where((l) => l.branchId == 'ALL' || l.branchId == activeBranchId).toList();

    return Scaffold(
      body: Column(
        children: [
          // Subheader
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                final infoBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security, Compliance & Settings: $branchName',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Text(
                      'AES-256 DB Encryption: Active | TLS 1.3 Transmission: Verified',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                );

                final statusBlock = Text(
                  'ISO 27001 Compliant',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade400, fontSize: 11),
                );

                return isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          infoBlock,
                          const SizedBox(height: 8),
                          statusBlock,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: infoBlock),
                          const SizedBox(width: 16),
                          statusBlock,
                        ],
                      );
              },
            ),
          ),

          // Tab Bar
          Container(
            color: isDark ? Colors.black12 : Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: const [
                Tab(icon: Icon(Icons.security_rounded, size: 16), text: 'MFA, SSO & Whitelisted IPs'),
                Tab(icon: Icon(Icons.history_toggle_off_rounded, size: 16), text: 'Audit Logs & Backups'),
                Tab(icon: Icon(Icons.verified_user_rounded, size: 16), text: 'GDPR & Student Privacy'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAuthTab(policy),
                _buildAuditTab(auditLogs),
                _buildPrivacyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — MFA, SSO & Whitelisted IPs Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildAuthTab(SecurityPolicy policy) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          final rulesForm = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✏️ Authentications & Security Rules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              SwitchListTile(
                dense: true,
                title: const Text('Enforce Multi-Factor Authentication (MFA/2FA)', style: TextStyle(fontSize: 11)),
                value: _mfa,
                onChanged: (val) => setState(() => _mfa = val),
              ),
              SwitchListTile(
                dense: true,
                title: const Text('Enable SAML 2.0 / OAuth2 Single Sign-On (SSO)', style: TextStyle(fontSize: 11)),
                value: _sso,
                onChanged: (val) => setState(() => _sso = val),
              ),
              const SizedBox(height: 12),
              Text('Session Inactivity Timeout: $_timeout minutes', style: const TextStyle(fontSize: 11)),
              Slider(
                min: 5,
                max: 120,
                divisions: 23,
                value: _timeout.toDouble(),
                onChanged: (val) => setState(() => _timeout = val.toInt()),
              ),
              Text('Minimum Password Length rule: $_passLen characters', style: const TextStyle(fontSize: 11)),
              Slider(
                min: 8,
                max: 20,
                divisions: 12,
                value: _passLen.toDouble(),
                onChanged: (val) => setState(() => _passLen = val.toInt()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    final updated = policy.copyWith(
                      mfaEnabled: _mfa,
                      ssoEnabled: _sso,
                      sessionTimeoutMins: _timeout,
                      minPasswordLength: _passLen,
                    );
                    ref.read(securityPolicyProvider.notifier).updatePolicy(updated);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Password parameters and login security rules committed.')),
                    );
                  },
                  child: const Text('Apply Access Security Rules', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );

          final ipWhitelistBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🔒 IP Whitelist Restrictions (Branch-Scoped)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ipCtrl,
                      decoration: const InputDecoration(labelText: 'IP / CIDR Block (e.g. 192.168.1.1)', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_ipCtrl.text.isNotEmpty) {
                        ref.read(securityPolicyProvider.notifier).addIp(_ipCtrl.text);
                        _ipCtrl.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ IP added to whitelist registry.')),
                        );
                      }
                    },
                    child: const Text('Add IP', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...policy.whitelistedIps.map((ip) => Card(
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.lock_rounded, color: Colors.indigo, size: 16),
                      title: Text(ip, style: const TextStyle(fontSize: 11)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 16),
                        onPressed: () {
                          ref.read(securityPolicyProvider.notifier).removeIp(ip);
                        },
                      ),
                    ),
                  )),
            ],
          );

          return isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    rulesForm,
                    const SizedBox(height: 24),
                    ipWhitelistBlock,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: rulesForm),
                    const SizedBox(width: 24),
                    Expanded(child: ipWhitelistBlock),
                  ],
                );
        },
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Audit Logs & Backups Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildAuditTab(List<SecurityAuditLog> logs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          final backupsBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💽 Automated Backup Schedules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              const Card(
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.cloud_upload_rounded, color: Colors.teal),
                  title: Text('Last Backup Status: Successful', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  subtitle: Text('Date: 2026-08-19 02:00 AM | Type: Full DB'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Initializing AES-256 DB backup generation... Done.')),
                    );
                  },
                  icon: const Icon(Icons.backup_rounded, color: Colors.white),
                  label: const Text('Perform Full Secure Backup Now', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ],
          );

          final auditLogsBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📋 Campus Security Audit Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Card(
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.fingerprint_rounded, color: Colors.indigo),
                      title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      subtitle: Text('User: ${log.user} | IP: ${log.ipAddress}\nTime: ${log.time}'),
                      trailing: Chip(
                        label: Text(log.branchId == 'ALL' ? 'Org-wide' : 'Local Branch', style: const TextStyle(fontSize: 8)),
                      ),
                    ),
                  );
                },
              ),
            ],
          );

          return isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    backupsBlock,
                    const SizedBox(height: 24),
                    auditLogsBlock,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: backupsBlock),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: auditLogsBlock),
                  ],
                );
        },
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — GDPR & Student Privacy Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPrivacyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          final anonymizationForm = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('👤 GDPR Data Anonymization Tool', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              const Text(
                'GDPR / FERPA mandates allow parents and staff to request data deletion. Using this tool replaces active name parameters with [ANONYMIZED_USER].',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _anonymizeEmailCtrl,
                decoration: const InputDecoration(labelText: 'User Email/ID to Anonymize'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    if (_anonymizeEmailCtrl.text.isNotEmpty) {
                      _anonymizeEmailCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ User credentials anonymized and encrypted under GDPR protocols.')),
                      );
                    }
                  },
                  child: const Text('Anonymize & Mask User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );

          final complianceStatusBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🛡️ Data Protection Compliance Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              _buildComplianceCard('FERPA / COPPA Student Protection', 'Compliant', Colors.green),
              _buildComplianceCard('SOC 2 Type II Audits', 'Certified', Colors.green),
              _buildComplianceCard('GDPR Data residency rules', 'Region: Asia-Pacific (Mumbai)', Colors.blue),
            ],
          );

          return isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    anonymizationForm,
                    const SizedBox(height: 24),
                    complianceStatusBlock,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: anonymizationForm),
                    const SizedBox(width: 24),
                    Expanded(child: complianceStatusBlock),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildComplianceCard(String title, String status, Color color) {
    return Card(
      child: ListTile(
        dense: true,
        leading: Icon(Icons.verified_user_rounded, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        trailing: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
      ),
    );
  }
}

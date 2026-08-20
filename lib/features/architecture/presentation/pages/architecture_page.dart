import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class TechnicalArchitecturePage extends ConsumerStatefulWidget {
  const TechnicalArchitecturePage({super.key});

  @override
  ConsumerState<TechnicalArchitecturePage> createState() =>
      _TechnicalArchitecturePageState();
}

class _TechnicalArchitecturePageState
    extends ConsumerState<TechnicalArchitecturePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // RLS Simulation states
  String _selectedRlsBranch = 'BR-001';
  bool _executingRls = false;
  String _transpiledSql = '';
  List<Map<String, String>> _rlsResults = [];

  // DevOps states
  bool _runningCiCd = false;
  List<String> _ciCdSteps = [];
  String _activeNode = 'Blue';
  final _webhookUrlCtrl = TextEditingController();
  final _gqlCtrl = TextEditingController(
    text:
        'query {\n  students(branch: "BR-001") {\n    name\n    enrollment\n  }\n}',
  );
  String _gqlResult = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _webhookUrlCtrl.dispose();
    _gqlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final jwt = ref.watch(jwtClaimsProvider);
    final pods = ref.watch(k8sPodsProvider);
    final webhooks = ref.watch(orgWebhooksProvider);

    return Scaffold(
      body: Column(
        children: [
          // Subheader
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Technical Architecture & Orchestration: $branchName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Text(
                    'Kubernetes Cluster: Healthy | Multi-Tenant Data Isolation: Strict RLS',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );

              final statusWidget = Text(
                'Postgres RLS Enabled',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade400,
                  fontSize: 11,
                ),
              );

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDark
                    ? Colors.white10
                    : Colors.grey.withValues(alpha: 0.05),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleWidget,
                          const SizedBox(height: 8),
                          statusWidget,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: titleWidget),
                          const SizedBox(width: 12),
                          statusWidget,
                        ],
                      ),
              );
            },
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
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.storage_rounded, size: 16),
                  text: 'Multi-Tenant Database & RLS Simulator',
                ),
                Tab(
                  icon: Icon(Icons.token_rounded, size: 16),
                  text: 'JWT Decoded Claims & Gateway Rules',
                ),
                Tab(
                  icon: Icon(Icons.dns_rounded, size: 16),
                  text: 'K8s Containers & Caching Metrics',
                ),
                Tab(
                  icon: Icon(Icons.hub_rounded, size: 16),
                  text: 'DevOps Pipelines & Webhooks',
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRlsTab(),
                _buildJwtTab(jwt),
                _buildK8sTab(pods),
                _buildDevOpsTab(webhooks),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Multi-Tenant DB & RLS Simulator
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildRlsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🗄️ Multi-Tenant Shared Database Table Schema',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          const Text(
            'All application tables share tenant storage but isolate data logically using org_id + branch_id columns.',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder.all(color: Colors.grey.shade300),
              children: const [
                TableRow(
                  decoration: BoxDecoration(color: Colors.black12),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('student_id', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('org_id (Tenant)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('branch_id (RLS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('ST-001', style: TextStyle(fontSize: 10))),
                    Padding(padding: EdgeInsets.all(8), child: Text('ORG-001', style: TextStyle(fontSize: 10))),
                    Padding(padding: EdgeInsets.all(8), child: Text('BR-001', style: TextStyle(fontSize: 10))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Aarav Sharma', style: TextStyle(fontSize: 10))),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8), child: Text('ST-003', style: TextStyle(fontSize: 10))),
                    Padding(padding: EdgeInsets.all(8), child: Text('ORG-001', style: TextStyle(fontSize: 10))),
                    Padding(padding: EdgeInsets.all(8), child: Text('BR-002', style: TextStyle(fontSize: 10))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Rohan Mehta', style: TextStyle(fontSize: 10))),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 36),

          const Text(
            '⚡ Postgres Row-Level Security (RLS) Simulator',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Active Client Branch Context: ',
                style: TextStyle(fontSize: 11),
              ),
              DropdownButton<String>(
                value: _selectedRlsBranch,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'BR-001',
                    child: Text('Delhi Campus (BR-001)'),
                  ),
                  DropdownMenuItem(
                    value: 'BR-002',
                    child: Text('Mumbai Campus (BR-002)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedRlsBranch = val;
                    });
                  }
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () async {
                  setState(() {
                    _executingRls = true;
                    _transpiledSql = '';
                    _rlsResults = [];
                  });
                  await Future.delayed(const Duration(milliseconds: 800));
                  if (!mounted) return;
                  setState(() {
                    _executingRls = false;
                    _transpiledSql =
                        "SELECT * FROM students s \nWHERE s.org_id = 'ORG-001' \n  AND s.branch_id = '$_selectedRlsBranch';";
                    if (_selectedRlsBranch == 'BR-001') {
                      _rlsResults = [
                        {
                          'student_id': 'ST-001',
                          'name': 'Aarav Sharma',
                          'branch_id': 'BR-001',
                        },
                        {
                          'student_id': 'ST-002',
                          'name': 'Sunita Rao',
                          'branch_id': 'BR-001',
                        },
                      ];
                    } else {
                      _rlsResults = [
                        {
                          'student_id': 'ST-003',
                          'name': 'Rohan Mehta',
                          'branch_id': 'BR-002',
                        },
                      ];
                    }
                  });
                },
                child: const Text(
                  'Execute RLS Scope Check',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          if (_executingRls)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: LinearProgressIndicator(),
            )
          else if (_transpiledSql.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.all(12),
              child: Text(
                '// Transpiled SQL query enforcing isolation:\n$_transpiledSql',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Database Returned Rows (Isolate scope):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: TableBorder.all(color: Colors.grey.shade300),
                children: _rlsResults.map((row) {
                  return TableRow(
                    children: row.values
                        .map(
                          (v) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(v, style: const TextStyle(fontSize: 9)),
                          ),
                        )
                        .toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — JWT Claims & API Gateway
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildJwtTab(JwtClaims jwt) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final decodedSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔑 Decoded Client JWT Claims Payload',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              'Decoded tokens show active tenant identifiers injected inside payload claims.',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '{',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  _buildCodeLine('  "sub": "${jwt.sub}",'),
                  _buildCodeLine('  "name": "${jwt.name}",'),
                  _buildCodeLine('  "org_id": "${jwt.orgId}",'),
                  _buildCodeLine('  "branch_id": "${jwt.branchId}",'),
                  _buildCodeLine('  "role": "${jwt.role}",'),
                  _buildCodeLine('  "exp": ${jwt.exp}'),
                  const Text(
                    '}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final routingSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚦 API Gateway Routing Middleware logs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _buildLogCard(
              'GET /api/v1/academic/students',
              'Resolved: org_id=ORG-001, branch_id=BR-001',
            ),
            _buildLogCard(
              'POST /api/v1/finance/receipts',
              'Injected Headers: X-Tenant-ID: ORG-001, X-Branch-ID: BR-001',
            ),
            _buildLogCard(
              'GET /api/v1/reports/consolidated',
              'Cross-branch query validation check... PASS',
            ),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    decodedSection,
                    const SizedBox(height: 24),
                    routingSection,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: decodedSection),
                    const SizedBox(width: 24),
                    Expanded(child: routingSection),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCodeLine(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.amberAccent,
        fontSize: 11,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildLogCard(String endpoint, String details) {
    return Card(
      color: Colors.blueGrey.shade900,
      child: ListTile(
        dense: true,
        title: Text(
          endpoint,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Text(
          details,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — K8s Pods & Caching Dashboard
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildK8sTab(List<K8sPodStatus> pods) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final k8sSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '🐳 Kubernetes Container Cluster Nodes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(k8sPodsProvider.notifier).scalePods();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '✓ Pod scaling scheduled dynamically...',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Scale Cluster',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...pods.map(
              (p) => Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.layers_rounded,
                    color: Colors.blue,
                  ),
                  title: Text(
                    p.podName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  subtitle: Text(
                    'CPU Util: ${p.cpuUtilization}% | Memory: ${p.memoryUsageMb} MB',
                  ),
                  trailing: Chip(
                    label: Text(
                      p.status,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ),
          ],
        );

        final metricsSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Redis Cache and Search Metrics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _buildMetricRow('Redis Hit Rate', '98.6%', Colors.teal),
            _buildMetricRow(
              'Elasticsearch Queries Latency',
              '4.2 ms',
              Colors.teal,
            ),
            _buildMetricRow(
              'Active WebSocket Streams',
              '42 channels',
              Colors.teal,
            ),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    k8sSection,
                    const SizedBox(height: 24),
                    metricsSection,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: k8sSection),
                    const SizedBox(width: 24),
                    Expanded(child: metricsSection),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildMetricRow(String name, String value, Color color) {
    return Card(
      child: ListTile(
        dense: true,
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — DevOps Pipelines & Webhooks
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildDevOpsTab(List<OrgWebhook> webhooks) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final devOpsSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚀 DevOps CI/CD & Deployments',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_outline, size: 16),
              onPressed: _runningCiCd
                  ? null
                  : () async {
                      setState(() {
                        _runningCiCd = true;
                        _ciCdSteps = [];
                      });
                      final steps = [
                        '✓ Linter check: OK',
                        '✓ Unit tests: 418 passed',
                        '✓ E2E Integration checks: OK',
                        '✓ Docker Build & Push: OK',
                      ];
                      for (final step in steps) {
                        await Future.delayed(
                          const Duration(milliseconds: 600),
                        );
                        if (!mounted) return;
                        setState(() {
                          _ciCdSteps.add(step);
                        });
                      }
                      if (!mounted) return;
                      setState(() {
                        _runningCiCd = false;
                      });
                    },
              label: const Text(
                'Trigger Pipeline build',
                style: TextStyle(fontSize: 11),
              ),
            ),
            if (_ciCdSteps.isNotEmpty) ...[
              const SizedBox(height: 12),
              ..._ciCdSteps.map(
                (s) => Text(
                  s,
                  style: const TextStyle(color: Colors.green, fontSize: 11),
                ),
              ),
            ],
            const Divider(height: 24),
            const Text(
              '🌐 Zero-Downtime Blue-Green Deployment Routing',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 8),
            Text(
              'Active Node Route: $_activeNode Node (100% Traffic Load)',
              style: const TextStyle(fontSize: 11, color: Colors.indigo),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _activeNode = _activeNode == 'Blue' ? 'Green' : 'Blue';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✓ Rotated active gateway traffic route to $_activeNode.',
                    ),
                  ),
                );
              },
              child: const Text(
                'Rotate Traffic (Blue/Green)',
                style: TextStyle(fontSize: 10),
              ),
            ),
            const Divider(height: 24),
            const Text(
              '📂 Branch GDPR Data Exports & PITR Backups',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.download_rounded, size: 14),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '✓ Generating GDPR compliant branch JSON payload... Download ready.',
                        ),
                      ),
                    );
                  },
                  label: const Text(
                    'Export GDPR Package',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.history_rounded, size: 14),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '✓ Restoring point-in-time snapshot to 2026-08-19 12:00:00... OK',
                        ),
                      ),
                    );
                  },
                  label: const Text(
                    'Point-in-time Backup',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        );

        final gqlWebhooksSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🕸️ GraphQL Query Console (Branch context)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gqlCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'GraphQL Query Body',
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _gqlResult =
                      '{\n  "data": {\n    "students": [\n      { "name": "Aarav Sharma", "enrollment": "DEL-901" },\n      { "name": "Sunita Rao", "enrollment": "DEL-902" }\n    ]\n  }\n}';
                });
              },
              child: const Text(
                'Query GraphQL API',
                style: TextStyle(fontSize: 10),
              ),
            ),
            if (_gqlResult.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                color: Colors.black87,
                padding: const EdgeInsets.all(8),
                child: Text(
                  _gqlResult,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            const Divider(height: 24),
            const Text(
              '🪝 Active Organization Webhooks triggers',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _webhookUrlCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Webhook URL (e.g. https://api.site.com/hook)',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_webhookUrlCtrl.text.isNotEmpty) {
                      ref.read(orgWebhooksProvider.notifier).addWebhook(
                        _webhookUrlCtrl.text,
                        ['student.admitted'],
                      );
                      _webhookUrlCtrl.clear();
                    }
                  },
                  child: const Text(
                    'Add Hook',
                    style: TextStyle(fontSize: 9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...webhooks.map(
              (w) => Card(
                child: ListTile(
                  dense: true,
                  title: Text(
                    w.url,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('Events: ${w.eventTriggers.join(', ')}'),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    onPressed: () {
                      ref
                          .read(orgWebhooksProvider.notifier)
                          .removeWebhook(w.id);
                    },
                  ),
                ),
              ),
            ),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    devOpsSection,
                    const SizedBox(height: 24),
                    gqlWebhooksSection,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: devOpsSection),
                    const SizedBox(width: 24),
                    Expanded(child: gqlWebhooksSection),
                  ],
                ),
        );
      },
    );
  }
}

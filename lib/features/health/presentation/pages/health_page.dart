import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class HealthMedicalPage extends ConsumerStatefulWidget {
  const HealthMedicalPage({super.key});

  @override
  ConsumerState<HealthMedicalPage> createState() => _HealthMedicalPageState();
}

class _HealthMedicalPageState extends ConsumerState<HealthMedicalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Check-up parameters fields
  StudentHealthRecord? _selectedRecord;
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _visionCtrl = TextEditingController();
  final _dentalCtrl = TextEditingController();

  // First Aid fields
  final _firstAidStudentCtrl = TextEditingController();
  final _incidentCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();

  // Restock fields
  String? _selectedStockId;
  final _restockQtyCtrl = TextEditingController();

  // Emergency trigger
  bool _medicalAlertActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _visionCtrl.dispose();
    _dentalCtrl.dispose();
    _firstAidStudentCtrl.dispose();
    _incidentCtrl.dispose();
    _treatmentCtrl.dispose();
    _restockQtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final healthRecords = ref.watch(studentHealthProvider).where((h) => h.branchId == activeBranchId).toList();
    final firstAidLogs = ref.watch(firstAidProvider).where((f) => f.branchId == activeBranchId).toList();
    final pharmacyStock = ref.watch(medicalStockProvider);
    final epidemicCases = ref.watch(epidemicTrackerProvider);

    return Scaffold(
      body: Column(
        children: [
          // Subheader
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;
              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Infirmary & Health Records: $branchName',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Text(
                    'Vision & Dental Logs | Emergency Contact ID integration: Active',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              );

              final alertButton = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() {
                    _medicalAlertActive = !_medicalAlertActive;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _medicalAlertActive ? Colors.red : Colors.green,
                      content: Text(
                        _medicalAlertActive
                            ? '🚨 EMERGENCY ALERT: Campus ambulances notified! Gate entry clearance active.'
                            : '✓ Medical alert cleared.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.emergency_rounded, color: Colors.white, size: 16),
                label: Text(
                  _medicalAlertActive ? 'Clear Emergency' : 'Medical Emergency Alert',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              );

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleWidget,
                          const SizedBox(height: 12),
                          alertButton,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: titleWidget),
                          const SizedBox(width: 16),
                          alertButton,
                        ],
                      ),
              );
            },
          ),

          // Medical emergency warning card
          if (_medicalAlertActive)
            Container(
              width: double.infinity,
              color: Colors.red.shade900,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.local_hospital_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    '🚨 CAMPUS MEDICAL CRISIS RESPONSE ON: Infirmary staff alerted, emergency contacts notified.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
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
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: const [
                Tab(icon: Icon(Icons.favorite_rounded, size: 16), text: 'Student Health Profiles & Exams'),
                Tab(icon: Icon(Icons.medical_services_rounded, size: 16), text: 'First Aid & Medication roster'),
                Tab(icon: Icon(Icons.vaccines_rounded, size: 16), text: 'Infirmary Stock & Epidemics'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecordsTab(healthRecords),
                _buildFirstAidTab(firstAidLogs),
                _buildEpidemicTab(pharmacyStock, epidemicCases),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Medical Records & Checkups Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildRecordsTab(List<StudentHealthRecord> records) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final formWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✏️ Update Student Health Parameters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            DropdownButtonFormField<StudentHealthRecord>(
              initialValue: _selectedRecord,
              hint: const Text('Choose Student Health Profile', style: TextStyle(fontSize: 11)),
              items: records.map((r) {
                return DropdownMenuItem<StudentHealthRecord>(
                  value: r,
                  child: Text(r.studentName, style: const TextStyle(fontSize: 11)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedRecord = val;
                  if (val != null) {
                    _heightCtrl.text = val.heightCm.toString();
                    _weightCtrl.text = val.weightKg.toString();
                    _visionCtrl.text = val.visionDetails;
                    _dentalCtrl.text = val.dentalDetails;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(controller: _heightCtrl, decoration: const InputDecoration(labelText: 'Height (cm)')),
            TextField(controller: _weightCtrl, decoration: const InputDecoration(labelText: 'Weight (kg)')),
            TextField(controller: _visionCtrl, decoration: const InputDecoration(labelText: 'Vision (e.g. L: 6/6, R: 6/9)')),
            TextField(controller: _dentalCtrl, decoration: const InputDecoration(labelText: 'Dental description')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  final h = double.tryParse(_heightCtrl.text) ?? 150.0;
                  final w = double.tryParse(_weightCtrl.text) ?? 50.0;
                  if (_selectedRecord != null) {
                    final bmiVal = w / ((h / 100) * (h / 100));
                    final updated = _selectedRecord!.copyWith(
                      heightCm: h,
                      weightKg: w,
                      bmi: double.parse(bmiVal.toStringAsFixed(1)),
                      visionDetails: _visionCtrl.text,
                      dentalDetails: _dentalCtrl.text,
                    );
                    ref.read(studentHealthProvider.notifier).updateRecord(updated);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Student check-up parameters saved in medical file.')),
                    );
                  }
                },
                child: const Text('Save Examination Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );

        final listWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Student Infirmary Directory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            ...records.map((r) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(r.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('BMI: ${r.bmi} (Height: ${r.heightCm}cm, Weight: ${r.weightKg}kg)', style: const TextStyle(fontSize: 10, color: Colors.indigo)),
                          ],
                        ),
                        const Divider(height: 12),
                        Text('Allergies: ${r.allergies}', style: const TextStyle(fontSize: 10, color: Colors.red)),
                        Text('Vaccinations: ${r.vaccinations}', style: const TextStyle(fontSize: 10)),
                        Text('Vision: ${r.visionDetails} | Dental: ${r.dentalDetails}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.contact_phone_rounded, size: 12, color: Colors.teal),
                            const SizedBox(width: 4),
                            Text('Emergency Contact ID Integration: ${r.emergencyContact}', style: const TextStyle(fontSize: 9, color: Colors.teal)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    formWidget,
                    const SizedBox(height: 32),
                    listWidget,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: formWidget),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: listWidget),
                  ],
                ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — First Aid & Daily Medication
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildFirstAidTab(List<FirstAidLog> logs) {
    final dailyMedications = [
      {'name': 'Sunita Rao', 'med': 'Asthalin Inhaler (1 puff)', 'time': '01:00 PM'},
      {'name': 'Vikram Malhotra (Staff)', 'med': 'BP Metoprolol 25mg', 'time': '09:00 AM'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final formWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✏️ Log First Aid Treatment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(controller: _firstAidStudentCtrl, decoration: const InputDecoration(labelText: 'Student / User Name')),
            TextField(controller: _incidentCtrl, decoration: const InputDecoration(labelText: 'Incident Description (e.g. cut, fall)')),
            TextField(controller: _treatmentCtrl, decoration: const InputDecoration(labelText: 'Treatment Given (First aid medicine)')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  if (_firstAidStudentCtrl.text.isNotEmpty && _incidentCtrl.text.isNotEmpty) {
                    ref.read(firstAidProvider.notifier).logFirstAid(
                      FirstAidLog(
                        id: 'AID-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: 'BR-001',
                        studentName: _firstAidStudentCtrl.text,
                        incident: _incidentCtrl.text,
                        treatment: _treatmentCtrl.text,
                        timestamp: '2026-08-19 12:45 PM',
                      ),
                    );
                    _firstAidStudentCtrl.clear();
                    _incidentCtrl.clear();
                    _treatmentCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ First Aid log created. Parent alert notification sent.')),
                    );
                  }
                },
                child: const Text('Add Log Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const Divider(height: 36),

            // Medication schedule
            const Text('📋 Daily Roster Medication Schedules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            ...dailyMedications.map((m) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.watch_later_rounded, color: Colors.amber),
                    title: Text(m['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    subtitle: Text('Medication: ${m["med"]} | Time: ${m["time"]}'),
                  ),
                )),
          ],
        );

        final listWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 First Aid Log Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            ...logs.map((l) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.healing_rounded, color: Colors.red),
                    title: Text(l.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    subtitle: Text('Incident: ${l.incident}\nTreatment: ${l.treatment}\nTime: ${l.timestamp}'),
                  ),
                )),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    formWidget,
                    const SizedBox(height: 32),
                    listWidget,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: formWidget),
                    const SizedBox(width: 24),
                    Expanded(child: listWidget),
                  ],
                ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Infirmary Pharmacy & Epidemic Alerts
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildEpidemicTab(List<MedicalStock> stocks, List<DiseaseCase> diseases) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final stockWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Infirmary Stock Registry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedStockId,
              hint: const Text('Select Medical Item to Restock', style: TextStyle(fontSize: 11)),
              items: stocks.map((s) {
                return DropdownMenuItem<String>(
                  value: s.id,
                  child: Text('${s.name} (Available: ${s.qty})', style: const TextStyle(fontSize: 11)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedStockId = val),
            ),
            const SizedBox(height: 12),
            TextField(controller: _restockQtyCtrl, decoration: const InputDecoration(labelText: 'Restock Quantity')),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  final add = int.tryParse(_restockQtyCtrl.text) ?? 0;
                  if (_selectedStockId != null && add > 0) {
                    ref.read(medicalStockProvider.notifier).restock(_selectedStockId!, add);
                    _restockQtyCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Pharmacy stock ledger restocked.')),
                    );
                  }
                },
                child: const Text('Confirm Restock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            ...stocks.map((s) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.medical_information_rounded, color: Colors.teal),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    subtitle: Text('Qty: ${s.qty} units | Expiry: ${s.expDate}'),
                  ),
                )),
          ],
        );

        final epidemicWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🦟 Active Epidemic Isolation tracking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            ...diseases.map((d) => Card(
                  color: d.activeCases > 0 ? Colors.orange.withValues(alpha: 0.05) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(d.diseaseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            Chip(
                              label: Text('${d.activeCases} active cases', style: const TextStyle(fontSize: 8, color: Colors.white)),
                              backgroundColor: d.activeCases > 0 ? Colors.orange : Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Isolation Protocol: ${d.protocol}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                )),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Starting branch medical checkup statistics download...')),
                  );
                },
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text('Export Infirmary Health Report', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    stockWidget,
                    const SizedBox(height: 32),
                    epidemicWidget,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: stockWidget),
                    const SizedBox(width: 24),
                    Expanded(child: epidemicWidget),
                  ],
                ),
        );
      },
    );
  }
}

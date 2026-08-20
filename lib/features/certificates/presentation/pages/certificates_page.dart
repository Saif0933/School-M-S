import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../../academic/providers.dart';
import '../../providers.dart';

class CertificatesPage extends ConsumerStatefulWidget {
  const CertificatesPage({super.key});

  @override
  ConsumerState<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends ConsumerState<CertificatesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // New Certificate Issue States
  StudentEntity? _selectedStudent;
  String _selectedCertType = 'Bonafide Student Certificate';
  final _certCustomTextCtrl = TextEditingController(
    text: 'This is to certify that the student has demonstrated exemplary behavior and completed courses successfully.',
  );
  bool _watermarkedEnabled = true;
  GeneratedCertificateRecord? _latestGeneratedCert;

  // Verification Dialog controller
  final _verificationSerialCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _certCustomTextCtrl.dispose();
    _verificationSerialCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final students = ref.watch(academicStudentsProvider).where((s) => s.branchId == activeBranchId).toList();
    final templates = ref.watch(certificateTemplatesProvider);
    final issuedCerts = ref.watch(generatedCertificatesProvider).where((c) => c.branchId == activeBranchId).toList();

    return Scaffold(
      body: Column(
        children: [
          // Sub Header
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;
              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Certificate & ID Card Generation: $branchName',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Branch Address & Seal Scoping | Total Issued Certificates: ${issuedCerts.length}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              );

              final actionButtons = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () => _triggerBulkIDCardGeneration(context, students),
                    icon: const Icon(Icons.badge_rounded, color: Colors.white, size: 16),
                    label: const Text('Bulk ID Cards print', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () => _showVerificationSearch(context, activeBranchId),
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 16),
                    label: const Text('Verify QR Certificate', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
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
                          actionButtons,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: titleWidget),
                          const SizedBox(width: 16),
                          actionButtons,
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: const [
                Tab(icon: Icon(Icons.contact_mail_rounded, size: 16), text: 'ID Card Designer'),
                Tab(icon: Icon(Icons.verified_user_rounded, size: 16), text: 'Issue Certificate'),
                Tab(icon: Icon(Icons.auto_awesome_motion_rounded, size: 16), text: '50+ Templates & Custom Upload'),
                Tab(icon: Icon(Icons.history_edu_rounded, size: 16), text: 'Verification & Reissues'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _IDCardDesignerTab(branchName: branchName, students: students),
                _IssueCertificateTab(
                  students: students,
                  selectedStudent: _selectedStudent,
                  selectedCertType: _selectedCertType,
                  customTextCtrl: _certCustomTextCtrl,
                  watermarkEnabled: _watermarkedEnabled,
                  latestGenerated: _latestGeneratedCert,
                  branchId: activeBranchId,
                  branchName: branchName,
                  onStudentChanged: (val) => setState(() => _selectedStudent = val),
                  onCertTypeChanged: (val) => setState(() => _selectedCertType = val ?? 'Bonafide Student Certificate'),
                  onWatermarkChanged: (val) => setState(() => _watermarkedEnabled = val ?? true),
                  onGenerateTriggered: (record) => setState(() => _latestGeneratedCert = record),
                ),
                _TemplatesTab(
                  templates: templates,
                  onSelectTemplate: (name) {
                    setState(() {
                      _selectedCertType = name;
                      _tabController.animateTo(1);
                    });
                  },
                ),
                _ReissuesTab(issuedCerts: issuedCerts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _triggerBulkIDCardGeneration(BuildContext context, List<StudentEntity> students) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bulk ID Card PDF Print'),
          content: Text('Do you want to generate ID Card layout PDF and barcode lists for all ${students.length} students?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Generating Bulk ID Card sheet batch... Download started.')),
                );
              },
              child: const Text('Print Batch'),
            ),
          ],
        );
      },
    );
  }

  void _showVerificationSearch(BuildContext context, String branchId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify Digital Certificate QR code'),
          content: TextField(controller: _verificationSerialCtrl, decoration: const InputDecoration(hintText: 'Enter Serial e.g. CERT-DEL-2026-001')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ElevatedButton(
              onPressed: () {
                final serial = _verificationSerialCtrl.text;
                final certs = ref.read(generatedCertificatesProvider);
                final exists = certs.any((c) => c.serialNumber == serial && c.branchId == branchId);

                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(exists ? '✓ Certificate Verified' : '❌ Verification Failed'),
                      content: Text(
                        exists
                            ? 'Security verification successful.\nSerial: $serial\nIssuer Campus Branch: Delhi Central SIS\nSeal status: VALID.'
                            : 'The scanned serial $serial is not registered or belongs to a different branch scope.',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                      ],
                    );
                  },
                );
                _verificationSerialCtrl.clear();
              },
              child: const Text('Scan / Search'),
            ),
          ],
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 1 — ID Card Designer & Preview
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _IDCardDesignerTab extends ConsumerWidget {
  final String branchName;
  final List<StudentEntity> students;

  const _IDCardDesignerTab({required this.branchName, required this.students});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final design = ref.watch(idCardDesignerProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final controlsSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎨 Template Layout Designer Controls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: design.layoutStyle,
              decoration: const InputDecoration(labelText: 'Card Orientation Layout'),
              items: const [
                DropdownMenuItem(value: 'Vertical', child: Text('Vertical Orientation')),
                DropdownMenuItem(value: 'Horizontal', child: Text('Horizontal Orientation')),
              ],
              onChanged: (val) => ref.read(idCardDesignerProvider.notifier).updateConfig(layoutStyle: val),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: design.cardColorTheme,
              decoration: const InputDecoration(labelText: 'Card Color Background Theme'),
              items: const [
                DropdownMenuItem(value: 'Ocean Blue', child: Text('Ocean Blue (SIS Custom)')),
                DropdownMenuItem(value: 'Charcoal', child: Text('Modern Charcoal')),
                DropdownMenuItem(value: 'Forest Green', child: Text('Forest Green')),
              ],
              onChanged: (val) => ref.read(idCardDesignerProvider.notifier).updateConfig(cardColorTheme: val),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              dense: true,
              title: const Text('Render barcode tag', style: TextStyle(fontSize: 11)),
              value: design.showBarcode,
              onChanged: (val) => ref.read(idCardDesignerProvider.notifier).updateConfig(showBarcode: val),
            ),
            SwitchListTile(
              dense: true,
              title: const Text('Render verification QR stamp', style: TextStyle(fontSize: 11)),
              value: design.showQrCode,
              onChanged: (val) => ref.read(idCardDesignerProvider.notifier).updateConfig(showQrCode: val),
            ),
          ],
        );

        final previewSection = Center(
          child: Container(
            width: design.layoutStyle == 'Vertical' ? 220 : 320,
            height: design.layoutStyle == 'Vertical' ? 340 : 220,
            decoration: BoxDecoration(
              color: design.cardColorTheme == 'Ocean Blue'
                  ? Colors.indigo.shade900
                  : (design.cardColorTheme == 'Charcoal' ? Colors.grey.shade900 : Colors.green.shade900),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Header with branch name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        branchName.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 12),

                // Profile Photo
                const Spacer(),
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person_rounded, size: 36, color: Colors.white70),
                ),
                const SizedBox(height: 8),

                // Student Details
                const Text('AARAV SHARMA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                const Text('Class: 11 Science | Adm No: ADM-DEL-101', style: TextStyle(color: Colors.white70, fontSize: 8)),
                const Text('Blood Group: B+ | Emergency: +91 9999988888', style: TextStyle(color: Colors.white54, fontSize: 8)),
                const Spacer(),

                // Barcode & QR Code stamps
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (design.showBarcode)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        color: Colors.white,
                        child: const Text('|||| BARCODE ||||', style: TextStyle(color: Colors.black, fontSize: 6, fontWeight: FontWeight.bold)),
                      )
                    else
                      const SizedBox.shrink(),
                    if (design.showQrCode)
                      const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 24)
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    previewSection,
                    const SizedBox(height: 24),
                    controlsSection,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: controlsSection),
                    const SizedBox(width: 24),
                    Expanded(child: previewSection),
                  ],
                ),
        );
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 2 — Issue New Certificate Desk
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _IssueCertificateTab extends StatelessWidget {
  final List<StudentEntity> students;
  final StudentEntity? selectedStudent;
  final String selectedCertType;
  final TextEditingController customTextCtrl;
  final bool watermarkEnabled;
  final GeneratedCertificateRecord? latestGenerated;
  final String branchId;
  final String branchName;
  final ValueChanged<StudentEntity?> onStudentChanged;
  final ValueChanged<String?> onCertTypeChanged;
  final ValueChanged<bool?> onWatermarkChanged;
  final ValueChanged<GeneratedCertificateRecord> onGenerateTriggered;

  const _IssueCertificateTab({
    required this.students,
    required this.selectedStudent,
    required this.selectedCertType,
    required this.customTextCtrl,
    required this.watermarkEnabled,
    required this.latestGenerated,
    required this.branchId,
    required this.branchName,
    required this.onStudentChanged,
    required this.onCertTypeChanged,
    required this.onWatermarkChanged,
    required this.onGenerateTriggered,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📝 Certificate Generator Fields', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          DropdownButtonFormField<StudentEntity>(
            initialValue: selectedStudent,
            decoration: const InputDecoration(labelText: 'Recipient Student Name'),
            items: students.map((s) {
              return DropdownMenuItem<StudentEntity>(
                value: s,
                child: Text(s.name),
              );
            }).toList(),
            onChanged: onStudentChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedCertType,
            decoration: const InputDecoration(labelText: 'Certificate Template Type'),
            items: const [
              DropdownMenuItem(value: 'Transfer Certificate (Standard)', child: Text('Transfer Certificate (Standard)')),
              DropdownMenuItem(value: 'Character Certificate (Standard)', child: Text('Character Certificate (Standard)')),
              DropdownMenuItem(value: 'Bonafide Student Certificate', child: Text('Bonafide Student Certificate')),
              DropdownMenuItem(value: 'Course Completion Certificate', child: Text('Course Completion Certificate')),
              DropdownMenuItem(value: 'Sports Achievement Certificate', child: Text('Sports Achievement Certificate')),
            ],
            onChanged: onCertTypeChanged,
          ),
          const SizedBox(height: 12),
          TextField(controller: customTextCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Custom Body Description Text')),
          const SizedBox(height: 16),
          SwitchListTile(
            dense: true,
            title: const Text('Apply Secure Anti-Forgery Watermark background', style: TextStyle(fontSize: 11)),
            value: watermarkEnabled,
            onChanged: onWatermarkChanged,
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: selectedStudent != null
                      ? () {
                          final record = GeneratedCertificateRecord(
                            id: 'CRT-${DateTime.now().millisecondsSinceEpoch}',
                            branchId: branchId,
                            studentName: selectedStudent!.name,
                            certificateType: selectedCertType,
                            serialNumber: 'CERT-${branchId.replaceAll("BR-", "CAMP-")}-${DateTime.now().millisecond}',
                            issuedDate: '2026-08-19',
                            status: 'Active',
                          );
                          ref.read(generatedCertificatesProvider.notifier).issueCertificate(record);
                          onGenerateTriggered(record);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Secure Certificate generated and logged in database.')),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.security_rounded, color: Colors.white),
                  label: const Text('Generate Secure Certificate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
          
          if (latestGenerated != null) ...[
            const Divider(height: 36),
            const Text('📄 Secure Watermarked Certificate Print Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.amber, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                padding: const EdgeInsets.all(24),
                child: Stack(
                  children: [
                    // Watermark background
                    if (watermarkEnabled)
                      Positioned.fill(
                        child: Center(
                          child: Opacity(
                            opacity: 0.05,
                            child: Text(
                              branchName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ),
                      ),

                    Column(
                      children: [
                        Text(
                          branchName.toUpperCase(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo, letterSpacing: 1),
                        ),
                        const Text('Sunrise International Educational Group', style: TextStyle(fontSize: 8, color: Colors.grey)),
                        const Text('CERTIFICATE OF RECOGNITION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 0.8)),
                        const Divider(height: 24),
                        const SizedBox(height: 12),
                        
                        Text(
                          'This is proudly presented to ${latestGenerated!.studentName}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          customTextCtrl.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 24),

                        // Signature and QR codes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/f/f8/Signature_of_Robert_Muldoon.svg',
                                  width: 80,
                                  height: 30,
                                  errorBuilder: (context, error, stackTrace) => const Text('Signed', style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic, color: Colors.black)),
                                ),
                                const Text('Principal E-Signature', style: TextStyle(fontSize: 8, color: Colors.grey)),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.qr_code_2_rounded, size: 36, color: Colors.black),
                                Text('Verif: ${latestGenerated!.serialNumber}', style: const TextStyle(fontSize: 6, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 3 — 50+ Pre-built Templates Library
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _TemplatesTab extends StatelessWidget {
  final List<CertificateTemplateEntity> templates;
  final ValueChanged<String> onSelectTemplate;

  const _TemplatesTab({required this.templates, required this.onSelectTemplate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom design upload desk
        Container(
          padding: const EdgeInsets.all(12),
          child: Card(
            color: Colors.blue.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final contentWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Upload Custom Certificate Layout Template', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      SizedBox(height: 4),
                      Text('Import branch SVG/PNG templates scoped only to this branch.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  );

                  final buttonWidget = ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ Selecting local template graphic file... Custom upload successful.')),
                      );
                    },
                    child: const Text('Upload file', style: TextStyle(fontSize: 9)),
                  );

                  return isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            contentWidget,
                            const SizedBox(height: 12),
                            SizedBox(width: double.infinity, child: buttonWidget),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: contentWidget),
                            const SizedBox(width: 12),
                            buttonWidget,
                          ],
                        );
                },
              ),
            ),
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final t = templates[index];
              return Card(
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.design_services_rounded, color: Colors.amber),
                  title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: Text('Category: ${t.category} | Theme Frame: ${t.designTheme}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () => onSelectTemplate(t.name),
                    child: const Text('Use Template', style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-TAB 4 — History Registry & Reissues
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _ReissuesTab extends ConsumerWidget {
  final List<GeneratedCertificateRecord> issuedCerts;
  const _ReissuesTab({required this.issuedCerts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: issuedCerts.length,
      itemBuilder: (context, index) {
        final c = issuedCerts[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                final details = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${c.studentName} — ${c.certificateType}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Serial: ${c.serialNumber}\nIssued Date: ${c.issuedDate}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                );

                final statusActions = Column(
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    Chip(
                      label: Text(c.status, style: const TextStyle(fontSize: 9, color: Colors.white)),
                      backgroundColor: c.status == 'Active' ? Colors.green : Colors.orange,
                    ),
                    if (c.status == 'Active') ...[
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(80, 28),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          ref.read(generatedCertificatesProvider.notifier).reissueCertificate(c.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Reissue certificate requested! Generated new serial stamp.')),
                          );
                        },
                        child: const Text('Reissue Cert', style: TextStyle(fontSize: 8, color: Colors.white)),
                      ),
                    ],
                  ],
                );

                return isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          details,
                          const SizedBox(height: 12),
                          statusActions,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: details),
                          const SizedBox(width: 12),
                          statusActions,
                        ],
                      );
              },
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class AlumniManagementPage extends ConsumerStatefulWidget {
  const AlumniManagementPage({super.key});

  @override
  ConsumerState<AlumniManagementPage> createState() => _AlumniManagementPageState();
}

class _AlumniManagementPageState extends ConsumerState<AlumniManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Selected Alumni profile for card preview
  AlumniProfile? _selectedAlumniCard;

  // Job Form fields
  final _jobTitleCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();

  // Donation Form fields
  final _donorNameCtrl = TextEditingController();
  final _donationAmtCtrl = TextEditingController(text: '1000');
  String? _selectedCampaignId;

  // Batch Filter
  String _selectedBatchFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _jobTitleCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    _donorNameCtrl.dispose();
    _donationAmtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    final alumniList = ref.watch(alumniProvider).where((al) {
      final matchesBranch = al.branchId == activeBranchId;
      final matchesBatch = _selectedBatchFilter == 'All' || al.batchYear.contains(_selectedBatchFilter);
      return matchesBranch && matchesBatch;
    }).toList();

    final jobs = ref.watch(alumniJobsProvider).where((j) => j.branchId == activeBranchId).toList();
    final campaigns = ref.watch(alumniDonationProvider).where((d) => d.branchId == activeBranchId).toList();

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
                    'Alumni & Graduate Networks: $branchName',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Text(
                    'Graduated Batches Portal | Cross-Branch Org Network: Connected',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              );

              final actionBtn = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => _tabController.animateTo(1),
                icon: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 16),
                label: const Text('Post Job Opening', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              );

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleWidget,
                          const SizedBox(height: 8),
                          actionBtn,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: titleWidget),
                          const SizedBox(width: 12),
                          actionBtn,
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
                Tab(icon: Icon(Icons.contact_phone_rounded, size: 16), text: 'Alumni Directory & Card'),
                Tab(icon: Icon(Icons.school_rounded, size: 16), text: 'Mentorship & Jobs Board'),
                Tab(icon: Icon(Icons.volunteer_activism_rounded, size: 16), text: 'Fundraising Campaigns'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDirectoryTab(alumniList, branchName),
                _buildJobsTab(jobs, activeBranchId),
                _buildDonationsTab(campaigns),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Directory & Cards Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildDirectoryTab(List<AlumniProfile> alumniList, String branchName) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final directorySection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('👥 Alumni Directory Register', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                DropdownButton<String>(
                  value: _selectedBatchFilter,
                  style: const TextStyle(fontSize: 11, color: Colors.indigo),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Batches')),
                    DropdownMenuItem(value: '2020', child: Text('Batch of 2020')),
                    DropdownMenuItem(value: '2022', child: Text('Batch of 2022')),
                  ],
                  onChanged: (val) => setState(() => _selectedBatchFilter = val ?? 'All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...alumniList.map((al) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(al.photoUrl),
                    ),
                    title: Text(al.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    subtitle: Text('${al.batchYear} | ${al.occupation}\nEmail: ${al.email}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedAlumniCard = al;
                        });
                      },
                      child: const Text('View Card', style: TextStyle(fontSize: 9)),
                    ),
                  ),
                )),
          ],
        );

        final cardPreviewSection = _selectedAlumniCard != null
            ? Center(
                child: Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade900,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(branchName.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: Colors.white, letterSpacing: 0.8)),
                      const Text('ALUMNI ASSOCIATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.amberAccent, letterSpacing: 0.8)),
                      const Divider(color: Colors.white24, height: 16),
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(_selectedAlumniCard!.photoUrl),
                      ),
                      const SizedBox(height: 8),
                      Text(_selectedAlumniCard!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                      Text(_selectedAlumniCard!.batchYear, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      Text(_selectedAlumniCard!.occupation, style: const TextStyle(fontSize: 9, color: Colors.white54, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Member ID: ${_selectedAlumniCard!.id.replaceAll("AL-", "ALM-")}', style: const TextStyle(fontSize: 7, color: Colors.white30)),
                              const Text('Status: Verified ✓', style: TextStyle(fontSize: 8, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Icon(Icons.qr_code_2_rounded, size: 28, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    directorySection,
                    if (_selectedAlumniCard != null) ...[
                      const SizedBox(height: 24),
                      cardPreviewSection,
                    ],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: directorySection),
                    if (_selectedAlumniCard != null) ...[
                      const SizedBox(width: 24),
                      Expanded(child: cardPreviewSection),
                    ],
                  ],
                ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Mentorship & Job Board
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildJobsTab(List<AlumniJob> jobs, String branchId) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final publishSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✏️ Publish New Job Opening', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(controller: _jobTitleCtrl, decoration: const InputDecoration(labelText: 'Job Title')),
            TextField(controller: _companyCtrl, decoration: const InputDecoration(labelText: 'Company / Firm')),
            TextField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
            TextField(controller: _salaryCtrl, decoration: const InputDecoration(labelText: 'Estimated Salary / Package')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  if (_jobTitleCtrl.text.isNotEmpty && _companyCtrl.text.isNotEmpty) {
                    ref.read(alumniJobsProvider.notifier).postJob(
                      AlumniJob(
                        id: 'JOB-${DateTime.now().millisecondsSinceEpoch}',
                        branchId: branchId,
                        title: _jobTitleCtrl.text,
                        company: _companyCtrl.text,
                        location: _locationCtrl.text.isNotEmpty ? _locationCtrl.text : 'Remote',
                        salary: _salaryCtrl.text.isNotEmpty ? _salaryCtrl.text : 'Unpaid',
                        postedBy: 'Verified Graduate Alumni',
                      ),
                    );
                    _jobTitleCtrl.clear();
                    _companyCtrl.clear();
                    _locationCtrl.clear();
                    _salaryCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Job published to student placement board.')),
                    );
                  }
                },
                child: const Text('Post Job Vacancy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),

            // Mentorship pairing desk
            const Text('🤝 Alumni Mentorship pairing desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.supervisor_account_rounded, color: Colors.teal),
                title: const Text('Aditya Sen (Class of 2020)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                subtitle: const Text('Mentorship: Software Internships prep & DSA coding.'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Mentorship pairing request sent to alumni mail.')),
                    );
                  },
                  child: const Text('Request Mentor', style: TextStyle(fontSize: 8, color: Colors.white)),
                ),
              ),
            ),
          ],
        );

        final placementsSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Student Jobs & Internship Openings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            if (jobs.isEmpty)
              const Text('No openings listed currently.', style: TextStyle(color: Colors.grey, fontSize: 11))
            else
              ...jobs.map((j) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.work_rounded, color: Colors.indigo),
                      title: Text(j.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      subtitle: Text('Company: ${j.company} | Location: ${j.location}\nSalary: ${j.salary} | Posted by: ${j.postedBy}'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Redirecting to job application portal...')),
                        );
                      },
                    ),
                  )),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    publishSection,
                    const SizedBox(height: 24),
                    placementsSection,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: publishSection),
                    const SizedBox(width: 24),
                    Expanded(child: placementsSection),
                  ],
                ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Fundraising Campaigns Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildDonationsTab(List<AlumniDonation> campaigns) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        final donationForm = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✏️ Make Alumni Donation Contribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCampaignId,
              hint: const Text('Choose Fundraising Campaign', style: TextStyle(fontSize: 11)),
              items: campaigns.map((c) {
                return DropdownMenuItem<String>(
                  value: c.id,
                  child: Text(c.title, style: const TextStyle(fontSize: 11)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCampaignId = val),
            ),
            const SizedBox(height: 12),
            TextField(controller: _donorNameCtrl, decoration: const InputDecoration(labelText: 'Donor Name')),
            TextField(controller: _donationAmtCtrl, decoration: const InputDecoration(labelText: 'Contribution Amount (₹)')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  final amt = double.tryParse(_donationAmtCtrl.text) ?? 0.0;
                  if (_selectedCampaignId != null && amt > 0) {
                    ref.read(alumniDonationProvider.notifier).donate(_selectedCampaignId!, amt);
                    _donorNameCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Thank you for your donation! Campaign totals updated.')),
                    );
                  }
                },
                child: const Text('Donate Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );

        final campaignsListSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Active Fundraising Campaigns', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            ...campaigns.map((c) {
              final progress = c.raised / c.goal;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(c.description, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Raised: ₹${c.raised.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('Goal: ₹${c.goal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress > 1.0 ? 1.0 : progress,
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Compiling fundraising summary report...')),
                  );
                },
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text('Download Fundraising Report', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  children: [
                    donationForm,
                    const SizedBox(height: 24),
                    campaignsListSection,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: donationForm),
                    const SizedBox(width: 24),
                    Expanded(child: campaignsListSection),
                  ],
                ),
        );
      },
    );
  }
}

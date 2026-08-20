import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class MobileFeaturesPage extends ConsumerStatefulWidget {
  const MobileFeaturesPage({super.key});

  @override
  ConsumerState<MobileFeaturesPage> createState() => _MobileFeaturesPageState();
}

class _MobileFeaturesPageState extends ConsumerState<MobileFeaturesPage> {
  final _messageTextCtrl = TextEditingController();
  final _homeworkTextCtrl = TextEditingController();

  // GPS Simulation coordinates
  final List<Map<String, dynamic>> _gpsLocations = [
    {'name': 'Inside Delhi Campus Geofence', 'lat': 28.6139, 'lng': 77.2090},
    {'name': 'Inside Mumbai Campus Geofence', 'lat': 19.0760, 'lng': 72.8777},
    {'name': 'Outside Campus Area (Defaulter)', 'lat': 28.9100, 'lng': 77.8000},
  ];
  Map<String, dynamic>? _selectedGps;

  @override
  void initState() {
    super.initState();
    _selectedGps = _gpsLocations[0];
  }

  @override
  void dispose() {
    _messageTextCtrl.dispose();
    _homeworkTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';

    final mobileConfig = ref.watch(mobileConfigProvider);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          final configWidget = Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📱 Mobile App Simulation Desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text(
                  'Simulate and configure branch-scoped features, biometric authorization, GPS fences, offline databases sync, and multi-app interfaces.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Divider(height: 24),

                // Role Selection Switcher
                const Text('Select App Interface:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Org Admin', 'Branch Admin', 'Teacher', 'Parent', 'Student'].map((role) {
                    final active = mobileConfig.activeAppRole == role;
                    return ChoiceChip(
                      label: Text(role, style: TextStyle(fontSize: 10, color: active ? Colors.white : null)),
                      selected: active,
                      selectedColor: AppColors.primary,
                      onSelected: (sel) {
                        if (sel) {
                          ref.read(mobileConfigProvider.notifier).switchAppRole(role);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Biometrics Toggle
                Card(
                  child: ListTile(
                    title: const Text('Biometric Authentication (Face ID)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: Text(mobileConfig.biometricEnabled ? 'Enabled (Prompts scanner upon app launch)' : 'Disabled'),
                    trailing: Switch(
                      value: mobileConfig.biometricEnabled,
                      onChanged: (val) => ref.read(mobileConfigProvider.notifier).toggleBiometrics(),
                    ),
                  ),
                ),

                // Offline Mode Sync
                Card(
                  child: ListTile(
                    title: const Text('Offline Mode Syncing', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: Text(mobileConfig.offlineMode ? 'Running Offline (Using cached SQLite)' : 'Connected Online (Real-time Sync)'),
                    trailing: Switch(
                      value: mobileConfig.offlineMode,
                      onChanged: (val) => ref.read(mobileConfigProvider.notifier).toggleOfflineMode(),
                    ),
                  ),
                ),
                if (mobileConfig.offlineMode) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(mobileConfigProvider.notifier).triggerSync();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Sync complete! Local cache written back to branch servers.')),
                        );
                      },
                      icon: Icon(mobileConfig.synced ? Icons.cloud_done_rounded : Icons.sync_rounded, size: 16),
                      label: Text(mobileConfig.synced ? 'Branch Sync Cache' : 'Synchronizing...'),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // GPS Coordinates Location Emulator
                const Text('GPS Location Simulation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                DropdownButtonFormField<Map<String, dynamic>>(
                  initialValue: _selectedGps,
                  decoration: const InputDecoration(labelText: 'Simulated Device Location'),
                  items: _gpsLocations.map((loc) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: loc,
                      child: Text(loc['name'], style: const TextStyle(fontSize: 11)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedGps = val);
                      ref.read(mobileConfigProvider.notifier).updateGps(val['lat'], val['lng']);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Theme and Language Selector
                const Text('App Translation & Style:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: mobileConfig.currentLanguage,
                  decoration: const InputDecoration(labelText: 'Language Translation'),
                  items: const [
                    DropdownMenuItem(value: 'English', child: Text('English (Global)')),
                    DropdownMenuItem(value: 'Hindi', child: Text('Hindi (हिन्दी)')),
                    DropdownMenuItem(value: 'Marathi', child: Text('Marathi (मराठी)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(mobileConfigProvider.notifier).changeLanguage(val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: mobileConfig.activeThemeMode,
                  decoration: const InputDecoration(labelText: 'Visual Dark Mode / Theme'),
                  items: const [
                    DropdownMenuItem(value: 'Light', child: Text('Classic Light')),
                    DropdownMenuItem(value: 'Dark', child: Text('Sleek Dark Mode')),
                    DropdownMenuItem(value: 'Branch Custom', child: Text('Branch HSL Color Theme')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(mobileConfigProvider.notifier).changeTheme(val);
                    }
                  },
                ),
              ],
            ),
          );

          final simulatorWidget = Container(
            color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.1),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Container(
              width: 320,
              height: 600,
              decoration: BoxDecoration(
                color: mobileConfig.activeThemeMode == 'Dark'
                    ? Colors.black
                    : (mobileConfig.activeThemeMode == 'Light' ? Colors.white : AppColors.primary.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.8), width: 8),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 8)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: Text(
                      '${mobileConfig.activeAppRole} Mobile App',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      if (mobileConfig.biometricEnabled)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.fingerprint_rounded, size: 18, color: Colors.green),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          mobileConfig.offlineMode ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      // Dynamic Phone Viewport Area
                      Expanded(
                        child: _buildPhoneViewportContent(activeBranchId, user?.activeBranch?.branchName ?? "Campus"),
                      ),

                      // Simple In-App Messaging input inside the mockup
                      const Divider(height: 1),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageTextCtrl,
                                style: const TextStyle(fontSize: 10),
                                decoration: const InputDecoration(
                                  hintText: 'In-app branch message...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send_rounded, size: 16, color: AppColors.primary),
                              onPressed: () {
                                if (_messageTextCtrl.text.isNotEmpty) {
                                  ref.read(mobileMessagesProvider.notifier).postMessage(
                                    activeBranchId,
                                    '${mobileConfig.activeAppRole} Device',
                                    _messageTextCtrl.text,
                                  );
                                  _messageTextCtrl.clear();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          return isMobile
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      configWidget,
                      const Divider(height: 1),
                      simulatorWidget,
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: configWidget,
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      flex: 3,
                      child: simulatorWidget,
                    ),
                  ],
                );
        },
      ),
    );
  }

  // Helper method to draw inside the simulator screen
  Widget _buildPhoneViewportContent(String branchId, String branchName) {
    final config = ref.read(mobileConfigProvider);

    switch (config.activeAppRole) {
      case 'Org Admin':
        return _buildOrgAdminView();
      case 'Branch Admin':
        return _buildBranchAdminView();
      case 'Teacher':
        return _buildTeacherView(branchId, branchName);
      case 'Parent':
        return _buildParentView(branchId);
      case 'Student':
      default:
        return _buildStudentView();
    }
  }

  // 1. ORG ADMIN MOBILE VIEW
  Widget _buildOrgAdminView() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        Text('🏢 Org-Level Multi-Branch Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        SizedBox(height: 8),
        Card(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delhi Campus Enrolled', style: TextStyle(fontSize: 9, color: Colors.grey)),
                Text('240 Students', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Divider(height: 12),
                Text('Mumbai Campus Enrolled', style: TextStyle(fontSize: 9, color: Colors.grey)),
                Text('180 Students', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Card(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Text('Gross Org Collections', style: TextStyle(fontSize: 9, color: Colors.grey)),
                Text('₹5,00,000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 2. BRANCH ADMIN MOBILE VIEW
  Widget _buildBranchAdminView() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('🏫 Branch Admin Utilities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            dense: true,
            title: const Text('Broadcast Emergency Push Alert', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            subtitle: const Text('Fires geo-targeted notifications to Delhi parents'),
            trailing: const Icon(Icons.emergency_share_rounded, color: Colors.red, size: 18),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Geo-targeted alert dispatched!')),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Attendance Heatmap', style: TextStyle(fontSize: 9, color: Colors.grey)),
                SizedBox(height: 6),
                LinearProgressIndicator(value: 0.93, color: Colors.green, minHeight: 6),
                SizedBox(height: 4),
                Text('Delhi central is running at 93.5% attendance.', style: TextStyle(fontSize: 8, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. TEACHER MOBILE VIEW
  Widget _buildTeacherView(String branchId, String branchName) {
    final gps = ref.watch(mobileConfigProvider);
    // Delhi geofence check
    final isWithinFence = (gps.currentLat == 28.6139 && gps.currentLng == 77.2090) ||
        (gps.currentLat == 19.0760 && gps.currentLng == 72.8777);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('👩‍🏫 Teacher Desk & GPS Check-In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        const SizedBox(height: 8),
        Card(
          color: isWithinFence ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  isWithinFence ? '✓ Inside Campus Geofence' : '⚠ Outside Geofence Area',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isWithinFence ? Colors.green : Colors.red),
                ),
                Text(
                  'Current Coordinates: ${gps.currentLat.toStringAsFixed(4)}, ${gps.currentLng.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWithinFence ? Colors.green : Colors.grey,
                    minimumSize: const Size(120, 28),
                  ),
                  onPressed: isWithinFence
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ GPS Attendance recorded! Status marked Present.')),
                          );
                        }
                      : null,
                  child: const Text('Mark GPS Attendance', style: TextStyle(fontSize: 9, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Assign Homework Board', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _homeworkTextCtrl,
                  style: const TextStyle(fontSize: 9),
                  decoration: const InputDecoration(hintText: 'Homework description...'),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(80, 24)),
                  onPressed: () {
                    if (_homeworkTextCtrl.text.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ Homework assigned & notifications dispatched to parents.')),
                      );
                      _homeworkTextCtrl.clear();
                    }
                  },
                  child: const Text('Assign Homework', style: TextStyle(fontSize: 9)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 4. PARENT MOBILE VIEW
  Widget _buildParentView(String branchId) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('👨‍👩‍👧 Parent Portal Simulator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        const SizedBox(height: 8),
        
        // Digital ID card mockup
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text('STUDENT DIGITAL ID CARD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.primary)),
                const SizedBox(height: 6),
                const CircleAvatar(radius: 18, child: Icon(Icons.person_rounded)),
                const SizedBox(height: 4),
                const Text('Aarav Sharma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                const Text('Delhi central - Class 11-A', style: TextStyle(fontSize: 8, color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black)),
                  child: const Text('||| BARCODE |||', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Cafeteria pre-ordering thali
        Card(
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.lunch_dining_rounded, color: Colors.amber),
            title: const Text('Pre-Order Cafeteria Meal', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            subtitle: const Text('Order healthy Thali lunch box for ward'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Cafeteria lunch pre-ordered!')),
              );
            },
          ),
        ),
        
        // Bus tracking simulator
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🚌 Live School Bus Tracker', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Route: Sector 15 to Delhi central', style: TextStyle(fontSize: 8, color: Colors.grey)),
                    Text('ETA: 10 Mins', style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(value: 0.7, color: Colors.amber, minHeight: 6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 5. STUDENT MOBILE VIEW
  Widget _buildStudentView() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('🎓 Student App Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.menu_book_rounded, color: Colors.blue),
            title: const Text('Timetable View', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            subtitle: const Text('Delhi campus class schedule timetable'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Today Timetable'),
                    content: const Text('Period 1: Math (08:30 AM)\nPeriod 2: Physics (09:30 AM)\nPeriod 3: Chem (10:30 AM)'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                    ],
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.online_prediction_rounded, color: Colors.deepPurple),
            title: const Text('Online Entrance MCQ Test', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            subtitle: const Text('Launch online exam MCQ portal'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Loading Entrance MCQ Test...')),
              );
            },
          ),
        ),
      ],
    );
  }
}

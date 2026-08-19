import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Mobile App Configuration State
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class MobileAppConfig {
  final String activeAppRole; // 'Org Admin', 'Branch Admin', 'Teacher', 'Parent', 'Student'
  final bool biometricEnabled;
  final bool offlineMode;
  final bool synced;
  final double currentLat;
  final double currentLng;
  final String currentLanguage; // 'English', 'Hindi', 'Marathi'
  final String activeThemeMode; // 'Light', 'Dark', 'Branch Custom'

  const MobileAppConfig({
    required this.activeAppRole,
    required this.biometricEnabled,
    required this.offlineMode,
    required this.synced,
    required this.currentLat,
    required this.currentLng,
    required this.currentLanguage,
    required this.activeThemeMode,
  });

  MobileAppConfig copyWith({
    String? activeAppRole,
    bool? biometricEnabled,
    bool? offlineMode,
    bool? synced,
    double? currentLat,
    double? currentLng,
    String? currentLanguage,
    String? activeThemeMode,
  }) {
    return MobileAppConfig(
      activeAppRole: activeAppRole ?? this.activeAppRole,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      offlineMode: offlineMode ?? this.offlineMode,
      synced: synced ?? this.synced,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      activeThemeMode: activeThemeMode ?? this.activeThemeMode,
    );
  }
}

class MobileConfigNotifier extends StateNotifier<MobileAppConfig> {
  MobileConfigNotifier() : super(const MobileAppConfig(
    activeAppRole: 'Student',
    biometricEnabled: true,
    offlineMode: false,
    synced: true,
    currentLat: 28.6139,
    currentLng: 77.2090, // Delhi Central default
    currentLanguage: 'English',
    activeThemeMode: 'Branch Custom',
  ));

  void switchAppRole(String role) {
    state = state.copyWith(activeAppRole: role);
  }

  void toggleBiometrics() {
    state = state.copyWith(biometricEnabled: !state.biometricEnabled);
  }

  void toggleOfflineMode() {
    state = state.copyWith(offlineMode: !state.offlineMode);
  }

  void triggerSync() {
    state = state.copyWith(synced: false);
    // Simulate immediate sync complete
    Future.delayed(const Duration(milliseconds: 600), () {
      state = state.copyWith(synced: true);
    });
  }

  void updateGps(double lat, double lng) {
    state = state.copyWith(currentLat: lat, currentLng: lng);
  }

  void changeLanguage(String lang) {
    state = state.copyWith(currentLanguage: lang);
  }

  void changeTheme(String theme) {
    state = state.copyWith(activeThemeMode: theme);
  }
}

final mobileConfigProvider = StateNotifierProvider<MobileConfigNotifier, MobileAppConfig>((ref) {
  return MobileConfigNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Mobile App In-App Messages
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class MobileMessageEntity {
  final String id;
  final String branchId;
  final String sender;
  final String text;
  final String time;

  const MobileMessageEntity({
    required this.id,
    required this.branchId,
    required this.sender,
    required this.text,
    required this.time,
  });
}

class MobileMessagesNotifier extends StateNotifier<List<MobileMessageEntity>> {
  MobileMessagesNotifier() : super([
    const MobileMessageEntity(
      id: 'MSG-01',
      branchId: 'BR-001',
      sender: 'Delhi Transport Desk',
      text: 'Route 10 Bus is delayed by 15 mins due to construction near Ring Road.',
      time: '10:00 AM',
    ),
    const MobileMessageEntity(
      id: 'MSG-02',
      branchId: 'BR-001',
      sender: 'Principal Office',
      text: 'Gentle reminder to download the report card PDF from parent portal.',
      time: '09:15 AM',
    ),
  ]);

  void postMessage(String branchId, String sender, String text) {
    state = [
      MobileMessageEntity(
        id: 'MSG-${DateTime.now().millisecondsSinceEpoch}',
        branchId: branchId,
        sender: sender,
        text: text,
        time: 'Just Now',
      ),
      ...state
    ];
  }
}

final mobileMessagesProvider = StateNotifierProvider<MobileMessagesNotifier, List<MobileMessageEntity>>((ref) {
  return MobileMessagesNotifier();
});

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../auth/providers.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Cross-Branch Transfer Request Model & State Providers
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class CrossBranchTransferLog {
  final String id;
  final String entityType; // 'student' or 'staff'
  final String entityName;
  final String entityCode;
  final String fromBranchName;
  final String toBranchName;
  final String reason;
  final String status; // 'pending', 'migrated', 'rejected'
  final DateTime date;

  const CrossBranchTransferLog({
    required this.id,
    required this.entityType,
    required this.entityName,
    required this.entityCode,
    required this.fromBranchName,
    required this.toBranchName,
    required this.reason,
    required this.status,
    required this.date,
  });

  factory CrossBranchTransferLog.fromJson(Map<String, dynamic> json) {
    return CrossBranchTransferLog(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      entityName: json['entityName'] as String,
      entityCode: json['entityCode'] as String,
      fromBranchName: json['fromBranchName'] as String,
      toBranchName: json['toBranchName'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class CrossBranchTransferNotifier
    extends StateNotifier<List<CrossBranchTransferLog>> {
  final ApiClient _apiClient;

  CrossBranchTransferNotifier(this._apiClient) : super(const []);

  /// Fetch active transfer requests from the backend database
  Future<void> fetchTransfers() async {
    try {
      final response = await _apiClient.dio.get('/organization/transfer');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>? ?? [];
        state = list
            .map((x) => CrossBranchTransferLog.fromJson(x as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching transfer requests: $e');
    }
  }

  /// Create a new inter-branch student/staff transfer request
  Future<bool> requestTransfer({
    required String entityType,
    required String entityName,
    required String entityCode,
    required String fromBranchName,
    required String toBranchName,
    required String reason,
  }) async {
    try {
      final response = await _apiClient.dio.post('/organization/transfer', data: {
        'entityType': entityType,
        'entityCode': entityCode,
        'fromBranchName': fromBranchName,
        'toBranchName': toBranchName,
        'reason': reason,
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        await fetchTransfers();
        return true;
      }
    } catch (e) {
      debugPrint('Error creating transfer request: $e');
    }
    return false;
  }
}

/// Provider for Cross-Branch Transfers list
final crossBranchTransferProvider = StateNotifierProvider<
    CrossBranchTransferNotifier, List<CrossBranchTransferLog>>((ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);
  final apiClient = ref.read(apiClientProvider);
  final notifier = CrossBranchTransferNotifier(apiClient);
  if (isLoggedIn) {
    notifier.fetchTransfers();
  }
  return notifier;
});

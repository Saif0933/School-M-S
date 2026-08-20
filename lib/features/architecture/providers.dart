import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// JWT Claims Payload Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class JwtClaims {
  final String sub;
  final String name;
  final String orgId;
  final String branchId;
  final String role;
  final int exp;

  const JwtClaims({
    required this.sub,
    required this.name,
    required this.orgId,
    required this.branchId,
    required this.role,
    required this.exp,
  });
}

final jwtClaimsProvider = Provider<JwtClaims>((ref) {
  return const JwtClaims(
    sub: 'USR-904812',
    name: 'Meenakshi Sundaram',
    orgId: 'ORG-001',
    branchId: 'BR-001',
    role: 'branchAdmin',
    exp: 1787268000, // 2026 exp epoch
  );
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Kubernetes Pod Replica Node Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class K8sPodStatus {
  final String podName;
  final String status; // 'Running', 'Scaling', 'Terminated'
  final double cpuUtilization;
  final double memoryUsageMb;

  const K8sPodStatus({
    required this.podName,
    required this.status,
    required this.cpuUtilization,
    required this.memoryUsageMb,
  });
}

class PodsNotifier extends StateNotifier<List<K8sPodStatus>> {
  PodsNotifier() : super([
    const K8sPodStatus(podName: 'sunrise-gateway-pod-7bf', status: 'Running', cpuUtilization: 14.5, memoryUsageMb: 184.0),
    const K8sPodStatus(podName: 'sunrise-auth-pod-12a', status: 'Running', cpuUtilization: 8.2, memoryUsageMb: 112.0),
    const K8sPodStatus(podName: 'sunrise-academic-pod-9e', status: 'Running', cpuUtilization: 22.0, memoryUsageMb: 245.0),
  ]);

  void scalePods() {
    state = [
      ...state,
      K8sPodStatus(
        podName: 'sunrise-academic-pod-scaled-${state.length + 1}',
        status: 'Running',
        cpuUtilization: 1.0,
        memoryUsageMb: 85.0,
      )
    ];
  }
}

final k8sPodsProvider = StateNotifierProvider<PodsNotifier, List<K8sPodStatus>>((ref) {
  return PodsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Org Webhook Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OrgWebhook {
  final String id;
  final String url;
  final List<String> eventTriggers;
  final bool active;

  const OrgWebhook({
    required this.id,
    required this.url,
    required this.eventTriggers,
    required this.active,
  });

  OrgWebhook copyWith({
    String? url,
    List<String>? eventTriggers,
    bool? active,
  }) {
    return OrgWebhook(
      id: id,
      url: url ?? this.url,
      eventTriggers: eventTriggers ?? this.eventTriggers,
      active: active ?? this.active,
    );
  }
}

class WebhooksNotifier extends StateNotifier<List<OrgWebhook>> {
  WebhooksNotifier() : super([
    const OrgWebhook(
      id: 'WEB-001',
      url: 'https://api.thirdparty.com/v1/students',
      eventTriggers: ['student.admitted'],
      active: true,
    ),
  ]);

  void addWebhook(String url, List<String> triggers) {
    state = [
      ...state,
      OrgWebhook(
        id: 'WEB-00${state.length + 1}',
        url: url,
        eventTriggers: triggers,
        active: true,
      ),
    ];
  }

  void removeWebhook(String id) {
    state = state.where((w) => w.id != id).toList();
  }
}

final orgWebhooksProvider = StateNotifierProvider<WebhooksNotifier, List<OrgWebhook>>((ref) {
  return WebhooksNotifier();
});

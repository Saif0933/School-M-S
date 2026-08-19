import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Notice Board Entity Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class NoticeEntity {
  final String id;
  final String branchId; // 'BR-001', 'BR-002' or 'ALL'
  final String title;
  final String content;
  final String category; // 'Academic', 'Administrative', 'Emergency', 'General'
  final String priority; // 'High', 'Medium', 'Low'
  final bool isPinned;
  final String publishedDate;
  final String? attachmentName;
  final int views;
  final List<String> acknowledgedBy; // List of user names/IDs

  const NoticeEntity({
    required this.id,
    required this.branchId,
    required this.title,
    required this.content,
    required this.category,
    required this.priority,
    required this.isPinned,
    required this.publishedDate,
    this.attachmentName,
    this.views = 0,
    this.acknowledgedBy = const [],
  });

  NoticeEntity copyWith({
    int? views,
    List<String>? acknowledgedBy,
  }) {
    return NoticeEntity(
      id: id,
      branchId: branchId,
      title: title,
      content: content,
      category: category,
      priority: priority,
      isPinned: isPinned,
      publishedDate: publishedDate,
      attachmentName: attachmentName,
      views: views ?? this.views,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
    );
  }
}

class NoticesNotifier extends StateNotifier<List<NoticeEntity>> {
  NoticesNotifier() : super([
    // Org-Wide Notice
    const NoticeEntity(
      id: 'NTC-ORG-01',
      branchId: 'ALL',
      title: 'Annual Day Consolidated Schedule 2026',
      content: 'The grand cultural convocation for all campus branches will commence from Dec 15th at the main stadium.',
      category: 'General',
      priority: 'Medium',
      isPinned: true,
      publishedDate: '2026-08-18',
      views: 142,
    ),
    // Delhi campus specific
    const NoticeEntity(
      id: 'NTC-DEL-01',
      branchId: 'BR-001',
      title: 'Water Pipe Maintenance Shutdown',
      content: 'Campuses toilet lines will undergo water system cleaning tonight between 8 PM to 12 PM. Use block B toilets.',
      category: 'Emergency',
      priority: 'High',
      isPinned: true,
      publishedDate: '2026-08-19',
      views: 95,
      attachmentName: 'blockB_map.png',
    ),
    const NoticeEntity(
      id: 'NTC-DEL-02',
      branchId: 'BR-001',
      title: 'Class 11 Science Laboratory Reschedule',
      content: 'Physics lab hours are shifted to Thursday afternoon. Prepare pre-lab proof sheets.',
      category: 'Academic',
      priority: 'Low',
      isPinned: false,
      publishedDate: '2026-08-19',
      views: 31,
    ),
  ]);

  void publishNotice(NoticeEntity notice) {
    state = [notice, ...state];
  }

  void incrementViews(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(views: n.views + 1) : n).toList();
  }

  void acknowledgeNotice(String id, String user) {
    state = state.map((n) {
      if (n.id == id) {
        final list = List<String>.from(n.acknowledgedBy);
        if (!list.contains(user)) {
          list.add(user);
        }
        return n.copyWith(acknowledgedBy: list);
      }
      return n;
    }).toList();
  }
}

final noticesProvider = StateNotifierProvider<NoticesNotifier, List<NoticeEntity>>((ref) {
  return NoticesNotifier();
});

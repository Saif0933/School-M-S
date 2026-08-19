import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Live Class Schedule Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LiveClassEntity {
  final String id;
  final String branchId;
  final String title;
  final String subject;
  final String time;
  final String platform; // 'Zoom', 'Google Meet', 'In-Platform'
  final String joinUrl;

  const LiveClassEntity({
    required this.id,
    required this.branchId,
    required this.title,
    required this.subject,
    required this.time,
    required this.platform,
    required this.joinUrl,
  });
}

class LiveClassesNotifier extends StateNotifier<List<LiveClassEntity>> {
  LiveClassesNotifier() : super([
    const LiveClassEntity(
      id: 'LC-DEL-01',
      branchId: 'BR-001',
      title: 'Vector Algebra Advanced Session',
      subject: 'Mathematics',
      time: 'Today, 02:00 PM',
      platform: 'In-Platform',
      joinUrl: 'https://meet.symbosys.com/del/math-vector',
    ),
    const LiveClassEntity(
      id: 'LC-MUM-01',
      branchId: 'BR-002',
      title: 'Organic Chemistry Reactions',
      subject: 'Chemistry',
      time: 'Tomorrow, 11:30 AM',
      platform: 'Zoom',
      joinUrl: 'https://zoom.us/j/9082348123',
    ),
  ]);

  void scheduleClass(LiveClassEntity lc) {
    state = [...state, lc];
  }
}

final liveClassesProvider = StateNotifierProvider<LiveClassesNotifier, List<LiveClassEntity>>((ref) {
  return LiveClassesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Recorded Video Library
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class RecordedVideoEntity {
  final String id;
  final String branchId;
  final String title;
  final String subject;
  final String duration;
  final String recordedDate;
  final String watchUrl;

  const RecordedVideoEntity({
    required this.id,
    required this.branchId,
    required this.title,
    required this.subject,
    required this.duration,
    required this.recordedDate,
    required this.watchUrl,
  });
}

class RecordedVideosNotifier extends StateNotifier<List<RecordedVideoEntity>> {
  RecordedVideosNotifier() : super([
    const RecordedVideoEntity(
      id: 'REC-DEL-01',
      branchId: 'BR-001',
      title: 'Newtonian Physics & Force Diagrams',
      subject: 'Physics',
      duration: '45 mins',
      recordedDate: '2026-08-15',
      watchUrl: 'https://youtube.com/watch?v=NewtonPhysics',
    ),
    const RecordedVideoEntity(
      id: 'REC-DEL-02',
      branchId: 'BR-001',
      title: 'Quadratic Equations Solver Formulas',
      subject: 'Mathematics',
      duration: '50 mins',
      recordedDate: '2026-08-16',
      watchUrl: 'https://youtube.com/watch?v=QuadEquations',
    ),
  ]);

  void addRecord(RecordedVideoEntity video) {
    state = [video, ...state];
  }
}

final recordedVideosProvider = StateNotifierProvider<RecordedVideosNotifier, List<RecordedVideoEntity>>((ref) {
  return RecordedVideosNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Study Material & Course Resources
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StudyMaterialEntity {
  final String id;
  final String branchId;
  final String title;
  final String subject;
  final String fileType; // 'PDF', 'PPT', 'Video', 'Audio'
  final String fileUrl;

  const StudyMaterialEntity({
    required this.id,
    required this.branchId,
    required this.title,
    required this.subject,
    required this.fileType,
    required this.fileUrl,
  });
}

class StudyMaterialNotifier extends StateNotifier<List<StudyMaterialEntity>> {
  StudyMaterialNotifier() : super([
    const StudyMaterialEntity(
      id: 'MAT-DEL-01',
      branchId: 'BR-001',
      title: 'Class 11 Thermodynamics Notes PDF',
      subject: 'Physics',
      fileType: 'PDF',
      fileUrl: 'materials/thermo_notes.pdf',
    ),
  ]);

  void addMaterial(StudyMaterialEntity mat) {
    state = [...state, mat];
  }
}

final studyMaterialProvider = StateNotifierProvider<StudyMaterialNotifier, List<StudyMaterialEntity>>((ref) {
  return StudyMaterialNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Discussion Forum Topic Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ForumTopicEntity {
  final String id;
  final String branchId;
  final String subject;
  final String title;
  final String poster;
  final List<String> replies;

  const ForumTopicEntity({
    required this.id,
    required this.branchId,
    required this.subject,
    required this.title,
    required this.poster,
    required this.replies,
  });

  ForumTopicEntity copyWith({List<String>? replies}) {
    return ForumTopicEntity(
      id: id,
      branchId: branchId,
      subject: subject,
      title: title,
      poster: poster,
      replies: replies ?? this.replies,
    );
  }
}

class ForumTopicsNotifier extends StateNotifier<List<ForumTopicEntity>> {
  ForumTopicsNotifier() : super([
    const ForumTopicEntity(
      id: 'FRM-DEL-01',
      branchId: 'BR-001',
      subject: 'Physics',
      title: 'Why is energy conserved in a closed loop?',
      poster: 'Aarav Sharma',
      replies: ['Because force is conservative!'],
    ),
  ]);

  void addTopic(ForumTopicEntity topic) {
    state = [...state, topic];
  }

  void addReply(String topicId, String reply) {
    state = state.map((t) {
      if (t.id == topicId) {
        return t.copyWith(replies: [...t.replies, reply]);
      }
      return t;
    }).toList();
  }
}

final forumTopicsProvider = StateNotifierProvider<ForumTopicsNotifier, List<ForumTopicEntity>>((ref) {
  return ForumTopicsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Gamification & XP Leaderboard
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LeaderboardUser {
  final String id;
  final String name;
  final int xpPoints;
  final List<String> badges;

  const LeaderboardUser({
    required this.id,
    required this.name,
    required this.xpPoints,
    required this.badges,
  });

  LeaderboardUser copyWith({int? xpPoints, List<String>? badges}) {
    return LeaderboardUser(
      id: id,
      name: name,
      xpPoints: xpPoints ?? this.xpPoints,
      badges: badges ?? this.badges,
    );
  }
}

class LeaderboardNotifier extends StateNotifier<List<LeaderboardUser>> {
  LeaderboardNotifier() : super([
    const LeaderboardUser(id: 'STU-01', name: 'Aarav Sharma', xpPoints: 340, badges: ['Code Master', 'Quiz Whiz']),
    const LeaderboardUser(id: 'STU-02', name: 'Sachin Tendulkar', xpPoints: 310, badges: ['Perfect Attendance']),
    const LeaderboardUser(id: 'STU-03', name: 'Sunita Rao', xpPoints: 280, badges: ['Curious Mind']),
  ]);

  void awardXP(String id, int points) {
    state = state.map((u) => u.id == id ? u.copyWith(xpPoints: u.xpPoints + points) : u).toList();
  }

  void awardBadge(String id, String badge) {
    state = state.map((u) {
      if (u.id == id && !u.badges.contains(badge)) {
        return u.copyWith(badges: [...u.badges, badge]);
      }
      return u;
    }).toList();
  }
}

final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, List<LeaderboardUser>>((ref) {
  return LeaderboardNotifier();
});

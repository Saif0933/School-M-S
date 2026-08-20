import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Predictive Dropout Risk Student Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StudentRiskModel {
  final String studentName;
  final String classId;
  final double dropoutRiskPct;
  final String status; // 'Safe', 'Warning', 'Critical'
  final String keyFactors;

  const StudentRiskModel({
    required this.studentName,
    required this.classId,
    required this.dropoutRiskPct,
    required this.status,
    required this.keyFactors,
  });
}

final dropoutPredictorProvider = Provider<List<StudentRiskModel>>((ref) {
  return const [
    StudentRiskModel(
      studentName: 'Aarav Sharma',
      classId: 'Class 11 Science',
      dropoutRiskPct: 8.5,
      status: 'Safe',
      keyFactors: 'High attendance (94%), steady midterm test performance.',
    ),
    StudentRiskModel(
      studentName: 'Sunita Rao',
      classId: 'Class 11 Commerce',
      dropoutRiskPct: 42.0,
      status: 'Warning',
      keyFactors: 'Decline in weekly homework submissions. Late fee alert active.',
    ),
  ];
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// NLQ Query Log Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class NlqQueryLog {
  final String queryText;
  final String resultSummary;
  final List<Map<String, String>> resultTable;

  const NlqQueryLog({required this.queryText, required this.resultSummary, required this.resultTable});
}

class NlqQueriesNotifier extends StateNotifier<List<NlqQueryLog>> {
  NlqQueriesNotifier() : super([
    const NlqQueryLog(
      queryText: 'Show top 10 students of Branch Delhi',
      resultSummary: 'Found 10 students matching academic rank metrics in Sunrise International School - Delhi.',
      resultTable: [
        {'Rank': '1', 'Student': 'Aarav Sharma', 'GPA': '9.8'},
        {'Rank': '2', 'Student': 'Sunita Rao', 'GPA': '9.2'},
      ],
    ),
  ]);

  void runQuery(String query) {
    // Simulated NLQ engine matches keywords
    final lower = query.toLowerCase();
    String summary = 'Query executed. Mapped matching parameters across branch databases.';
    List<Map<String, String>> table = [];

    if (lower.contains('top') || lower.contains('student')) {
      summary = 'Consolidated highest performing student records for active campus.';
      table = [
        {'Student': 'Aarav Sharma', 'GPA': '9.8', 'Subject': 'Physics'},
        {'Student': 'Sunita Rao', 'GPA': '9.2', 'Subject': 'Math'},
      ];
    } else if (lower.contains('fee') || lower.contains('outstanding')) {
      summary = 'Identified pending fee collection records across branch finance registries.';
      table = [
        {'Student': 'Sunita Rao', 'Pending': '₹12,500', 'Due': '2026-08-20'},
      ];
    } else {
      table = [
        {'Field': 'Parameters matches', 'Metric': 'Verified compliance check'},
      ];
    }

    state = [NlqQueryLog(queryText: query, resultSummary: summary, resultTable: table), ...state];
  }
}

final nlqQueriesProvider = StateNotifierProvider<NlqQueriesNotifier, List<NlqQueryLog>>((ref) {
  return NlqQueriesNotifier();
});

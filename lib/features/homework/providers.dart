import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Homework Assignment Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HomeworkEntity {
  final String id;
  final String branchId;
  final String classId;
  final String subject;
  final String title;
  final String description;
  final String dueDate; // YYYY-MM-DD
  final String attachmentType; // 'PDF', 'Image', 'Video', 'Link'
  final String attachmentName;
  final bool isTemplate;

  const HomeworkEntity({
    required this.id,
    required this.branchId,
    required this.classId,
    required this.subject,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.attachmentType,
    required this.attachmentName,
    this.isTemplate = false,
  });
}

class HomeworkNotifier extends StateNotifier<List<HomeworkEntity>> {
  HomeworkNotifier() : super([
    const HomeworkEntity(
      id: 'HW-DEL-01',
      branchId: 'BR-001',
      classId: 'Class 11',
      subject: 'Physics',
      title: 'Thermodynamics Laws Exercises',
      description: 'Solve questions 1 to 10 from Chapter 3 workbook.',
      dueDate: '2026-08-22',
      attachmentType: 'PDF',
      attachmentName: 'thermo_chapter3.pdf',
    ),
    const HomeworkEntity(
      id: 'HW-DEL-02',
      branchId: 'BR-001',
      classId: 'Class 11',
      subject: 'Mathematics',
      title: 'Vector Cross-Product Proofs',
      description: 'Prove the cross-product distributive property.',
      dueDate: '2026-08-25',
      attachmentType: 'Link',
      attachmentName: 'https://youtube.com/math-vector-proof',
    ),
    const HomeworkEntity(
      id: 'HW-MUM-01',
      branchId: 'BR-002',
      classId: 'Class 12',
      subject: 'Chemistry',
      title: 'Benzene Ring Structure Drawing',
      description: 'Draw the resonating structures of Benzene.',
      dueDate: '2026-08-20',
      attachmentType: 'Image',
      attachmentName: 'benzene_kekule.png',
    ),
  ]);

  void addHomework(HomeworkEntity hw) {
    state = [...state, hw];
  }
}

final homeworkProvider = StateNotifierProvider<HomeworkNotifier, List<HomeworkEntity>>((ref) {
  return HomeworkNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Student Submission Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HomeworkSubmission {
  final String id;
  final String homeworkId;
  final String studentName;
  final String submissionDate;
  final String onlineAnswer;
  final String? photoUrl; // Handwritten photo
  final bool isLate;
  final String status; // 'Submitted', 'Graded'
  final int? marksAwarded;
  final String? feedbackRemarks;
  final double plagiarismMatch; // 0.0 to 100.0

  const HomeworkSubmission({
    required this.id,
    required this.homeworkId,
    required this.studentName,
    required this.submissionDate,
    required this.onlineAnswer,
    this.photoUrl,
    required this.isLate,
    required this.status,
    this.marksAwarded,
    this.feedbackRemarks,
    this.plagiarismMatch = 0.0,
  });

  HomeworkSubmission copyWith({
    String? status,
    int? marksAwarded,
    String? feedbackRemarks,
    double? plagiarismMatch,
  }) {
    return HomeworkSubmission(
      id: id,
      homeworkId: homeworkId,
      studentName: studentName,
      submissionDate: submissionDate,
      onlineAnswer: onlineAnswer,
      photoUrl: photoUrl,
      isLate: isLate,
      status: status ?? this.status,
      marksAwarded: marksAwarded ?? this.marksAwarded,
      feedbackRemarks: feedbackRemarks ?? this.feedbackRemarks,
      plagiarismMatch: plagiarismMatch ?? this.plagiarismMatch,
    );
  }
}

class SubmissionsNotifier extends StateNotifier<List<HomeworkSubmission>> {
  SubmissionsNotifier() : super([
    const HomeworkSubmission(
      id: 'SUB-DEL-01',
      homeworkId: 'HW-DEL-01',
      studentName: 'Aarav Sharma',
      submissionDate: '2026-08-19',
      onlineAnswer: 'Q1: Conservation of internal energy holds delta U = Q - W. Completed exercises in attachment.',
      photoUrl: 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe',
      isLate: false,
      status: 'Submitted',
    ),
  ]);

  void addSubmission(HomeworkSubmission sub) {
    state = [sub, ...state];
  }

  void gradeSubmission(String id, int marks, String feedback, double plagiarism) {
    state = state.map((s) {
      if (s.id == id) {
        return s.copyWith(
          status: 'Graded',
          marksAwarded: marks,
          feedbackRemarks: feedback,
          plagiarismMatch: plagiarism,
        );
      }
      return s;
    }).toList();
  }
}

final submissionsProvider = StateNotifierProvider<SubmissionsNotifier, List<HomeworkSubmission>>((ref) {
  return SubmissionsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Homework Templates List
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
final homeworkTemplatesProvider = Provider<List<HomeworkEntity>>((ref) {
  return const [
    HomeworkEntity(
      id: 'TMP-01',
      branchId: 'ALL',
      classId: 'Class 11',
      subject: 'Physics',
      title: 'Midterm Revision Sheet Template',
      description: 'Standard revision guidelines covering kinematics and mechanics.',
      dueDate: '',
      attachmentType: 'PDF',
      attachmentName: 'mechanics_revision.pdf',
      isTemplate: true,
    ),
  ];
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Report Template Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ReportTemplateEntity {
  final String id;
  final String name;
  final String category; // 'Academic', 'Finance', 'Logistics', 'Compliance'
  final String description;
  final bool isBookmarked;

  const ReportTemplateEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.isBookmarked = false,
  });

  ReportTemplateEntity copyWith({bool? isBookmarked}) {
    return ReportTemplateEntity(
      id: id,
      name: name,
      category: category,
      description: description,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class ReportTemplatesNotifier extends StateNotifier<List<ReportTemplateEntity>> {
  ReportTemplatesNotifier() : super([
    // Academic (15 templates represented by core categories)
    const ReportTemplateEntity(id: 'AC-01', name: 'Class-wise Subject Grade Averages', category: 'Academic', description: 'Lists gross score averages and letter grades per subject.'),
    const ReportTemplateEntity(id: 'AC-02', name: 'Student Attendance Summary (Monthly)', category: 'Academic', description: 'Attendance logs, half days, and sick leave percentages.'),
    const ReportTemplateEntity(id: 'AC-03', name: 'Branch Merit List Toppers Roll', category: 'Academic', description: 'Lists top 3 students by cumulative exam scoring.'),
    const ReportTemplateEntity(id: 'AC-04', name: 'Compartment & ATKT Defaulters', category: 'Academic', description: 'Lists students failing in one or more papers.'),
    const ReportTemplateEntity(id: 'AC-05', name: 'Teacher Subject Syllabus Coverage', category: 'Academic', description: 'Syllabus completion percentages reported by teachers.'),
    
    // Finance (15 templates)
    const ReportTemplateEntity(id: 'FN-01', name: 'Daily Cash Book Collections Ledger', category: 'Finance', description: 'Itemized collections categorized by cashiers and payment modes.'),
    const ReportTemplateEntity(id: 'FN-02', name: 'Outstanding Overdue Fees & Late Fines', category: 'Finance', description: 'Defaulters list with accumulated fine rates and penalty days.'),
    const ReportTemplateEntity(id: 'FN-03', name: 'Income and Expenditure Statement', category: 'Finance', description: 'Branch gross revenue vs operating expenses cash ledger.'),
    const ReportTemplateEntity(id: 'FN-04', name: 'Consolidated General Trial Balance', category: 'Finance', description: 'Debit vs credit summary across active branch ledger accounts.'),
    const ReportTemplateEntity(id: 'FN-05', name: 'Vendor Procurement Payment Audit', category: 'Finance', description: 'Unpaid purchase invoices vs cleared vendor bills.'),

    // Logistics (10 templates)
    const ReportTemplateEntity(id: 'LG-01', name: 'Bus Route Fleet Running Costs', category: 'Logistics', description: 'Fuel expenses, repairs, driver logs, and cost per student.'),
    const ReportTemplateEntity(id: 'LG-02', name: 'Hostel Building Occupancy & Mess Logs', category: 'Logistics', description: 'Available beds, room cleanings, and mess attendance counts.'),
    const ReportTemplateEntity(id: 'LG-03', name: 'Library Book Stock & Overdue Fines', category: 'Logistics', description: 'Total catalog count, current issues, and unpaid library fines.'),

    // Compliance (10 templates)
    const ReportTemplateEntity(id: 'CP-01', name: 'Affiliation Board Compliance Review', category: 'Compliance', description: 'Teacher ratios, lab resources, and safety clearance dates.'),
    const ReportTemplateEntity(id: 'CP-02', name: 'State Government Scholarship Allocation', category: 'Compliance', description: 'List of students receiving OBC/SC/ST government waivers.'),
  ]);

  void toggleBookmark(String id) {
    state = state.map((r) => r.id == id ? r.copyWith(isBookmarked: !r.isBookmarked) : r).toList();
  }
}

final reportTemplatesProvider = StateNotifierProvider<ReportTemplatesNotifier, List<ReportTemplateEntity>>((ref) {
  return ReportTemplatesNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Scheduled Report Dispatcher
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ScheduledReportEntity {
  final String id;
  final String templateName;
  final String email;
  final String frequency; // 'Daily', 'Weekly', 'Monthly'
  final String status;

  const ScheduledReportEntity({
    required this.id,
    required this.templateName,
    required this.email,
    required this.frequency,
    required this.status,
  });
}

class ScheduledReportsNotifier extends StateNotifier<List<ScheduledReportEntity>> {
  ScheduledReportsNotifier() : super([
    const ScheduledReportEntity(
      id: 'SCH-01',
      templateName: 'Daily Cash Book Collections Ledger',
      email: 'finance.head@school.com',
      frequency: 'Daily',
      status: 'Active',
    ),
  ]);

  void scheduleReport(ScheduledReportEntity sch) {
    state = [sch, ...state];
  }

  void removeSchedule(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final scheduledReportsProvider = StateNotifierProvider<ScheduledReportsNotifier, List<ScheduledReportEntity>>((ref) {
  return ScheduledReportsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Predictive Analytics Engine
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class PredictiveMetricsEntity {
  final String branchId;
  final double currentEnrollment;
  final double projectedEnrollment;
  final double currentRevenue;
  final double projectedRevenue;
  final String growthTrend; // 'Stable', 'Strong Growth', 'Decline'

  const PredictiveMetricsEntity({
    required this.branchId,
    required this.currentEnrollment,
    required this.projectedEnrollment,
    required this.currentRevenue,
    required this.projectedRevenue,
    required this.growthTrend,
  });
}

final predictiveAnalyticsProvider = Provider<List<PredictiveMetricsEntity>>((ref) {
  return const [
    PredictiveMetricsEntity(
      branchId: 'BR-001',
      currentEnrollment: 240,
      projectedEnrollment: 275, // +14.5% based on past admission enquiries
      currentRevenue: 315000.0,
      projectedRevenue: 360000.0,
      growthTrend: 'Strong Growth',
    ),
    PredictiveMetricsEntity(
      branchId: 'BR-002',
      currentEnrollment: 180,
      projectedEnrollment: 195, // +8.3%
      currentRevenue: 185000.0,
      projectedRevenue: 200000.0,
      growthTrend: 'Stable',
    ),
  ];
});

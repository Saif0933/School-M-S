import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Event Entity Model
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SchoolEventEntity {
  final String id;
  final String branchId; // 'BR-001', 'BR-002' or 'ALL' (Org-wide)
  final String title;
  final String description;
  final String date; // YYYY-MM-DD
  final String category; // 'Academic', 'Sports', 'Cultural', 'Exam', 'Org-Wide'
  final String venue;
  final double budget;
  final List<String> volunteers;
  final List<String> rsvps; // List of student/staff IDs attending
  final bool isRecurring; // e.g. weekly assembly

  const SchoolEventEntity({
    required this.id,
    required this.branchId,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.venue,
    required this.budget,
    this.volunteers = const [],
    this.rsvps = const [],
    this.isRecurring = false,
  });

  SchoolEventEntity copyWith({
    List<String>? volunteers,
    List<String>? rsvps,
  }) {
    return SchoolEventEntity(
      id: id,
      branchId: branchId,
      title: title,
      description: description,
      date: date,
      category: category,
      venue: venue,
      budget: budget,
      volunteers: volunteers ?? this.volunteers,
      rsvps: rsvps ?? this.rsvps,
      isRecurring: isRecurring,
    );
  }
}

class EventsNotifier extends StateNotifier<List<SchoolEventEntity>> {
  EventsNotifier() : super([
    // Org-wide events
    const SchoolEventEntity(
      id: 'EVT-ORG-01',
      branchId: 'ALL',
      title: 'Sunrise Consolidated Sports Meet',
      description: 'Annual inter-branch athletics tournament hosted in Delhi.',
      date: '2026-08-25',
      category: 'Org-Wide',
      venue: 'Main Campus Stadium (Delhi)',
      budget: 150000.0,
      volunteers: ['Aarav Sharma', 'Sachin Tendulkar'],
      rsvps: ['Aarav Sharma', 'Sachin Tendulkar'],
    ),
    // Delhi campus specific
    const SchoolEventEntity(
      id: 'EVT-DEL-01',
      branchId: 'BR-001',
      title: 'Class 11 Chemistry Term Assessment',
      description: 'First midterm written paper on Thermodynamics.',
      date: '2026-08-20',
      category: 'Exam',
      venue: 'Exam Hall B',
      budget: 2000.0,
    ),
    const SchoolEventEntity(
      id: 'EVT-DEL-02',
      branchId: 'BR-001',
      title: 'Delhi Branch Cultural Fest',
      description: 'Music, theater, and arts intra-campus event.',
      date: '2026-08-28',
      category: 'Cultural',
      venue: 'Delhi Auditorium',
      budget: 45000.0,
      volunteers: ['Aarav Sharma'],
    ),
    // Mumbai campus specific
    const SchoolEventEntity(
      id: 'EVT-MUM-01',
      branchId: 'BR-002',
      title: 'Mumbai Primary Picnic',
      description: 'Fun day out at Imagica Theme park for primary students.',
      date: '2026-08-22',
      category: 'Cultural',
      venue: 'Imagica Park',
      budget: 60000.0,
      volunteers: ['Sachin Tendulkar'],
    ),
  ]);

  void addEvent(SchoolEventEntity event) {
    state = [...state, event];
  }

  void toggleRsvp(String id, String studentName) {
    state = state.map((e) {
      if (e.id == id) {
        final list = List<String>.from(e.rsvps);
        if (list.contains(studentName)) {
          list.remove(studentName);
        } else {
          list.add(studentName);
        }
        return e.copyWith(rsvps: list);
      }
      return e;
    }).toList();
  }

  void assignVolunteer(String id, String name) {
    state = state.map((e) {
      if (e.id == id) {
        final list = List<String>.from(e.volunteers);
        if (!list.contains(name)) {
          list.add(name);
        }
        return e.copyWith(volunteers: list);
      }
      return e;
    }).toList();
  }
}

final eventsProvider = StateNotifierProvider<EventsNotifier, List<SchoolEventEntity>>((ref) {
  return EventsNotifier();
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Holiday Model per Branch
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HolidayEntity {
  final String id;
  final String branchId; // 'BR-001', 'BR-002' or 'ALL'
  final String name;
  final String date;

  const HolidayEntity({
    required this.id,
    required this.branchId,
    required this.name,
    required this.date,
  });
}

final holidaysProvider = Provider<List<HolidayEntity>>((ref) {
  return const [
    HolidayEntity(id: 'HOL-01', branchId: 'ALL', name: 'Independence Day break', date: '2026-08-15'),
    HolidayEntity(id: 'HOL-02', branchId: 'ALL', name: 'Ganesh Chaturthi festival', date: '2026-09-07'),
    HolidayEntity(id: 'HOL-03', branchId: 'BR-001', name: 'Delhi local local holiday', date: '2026-08-29'),
  ];
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Event Feedback System
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class EventFeedbackEntity {
  final String id;
  final String eventId;
  final String author;
  final double rating; // 1 to 5 stars
  final String comment;

  const EventFeedbackEntity({
    required this.id,
    required this.eventId,
    required this.author,
    required this.rating,
    required this.comment,
  });
}

class EventFeedbackNotifier extends StateNotifier<List<EventFeedbackEntity>> {
  EventFeedbackNotifier() : super([
    const EventFeedbackEntity(id: 'FDB-01', eventId: 'EVT-ORG-01', author: 'Parent of Aarav', rating: 5.0, comment: 'Amazing coordination, the kids had a blast!'),
  ]);

  void submitFeedback(EventFeedbackEntity feedback) {
    state = [...state, feedback];
  }
}

final eventFeedbackProvider = StateNotifierProvider<EventFeedbackNotifier, List<EventFeedbackEntity>>((ref) {
  return EventFeedbackNotifier();
});

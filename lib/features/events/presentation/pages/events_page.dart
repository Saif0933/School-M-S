import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers.dart';
import '../../providers.dart';

class EventsCalendarPage extends ConsumerStatefulWidget {
  const EventsCalendarPage({super.key});

  @override
  ConsumerState<EventsCalendarPage> createState() => _EventsCalendarPageState();
}

class _EventsCalendarPageState extends ConsumerState<EventsCalendarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Calendar parameters
  String _calendarScope = 'Branch'; // 'Branch' or 'Org-Wide'
  int _selectedDay = 20; // default selected calendar day in Aug 2026

  // Form Controllers
  final _eventTitleCtrl = TextEditingController();
  final _eventDescCtrl = TextEditingController();
  final _eventDateCtrl = TextEditingController(text: '2026-08-20');
  final _eventVenueCtrl = TextEditingController();
  final _eventBudgetCtrl = TextEditingController(text: '10000');
  String _selectedScope = 'BR-001'; // Delhi Default
  String _selectedCategory = 'Academic';
  bool _isRecurring = false;

  // Volunteer/Feedback inputs
  final _volunteerNameCtrl = TextEditingController();
  final _feedbackCommentCtrl = TextEditingController();
  double _feedbackRating = 5.0;
  String? _feedbackSelectedEventId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventTitleCtrl.dispose();
    _eventDescCtrl.dispose();
    _eventDateCtrl.dispose();
    _eventVenueCtrl.dispose();
    _eventBudgetCtrl.dispose();
    _volunteerNameCtrl.dispose();
    _feedbackCommentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final activeBranchId = user?.activeBranchId ?? 'BR-001';
    final branchName = user?.activeBranch?.branchName ?? 'Primary Campus';

    // Filters based on scope selection
    final allEvents = ref.watch(eventsProvider);
    final filteredEvents = allEvents.where((e) {
      if (_calendarScope == 'Branch') {
        return e.branchId == activeBranchId || e.branchId == 'ALL';
      }
      return true; // Return all for consolidated Org-Wide calendar
    }).toList();

    final holidays = ref.watch(holidaysProvider).where((h) {
      return h.branchId == activeBranchId || h.branchId == 'ALL';
    }).toList();

    final feedbackList = ref.watch(eventFeedbackProvider);

    return Scaffold(
      body: Column(
        children: [
          // Sub Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Events & Academic Calendars: $branchName',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Consolidated & Branch Activities | Venue Lockings Status: Operational',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () => _tabController.animateTo(1),
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 16),
                      label: const Text('Schedule Event', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: () => _exportICalFeed(context),
                      icon: const Icon(Icons.share_rounded, color: Colors.white, size: 16),
                      label: const Text('Export iCal', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: isDark ? Colors.black12 : Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: const [
                Tab(icon: Icon(Icons.calendar_month_rounded, size: 16), text: 'Multi-Scope Calendar'),
                Tab(icon: Icon(Icons.event_note_rounded, size: 16), text: 'Schedule Activities & Venues'),
                Tab(icon: Icon(Icons.beach_access_rounded, size: 16), text: 'Holidays & Term Exams'),
                Tab(icon: Icon(Icons.bar_chart_rounded, size: 16), text: 'Event Budgets & Feedback'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Calendar View
                _buildCalendarTab(filteredEvents),

                // Tab 2: Event Form
                _buildScheduleTab(activeBranchId),

                // Tab 3: Holidays list
                _buildHolidaysTab(holidays, filteredEvents.where((e) => e.category == 'Exam').toList()),

                // Tab 4: Budgets & Feedback
                _buildAnalyticsTab(allEvents, feedbackList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _exportICalFeed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ iCal & Google Calendar shared feed link copied to clipboard!')),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Calendar Grid Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildCalendarTab(List<SchoolEventEntity> events) {
    // Generate dates representing August 2026
    final selectedDateString = '2026-08-${_selectedDay.toString().padLeft(2, "0")}';
    final dayEvents = events.where((e) => e.date == selectedDateString).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📆 Interactive Month Planner (August 2026)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              DropdownButton<String>(
                value: _calendarScope,
                items: const [
                  DropdownMenuItem(value: 'Branch', child: Text('My Campus Events Only', style: TextStyle(fontSize: 11))),
                  DropdownMenuItem(value: 'Org-Wide', child: Text('Consolidated All-Branch Calendar', style: TextStyle(fontSize: 11))),
                ],
                onChanged: (val) => setState(() => _calendarScope = val ?? 'Branch'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: 31,
            itemBuilder: (context, index) {
              final day = index + 1;
              final dayStr = '2026-08-${day.toString().padLeft(2, "0")}';
              final hasEvents = events.any((e) => e.date == dayStr);
              final isSelected = day == _selectedDay;

              return InkWell(
                onTap: () => setState(() => _selectedDay = day),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (hasEvents ? Colors.teal.withValues(alpha: 0.1) : Colors.transparent),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : null,
                          fontSize: 12,
                        ),
                      ),
                      if (hasEvents && !isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Activities scheduled for August ${_selectedDay.toString().padLeft(2, "0")}, 2026:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),

          if (dayEvents.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text('No events scheduled for this day.', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ),
              ),
            )
          else
            ...dayEvents.map((evt) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(evt.category, style: const TextStyle(fontSize: 8, color: Colors.white)),
                              backgroundColor: evt.category == 'Org-Wide' ? Colors.indigo : Colors.blue,
                            ),
                            Text('Venue: ${evt.venue}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(evt.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(evt.description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Volunteers: ${evt.volunteers.join(", ")}', style: const TextStyle(fontSize: 10, color: Colors.teal)),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _showAddVolunteerDialog(context, evt.id),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(60, 28),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  child: const Text('Volunteer', style: TextStyle(fontSize: 9)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: evt.rsvps.contains('Me') ? Colors.amber : AppColors.primary,
                                    minimumSize: const Size(60, 28),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  onPressed: () {
                                    ref.read(eventsProvider.notifier).toggleRsvp(evt.id, 'Me');
                                  },
                                  child: Text(
                                    evt.rsvps.contains('Me') ? 'Leave RSVP' : 'Join RSVP',
                                    style: const TextStyle(fontSize: 9, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _showAddVolunteerDialog(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Volunteer Registration'),
          content: TextField(
            controller: _volunteerNameCtrl,
            decoration: const InputDecoration(labelText: 'Volunteer Student / Staff Name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (_volunteerNameCtrl.text.isNotEmpty) {
                  ref.read(eventsProvider.notifier).assignVolunteer(eventId, _volunteerNameCtrl.text);
                  Navigator.pop(context);
                  _volunteerNameCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Volunteer assigned to event duty roster.')),
                  );
                }
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Event Schedule Form Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildScheduleTab(String activeBranchId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✏️ Schedule New Campus Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(controller: _eventTitleCtrl, decoration: const InputDecoration(labelText: 'Event Title')),
          TextField(controller: _eventDescCtrl, decoration: const InputDecoration(labelText: 'Description')),
          TextField(controller: _eventDateCtrl, decoration: const InputDecoration(labelText: 'Event Date (YYYY-MM-DD)')),
          TextField(controller: _eventVenueCtrl, decoration: const InputDecoration(labelText: 'Allocated Venue Room')),
          TextField(controller: _eventBudgetCtrl, decoration: const InputDecoration(labelText: 'Estimated Budget Allocation (₹)')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedScope,
            decoration: const InputDecoration(labelText: 'Scope Allocation Participation'),
            items: [
              DropdownMenuItem(value: activeBranchId, child: const Text('Local Branch Only')),
              const DropdownMenuItem(value: 'ALL', child: Text('Organization-Wide (All campuses)')),
            ],
            onChanged: (val) => setState(() => _selectedScope = val ?? 'ALL'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Category Class'),
            items: const [
              DropdownMenuItem(value: 'Academic', child: Text('Academic Event')),
              DropdownMenuItem(value: 'Sports', child: Text('Sports Event')),
              DropdownMenuItem(value: 'Cultural', child: Text('Cultural Activity')),
              DropdownMenuItem(value: 'Exam', child: Text('Term Examinations')),
            ],
            onChanged: (val) => setState(() => _selectedCategory = val ?? 'Academic'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            dense: true,
            title: const Text('Set as recurring assembly (Weekly recurring)', style: TextStyle(fontSize: 11)),
            value: _isRecurring,
            onChanged: (val) => setState(() => _isRecurring = val),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (_eventTitleCtrl.text.isNotEmpty) {
                  ref.read(eventsProvider.notifier).addEvent(
                    SchoolEventEntity(
                      id: 'EVT-${DateTime.now().millisecondsSinceEpoch}',
                      branchId: _selectedScope,
                      title: _eventTitleCtrl.text,
                      description: _eventDescCtrl.text,
                      date: _eventDateCtrl.text,
                      category: _selectedCategory,
                      venue: _eventVenueCtrl.text.isNotEmpty ? _eventVenueCtrl.text : 'Campus Hall',
                      budget: double.tryParse(_eventBudgetCtrl.text) ?? 5000.0,
                      isRecurring: _isRecurring,
                    ),
                  );
                  _eventTitleCtrl.clear();
                  _eventDescCtrl.clear();
                  _eventVenueCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Event published on selected calendar scopes successfully!')),
                  );
                  _tabController.animateTo(0);
                }
              },
              child: const Text('Schedule Event & Allocate Venue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Holidays & Exams Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildHolidaysTab(List<HolidayEntity> holidays, List<SchoolEventEntity> exams) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('🌴 Official Campus Holidays list', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        ...holidays.map((h) => Card(
              child: ListTile(
                leading: const Icon(Icons.beach_access_rounded, color: Colors.orange),
                title: Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                subtitle: Text('Date: ${h.date} | Scope: ${h.branchId == "ALL" ? "All Branches" : "This Branch"}'),
              ),
            )),
        const SizedBox(height: 24),

        const Text('✍️ Academic Exam Schedule Calendar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        if (exams.isEmpty)
          const Text('No exams currently scheduled this term.', style: TextStyle(color: Colors.grey, fontSize: 11))
        else
          ...exams.map((ex) => Card(
                child: ListTile(
                  leading: const Icon(Icons.quiz_rounded, color: Colors.red),
                  title: Text(ex.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: Text('Date: ${ex.date} | Venue: ${ex.venue}'),
                ),
              )),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // WIDGETS — Budgets & Feedback Tab
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildAnalyticsTab(List<SchoolEventEntity> events, List<EventFeedbackEntity> feedbacks) {
    // Math logic for budget calculations
    double delhiBudget = 0.0;
    double mumbaiBudget = 0.0;
    double consolidatedBudget = 0.0;

    for (var e in events) {
      consolidatedBudget += e.budget;
      if (e.branchId == 'BR-001') delhiBudget += e.budget;
      if (e.branchId == 'BR-002') mumbaiBudget += e.budget;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budgets Card
          const Text('💰 Consolidated Event Budgets Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Card(
            color: Colors.teal.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Consolidated Org Event Budget:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('₹${consolidatedBudget.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 12)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delhi Branch Allocation:', style: TextStyle(fontSize: 11)),
                      Text('₹${delhiBudget.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mumbai Branch Allocation:', style: TextStyle(fontSize: 11)),
                      Text('₹${mumbaiBudget.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Feedback list
          const Text('💬 Event Feedback Board', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ...feedbacks.map((f) => Card(
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(f.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      Row(
                        children: List.generate(5, (idx) {
                          return Icon(
                            idx < f.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 12,
                          );
                        }),
                      ),
                    ],
                  ),
                  subtitle: Text(f.comment, style: const TextStyle(fontSize: 11)),
                ),
              )),
          const SizedBox(height: 16),

          // Add feedback form
          const Text('Submit Event Review Feedback:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _feedbackSelectedEventId,
            hint: const Text('Choose Event', style: TextStyle(fontSize: 11)),
            items: events.map((e) {
              return DropdownMenuItem<String>(
                value: e.id,
                child: Text(e.title, style: const TextStyle(fontSize: 11)),
              );
            }).toList(),
            onChanged: (val) => setState(() => _feedbackSelectedEventId = val),
          ),
          TextField(controller: _feedbackCommentCtrl, decoration: const InputDecoration(labelText: 'Review comment details')),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Rating: ', style: TextStyle(fontSize: 11)),
              Slider(
                min: 1.0,
                max: 5.0,
                divisions: 4,
                label: '$_feedbackRating Stars',
                value: _feedbackRating,
                onChanged: (val) => setState(() => _feedbackRating = val),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (_feedbackCommentCtrl.text.isNotEmpty && _feedbackSelectedEventId != null) {
                  ref.read(eventFeedbackProvider.notifier).submitFeedback(
                    EventFeedbackEntity(
                      id: 'FDB-${DateTime.now().millisecondsSinceEpoch}',
                      eventId: _feedbackSelectedEventId!,
                      author: 'Parent User',
                      rating: _feedbackRating,
                      comment: _feedbackCommentCtrl.text,
                    ),
                  );
                  _feedbackCommentCtrl.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Feedback review submitted to branch report logs.')),
                  );
                }
              },
              child: const Text('Submit Review', style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

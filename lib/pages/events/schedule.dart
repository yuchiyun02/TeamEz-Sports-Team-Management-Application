import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/models/events_model.dart';
import 'package:teamez/pages/events/add_edit_event.dart';
import 'package:teamez/widgets/general/appbar_title.dart';
import 'package:teamez/widgets/general/custom_fab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamez/pages/events/view_event.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime today = DateTime.now();
  DateTime? _selectedDay;
  List<Event> allEvents = [];
  Map<DateTime, List<Event>> markers = {};
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(today);
    _loadEvents();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = _normalizeDate(day);
    });
  }

  void _loadEvents() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).collection('events').get();

    List<Event> loadedEvents = [];
    Map<DateTime, List<Event>> tempMarkers = {};

    for (var doc in snapshot.docs) {
      final event = Event.fromFirestore(doc);
      loadedEvents.add(event);

      final markerDay = _normalizeDate(event.dateFrom);
      tempMarkers.putIfAbsent(markerDay, () => []).add(event);
    }

    setState(() {
      allEvents = loadedEvents;
      markers = tempMarkers;
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    final selected = _normalizeDate(day);
    return allEvents.where((event) {
      final from = _normalizeDate(event.dateFrom);
      final to = _normalizeDate(event.dateTo);
      return (selected.isAtSameMomentAs(from) ||
          selected.isAtSameMomentAs(to) ||
          (selected.isAfter(from) && selected.isBefore(to)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? today;

    return Scaffold(
      appBar: AppBarTitle(title: "Schedule"),
      backgroundColor: CustomCol.bgGreen,
      floatingActionButton: CustomFAB(destination: AddEditEventPage(isEdit: false)),
      body: Column(
        children: [
          TableCalendar<Event>(
            rowHeight: 43,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markersAlignment: Alignment.bottomCenter,
              markersMaxCount: 3,
            ),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: today,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: (day) => markers[_normalizeDate(day)] ?? [],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: _getEventsForDay(selected).isEmpty
                ? const Center(child: Text("No events for this day."))
                : ListView.builder(
                    itemCount: _getEventsForDay(selected).length,
                    itemBuilder: (context, index) {
                      final event = _getEventsForDay(selected)[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(event.title),
                          subtitle: Text(
                            "${event.venue} • ${event.timeFrom.format(context)} (${event.dateFrom.day}/${event.dateFrom.month}) - ${event.timeTo.format(context)} (${event.dateTo.day}/${event.dateTo.month})",
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewEventPage(event: event),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}

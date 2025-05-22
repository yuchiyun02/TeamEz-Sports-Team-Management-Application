import 'package:flutter/material.dart';
import 'package:teamez/models/events_model.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/pages/events/view_event.dart';

class EventsTab extends StatelessWidget {
  final List<Event> events;

  const EventsTab({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final upcomingEvents = events.where((e) => e.dateTo.isAfter(now)).toList();
    final pastEvents = events.where((e) => e.dateTo.isBefore(now)).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: TabBar(
              indicatorColor: CustomCol.armyGreen,
              labelColor: CustomCol.armyGreen,
              tabs: [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              EventListView(events: upcomingEvents),
              EventListView(events: pastEvents),
            ],
          ),
        ),
      ),
    );
  }
}

class EventListView extends StatelessWidget {
  final List<Event> events;

  const EventListView({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(child: Text('No events found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          color: CustomCol.silver,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(event.title),
            subtitle: Text(
              "${event.venue} • ${event.timeFrom.format(context)} (${event.dateFrom.day}/${event.dateFrom.month}) - ${event.timeTo.format(context)} (${event.dateTo.day}/${event.dateTo.month})",
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () {

                // PLACEHOLDER : EDIT EVENT
                // Replace with View Event after design review

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
    );
  }
}
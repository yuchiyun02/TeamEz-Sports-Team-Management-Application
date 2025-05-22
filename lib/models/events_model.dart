import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String venue;
  final String description;
  final String eventType;
  final String sport;
  final DateTime dateFrom;
  final DateTime dateTo;
  final TimeOfDay timeFrom;
  final TimeOfDay timeTo;
  final List<String> participants;

  Event({
    required this.id,
    required this.title,
    required this.venue,
    required this.description,
    required this.eventType,
    required this.sport,
    required this.dateFrom,
    required this.dateTo,
    required this.timeFrom,
    required this.timeTo,
    required this.participants,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Event(   
      id: doc.id,
      title: data['title'],
      venue: data['venue'],
      description: data['description'],
      eventType: data['eventType'],
      sport: data['sport'],
      dateFrom: (data['dateFrom'] as Timestamp).toDate().toLocal(),
      dateTo: (data['dateTo'] as Timestamp).toDate().toLocal(),
      timeFrom: TimeOfDay(
        hour: data['timeFrom']['hour'],
        minute: data['timeFrom']['minute'],
      ),
      timeTo: TimeOfDay(
        hour: data['timeTo']['hour'],
        minute: data['timeTo']['minute'],
      ),
      participants: List<String>.from(data['participants'] ?? []),
    );
  }

  factory Event.fromMap(Map<String, dynamic> data) {
    return Event(
      id: data['id'],
      title: data['title'],
      venue: data['venue'],
      description: data['description'],
      eventType: data['eventType'],
      sport: data['sport'],
      dateFrom: (data['dateFrom'] as Timestamp).toDate().toLocal(),
      dateTo: (data['dateTo'] as Timestamp).toDate().toLocal(),
      timeFrom: TimeOfDay(
        hour: data['timeFrom']['hour'],
        minute: data['timeFrom']['minute'],
      ),
      timeTo: TimeOfDay(
        hour: data['timeTo']['hour'],
        minute: data['timeTo']['minute'],
      ),
      participants: List<String>.from(data['participants'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'venue': venue,
      'description': description,
      'eventType': eventType,
      'sport': sport,
      'dateFrom': Timestamp.fromDate(dateFrom),
      'dateTo': Timestamp.fromDate(dateTo),
      'timeFrom': {
        'hour': timeFrom.hour,
        'minute': timeFrom.minute,
      },
      'timeTo': {
        'hour': timeTo.hour,
        'minute': timeTo.minute,
      },
    };
  }
}

class EventMetrics {
  int targetScore;
  int actualScore;
  int attendance;
  int injuries;
  List<EventLogEntry> eventLog;

  EventMetrics({
    required this.targetScore,
    required this.actualScore,
    required this.attendance,
    required this.injuries,
    required this.eventLog,
  });

  factory EventMetrics.fromMap(Map<String, dynamic> data) {
    return EventMetrics(
      targetScore: data['targetScore'] ?? 0,
      actualScore: data['actualScore'] ?? 0,
      attendance: data['attendance'] ?? 0,
      injuries: data['injuries'] ?? 0,
      eventLog: (data['eventLog'] as List<dynamic>? ?? [])
          .map((e) => EventLogEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetScore': targetScore,
      'actualScore': actualScore,
      'attendance': attendance,
      'injuries': injuries,
      'eventLog': eventLog.map((e) => e.toMap()).toList(),
    };
  }
}

class EventLogEntry {
  String scorer;
  String assister;
  Timestamp timestamp;

  EventLogEntry({required this.scorer, required this.assister, required this.timestamp,});

  factory EventLogEntry.fromMap(Map<String, dynamic> map) {
    return EventLogEntry(
      scorer: map['scorer'] ?? '',
      assister: map['assister'] ?? '',
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() => {
        'scorer': scorer,
        'assister': assister,
        'timestamp': timestamp,
      };
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/models/notes_model.dart';
import 'package:teamez/pages/events/view_event.dart';
import 'package:teamez/pages/notes/add_edit_notes.dart';
import 'package:teamez/models/events_model.dart';

class ViewNotePage extends StatelessWidget {
  final String userId;
  final String noteId;

  const ViewNotePage({super.key, required this.userId, required this.noteId});

  @override
  Widget build(BuildContext context) {
    final noteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId);

    return Scaffold(
      backgroundColor: CustomCol.bgGreen,
      appBar: AppBar(backgroundColor: CustomCol.bgGreen, elevation: 0, scrolledUnderElevation: 0,),
      body: FutureBuilder<DocumentSnapshot>(
        future: noteRef.get(),
        builder: (context, noteSnapshot) {
          if (noteSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!noteSnapshot.hasData || !noteSnapshot.data!.exists) {
            return Center(child: Text('Note not found.'));
          }

          final noteData = noteSnapshot.data!.data() as Map<String, dynamic>;
          final title = noteData['title'] ?? '';
          final content = noteData['content'] ?? '';
          final linkedEventId = noteData['eventId'];
          final displayOnHome = noteData['displayOnHome'] ?? false;

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Stack(children: [
                  Center(child: Text(title, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(onPressed: (){
                      final note = Note.fromMap(noteId, noteData);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditNotePage(existingNote: note)
                        ),
                      );
                    }, icon: Icon(Icons.edit)),
                  )
                ]),

                SizedBox(height: 8),

                if (linkedEventId != null && linkedEventId.isNotEmpty)
                  LinkedEventCard(
                    userId: userId,
                    eventId: linkedEventId,
                  ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Text('Display on Home:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(
                      displayOnHome ? Icons.check_circle : Icons.cancel,
                      color: displayOnHome ? Colors.green : Colors.red,
                    ),
                  ],
                ),

                SizedBox(height: 8),

                Text(content),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LinkedEventCard extends StatelessWidget {
  final String userId;
  final String eventId;

  const LinkedEventCard({super.key, required this.userId, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final eventRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId);

    return FutureBuilder<DocumentSnapshot>(
      future: eventRef.get(),
      builder: (context, eventSnapshot) {
        if (eventSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!eventSnapshot.hasData || !eventSnapshot.data!.exists) {
          return const Text('Linked event not found.');
        }

        final eventData = eventSnapshot.data!.data() as Map<String, dynamic>;
        final title = eventData['title'] ?? 'Untitled Event';
        final dateFrom = (eventData['dateFrom'] as Timestamp?)?.toDate();

        final event = Event.fromMap(eventData);

        return Card(
          color: CustomCol.silver,
          child: ListTile(
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: dateFrom != null
                ? Text('Starts: ${dateFrom.toLocal().toString().split(' ')[0]}')
                : null,
            leading: const Icon(Icons.event),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewEventPage(event:event)),
              );
            },
          ),
        );
      },
    );
  }
}





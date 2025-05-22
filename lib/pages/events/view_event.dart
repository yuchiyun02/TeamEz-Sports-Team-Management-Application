import 'package:flutter/material.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/models/events_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamez/models/members_model.dart';
import 'package:teamez/models/notes_model.dart';
import 'package:teamez/pages/events/add_edit_event.dart';
import 'package:teamez/pages/events/event_metrics.dart';
import 'package:teamez/pages/notes/view_note.dart';
import 'package:teamez/widgets/events/edit_participants_dialog.dart';
import 'package:teamez/widgets/events/notes_select_dialog.dart';

class ViewEventPage extends StatefulWidget{
  final Event event;
  const ViewEventPage({super.key, required this.event});

  @override
  State<ViewEventPage> createState() => _ViewEventPageState();
}

class _ViewEventPageState extends State<ViewEventPage> {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  //Chunking method to overcome 10 limit for Firebase whereIn function
  List<List<String>> chunkList(List<String> list, int chunkSize) {
    List<List<String>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  Future<List<Member>> _fetchParticipants(List<String> uids) async {
    final chunks = chunkList(uids, 10);
    final List<Member> allMembers = [];

    for (final chunk in chunks) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('members')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      final members = snapshot.docs.map((doc) {
        return Member.fromMap(doc.data());
      }).toList();

      allMembers.addAll(members);
    }

    return allMembers;
  }

  void _openEditParticipantsDialog() async {
    final updated = await showDialog<List<String>>(
      context: context,
      builder: (context) => EditParticipantsDialog(
        currentParticipantIds: widget.event.participants,
        eventId: widget.event.id,
      ),
    );

    if (updated != null) {
      setState(() {
        widget.event.participants
          ..clear()
          ..addAll(updated);
      });

      for (var participantId in updated) {
        final memberDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('members')
            .doc(participantId)
            .get();

        if (memberDoc.exists) {
          final member = Member.fromMap(memberDoc.data()!);
          _addParticipant(member);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Participants updated")),
      );
    }
  }

  Future<void> _addParticipant(Member member) async {
    final updatedParticipants = List<String>.from(widget.event.participants)
      ..add(member.id);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(widget.event.id)
        .update({'participants': updatedParticipants});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('members')
        .doc(member.id)
        .update({
      'totalGames': FieldValue.increment(1),
    });

    setState(() {
      widget.event.participants
        ..clear()
        ..addAll(updatedParticipants);
    });
  }

  Future<void> _removeParticipant(Member member) async {
    final updatedParticipants = List<String>.from(widget.event.participants)
      ..remove(member.id);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(widget.event.id)
        .update({'participants': updatedParticipants});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('members')
        .doc(member.id)
        .update({
      'totalGames': FieldValue.increment(-1),
    });

    setState(() {
      widget.event.participants
        ..clear()
        ..addAll(updatedParticipants);
    });
  }
  
  TextStyle eventInfoTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0, 
        backgroundColor: CustomCol.bgGreen,
      ),
      backgroundColor: CustomCol.bgGreen,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Column(
              children: [
                Text(widget.event.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height:2),
                Text(widget.event.sport, 
                  style: TextStyle(
                    color: CustomCol.darkGrey, 
                    fontSize: 14
                  )
                ),
                Text(widget.event.eventType, 
                  style: TextStyle(
                    color: CustomCol.darkGrey, 
                    fontSize: 14
                  )
                ),
        
                SizedBox(height:5),
        
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: CustomCol.yellowGreen,
                    ),
                    child: Column(
                      children: [
                        Text(widget.event.dateFrom.isAtSameMomentAs(widget.event.dateTo)
                          ? "${widget.event.dateFrom.day}/${widget.event.dateFrom.month}"
                          : "${widget.event.dateFrom.day}/${widget.event.dateFrom.month} - ${widget.event.dateTo.day}/${widget.event.dateTo.month}",
                          style: eventInfoTextStyle
                        ),
                        Text("${widget.event.timeFrom.format(context)} - ${widget.event.timeTo.format(context)}",
                          style: eventInfoTextStyle
                        ),
                        Text("@ ${widget.event.venue}", style: eventInfoTextStyle)
                      ],
                    )
                  ),
                ),

                Text("About", style:eventInfoTextStyle),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.event.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                SizedBox(height:20),

                //Attached Note widget
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('notes')
                      .where('eventId', isEqualTo: widget.event.id)
                      .limit(1)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final noteDoc = snapshot.data!.docs.first;
                      final note = Note.fromMap(noteDoc.id, noteDoc.data() as Map<String, dynamic>);
                      return _NoteCard(note: note);
                    }

                    return GestureDetector(
                       onTap: () async {
                        final selectedNoteId = await showDialog<String>(
                          context: context,
                          builder: (_) => SelectNoteDialog(eventId: widget.event.id),
                        );

                        if (selectedNoteId != null) {
                          await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('notes')
                            .doc(selectedNoteId)
                            .update({'eventId': widget.event.id});

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Note linked successfully")),
                          );
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: CustomCol.silver,
                        ),
                        child: Center(child: Icon(Icons.add)),
                      ),
                    );
                  },
                ),

                SizedBox(height:20),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      "Participating Members",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                    Align(
                      alignment: Alignment.centerRight, 
                      child: IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        tooltip: "Edit Participants",
                        onPressed: _openEditParticipantsDialog,
                      ),
                    ),
                  ],
                ),

                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: CustomCol.midGreen
                  ),
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('events')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No events found.'));
                      }

                      final participantUids = widget.event.participants;

                      if (participantUids.isEmpty) {
                        return Center(child: Text('No participants.'));
                      }

                      return FutureBuilder<List<Member>>(
                        future: _fetchParticipants(participantUids),
                        builder: (context, memberSnapshot) {
                          if (memberSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (memberSnapshot.hasError) {
                            return Center(child: Text('Error: ${memberSnapshot.error}'));
                          } else if (!memberSnapshot.hasData || memberSnapshot.data!.isEmpty) {
                            return Center(child: Text('No matching members.'));
                          }

                          final members = memberSnapshot.data!;

                          return ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: member.avatarURL != null && member.avatarURL!.isNotEmpty
                                        ? NetworkImage(member.avatarURL!)
                                        : null,
                                    child: member.avatarURL == null || member.avatarURL!.isEmpty
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Text(member.name),
                                  subtitle: Text(member.position),
                                  trailing: IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    tooltip: 'Remove Participant',
                                    onPressed: () => _removeParticipant(member),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height:10),

                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomCol.armyGreen
                      ),
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventMetricsPage(event: widget.event),
                          ),
                        );
                      },
                      child: Text("Event Metrics",
                        style: TextStyle(color: CustomCol.silver),
                      ),
                    ),
                  ),
                
                SizedBox(height: 5),

                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditEventPage(isEdit: true, id: widget.event.id),
                          ),
                        );
                      },
                      child: Text("Edit Event",
                        style: TextStyle(color: CustomCol.darkGrey),
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      )
    );
  }
}

class _NoteCard extends StatefulWidget {
  final Note note;

  const _NoteCard({required this.note});

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard> {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewNotePage(
              userId: userId,
              noteId: widget.note.id,
            ),
          ),
        );
      },
      
      child: Container(
        height: 300,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(30,20,30,20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: CustomCol.silver,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.note.title, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

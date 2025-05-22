import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/models/notes_model.dart';
import 'package:teamez/navigation.dart';
import 'package:teamez/pages/notes/view_note.dart';

class HomeNotesView extends StatefulWidget {
  final String userId;

  const HomeNotesView({super.key, required this.userId});

  @override
  State<HomeNotesView> createState() => _HomeNotesViewState();
}

class _HomeNotesViewState extends State<HomeNotesView> {
  Note? _defaultNote;

  @override
  void initState() {
    super.initState();
    _fetchDefaultNote();
  }
  Future<void> _fetchDefaultNote() async {
    try {
      final notesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('notes')
          .where('displayOnHome', isEqualTo: true)
          .limit(1) // Limit to 1 note
          .get();

      if (notesSnapshot.docs.isNotEmpty) {
        final noteData = notesSnapshot.docs.first.data();
        setState(() {
          _defaultNote = Note.fromMap(notesSnapshot.docs.first.id, noteData);
        });
      } else {
        setState(() {
          _defaultNote = null;
        });
      }
    } catch (e) {
      print('Error fetching default note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_defaultNote != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewNotePage(
                userId: widget.userId,
                noteId: _defaultNote!.id,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NavigationPage(initialIndex: 2),
            ),
          );
        }
      },
      child: Container(
        height: 250,
        width: 175,
        margin: EdgeInsets.fromLTRB(16, 20, 16, 16),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: CustomCol.midGreen,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _defaultNote == null
            ? Center(
                child: Text(
                  'No notes \n set for home',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _defaultNote!.title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _defaultNote!.content.length > 50
                          ? '${_defaultNote!.content.substring(0, 50)}...'
                          : _defaultNote!.content,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

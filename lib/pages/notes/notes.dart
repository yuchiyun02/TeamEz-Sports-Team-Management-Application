import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamez/models/notes_model.dart';
import 'package:teamez/constant/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamez/pages/notes/add_edit_notes.dart';
import 'package:teamez/pages/notes/view_note.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  Stream<List<Note>> _getNotesStream() {
    var query = FirebaseFirestore.instance.collection('users').doc(userId).collection('notes').orderBy('timestamp', descending: true);
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Note.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> _deleteNote(String noteId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('notes').doc(noteId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomCol.bgGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: CustomCol.bgGreen,
        title: Stack(
          children: [
            Center(child: Text('Notes', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 30))),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditNotePage()
                  ),
                );
              }, 
              icon: Icon(Icons.add))
              )
        ]),
      ),
      body: StreamBuilder<List<Note>>(
        stream: _getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('No notes yet.'));
          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(8,3,8,3),
                child: Card(
                  child: ListTile(
                    title: Text(note.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${note.timestamp.day.toString()}/${note.timestamp.month.toString()}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteNote(note.id),
                    ),
                    onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewNotePage(userId: userId, noteId:note.id)
                      ));
                    }
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

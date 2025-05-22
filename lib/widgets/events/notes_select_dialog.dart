import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamez/constant/constants.dart';

class SelectNoteDialog extends StatefulWidget {
  final String eventId;

  const SelectNoteDialog({super.key, required this.eventId});

  @override
  State<SelectNoteDialog> createState() => _SelectNoteDialogState();
}

class _SelectNoteDialogState extends State<SelectNoteDialog> {
  late String userId = FirebaseAuth.instance.currentUser!.uid;
  late Future<List<QueryDocumentSnapshot>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = _fetchNotes();
  }

  Future<List<QueryDocumentSnapshot>> _fetchNotes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .where('eventId', isNull: true)
        .get();

    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text("Select Note to Link", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      backgroundColor: CustomCol.silver,
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _notesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading notes'));
            }

            final notes = snapshot.data!;
            if (notes.isEmpty) {
              return const Center(child: Text('No available notes.'));
            }

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final doc = notes[index];
                final data = doc.data() as Map<String, dynamic>;
                final title = data['title'] ?? 'Untitled';

                return ListTile(
                  title: Text(title),
                  onTap: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('notes')
                        .doc(doc.id)
                        .update({'eventId': widget.eventId});

                    Navigator.pop(context, doc.id);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
      ],
    );
  }
}

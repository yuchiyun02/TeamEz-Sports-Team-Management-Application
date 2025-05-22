import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamez/models/notes_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamez/models/events_model.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/widgets/general/custom_textfield.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? existingNote;
  final String? eventId;

  const AddEditNotePage({
    super.key,
    this.existingNote,
    this.eventId,
  });

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _displayOnHome = false;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  List<Event> _events = [];
  Event? _selectedEvent;

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!.title;
      _contentController.text = widget.existingNote!.content;
      _displayOnHome = widget.existingNote!.displayOnHome;
    }
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .orderBy('dateFrom', descending: true)
        .get();

    final loadedEvents = snapshot.docs
        .map((doc) => Event.fromMap(doc.data()))
        .cast<Event>()
        .toList();

    setState(() {
      _events = loadedEvents;

      final linkedEventId = widget.existingNote?.eventId ?? widget.eventId;
      _selectedEvent = _events.any((e) => e.id == linkedEventId)
          ? _events.firstWhere((e) => e.id == linkedEventId)
          : null;
    });
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final notesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');

    if (_displayOnHome) {
      // If this note is marked to be displayed on home, unmark others
      final othersWithDisplay = await notesRef
          .where('displayOnHome', isEqualTo: true)
          .get();

      for (var doc in othersWithDisplay.docs) {
        if (doc.id != widget.existingNote?.id) {
          await doc.reference.update({'displayOnHome': false});
        }
      }
    }

    // Creating the note to save
    final noteData = Note(
      id: widget.existingNote?.id ?? notesRef.doc().id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      timestamp: DateTime.now(),
      eventId: _selectedEvent?.id,
      displayOnHome: _displayOnHome,
    );

    await notesRef.doc(noteData.id).set(noteData.toMap());
    if (context.mounted) Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingNote != null;

    return Scaffold(
      backgroundColor: CustomCol.bgGreen,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: CustomCol.bgGreen,
      ),
      body: _isSaving
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          isEditing ? 'Edit Note' : 'Add Note',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Title Field
                      CustomTextField(
                        controller: _titleController,
                        label: "Title",
                        hintText: "Enter title",
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter title' : null,
                      ),
                      
                      SizedBox(height: 20),

                      // Event Dropdown
                      DropdownButtonFormField<Event?>(
                        value: _selectedEvent,
                        decoration: InputDecoration(
                          fillColor: CustomCol.silver,
                          filled: true,
                          labelText: 'Link Event (optional)',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: CustomCol.black),
                            borderRadius: BorderRadius.circular(10),
                          )
                        ),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<Event?>(
                            value: null,
                            child: Text('None'),
                          ),
                          ..._events.map((event) {
                            return DropdownMenuItem<Event?>(
                              value: event,
                              child: Text(
                                event.title,
                                style:
                                  TextStyle(fontWeight: FontWeight.bold),
                                ),
                            );
                          }),
                        ],
                        onChanged: (event) {
                          setState(() {
                            _selectedEvent = event;
                          });

                          
                        },
                      ),
                      const SizedBox(height: 20),

                      // Content Field
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          fillColor: CustomCol.silver,
                          filled: true,
                          labelText: "Content",
                          hintText: "Enter Content",
                          hintStyle: TextStyle(color: CustomCol.darkGrey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: CustomCol.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: CustomCol.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 20,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter content' : null,
                      ),

                      CheckboxListTile(
                        title: Text("Display on Home", style: TextStyle(fontWeight: FontWeight.bold)),
                        value: _displayOnHome,
                        onChanged: (value) {
                          setState(() {
                            _displayOnHome = value ?? false;
                          });
                        },
                      ),

                      const SizedBox(height: 20),
                      // Save Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomCol.armyGreen
                        ),
                        onPressed: _saveNote,
                        child: Text(isEditing ? 'Update Note' : 'Save Note',
                          style: TextStyle(color: CustomCol.silver)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

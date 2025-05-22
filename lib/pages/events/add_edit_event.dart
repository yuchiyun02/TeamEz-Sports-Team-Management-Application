import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamez/widgets/general/custom_textfield.dart';
import 'package:teamez/constant/constants.dart';

class AddEditEventPage extends StatefulWidget {
  final bool isEdit;
  final String? id;
  const AddEditEventPage({super.key, this.isEdit = false, this.id});

  @override
  State<AddEditEventPage> createState() => _AddEditEventPageState();
}

class _AddEditEventPageState extends State<AddEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();

  String userId = FirebaseAuth.instance.currentUser!.uid;
  DateTime? dateFrom;
  DateTime? dateTo;
  TimeOfDay? timeFrom;
  TimeOfDay? timeTo;

  bool dateNotPicked = false;
  bool timeFromNotPicked = false;
  bool timeToNotPicked = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.id != null) {
      fetchEventData();
    }
  }

  Future<void> fetchEventData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(widget.id)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _titleController.text = data['title'];
        _descController.text = data['description'];
        _venueController.text = data['venue'];
        _eventTypeController.text = data['eventType'];
        _sportController.text = data['sport'];
        dateFrom = (data['dateFrom'] as Timestamp).toDate();
        dateTo = (data['dateTo'] as Timestamp).toDate();
        timeFrom = TimeOfDay(
            hour: data['timeFrom']['hour'], minute: data['timeFrom']['minute']);
        timeTo = TimeOfDay(
            hour: data['timeTo']['hour'], minute: data['timeTo']['minute']);
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEdit ? "Saving Changes..." : "Adding Event...")),
      );

      try {
        final events = FirebaseFirestore.instance.collection('users').doc(userId).collection('events');

        // If editing, use the existing ID; otherwise, create a new doc ref with an auto-generated ID
        final eventDocRef = widget.isEdit && widget.id != null
            ? events.doc(widget.id)
            : events.doc();

        final eventData = {
          'title': _titleController.text,
          'description': _descController.text,
          'venue': _venueController.text,
          'eventType': _eventTypeController.text,
          'sport': _sportController.text,
          'dateFrom': dateFrom,
          'dateTo': dateTo,
          'timeFrom': {'hour': timeFrom?.hour ?? 0, 'minute': timeFrom?.minute ?? 0},
          'timeTo': {'hour': timeTo?.hour ?? 0, 'minute': timeTo?.minute ?? 0},
        };

        if (widget.isEdit) {
          await eventDocRef.update(eventData);
        } else {
          await eventDocRef.set({
            'id': eventDocRef.id,
            ...eventData,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? "Event updated successfully" : "Event added successfully")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }


  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dateFrom = picked.start;
        dateTo = picked.end;
        dateNotPicked = false;
      });
    } else {
      setState(() {
        dateNotPicked = true;
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          timeFrom = picked;
          timeFromNotPicked = false;
        } else {
          timeTo = picked;
          timeToNotPicked = false;
        }
      });
    }
  }

  Future<void> _deleteEvent() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(widget.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event deleted successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting event: $e")),
      );
    }
  }

  static final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: CustomCol.armyGreen,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // softer corners instead of stadium
    ),
    padding: EdgeInsets.symmetric(
      vertical: 18, 
      horizontal: 20, 
    ),
    textStyle: TextStyle(fontWeight: FontWeight.bold),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: CustomCol.bgGreen),
      backgroundColor: CustomCol.bgGreen,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 75,
                  width: 325,
                  child: Text(
                    widget.isEdit ? "Edit Event" : "Add Event",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),

                CustomTextField(
                  controller: _titleController,
                  label: "Title",
                  hintText: "Enter event title",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Title";
                    }
                      return null;
                    },
                ),

                SizedBox(height: 20),

                CustomTextField(
                  controller: _descController,
                  label: "Description",
                  hintText: "Enter description",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Description";
                    }
                      return null;
                    },
                ),  

                SizedBox(height: 20),

                CustomTextField(
                  controller: _venueController,
                  label: "Venue",
                  hintText: "Enter venue",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Venue";
                    }
                      return null;
                    },
                ),

                SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _eventTypeController.text.isNotEmpty ? _eventTypeController.text : null,
                  items: ['Tournament', 'Practice', 'Friendly'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) => setState(() => _eventTypeController.text = val ?? ''),
                  decoration: InputDecoration(
                    labelText: "Event Type",
                    filled: true,
                    fillColor: CustomCol.silver,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                CustomTextField(
                  controller: _sportController,
                  label: "Sport",
                  hintText: "Enter sport",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Sport";
                    }
                      return null;
                    },
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: _pickDateRange,
                    child: Text(dateFrom != null && dateTo != null
                        ? "${dateFrom!.toLocal().toString().split(' ')[0]}  to  ${dateTo!.toLocal().toString().split(' ')[0]}"
                        : "Pick Date Range"),
                  ),
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: buttonStyle,
                          onPressed: () => _pickTime(isStart: true),
                          child: Text(timeFrom != null
                              ? timeFrom!.format(context)
                              : "Pick Start Time"),
                        ),
                    ),
                    
                    SizedBox(width: 15),

                    Text("to", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CustomCol.darkGrey)),

                    SizedBox(width: 15),

                    Expanded(
                      child: ElevatedButton(
                          style: buttonStyle,
                          onPressed: () => _pickTime(isStart: false),
                          child: Text(timeTo != null
                              ? timeTo!.format(context)
                              : "Pick End Time"),
                      ),
                    ),
                  ],
                ),               

                SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:  (dateFrom != null && dateTo != null && timeFrom != null && timeTo != null) ? _saveEvent:null,
                    child: Text(
                      widget.isEdit ? "Save Changes" : "Add Event",
                      style: TextStyle(color: CustomCol.darkGrey),
                    ),
                  ),
                ),

                SizedBox(height: 5),

                if (widget.isEdit)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomCol.chilliRed,
                        foregroundColor: CustomCol.silver,),
                      onPressed: _deleteEvent,
                      child: Text("Delete Event"),
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

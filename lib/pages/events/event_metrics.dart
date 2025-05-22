import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamez/models/events_model.dart';
import 'package:teamez/models/members_model.dart';
import 'package:teamez/widgets/general/custom_textfield.dart';
import 'package:teamez/constant/constants.dart';
import 'package:collection/collection.dart';

class EventMetricsPage extends StatefulWidget {
  final Event event;

  const EventMetricsPage({super.key, required this.event});

  @override
  State<EventMetricsPage> createState() => _EventMetricsPageState();
}

class _EventMetricsPageState extends State<EventMetricsPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  late TextEditingController targetScoreController;
  late TextEditingController actualScoreController;
  late TextEditingController attendanceController;
  late TextEditingController injuriesController;

  EventMetrics? metrics;
  List<Member> participants = [];

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _loadParticipants();
  }

  Future<void> _loadMetrics() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(widget.event.id)
        .get();

    final data = doc.data()?['metrics'] ?? {};
    final loadedMetrics = EventMetrics.fromMap(Map<String, dynamic>.from(data));

    setState(() {
      metrics = loadedMetrics;
      targetScoreController = TextEditingController(text: metrics!.targetScore.toString());
      actualScoreController = TextEditingController(text: metrics!.actualScore.toString());
      attendanceController = TextEditingController(text: metrics!.attendance.toString());
      injuriesController = TextEditingController(text: metrics!.injuries.toString());
    });
  }

  Future<void> _loadParticipants() async {
    final chunks = _chunkList(widget.event.participants, 10);
    List<Member> all = [];

    for (final chunk in chunks) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('members')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      all.addAll(snapshot.docs.map((doc) => Member.fromMap(doc.data())));
    }

    setState(() {
      participants = all;
    });
  }

  List<List<String>> _chunkList(List<String> list, int size) {
    List<List<String>> chunks = [];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }

  void _addLogEntry() {
    setState(() {
      metrics!.eventLog.add(EventLogEntry(scorer: '', assister: '', timestamp: Timestamp.now()));
    });
  }

  Future<void> _updateMemberStats(String memberId, String statType) async {
    final memberDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('members')
        .doc(memberId)
        .get();

    if (memberDoc.exists) {
      final memberData = memberDoc.data() as Map<String, dynamic>;

      int updatedScore = memberData['scores'] ?? 0;
      int updatedAssists = memberData['assists'] ?? 0;

      if (statType == 'score') {
        updatedScore += 1;
      } else if (statType == 'assist') {
        updatedAssists += 1;
      } else if (statType == 'remove_score') {
        updatedScore -= 1;
      } else if (statType == 'remove_assist') {
        updatedAssists -= 1;
      }

      // Ensure scores and assists do not go below zero
      updatedScore = updatedScore < 0 ? 0 : updatedScore;
      updatedAssists = updatedAssists < 0 ? 0 : updatedAssists;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('members')
          .doc(memberId)
          .update({
        'scores': updatedScore,
        'assists': updatedAssists,
      });
    }
  }


  void _saveMetrics() async {
    final updatedMetrics = EventMetrics(
      targetScore: int.tryParse(targetScoreController.text) ?? 0,
      actualScore: int.tryParse(actualScoreController.text) ?? 0,
      attendance: int.tryParse(attendanceController.text) ?? 0,
      injuries: int.tryParse(injuriesController.text) ?? 0,
      eventLog: metrics!.eventLog,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(widget.event.id)
        .update({'metrics': updatedMetrics.toMap()});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Metrics saved')));
    Navigator.pop(context);
  }

  Widget _buildDropdown(String value, void Function(String?) onChanged, String role) {
    return DropdownButton<String>(
      value: value.isEmpty ? null : value,
      hint: Text("Select"),
      isExpanded: true,
      onChanged: (val) {
        setState(() {
          onChanged(val);
          if (val != null) {
            final Member? selectedMember = participants.firstWhereOrNull((m) => m.id == val);
            if (selectedMember != null) {
              _updateMemberStats(selectedMember.id, role);
            }
          }
        });
      },
      items: participants.map((m) {
        return DropdownMenuItem<String>(
          value: m.id,
          child: Text(m.name),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (metrics == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar:  AppBar(
        scrolledUnderElevation: 0, 
        backgroundColor: CustomCol.bgGreen,
      ),
      backgroundColor: CustomCol.bgGreen,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text("Event Metrics", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            Center(child: Text(widget.event.title, style: TextStyle(fontSize: 16, color: CustomCol.darkGrey))),
            SizedBox(height: 30),

            CustomTextField(controller: targetScoreController, label: "Target Score"),
            SizedBox(height: 20),
            CustomTextField(controller: actualScoreController, label: "Actual Score"),
            SizedBox(height: 20),
            CustomTextField(controller: attendanceController, label: "Attendance"),
            SizedBox(height: 20),
            CustomTextField(controller: injuriesController, label: "Injuries"),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Score Log", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _addLogEntry,
                  icon: Icon(Icons.add),
                  label: Text("Add"),
                ),
              ],
            ),

            ...metrics!.eventLog.asMap().entries.map((entry) {
              final index = entry.key;
              final log = entry.value;

              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text("Entry ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildDropdown(log.scorer, (val) {
                            setState(() => log.scorer = val ?? '');
                          }, "score")),
                          SizedBox(width: 10),
                          Expanded(child: _buildDropdown(log.assister, (val) {
                            setState(() => log.assister = val ?? '');
                          }, "assist")),
                          IconButton(
                            onPressed: () async {
                              final logToRemove = metrics!.eventLog[index];
                              if (logToRemove.scorer.isNotEmpty) {
                                await _updateMemberStats(logToRemove.scorer, 'remove_score');
                              }
                              if (logToRemove.assister.isNotEmpty) {
                                await _updateMemberStats(logToRemove.assister, 'remove_assist');
                              }

                              setState(() {
                                metrics!.eventLog.removeAt(index);
                              });
                            },
                            icon: Icon(Icons.close, color: Colors.red),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMetrics,
                child: Text("Save Metrics"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
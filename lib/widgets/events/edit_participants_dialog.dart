import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamez/models/members_model.dart';
import 'package:teamez/constant/constants.dart';


class EditParticipantsDialog extends StatefulWidget {
  final List<String> currentParticipantIds;
  final String eventId;

  const EditParticipantsDialog({
    super.key,
    required this.currentParticipantIds,
    required this.eventId,
  });

  @override
  State<EditParticipantsDialog> createState() => _EditParticipantsDialogState();
}

class _EditParticipantsDialogState extends State<EditParticipantsDialog> {
  late Set<String> selectedIds = Set.from(widget.currentParticipantIds);
  late Future<List<Member>> _membersFuture;

  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchAllMembers();
  }

  Future<List<Member>> _fetchAllMembers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).collection('members').get();
    return snapshot.docs.map((doc) =>
      Member.fromMap(doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child:Text("Edit Participants", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold))),
      backgroundColor: CustomCol.silver,
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: FutureBuilder<List<Member>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading members'));
            }

            final members = snapshot.data!;

            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isSelected = selectedIds.contains(member.id);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        selectedIds.add(member.id);
                      } else {
                        selectedIds.remove(member.id);
                      }
                    });
                  },
                  title: Text(member.name),
                  secondary: CircleAvatar(
                    backgroundImage: member.avatarURL != null && member.avatarURL!.isNotEmpty
                        ? NetworkImage(member.avatarURL!)
                        : null,
                    child: member.avatarURL == null || member.avatarURL!.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
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
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('events')
                .doc(widget.eventId)
                .update({'participants': selectedIds.toList()});

            Navigator.pop(context, selectedIds.toList()); // return updated list
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/widgets/general/appbar_title.dart';
import 'package:teamez/widgets/general/custom_fab.dart';
import 'package:teamez/pages/members/add_edit_member.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamez/models/members_model.dart';
import 'package:teamez/pages/members/view_member.dart';

class MembersPage extends StatefulWidget{
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

Stream<List<Member>> fetchMembersStream() {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('members')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Member.fromMap(doc.data())).toList());
}

class _MembersPageState extends State<MembersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarTitle(title: "Members"),
      floatingActionButton: CustomFAB(destination: AddEditMemberPage(isEdit: false)),
      backgroundColor: CustomCol.bgGreen,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<List<Member>>(
          stream: fetchMembersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final members = snapshot.data ?? [];

            if (members.isEmpty) {
              return Center(child: Text("No members found."));
            }

            return ListView.separated(
              itemCount: members.length,
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              itemBuilder: (context, index) {
                final member = members[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: (member.avatarURL != null && member.avatarURL!.isNotEmpty)
                          ? NetworkImage(member.avatarURL!)
                          : AssetImage("assets/default_profile.jpg"),
                    ),
                    title: Text(member.name),
                    subtitle: Text("${member.position} • ${member.playerStatus}"),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewMemberPage(member: member),
                        ),
                      );
                    }
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

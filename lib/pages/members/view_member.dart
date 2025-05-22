import 'package:flutter/material.dart';
import 'package:teamez/models/members_model.dart';
import 'package:teamez/widgets/profile/profile_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamez/widgets/general/file_upload_dialog.dart';
import 'package:flutter/services.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/pages/members/add_edit_member.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:teamez/models/events_model.dart';
import 'package:teamez/widgets/events/events_tab.dart';

class ViewMemberPage extends StatefulWidget {
  final Member member;
  const ViewMemberPage({super.key, required this.member});

  @override
  State<ViewMemberPage> createState() => _ViewMemberPageState();
}

class _ViewMemberPageState extends State<ViewMemberPage> {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  Color getStatusColor() {
    switch (widget.member.playerStatus) {
      case "Active":
        return Colors.green;
      case "Inactive":
        return Colors.red;
      case "Injured":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String getStatusText() {
    switch (widget.member.playerStatus) {
      case "Active":
        return "Player is active";
      case "Inactive":
        return "Player is inactive";
      case "Injured":
        return "Player is injured";
      default:
        return "Unknown status";
    }
  }

  TextStyle memberInfoTextStyle = TextStyle(
    color: CustomCol.darkGrey, 
    fontSize: 14
  );

  TextStyle memberStatsTextStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: CustomCol.black,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0, 
          backgroundColor: CustomCol.bgGreen,
        ),
        backgroundColor: CustomCol.bgGreen,
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [ProfileHeader(
              userId: userId,
              type: "member",
              memberId: widget.member.id,
              onClicked: () async {
                showDialog(
                  context: context,
                  builder: (context) => FileUploadDialog(
                    userId: userId,
                    folder: "members",
                    memberId: widget.member.id,
                    onFileUploaded: (downloadUrl) async {
                      if (mounted) {
                        final memberDocRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('members')
                          .doc(widget.member.id);

                        await memberDocRef.update({
                          'avatarURL': downloadUrl,
                        });

                        Clipboard.setData(ClipboardData(text: downloadUrl));

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Image update successful. Download link saved to clipboard. Refresh to see changes.",
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.member.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)
                  ),
                  SizedBox(width:5),
                  GestureDetector(
                    onTap:() {
                      Fluttertoast.showToast(
                        msg: getStatusText(),
                        toastLength: Toast.LENGTH_SHORT,  // Duration of the Toast
                        gravity: ToastGravity.BOTTOM,  // Position of the Toast
                        timeInSecForIosWeb: 1,  // Duration for web
                        backgroundColor: CustomCol.darkGrey,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    },
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: getStatusColor(),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ]
              ),

              SizedBox(height: 4),

              Text(widget.member.position, style: memberInfoTextStyle),

              SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: CustomCol.silver,
                  backgroundColor: CustomCol.armyGreen,
                  shape: StadiumBorder()
                ),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditMemberPage(isEdit: true, id:widget.member.id)));

                  Navigator.pop(context);
                }, 
                child: Text("Edit Member")),

              Container(
                decoration: BoxDecoration(
                  color: CustomCol.midGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
                child: Column(
                  children: [
                    Text("All Time Statistics", style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    )),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Scores :", style: memberStatsTextStyle),
                            SizedBox(height:5),
                            Text("Total Assists :", style: memberStatsTextStyle),
                            SizedBox(height:5),
                            Text("Total Games Played :", style: memberStatsTextStyle),
                            SizedBox(height:5),
                            Text("Scores Per Game :", style: memberStatsTextStyle),
                            SizedBox(height:5),
                            Text("Assists Per Game :", style: memberStatsTextStyle),
                            SizedBox(height:5),
                            Text("Lifetime Injuries :", style: memberStatsTextStyle),
                            SizedBox(height:15),
                          ],),
                    
                        Spacer(),
                    
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(widget.member.scores.toString(), style: memberStatsTextStyle),
                            SizedBox(height:5),
                            Text(widget.member.assists.toString(), style: memberStatsTextStyle),
                            SizedBox(height:5),
                            Text(widget.member.totalGames.toString(), style: memberStatsTextStyle),
                            SizedBox(height:5),
                            Text((widget.member.scores / widget.member.totalGames).toStringAsFixed(2), style: memberStatsTextStyle),
                            SizedBox(height:5),
                            Text((widget.member.assists / widget.member.totalGames).toStringAsFixed(2), style: memberStatsTextStyle),
                            SizedBox(height:5),
                            Text(widget.member.lifetimeInjuries.toString(), style: memberStatsTextStyle),
                            SizedBox(height:15),
                          ],),
                    ],),
                  ],
                ),
              ),

              SizedBox(height:15),

              Text("Events Participated",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
              ),

              SizedBox(height:5),

              Container(
                height:300,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('events').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No events found.'));
                        }
                  
                        final events = snapshot.data!.docs
                          .map((doc) => Event.fromFirestore(doc))
                          .where((event) => event.participants.contains(widget.member.id)) // 👈 filter
                          .toList();
                  
                        return EventsTab(events: events);
                      },
                    ),
              ), //Events Tab Display

              SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: CustomCol.bgGreen
                ),
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Column(
                  children: [
                    Text("Member Particulars", style: TextStyle(
                        color: CustomCol.darkGrey, 
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )
                    ),

                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Member since :", style: memberInfoTextStyle),
                            Text("Contact :", style: memberInfoTextStyle),
                            Text("Emergency Contact :", style: memberInfoTextStyle),
                            Text("Emergency Contact Relation :", style: memberInfoTextStyle),
                          ],),
                    
                        Spacer(),
                    
                        Column(crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(DateFormat("dd-MM-yy").format(widget.member.timestampJoined), style: memberInfoTextStyle),
                            Text(widget.member.contact, style: memberInfoTextStyle),
                            Text(widget.member.emergencyContact, style: memberInfoTextStyle),
                            Text(widget.member.emergencyContactRelation, style: memberInfoTextStyle),
                          ],),
                    ],),
                  ],
                ),
              ),

              SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: CustomCol.silver,
                  backgroundColor: CustomCol.chilliRed,
                  shape: StadiumBorder()
                ),
                onPressed: () async {
                  bool? confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: CustomCol.bgGreen,
                      title: Text("Are you sure?", style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Text("This action cannot be undone."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text("Cancel", style: TextStyle(color: CustomCol.black)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomCol.chilliRed
                          ),
                          child: Text("Yes, proceed", style: TextStyle(color: CustomCol.silver)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('members')
                      .doc(widget.member.id)
                      .delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Member has been deleted successfully.")),
                    );

                    Navigator.pop(context);
                  }
                }, 
                child: Text("Remove Member")),
          ],)
          ]
        ),
      );
  }
}
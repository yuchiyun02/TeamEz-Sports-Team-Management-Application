import 'package:flutter/material.dart';
import 'package:teamez/widgets/profile/profile_header.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/widgets/general/file_upload_dialog.dart';
import 'package:flutter/services.dart';
import 'package:teamez/widgets/profile/profile_numbers.dart';
import 'package:teamez/widgets/profile/profile_bio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget{
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String teamName = "";
  String email = "";
  String sport = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users') // Change collection name if needed
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          teamName = data?['teamName'] ?? "No Team Name";
          email = data?['email'] ?? "No Email";
          sport = data?['sport'] ?? "Sport Not Selected";
        });
      } else {
        setState(() {
          teamName = "Team not found";
          email = "Email not found";
          sport = "Sport not selected";
        });
      }
    } catch (e) {
      setState(() {
        teamName = "Error loading team";
        email = "Error loading email";
        sport = "Error loading sport";
      });
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomCol.bgGreen,
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileHeader(
            userId: userId,
            type: "profile",
            onClicked: () async {
              showDialog(
                        context: context,
                        builder: (context) => FileUploadDialog(
                          userId: userId,
                          folder: "profile",
                          onFileUploaded: (downloadUrl) {
                            if (mounted) {
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
              Text(teamName, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),

              SizedBox(height: 4),

              Text(sport, 
                style: TextStyle(color: CustomCol.darkGrey, fontSize: 14, fontWeight: FontWeight.bold)),

              SizedBox(height: 4),

              Text(email, 
                style: TextStyle(color: CustomCol.darkGrey, fontSize: 14)),

              SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: CustomCol.silver,
                  backgroundColor: CustomCol.armyGreen,
                  shape: StadiumBorder()
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/editprofilepage");
                }, 
                child: Text("Edit Profile")),

              SizedBox(height:24),
              ProfileNumbers(),
              SizedBox(height:48),
              ProfileBio(userId: userId),           
          ],)
        ],
      )
    );
  }
}
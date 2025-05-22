import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileBio extends StatelessWidget{
  final String userId;
  const ProfileBio({super.key, required this.userId});

  Future<String?> _getUserBio() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc['bio'] ?? 'No bio available';
    
    } catch (e) {
      print("Error fetching bio: $e");
      return 'Error fetching bio';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 48),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("About",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        
            SizedBox(height: 16),
            
            FutureBuilder<String?>(
              future: _getUserBio(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Failed to load bio',
                    style: TextStyle(fontSize: 16, height: 1.4));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No bio available',
                  style: TextStyle(fontSize: 16, height: 1.4));
                } else {
                  return Text(
                    snapshot.data!,
                    style: TextStyle(fontSize: 16, height: 1.4),
                  );
                }
              },
            )],
        ),
      ),
    );
  }
}
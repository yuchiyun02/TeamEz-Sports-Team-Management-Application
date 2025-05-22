import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/navigation.dart';

class ProfileNumbers extends StatefulWidget {
  const ProfileNumbers({super.key});

  @override
  State<ProfileNumbers> createState() => _ProfileNumbersState();
}

class _ProfileNumbersState extends State<ProfileNumbers> {
  int eventCount = 0;
  int friendCount = 0;
  int memberCount = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Get user document for events and friends
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      int events = 0;
      int friends = 0;
      int members = 0;

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        events = (data['events'] as List?)?.length ?? 0;
        friends = (data['friends'] as List?)?.length ?? 0;
      }
      QuerySnapshot eventsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();
      
      events = eventsSnapshot.docs.length;

      // Get count of documents in 'members' subcollection
      QuerySnapshot membersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('members')
          .get();

      members = membersSnapshot.docs.length;

      setState(() {
        eventCount = events;
        friendCount = friends;
        memberCount = members;
      });

    } catch (e) {
      debugPrint('Error fetching counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, eventCount.toString(), "Events", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage(initialIndex: 1)));
          }),
          VerticalDivider(color: CustomCol.black),
          buildButton(context, friendCount.toString(), "Friends", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage(initialIndex: 0))); //Not yet implemented
          }),
          VerticalDivider(color: CustomCol.black),
          buildButton(context, memberCount.toString(), "Members", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage(initialIndex: 6)));
          }),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String value, String text, VoidCallback onPressed) {
    return MaterialButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(height: 2),
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

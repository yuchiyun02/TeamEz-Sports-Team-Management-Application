import 'package:flutter/material.dart';
import 'package:teamez/navigation.dart';
import 'package:teamez/constant/constants.dart';

class AboutPage extends StatelessWidget{
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomCol.bgGreen,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("About", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        
            SizedBox(height:30),
        
            Text("TeamEz is a all-in-one sports management app to help you achieve your team management dreams. Enjoy all features free to use without any plan subscriptions or hidden fees."),
        
            SizedBox(height:20),
            Divider(),
        
            Text("App Version: v1.0.0\n Last Updated: May 8, 2025", style: TextStyle(fontWeight: FontWeight.bold)),
        
            SizedBox(height:5),
        
            Text("Contact Us : \n Website : www.teamezapp.com \n Email : teamezapp@gmail.com"),
        
            SizedBox(height:5),
        
            Text("© 2025 TeamEz Inc.", style: TextStyle(fontWeight: FontWeight.bold)),
        
            SizedBox(height:20),
        
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage(initialIndex: 0))); //Change to the notes
            }, child: Text ("Back to Main"),)
          ],
        ),
      ));
  }
}

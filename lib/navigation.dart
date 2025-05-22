import 'package:flutter/material.dart';
import 'package:teamez/pages/about.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/pages/home.dart';
import 'package:teamez/pages/members/members.dart';
import 'package:teamez/pages/notes/notes.dart';
import 'package:teamez/pages/profile/profile.dart';
import 'package:teamez/pages/events/schedule.dart';
import 'package:teamez/pages/tracker/tracker.dart';
import 'package:teamez/services/auth_service.dart';

class NavigationPage extends StatefulWidget {

  final int initialIndex;

  const NavigationPage({super.key, this.initialIndex = 0}); //Default index is home

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  //Tracks Page
  late int _selectedIndex; //Declared, but not initialized

  final List _pages = [
    MyHomePage(),
    SchedulePage(),
    NotesPage(),
    ProfilePage(),
    TrackerPage(),
    AboutPage(),
    MembersPage()
  ];

  // Allows navigation from other pages to nav page (including selected index)
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; //index initialized
  }

  // Updates Page Index
  void _navigateToPage(int index){
    setState((){
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomCol.bgGreen,
      appBar: AppBar(
        backgroundColor: CustomCol.bgGreen,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      drawer: Drawer(
        backgroundColor: CustomCol.bgGreen,
        child: Column(
          children: [
            DrawerHeader(
                child: Image.asset("assets/app_logo.png",
                  width: 120,
                  height: 60,
                  fit: BoxFit.contain),
                ),
            _drawerItem(Icons.home, "Home", 0),
            _drawerItem(Icons.account_circle_rounded, "Profile", 3),
            _drawerItem(Icons.people, "Members", 6),
            _drawerItem(Icons.calendar_month, "Schedule", 1),
            _drawerItem(Icons.stacked_bar_chart, "Tracker", 4),
            _drawerItem(Icons.book, "Notes", 2),
            _drawerItem(Icons.info, "About", 5),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                await AuthService().signout(context: context);
              },
              )
          ],)
      ),

     //Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: CustomCol.bgGreen, // Background color
          borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
         ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // Subtle shadow for depth
            blurRadius: 10,
            spreadRadius: 2,
          ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), // Rounded edges
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            fixedColor: CustomCol.brightGreen,
            backgroundColor: CustomCol.silver,
            unselectedItemColor: CustomCol.midGreen,
            currentIndex: _selectedIndex.clamp(0,3), //Prevents out-of-bounds error
            onTap: _navigateToPage,
            items: [
              BottomNavigationBarItem(icon: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Icon(Icons.home),
                  ),
                label: "Home"),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 10), 
                  child: Icon(Icons.calendar_month),
                ),
                label: "Schedule",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 10), 
                  child: Icon(Icons.book),
                ),
                label: "Notes",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 10), 
                  child: Icon(Icons.account_circle_rounded),
                ),
                label: "Profile",
              ),
            ]),
          ),
        ),

      body: _pages[_selectedIndex],

      );
  }

 // Helper function for Drawer Items
  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close Drawer
        _navigateToPage(index); // Navigate
      },
    );
  }
}
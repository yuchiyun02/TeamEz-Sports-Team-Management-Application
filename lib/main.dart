import 'package:flutter/material.dart';
import 'package:teamez/navigation.dart';
import 'package:teamez/pages/intro/forget_pass.dart';
import 'package:teamez/pages/intro/signup.dart';
import 'package:teamez/pages/intro/login.dart';
import 'package:teamez/pages/intro/welcome.dart';
import 'package:teamez/pages/profile/edit_profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await checkRememberMe();
}

Future<void> checkRememberMe() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool rememberMe = prefs.getBool('rememberMe') ?? false;
  User? user = FirebaseAuth.instance.currentUser;

  Widget initialScreen = (rememberMe && user != null) 
      ? NavigationPage() // Auto-login 
      : WelcomePage(); // Otherwise, show login screen

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialScreen});
  final Widget initialScreen;

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: initialScreen,
      routes: {
        '/navigationpage' :(context) => NavigationPage(),
        '/signuppage' :(context) => SignupPage(),
        '/loginpage' :(context) => LoginPage(),
        '/welcomepage' :(context) => WelcomePage(),
        '/forgetpasspage' :(context) => ForgetPassPage(),
        '/editprofilepage' :(context) => EditProfilePage(),
      },
    );
  }
}




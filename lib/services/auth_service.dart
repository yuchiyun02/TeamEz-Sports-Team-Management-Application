import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teamez/constant/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:teamez/models/users_model.dart';

void handleAuthError(FirebaseAuthException e) {
  String message;
  
  switch (e.code) {
    case "invalid-credential":
      message = "Invalid credentials provided. Please check and try again.";
      break;
    default:
      message = "An error occurred: ${e.code}";
      break;
  }

  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: CustomCol.midGreen,
    textColor: CustomCol.ashNavy,
    fontSize: 14,
  );
}

void  displayToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: CustomCol.midGreen,
    textColor: CustomCol.ashNavy,
    fontSize: 14,
  );
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create unique user number
  // Prevents duplication IF display name is invalid
  Future<int> _getUniqueNumber(String provider) async {
    DocumentReference counterRef = _firestore.collection('counters').doc('${provider}UserCounter');
    DocumentSnapshot snapshot = await counterRef.get();

    int currentNumber = 1;
    if (snapshot.exists && snapshot.data() != null) {
      currentNumber = snapshot['nextNumber'];
    }

    // Increment the counter
    await counterRef.set({'nextNumber': currentNumber + 1}, SetOptions(merge: true));

    return currentNumber;
  }

  
  //For email and password
  Future<void> signup({
    required BuildContext context,
    required String teamName,
    required String email,
    required String password,
  }) async {

    final navigator = Navigator.of(context);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String? userId = _auth.currentUser?.uid;

      if (userId != null) {
        UserModel user = UserModel(
          uid: userId,
          teamName: teamName.trim(),
          email: email.trim(),
        );

        // Save to Firestore
        await _firestore.collection('users').doc(userId).set(user.toMap());
      }

      await Future.delayed(Duration(seconds: 1));
      navigator.pushReplacementNamed("/navigationpage");

    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
    }
  }


  Future<void> signinGoogle({
    required BuildContext context,
  }) async {
    final navigator = Navigator.of(context);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        int uniqueNumber = await _getUniqueNumber('google');

        UserModel userModel = UserModel(
          uid: user.uid,
          teamName: user.displayName  ?? "Google User #$uniqueNumber",
          email: user.email ?? "email error",
        );

        // Save to Firestore
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap(), SetOptions(merge: true));
      }

      await Future.delayed(Duration(seconds: 1));
      navigator.pushReplacementNamed("/navigationpage");
    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
    } on Exception catch (e) {
      displayToast("Unexpected error: ${e.toString()}");
    }
  }

  Future<void> signInFacebook({required BuildContext context}) async {

    final navigator = Navigator.of(context);
    
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        int uniqueNumber = await _getUniqueNumber('facebook');

        UserModel userModel = UserModel(
          uid: user.uid,
          teamName: user.displayName ?? "Facebook User #$uniqueNumber", // Change if needed
          email: user.email ?? "email error",
        );

        await _firestore.collection('users').doc(user.uid).set(userModel.toMap(), SetOptions(merge: true));
      }
        await Future.delayed(Duration(seconds: 1));
        navigator.pushReplacementNamed("/navigationpage");
      } else {
        displayToast("Facebook Sign-In Cancelled");
      }
    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
    } on Exception catch (e) {
      displayToast("Unexpected error: ${e.toString()}");
    }
  }

  Future<void> signinTwitter({required BuildContext context}) async {

    final navigator = Navigator.of(context);

    final twitterLogin = TwitterLogin(
      apiKey: Keys.twitterAPI,
      apiSecretKey: Keys.twitterSecretAPI,
      redirectURI: 'teamez://callback',
    );

    // Trigger authentication
    final authResult = await twitterLogin.login();

    if (authResult.status == TwitterLoginStatus.loggedIn) {
      try {
        final AuthCredential twitterAuthCredential = TwitterAuthProvider.credential(
          accessToken: authResult.authToken!,
          secret: authResult.authTokenSecret!,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(twitterAuthCredential);
        final User? user = userCredential.user;

        if (user != null) {
          int uniqueNumber = await _getUniqueNumber('twitter');

          UserModel userModel = UserModel(
            uid: user.uid,
            teamName: user.displayName ?? "X User #$uniqueNumber", // Change if needed
            email: user.email ?? "email error",
          );

          await _firestore.collection('users').doc(user.uid).set(userModel.toMap(), SetOptions(merge: true));
        }

        await Future.delayed(Duration(seconds: 1));
        navigator.pushReplacementNamed("/navigationpage");
      } on FirebaseAuthException catch (e) {
        handleAuthError(e);
      } on Exception catch (e) {
        displayToast("Unexpected error: ${e.toString()}");
      }
    } else {
      displayToast("Twitter login failed: ${authResult.errorMessage}");
    }
  }

  //For email and password
  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {

    final navigator = Navigator.of(context);

    try {

      // Save "Remember Me" preference locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', rememberMe);

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password);

      await Future.delayed(Duration(seconds:1));
      if (!context.mounted) return;
      navigator.pushReplacementNamed("/navigationpage");
        
    } on FirebaseAuthException catch(e) {
      handleAuthError(e);
  }}

  Future<void> signout({
    required BuildContext context
  }) async {

    final navigator = Navigator.of(context);

    await _auth.signOut();
    await Future.delayed(Duration(seconds:1));
    navigator.pushReplacementNamed("/welcomepage");
  }

  // Password Reset
  Future<void> passwordReset({
    required BuildContext context,
    required String email}
    ) async {

      final navigator = Navigator.of(context);

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      displayToast("Password reset email sent.");

      await Future.delayed(Duration(seconds:1));
      navigator.pushReplacementNamed("/loginpage");

    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/widgets/general/custom_textfield.dart';
import 'package:teamez/models/users_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formEditProfileKey = GlobalKey<FormState>();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

    if (userDoc.exists) {
      UserModel user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      setState(() {
        _teamNameController.text = user.teamName ?? "";
        _emailController.text = user.email ?? "";
        _sportController.text = user.sport ?? "";
        _bioController.text = user.bio ?? "";
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      String uid = _auth.currentUser!.uid;
      Map<String, dynamic> updates = {};

      if (_teamNameController.text.isNotEmpty) {
        updates['teamName'] = _teamNameController.text;
      }
      if (_bioController.text.isNotEmpty) {
        updates['bio'] = _bioController.text;
      }
      if(_sportController.text.isNotEmpty) {
        updates['sport'] = _sportController.text;
      }

      // Update email first to avoid Firestore conflicts
      if (_emailController.text.isNotEmpty && _emailController.text != _auth.currentUser!.email) {
        await _auth.currentUser!.verifyBeforeUpdateEmail(_emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text('Email verification sent. Please verify your new email within 5 minutes. If you do not verify, your current email will remain unchanged.'),
          duration: Duration(seconds: 5),
        ),
      );

        Future.delayed(Duration(minutes: 5), () async {
          await _auth.currentUser!.reload();
          if (_auth.currentUser!.email != _emailController.text) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Email change not verified in time. Keeping current email.')),
              );
            }
            updates['email'] = _auth.currentUser!.email;
            await _firestore.collection('users').doc(uid).update(updates);
          } 


        });
        updates['email'] = _emailController.text;
      }

      // Update password if provided
      if (_passwordController.text.isNotEmpty) {
        await _auth.currentUser!.updatePassword(_passwordController.text);
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile updated successfully! Refresh to see changes.")),
          );
          _fetchUserData();
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No changes made.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomCol.bgGreen,
      ),
      backgroundColor: CustomCol.bgGreen,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formEditProfileKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 325,
                  color: CustomCol.bgGreen,
                  child: Text("Edit Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                  ),
                ),

                CustomTextField(
                  controller: _teamNameController,
                  label: "Team Name",
                  hintText: "Edit Team Name",
                ),

                SizedBox(height: 20),

                CustomTextField(
                  controller: _emailController,
                  label: "Email",
                  hintText: "Edit Email",
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !value.contains("@")) {
                      return "Please enter a valid email";
                    }
                    return null;
                  }),

                SizedBox(height: 20),

                CustomTextField(
                  controller: _passwordController,
                  label: "Password",
                  hintText: "Edit Password",
                  obscureText: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length <= 6) {
                      return "Password must be longer than 6 characters";
                    }
                    return null;
                  }),

                SizedBox(height: 20),

                CustomTextField(
                  controller: _sportController,
                  label: "Sport",
                  hintText: "Edit Sport",
                ),

                SizedBox(height: 20),

                TextField(
                  controller: _bioController,
                  maxLines: 7,
                  decoration: InputDecoration(
                    fillColor: CustomCol.silver,
                    filled: true,
                    labelText: "Bio",
                    hintText: "Edit Bio",
                    hintStyle: TextStyle(color: CustomCol.darkGrey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: CustomCol.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CustomCol.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formEditProfileKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Saving Changes...")),
                        );
                        await _updateProfile();
                      }
                    },
                    child: Text(
                      "Save Changes",
                      style: TextStyle(color: CustomCol.darkGrey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

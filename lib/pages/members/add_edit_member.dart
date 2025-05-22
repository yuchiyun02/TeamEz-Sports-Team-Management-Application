import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamez/widgets/general/custom_textfield.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/models/members_model.dart';  // Import the Member model

class AddEditMemberPage extends StatefulWidget {
  final bool isEdit;
  final String? id;
  const AddEditMemberPage({super.key, this.isEdit = false, this.id});

  @override
  State<AddEditMemberPage> createState() => _AddEditMemberPageState();
}

class _AddEditMemberPageState extends State<AddEditMemberPage> {
  final _formEditMemberKey = GlobalKey<FormState>();
  final TextEditingController _memberNameController = TextEditingController();
  final TextEditingController _eContactController = TextEditingController();
  final TextEditingController _eRelationController = TextEditingController();
  final TextEditingController _posController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String userId = FirebaseAuth.instance.currentUser!.uid;
  String playerStatus = "Active"; // Default value for player status

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.id != null) {
      fetchMemberData();
    }
  }

  Future<void> fetchMemberData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('members')
        .doc(widget.id)
        .get();

    if (doc.exists) {
      final member = Member.fromMap(doc.data()!);
      setState(() {
        _memberNameController.text = member.name;
        _posController.text = member.position;
        _contactController.text = member.contact;
        _eContactController.text = member.emergencyContact;
        _eRelationController.text = member.emergencyContactRelation;
        playerStatus = member.playerStatus;
      });
    }
  }

  Future<void> _saveMember() async {
    if (_formEditMemberKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEdit ? "Saving Changes..." : "Adding Member...")),
      );

      try {
        final memberDocRef = widget.isEdit && widget.id != null
            ? FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('members')
                .doc(widget.id)
            : FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('members')
                .doc();

        final memberData = {
          'name': _memberNameController.text,
          'position': _posController.text,
          'contact': _contactController.text,
          'emergencyContact': _eContactController.text,
          'emergencyContactRelation': _eRelationController.text,
          'playerStatus': playerStatus,
        };

        if (widget.isEdit) {
          // EDIT: Only update changed fields
          await memberDocRef.update(memberData);
        } else {
          // ADD: Add full member with default fields
          await memberDocRef.set({
            'id': memberDocRef.id,
            ...memberData
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? "Member updated successfully" : "Member added successfully")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
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
            key: _formEditMemberKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 75,
                  width: 325,
                  color: CustomCol.bgGreen,
                  child: Text(
                    widget.isEdit ? "Edit Member" : "Add Member",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                CustomTextField(
                  controller: _memberNameController,
                  label: "Member Name",
                  hintText: "Member Name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter name";
                    }
                      return null;
                    },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  controller: _posController,
                  label: "Position",
                  hintText: "Position",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter position";
                    }
                      return null;
                    },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  controller: _contactController,
                  label: "Contact",
                  hintText: "Contact",
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 10) {
                        return "Contact number must be exactly 10 digits long";
                      }
                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return "Contact number must contain only digits";
                      }
                      return null;
                    } else {
                      return "Please enter contact";
                    }
                  },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  controller: _eContactController,
                  label: "Emergency Contact",
                  hintText: "Emergency Contact",
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 10) {
                        return "Contact number must be exactly 10 digits long";
                      }
                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return "Contact number must contain only digits";
                      }
                      return null;
                    } else {
                      return "Please enter emergency contact";
                    }
                  },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  controller: _eRelationController,
                  label: "Emergency Contact Relation",
                  hintText: "Emergency Contact Relation",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter emergency contact relation";
                    }
                      return null;
                    },
                ),
                SizedBox(height: 20),
                
                // Dropdown for player status
                DropdownButtonFormField<String>(
                  value: playerStatus,
                  onChanged: (String? newValue) {
                    setState(() {
                      playerStatus = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Player Status",
                    filled: true,
                    fillColor: CustomCol.silver,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ["Active", "Inactive", "Injured"]
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                ),
                
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveMember,
                    child: Text(
                      widget.isEdit ? "Save Changes" : "Add Member",
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

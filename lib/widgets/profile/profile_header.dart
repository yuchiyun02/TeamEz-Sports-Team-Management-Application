import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teamez/constant/constants.dart';

class ProfileHeader extends StatefulWidget {
  final String userId;
  final String type;  // 'profile', 'member', or 'event'
  final String? memberId; 
  final String? eventId;  
  final VoidCallback onClicked;

  const ProfileHeader({
    super.key,
    required this.userId,
    required this.type,
    this.memberId,
    this.eventId,
    required this.onClicked,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  ImageProvider image = const AssetImage('assets/default_profile.jpg');

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  String _getStoragePath() {
    // Handle paths based on the type (string)
    if (widget.type == 'profile') {
      return 'user-uploads/${widget.userId}/profile';
    } else if (widget.type == 'member' && widget.memberId != null) {
      return 'user-uploads/${widget.userId}/members/${widget.memberId}';
    } else if (widget.type == 'event' && widget.eventId != null) {
      return 'user-uploads/${widget.userId}/events/${widget.eventId}';
    } else {
      return ''; // Default fallback
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final ref = FirebaseStorage.instance.ref(_getStoragePath());
      final listResult = await ref.listAll();
      final profileFiles = listResult.items.where((item) => item.name != 'keep.txt').toList();

      if (profileFiles.isNotEmpty) {
        final downloadUrl = await profileFiles.first.getDownloadURL();
        if (mounted) {
          setState(() {
            image = NetworkImage(downloadUrl);
          });
        }
      } else if (mounted) {
        setState(() {
          image = const AssetImage("assets/default_profile.jpg");
        });
      }
    } catch (e) {
      print('Error loading profile image: $e');
      if (mounted) {
        setState(() {
          image = const AssetImage("assets/default_profile.jpg");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // Profile picture
          ClipOval(
            child: Material(
              color: Colors.transparent,
              child: Ink.image(
                image: image,
                fit: BoxFit.cover,
                width: 128,
                height: 128,
                child: InkWell(onTap: widget.onClicked),
              ),
            ),
          ),

          // Edit icon
          Positioned(
            bottom: 0,
            right: 4,
            child: ClipOval(
              child: Container(
                padding: const EdgeInsets.all(3),
                color: CustomCol.bgGreen,
                child: ClipOval(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: CustomCol.darkGrey,
                    child: Icon(Icons.edit, color: CustomCol.silver, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

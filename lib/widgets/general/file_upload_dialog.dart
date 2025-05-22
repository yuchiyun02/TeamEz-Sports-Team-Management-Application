import 'dart:io';
import 'package:teamez/constant/constants.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FileUploadDialog extends StatefulWidget {
  final Function(String) onFileUploaded;
  final String userId;
  final String folder; // 'events', 'members', or 'profile'
  final String? memberId;
  final String? eventId;

  const FileUploadDialog({
    super.key,
    required this.onFileUploaded,
    required this.userId,
    required this.folder,
    this.memberId,
    this.eventId
  });

  @override
  FileUploadDialogState createState() => FileUploadDialogState();
}

class FileUploadDialogState extends State<FileUploadDialog> {
  PlatformFile? pickedFile;
  bool isUploading = false;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future<void> deleteExistingFilesInFolder(String folder, String userId, {String? subfolder}) async {
    try {
      String path = 'user-uploads/$userId/$folder';
      if (subfolder != null) {
        path += '/$subfolder';
      }

      final storageRef = FirebaseStorage.instance.ref(path);
      final listResult = await storageRef.listAll();

      for (var item in listResult.items) {
          await item.delete();
      }
    } catch (e) {
      print('Error deleting existing files in $folder: $e');
    }
  }

  Future<String?> uploadFileToFirebase(File file, String fileName) async {
    try {
      late final String bucketPath;

      if (widget.folder == 'profile') {
        await deleteExistingFilesInFolder('profile', widget.userId);
        bucketPath = 'user-uploads/${widget.userId}/profile/$fileName';
      } else if (widget.folder == 'members' && widget.memberId != null) {
        await deleteExistingFilesInFolder('members', widget.userId, subfolder: widget.memberId);
        bucketPath = 'user-uploads/${widget.userId}/members/${widget.memberId}/$fileName';
      } else if (widget.folder == 'events' && widget.eventId != null) {
        await deleteExistingFilesInFolder('events', widget.userId, subfolder: widget.eventId);
        bucketPath = 'user-uploads/${widget.userId}/events/${widget.eventId}/$fileName';
      } else {
        // Default fallback
        throw Exception('Invalid folder or missing required ID.');
      }

      final storageRef = FirebaseStorage.instance.ref().child(bucketPath);
      setState(() {
        isUploading = true;
      });

      final snapshot = await storageRef.putFile(file);
      setState(() {
        isUploading = false;
      });

      if (snapshot.state == TaskState.success) {
        return await storageRef.getDownloadURL();
      } else {
        print('Upload failed with state: ${snapshot.state}');
        return null;
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file. Please try again.')),
        );
      }
      return null;
    }
  }


  Future uploadFile() async {
    if (pickedFile == null) return;
    final file = File(pickedFile!.path!);
    final fileName = pickedFile!.name;

    final downloadUrl = await uploadFileToFirebase(file, fileName);
    if (downloadUrl != null) {
      widget.onFileUploaded(downloadUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text("Upload Photo", style: TextStyle(fontWeight: FontWeight.bold),)),
      backgroundColor: CustomCol.bgGreen,
      content: SizedBox(
        width: 300,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: CustomCol.midGreen,
              padding: EdgeInsets.all(4),
              child: pickedFile != null
                  ? Image.file(
                      File(pickedFile!.path!),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Text("No file selected",),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectFile,
              child: Text("Select File"),
            ),
            ElevatedButton(
              onPressed: isUploading ? null : uploadFile, //Avoids double submissions
              child: Text("Upload File"),
            ),
            SizedBox(height: 2),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            if (isUploading) ...[
              SizedBox(height: 10),
              CircularProgressIndicator(),
            ]],
        ),
      ),
    );
  }
}

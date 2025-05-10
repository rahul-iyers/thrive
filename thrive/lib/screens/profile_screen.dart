import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import '../models/user_profile.dart';
import 'settings_screen.dart';

// ... imports unchanged ...
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final box = Hive.box<UserProfile>('userProfile');
    final cached = box.get('cached');
    if (cached != null) {
      nameController.text = cached.displayName;
      photoUrl = cached.photoUrl;
      setState(() {});
    }

    final doc = await _firestore.collection('users').doc(user!.uid).get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['displayName'] ?? user?.displayName ?? '';
      photoUrl = data['photoUrl'] ?? user?.photoURL;
      setState(() {});
    }
  }

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isNotEmpty) {
      await user!.updateDisplayName(nameController.text.trim());
    }
    if (photoUrl != null) {
      await user!.updatePhotoURL(photoUrl);
    }
    await user!.reload();

    final box = Hive.box<UserProfile>('userProfile');
    final current = box.get('cached') ?? UserProfile(displayName: '', photoUrl: null);
    final updated = current.copyWith(displayName: nameController.text.trim(), photoUrl: photoUrl);
    box.put('cached', updated);

    await _firestore.collection('users').doc(user!.uid).set({
      'displayName': updated.displayName,
      'photoUrl': updated.photoUrl,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated')));
  }

  Future<void> _changePassword() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset email sent')));
  }

  Future<void> _pickAndUploadPhoto() async {
    if (Platform.isAndroid && await Permission.mediaLibrary.isDenied) {
      final status = await Permission.mediaLibrary.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Media access is required to choose a photo')),
        );
        return;
      }
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final storageRef = FirebaseStorage.instance.ref('profile_photos/${user!.uid}.jpg');

    try {
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();
      photoUrl = downloadUrl;
      await user!.updatePhotoURL(downloadUrl);
      setState(() {});
    } catch (e) {
      print("Upload failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Photo upload failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height:100),
            GestureDetector(
              onTap: _pickAndUploadPhoto,
              child: CircleAvatar(
                radius: 100,
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                child: photoUrl == null ? Icon(Icons.person, size: 40) : null,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: nameController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Your Name',
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(user?.email ?? '', style: TextStyle(fontSize: 18, color: Colors.grey[700])),

            SizedBox(height: 110),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save Profile'),
              onPressed: _saveProfile,
              style:ElevatedButton.styleFrom(minimumSize: Size(double.infinity,60)),
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
              style:OutlinedButton.styleFrom(minimumSize: Size(double.infinity,60))
            ),
          ],
        ),
      ),
    );
  }
}


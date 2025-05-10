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

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController calorieController = TextEditingController();
  final TextEditingController workoutController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();

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
      weightController.text = cached.weightGoal?.toString() ?? '';
      calorieController.text = cached.calorieGoal?.toString() ?? '';
      workoutController.text = cached.workoutGoal?.toString() ?? '';
      proteinController.text = cached.proteinGoal?.toString() ?? '';
      setState(() {});
    }

    final doc = await _firestore.collection('users').doc(user!.uid).get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['displayName'] ?? user?.displayName ?? '';
      weightController.text = data['weightGoal']?.toString() ?? '';
      calorieController.text = data['calorieGoal']?.toString() ?? '';
      workoutController.text = data['workoutGoal']?.toString() ?? '';
      proteinController.text = data['proteinGoal']?.toString() ?? '';
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

    final profile = UserProfile(
      displayName: nameController.text.trim(),
      photoUrl: photoUrl,
      weightGoal: int.tryParse(weightController.text),
      calorieGoal: int.tryParse(calorieController.text),
      workoutGoal: int.tryParse(workoutController.text),
      proteinGoal: int.tryParse(proteinController.text),
    );

    final box = Hive.box<UserProfile>('userProfile');
    box.put('cached', profile);

    await _firestore.collection('users').doc(user!.uid).set({
      'displayName': profile.displayName,
      'weightGoal': profile.weightGoal,
      'calorieGoal': profile.calorieGoal,
      'workoutGoal': profile.workoutGoal,
      'proteinGoal': profile.proteinGoal,
      'photoUrl': profile.photoUrl,
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
            GestureDetector(
              onTap: _pickAndUploadPhoto,
              child: CircleAvatar(
                radius: 40,
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(user?.email ?? '', style: TextStyle(color: Colors.grey[700])),

            Divider(height: 32),

            _buildGoalField('Weight Goal (lbs)', weightController),
            _buildGoalField('Calorie Goal (kcal)', calorieController),
            _buildGoalField('Workouts per Week', workoutController),
            _buildGoalField('Protein Goal (g)', proteinController),

            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save Profile'),
              onPressed: _saveProfile,
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

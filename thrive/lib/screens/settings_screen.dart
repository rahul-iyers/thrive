import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  String gender = 'Other';
  String weightUnit = 'Imperial';

  final user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = Hive.box<UserProfile>('userProfile');
    final cached = box.get('cached');
    if (cached != null) {
      ageController.text = cached.age?.toString() ?? '';
      heightController.text = cached.heightInches?.toString() ?? '';
      gender = cached.gender ?? 'Other';
      weightUnit = cached.weightUnit ?? 'Imperial';
      setState(() {});
    }

    final doc = await _firestore.collection('users').doc(user!.uid).get();
    final data = doc.data();
    if (data != null) {
      ageController.text = data['age']?.toString() ?? ageController.text;
      heightController.text = data['heightInches']?.toString() ?? heightController.text;
      gender = data['gender'] ?? gender;
      weightUnit = data['weightUnit'] ?? weightUnit;
      setState(() {});
    }
  }

  Future<void> _saveSettings() async {
    final box = Hive.box<UserProfile>('userProfile');
    final current = box.get('cached') ?? UserProfile(displayName: '', photoUrl: null);

    final updated = current.copyWith(
      age: int.tryParse(ageController.text),
      heightInches: double.tryParse(heightController.text),
      gender: gender,
      weightUnit: weightUnit,
    );

    await box.put('cached', updated);

    await _firestore.collection('users').doc(user!.uid).set({
      'age': updated.age,
      'heightInches': updated.heightInches,
      'gender': updated.gender,
      'weightUnit': updated.weightUnit,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Settings saved')));
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildField('Age', ageController),
            _buildField('Height (inches)', heightController),
            _buildDropdown('Gender', ['Male', 'Female', 'Other'], gender, (val) => setState(() => gender = val!)),
            _buildDropdown('Weight Unit', ['Imperial', 'Metric'], weightUnit, (val) => setState(() => weightUnit = val!)),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save Settings'),
              onPressed: _saveSettings,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildField(String label, TextEditingController controller) {
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

  Widget _buildDropdown(String label, List<String> options, String currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

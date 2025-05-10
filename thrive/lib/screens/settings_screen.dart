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
  final TextEditingController weightGoalController = TextEditingController();
  final TextEditingController calorieGoalController = TextEditingController();
  final TextEditingController workoutGoalController = TextEditingController();
  final TextEditingController proteinGoalController = TextEditingController();
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
      weightGoalController.text = cached.weightGoal?.toString() ?? '';
      calorieGoalController.text = cached.calorieGoal?.toString() ?? '';
      workoutGoalController.text = cached.workoutGoal?.toString() ?? '';
      proteinGoalController.text = cached.proteinGoal?.toString() ?? '';
      gender = cached.gender ?? 'Other';
      weightUnit = cached.weightUnit ?? 'Imperial';
      setState(() {});
    }

    final doc = await _firestore.collection('users').doc(user!.uid).get();
    final data = doc.data();
    if (data != null) {
      ageController.text = data['age']?.toString() ?? ageController.text;
      heightController.text = data['heightInches']?.toString() ?? heightController.text;
      weightGoalController.text = data['weightGoal']?.toString() ?? weightGoalController.text;
      calorieGoalController.text = data['calorieGoal']?.toString() ?? calorieGoalController.text;
      workoutGoalController.text = data['workoutGoal']?.toString() ?? workoutGoalController.text;
      proteinGoalController.text = data['proteinGoal']?.toString() ?? proteinGoalController.text;
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
      weightGoal: int.tryParse(weightGoalController.text),
      calorieGoal: int.tryParse(calorieGoalController.text),
      workoutGoal: int.tryParse(workoutGoalController.text),
      proteinGoal: int.tryParse(proteinGoalController.text),
    );

    await box.put('cached', updated);

    await _firestore.collection('users').doc(user!.uid).set({
      'age': updated.age,
      'heightInches': updated.heightInches,
      'gender': updated.gender,
      'weightUnit': updated.weightUnit,
      'weightGoal': updated.weightGoal,
      'calorieGoal': updated.calorieGoal,
      'workoutGoal': updated.workoutGoal,
      'proteinGoal': updated.proteinGoal,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildField('Age', ageController),
              _buildField('Height (inches)', heightController),
              _buildDropdown('Gender', ['Male', 'Female', 'Other'], gender, (val) => setState(() => gender = val!)),
              _buildDropdown('Weight Unit', ['Imperial', 'Metric'], weightUnit, (val) => setState(() => weightUnit = val!)),
              Divider(height: 32),
              _buildField('Weight Goal (lbs)', weightGoalController),
              _buildField('Calorie Goal (kcal)', calorieGoalController),
              _buildField('Workouts per Week', workoutGoalController),
              _buildField('Protein Goal (g)', proteinGoalController),
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Save Settings'),
                onPressed: _saveSettings,
              ),
            ],
          ),
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

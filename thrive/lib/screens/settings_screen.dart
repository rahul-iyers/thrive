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
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightGoalController = TextEditingController();
  final TextEditingController calorieGoalController = TextEditingController();
  final TextEditingController workoutGoalController = TextEditingController();
  final TextEditingController proteinGoalController = TextEditingController();
  final TextEditingController sleepGoalController = TextEditingController();

  String gender = 'Other';
  String weightUnit = 'Imperial';
  final user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  String? oldUsername;
  String? usernameStatusMessage;
  bool? isUsernameAvailable;

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
      sleepGoalController.text = cached.sleepGoal?.toString() ?? '';
      setState(() {});
    }

    final doc = await _firestore.collection('users').doc(user!.uid).get();
    final data = doc.data();
    if (data != null) {
      usernameController.text = data['username'] ?? '';
      oldUsername = data['username'];
      ageController.text = data['age']?.toString() ?? ageController.text;
      heightController.text = data['heightInches']?.toString() ?? heightController.text;
      weightGoalController.text = data['weightGoal']?.toString() ?? weightGoalController.text;
      calorieGoalController.text = data['calorieGoal']?.toString() ?? calorieGoalController.text;
      workoutGoalController.text = data['workoutGoal']?.toString() ?? workoutGoalController.text;
      proteinGoalController.text = data['proteinGoal']?.toString() ?? proteinGoalController.text;
      gender = data['gender'] ?? gender;
      weightUnit = data['weightUnit'] ?? weightUnit;
      sleepGoalController.text = data['sleepGoal']?.toString() ?? sleepGoalController.text;
      setState(() {});
    }
  }

  Future<void> checkUsernameAvailability(String username) async {
    final formatValid = RegExp(r'^[a-zA-Z0-9._]{3,30}$').hasMatch(username);
    if (!formatValid) {
      setState(() {
        isUsernameAvailable = null;
        usernameStatusMessage = "3–30 chars. Letters, numbers, '.', '_' only.";
      });
      return;
    }

    final doc = await _firestore.collection('usernames').doc(username).get();
    final isTaken = doc.exists && username != oldUsername;

    setState(() {
      isUsernameAvailable = !isTaken;
      usernameStatusMessage = isTaken ? "Username is taken" : "Username is available";
    });
  }

  Future<void> _saveSettings() async {
    final box = Hive.box<UserProfile>('userProfile');
    final current = box.get('cached') ?? UserProfile(displayName: '', photoUrl: null);

    final newUsername = usernameController.text.trim();

    if (newUsername.isNotEmpty && newUsername != oldUsername) {
      if (!RegExp(r'^[a-zA-Z0-9._]{3,30}$').hasMatch(newUsername)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username format.')),
        );
        return;
      }

      final taken = await _firestore.collection('usernames').doc(newUsername).get();
      if (taken.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username already taken.')),
        );
        return;
      }

      if (oldUsername != null) {
        await _firestore.collection('usernames').doc(oldUsername!).delete();
      }

      await _firestore.collection('usernames').doc(newUsername).set({
        'uid': user!.uid,
      });

      await _firestore.collection('users').doc(user!.uid).update({
        'username': newUsername,
      });

      oldUsername = newUsername;
    }

    final updated = current.copyWith(
      age: int.tryParse(ageController.text),
      heightInches: double.tryParse(heightController.text),
      gender: gender,
      weightUnit: weightUnit,
      weightGoal: int.tryParse(weightGoalController.text),
      calorieGoal: int.tryParse(calorieGoalController.text),
      workoutGoal: int.tryParse(workoutGoalController.text),
      proteinGoal: int.tryParse(proteinGoalController.text),
      sleepGoal: double.tryParse(sleepGoalController.text),
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
      'sleepGoal': updated.sleepGoal,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildUsernameField(),
              _buildField('Age', ageController),
              _buildField('Height (inches)', heightController),
              _buildDropdown('Gender', ['Male', 'Female', 'Other'], gender, (val) => setState(() => gender = val!)),
              _buildDropdown('Weight Unit', ['Imperial', 'Metric'], weightUnit, (val) => setState(() => weightUnit = val!)),
              Divider(height: 32),
              _buildField('Weight Goal (lbs)', weightGoalController),
              _buildField('Calorie Goal (kcal)', calorieGoalController),
              _buildField('Workouts per Week', workoutGoalController),
              _buildField('Protein Goal (g)', proteinGoalController),
              _buildField('Sleep Goal (hrs)', sleepGoalController),
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

  Widget _buildUsernameField() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom:16),
      child: TextField(
        controller: usernameController,
        onChanged: (value) => checkUsernameAvailability(value.trim()),
        decoration: InputDecoration(
          labelText: 'Username',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: isUsernameAvailable == null
              ? null
              : Icon(
            isUsernameAvailable! ? Icons.check_circle : Icons.error,
            color: isUsernameAvailable! ? Colors.green : Colors.red,
          ),
          helperText: usernameStatusMessage,
          helperStyle: TextStyle(
            color: isUsernameAvailable == false ? Colors.red : Colors.grey,
          ),
        ),
      ),
    );
  }
}

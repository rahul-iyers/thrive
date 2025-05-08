import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/food.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart'; // adjust path as needed

Future<void> saveHabitToFirestore(DateTime date, Habit habit, BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No user signed in.')),
    );
    return;
  }

  final firestore = FirebaseFirestore.instance;
  final userId = user.uid;
  final formattedDate = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  final habitData = {
    'sleepHours': habit.sleepHours,
    'moodRating': habit.moodRating,
    'dietNotes': habit.dietNotes,
    'workoutNotes': habit.workoutNotes,
    'dailyNotes': habit.dailyNotes,
    'sleepQuality': habit.sleepQuality,
    'sleepNotes': habit.sleepNotes,
    'exercises': habit.exercises.map((e) => e.toMap()).toList(),
    'foods': habit.foods.map((f) => f.toMap()).toList(),
    'workouts': habit.workouts.map((w) => w.toMap()).toList(),
    'timestamp': FieldValue.serverTimestamp(), // optional: track last update time
  };

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    await firestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(formattedDate)
        .set(habitData);

    Navigator.pop(context); // Close loading spinner

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Habit saved to cloud successfully!')),
    );
  } catch (e) {
    Navigator.pop(context); // Close loading spinner

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save habit.')),
    );
    print('Error saving habit to Firestore: $e');
  }
}

Future<Habit?> loadHabitFromFirestore(DateTime date, BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Not signed in.')),
    );
    return null;
  }

  final firestore = FirebaseFirestore.instance;
  final userId = user.uid;
  final formattedDate = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  try {
    final docSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(formattedDate)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();

      if (data == null) return null;

      // Rebuild Habit from Firestore data
      final habit = Habit(
        sleepHours: (data['sleepHours'] ?? 0).toDouble(),
        moodRating: (data['moodRating'] ?? 0).toInt(),
        dietNotes: (data['dietNotes'] ?? ''),
        exercises: (data['exercises'] as List<dynamic>?)?.map((e) => Exercise(
          name: e['name'] ?? '',
          minutes: (e['minutes'] ?? 0),
          sets: (e['sets'] ?? 0),
          reps: e['reps'] ?? '',
          weight: e['weight'] ?? '',
          notes: e['notes'] ?? '',
          type: e['type'] ?? 'Gym',
        )).toList() ?? [],
        foods: (data['foods'] as List<dynamic>?)?.map((f) => Food(
          name: f['name'] ?? '',
          calories: (f['calories'] ?? 0).toDouble(),
          carbs: (f['carbs'] ?? 0).toDouble(),
          protein: (f['protein'] ?? 0).toDouble(),
          fats: (f['fats'] ?? 0).toDouble(),
          addedSugar: (f['addedSugar'] ?? 0).toDouble(),
        )).toList() ?? [],
        workoutNotes: (data['workoutNotes'] ?? ''),
        workouts: (data['workouts'] as List<dynamic>?)?.map((w) => Workout(
          name: w['name'] ?? '',
          type: w['type'] ?? '',
          minutes: (w['minutes'] ?? 0).toDouble(),
          exercises: (w['exercises'] as List<dynamic>?)?.map((e) => Exercise(
            name: e['name'] ?? '',
            minutes: (e['minutes'] ?? 0),
            sets: (e['sets'] ?? 0),
            reps: e['reps'] ?? '',
            weight: e['weight'] ?? '',
            notes: e['notes'] ?? '',
            type: e['type'] ?? 'Gym',
          )).toList() ?? [],
        )).toList() ?? [],
        dailyNotes: (data['dailyNotes'] ?? ''),
        sleepQuality: (data['sleepQuality'] ?? 3).toInt(),
        sleepNotes: (data['sleepNotes'] ?? ''),
      );

      // Save it locally in Hive too
      final habitBox = Hive.box<Habit>('habits');
      habitBox.put(formattedDate, habit);

      return habit;
    } else {
      return null;
    }
  } catch (e) {
    print('Error loading habit from Firestore: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load habit from cloud')),
    );
    return null;
  }
}


import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/food.dart';
import '../models/mood_entry.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart'; // adjust path as needed

bool templatesLoaded = false;

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
    'moodEntries': habit.moodEntries.map((e) => e.toMap()).toList(),
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
        moodEntries: (data['moodEntries'] as List<dynamic>?)?.map((entry) => MoodEntry(
          timestamp: DateTime.tryParse(entry['timestamp'] ?? '') ?? DateTime.now(),
          rating: (entry['rating'] ?? 5).toInt(),
          notes: entry['notes'] ?? '',
        )).toList() ?? [],
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

Future<void> saveTemplatesToFirestore(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Not signed in.')),
    );
    return;
  }

  final exerciseBox = Hive.box<Exercise>('exercise_templates');
  final foodBox = Hive.box<Food>('food_templates');

  final firestore = FirebaseFirestore.instance;
  final userId = user.uid;

  try {
    final exercises = exerciseBox.values.map((e) => e.toMap()).toList();
    final foods = foodBox.values.map((f) => f.toMap()).toList();

    print('Saving ${exercises.length} exercises and ${foods.length} foods');

    await firestore
        .collection('users')
        .doc(userId)
        .collection('templates')
        .doc('user_templates')
        .set({
      'exercises': exercises,
      'foods': foods,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Templates saved to cloud successfully!')),
    );
  } catch (e) {
    print('Error saving templates: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save templates')),
    );
  }
}

Future<void> loadTemplatesFromFirestore(BuildContext context) async {
  if (templatesLoaded) {
    print('Templates already loaded — skipping...');
    return;
  }

  templatesLoaded = true;
  print('Loading templates from Firestore...');

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('No user signed in.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Not signed in.')),
    );
    return;
  }

  final exerciseBox = Hive.box<Exercise>('exercise_templates');
  final foodBox = Hive.box<Food>('food_templates');
  final firestore = FirebaseFirestore.instance;
  final userId = user.uid;

  try {
    final docSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('templates')
        .doc('user_templates')
        .get();

    if (docSnapshot.exists) {
      print('Templates document found.');

      final data = docSnapshot.data();

      if (data != null) {
        print('Templates data received.');

        final exercises = (data['exercises'] as List<dynamic>?) ?? [];
        final foods = (data['foods'] as List<dynamic>?) ?? [];

        print('Clearing local boxes...');
        await exerciseBox.clear();
        await foodBox.clear();
        print('Cleared.');

        print('Adding exercises...');
        for (var e in exercises) {
          final exercise = Exercise(
            name: e['name'] ?? '',
            minutes: (e['minutes'] ?? 0),
            sets: (e['sets'] ?? 0),
            reps: e['reps'] ?? '',
            weight: e['weight'] ?? '',
            notes: e['notes'] ?? '',
            type: e['type'] ?? 'Gym',
          );
          await exerciseBox.add(exercise);
        }

        print('Adding foods...');
        for (var f in foods) {
          final food = Food(
            name: f['name'] ?? '',
            calories: (f['calories'] ?? 0).toDouble(),
            carbs: (f['carbs'] ?? 0).toDouble(),
            protein: (f['protein'] ?? 0).toDouble(),
            fats: (f['fats'] ?? 0).toDouble(),
            addedSugar: (f['addedSugar'] ?? 0).toDouble(),
          );
          await foodBox.add(food);
        }

        print('Finished loading templates.');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Templates loaded from cloud!')),
        );
      }
    } else {
      print('No templates document found.');
    }
  } catch (e) {
    print('Error loading templates: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load templates')),
    );
  }
}


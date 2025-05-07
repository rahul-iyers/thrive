import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'calendar_screen.dart';
import 'models/habit.dart';
import 'models/exercise.dart';
import 'models/food.dart';
import 'models/workout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register all adapters
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(FoodAdapter());

  // Safely open all boxes
  await openSafeBox<Habit>('habits');
  await openSafeBox<Exercise>('exercise_templates');
  await openSafeBox<Food>('food_templates');

  runApp(Thrive());
}

Future<Box<T>> openSafeBox<T>(String boxName) async {
  try {
    return await Hive.openBox<T>(boxName);
  } catch (e) {
    print('Error opening $boxName: $e');
    print('Deleting and recreating $boxName...');
    await Hive.deleteBoxFromDisk(boxName);
    return await Hive.openBox<T>(boxName);
  }
}

class Thrive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thrive',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarScreen(),
    );
  }
}

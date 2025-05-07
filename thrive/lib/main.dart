import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:thrive/models/workout.dart';
import 'calendar_screen.dart';
import 'models/habit.dart';
import 'models/exercise.dart';
import 'models/food.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // await Hive.deleteBoxFromDisk('habits');
  // await Hive.deleteBoxFromDisk('exercise_templates');
  // await Hive.deleteBoxFromDisk('food_templates');

  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(FoodAdapter());
  Hive.registerAdapter(WorkoutAdapter());

  // await Hive.deleteBoxFromDisk('habits'); // clear old data (DELETES EVERYTHING)
  // await Hive.deleteBoxFromDisk('exercise_templates');

  await Hive.openBox<Habit>('habits');
  await Hive.openBox<Exercise>('exercise_templates');
  await Hive.openBox<Food>('food_templates');
  runApp(Thrive());
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

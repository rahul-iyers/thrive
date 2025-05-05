import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'calendar_screen.dart';
import 'models/habit.dart';
import 'models/exercise.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  // await Hive.deleteBoxFromDisk('habits'); // clear old data (DELETES EVERYTHING)
  await Hive.openBox<Habit>('habits');
  await Hive.openBox<Exercise>('exercise_templates');
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

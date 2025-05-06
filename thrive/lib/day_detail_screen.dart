import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'models/habit.dart';
import 'models/exercise.dart';
import '../screens/add_exercise_screen.dart';
import '../screens/view_exercises_screen.dart';
import '../screens/nutrition_screen.dart';

class DayDetailScreen extends StatefulWidget {
  final DateTime date;

  DayDetailScreen({required this.date});

  @override
  _DayDetailScreenState createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  late Box<Habit> habitBox;
  Habit? habit;

  double sleepHours = 0;
  int moodRating = 5;
  String dietNotes = '';
  List<Exercise> exercises = [];

  @override
  void initState() {
    super.initState();
    habitBox = Hive.box<Habit>('habits');
    loadHabit();
  }

  void loadHabit() {
    final key = DateFormat('yyyy-MM-dd').format(widget.date);
    final storedHabit = habitBox.get(key);
    if (storedHabit != null) {
      setState(() {
        habit = storedHabit;
        sleepHours = storedHabit.sleepHours;
        moodRating = storedHabit.moodRating;
        dietNotes = storedHabit.dietNotes;
        exercises = storedHabit.exercises;
      });
    }
  }

  void saveHabit() {
    final key = DateFormat('yyyy-MM-dd').format(widget.date);
    final newHabit = Habit(
      sleepHours: sleepHours,
      moodRating: moodRating,
      dietNotes: dietNotes,
      exercises: exercises,
      foods: habit?.foods ?? [],
    );
    habitBox.put(key, newHabit);
  }

  int get totalExerciseMinutes {
    return exercises.fold(0, (sum, exercise) => sum + exercise.minutes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMMd().format(widget.date)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Sleep Hours
            Text('Sleep Hours: ${sleepHours.toStringAsFixed(1)}'),
            Slider(
              min: 0,
              max: 12,
              divisions: 24,
              value: sleepHours,
              onChanged: (val) {
                setState(() {
                  sleepHours = val;
                });
              },
            ),
            SizedBox(height: 16),

            // Mood Rating
            Text('Mood Rating: $moodRating'),
            Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: moodRating.toDouble(),
              onChanged: (val) {
                setState(() {
                  moodRating = val.toInt();
                });
              },
            ),
            SizedBox(height: 16),

            // Total Exercise Minutes
            Text('Total Exercise Minutes: $totalExerciseMinutes'),
            SizedBox(height: 8),

            // Add Exercise Button
            ElevatedButton(
              onPressed: () async {
                final newExercise = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddExerciseScreen(
                      onAdd: (exercise) {
                        setState(() {
                          exercises.add(exercise);
                        });
                      },
                    ),
                  ),
                );
              },
              child: Text('Add Exercise'),
            ),

            // View Exercises Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewExercisesScreen(
                      exercises: exercises,
                      onUpdate: (updatedExercises) {
                        setState(() {
                          exercises = updatedExercises;
                        });
                      },
                    ),
                  ),
                );
              },
              child: Text('View Exercises'),
            ),

            SizedBox(height: 16),

            // 🥗 Nutrition Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NutritionScreen(habit: habit ?? Habit(
                      sleepHours: sleepHours,
                      moodRating: moodRating,
                      dietNotes: dietNotes,
                      exercises: exercises,
                    )),
                  ),
                );
              },
              child: Text('Nutrition'),
            ),

            SizedBox(height: 16),

            // Diet Notes
            TextField(
              controller: TextEditingController(text: dietNotes),
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Diet Notes',
              ),
              onChanged: (val) {
                dietNotes = val;
              },
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                saveHabit();
                Navigator.pop(context);
              },
              child: Text('Save Day'),
            ),
          ],
        ),
      ),
    );
  }
}

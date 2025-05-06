import 'package:flutter/material.dart';
import 'models/habit.dart';
import 'models/exercise.dart';
import 'models/workout.dart';
import 'screens/add_exercise_screen.dart';
import 'screens/view_exercises_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/workouts_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

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
  String workoutNotes = '';

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
        workoutNotes = storedHabit.workoutNotes;
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
      workouts: habit?.workouts ?? [],
      workoutNotes: workoutNotes
    );
    habitBox.put(key, newHabit);
    habit = newHabit;
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

            Text('Total Exercise Minutes: $totalExerciseMinutes'),
            SizedBox(height: 8),

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

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final updatedHabit = await Navigator.push<Habit>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutsScreen(habit: habit ?? Habit(
                      sleepHours: sleepHours,
                      moodRating: moodRating,
                      dietNotes: dietNotes,
                      exercises: exercises,
                      foods: [],
                      workoutNotes: workoutNotes
                    )),
                  ),
                );

                if (updatedHabit != null) {
                  setState(() {
                    habit = updatedHabit;
                    workoutNotes = updatedHabit.workoutNotes;
                  });
                  saveHabit();
                }
              },
              child: Text('Workouts'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final updatedHabit = await Navigator.push<Habit>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NutritionScreen(habit: habit ?? Habit(
                      sleepHours: sleepHours,
                      moodRating: moodRating,
                      dietNotes: dietNotes,
                      exercises: exercises,
                      foods: [],
                      workoutNotes: workoutNotes
                    )),
                  ),
                );

                if (updatedHabit != null) {
                  setState(() {
                    habit = updatedHabit;
                    dietNotes = updatedHabit.dietNotes;
                  });
                  saveHabit();
                }
              },
              child: Text('Nutrition'),
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

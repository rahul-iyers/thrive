import 'package:flutter/material.dart';
import 'models/habit.dart';
import 'models/exercise.dart';
import 'screens/nutrition_screen.dart';
import 'screens/workouts_screen.dart';
import 'screens/sleep_entry_screen.dart';
import 'screens/mood_entry_screen.dart';
import 'screens/daily_notes_screen.dart';
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
  String dailyNotes = '';
  int sleepQuality = 3;
  String sleepNotes = '';

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
        dailyNotes = storedHabit.dailyNotes;
        sleepQuality = storedHabit.sleepQuality;
        sleepNotes = storedHabit.sleepNotes;
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
      workoutNotes: workoutNotes,
      dailyNotes: dailyNotes,
      sleepQuality: sleepQuality,
      sleepNotes: sleepNotes,
    );
    habitBox.put(key, newHabit);
    habit = newHabit;
  }

  Widget _buildCategoryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Text(label, style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.9),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        onPressed: onPressed,
      ),
    );
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
            _buildCategoryButton(
              icon: Icons.bedtime,
              label: 'Sleep',
              color: Colors.indigoAccent,
              onPressed: () async {
                final updatedSleepData = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SleepEntryScreen(
                      initialSleepHours: sleepHours,
                      initialSleepQuality: sleepQuality,
                      initialSleepNotes: sleepNotes,
                    ),
                  ),
                );

                if (updatedSleepData != null) {
                  setState(() {
                    sleepHours = updatedSleepData['sleepHours'];
                    sleepQuality = updatedSleepData['sleepQuality'];
                    sleepNotes = updatedSleepData['sleepNotes'];
                  });
                  saveHabit();
                }
              },
            ),


            SizedBox(height: 12),
            _buildCategoryButton(
              icon: Icons.sentiment_satisfied_alt,
              label: 'Mood',
              color: Colors.pinkAccent,
              onPressed: () async {
                final updatedMood = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(builder: (context) => MoodEntryScreen(initialMoodRating: moodRating)),
                );
                if (updatedMood != null) {
                  setState(() {
                    moodRating = updatedMood;
                  });
                  saveHabit();
                }
              },
            ),
            SizedBox(height: 12),
            _buildCategoryButton(
              icon: Icons.fitness_center,
              label: 'Workouts',
              color: Colors.blueAccent,
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
                      workoutNotes: workoutNotes,
                      dailyNotes: dailyNotes
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
            ),
            SizedBox(height: 12),
            _buildCategoryButton(
              icon: Icons.restaurant,
              label: 'Nutrition',
              color: Colors.green,
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
                      workoutNotes: workoutNotes,
                      dailyNotes: dailyNotes
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
            ),
            SizedBox(height: 12),
            _buildCategoryButton(
              icon: Icons.note_alt,
              label: 'Daily Notes',
              color: Colors.orange,
              onPressed: () async {
                final updatedNotes = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => DailyNotesScreen(initialNotes: dailyNotes)),
                );
                if (updatedNotes != null) {
                  setState(() {
                    dailyNotes = updatedNotes;
                  });
                  saveHabit();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

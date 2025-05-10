import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'models/habit.dart';
import 'models/exercise.dart';
import 'models/mood_entry.dart';
import 'screens/nutrition_screen.dart';
import 'screens/workouts_screen.dart';
import 'screens/sleep_entry_screen.dart';
import 'screens/mood_entry_screen.dart';
import 'screens/daily_notes_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import 'models/user_profile.dart';

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
  List<MoodEntry> moodEntries = [];
  String dietNotes = '';
  List<Exercise> exercises = [];
  String workoutNotes = '';
  String dailyNotes = '';
  int sleepQuality = 3;
  String sleepNotes = '';

  double? sleepGoal;
  int? calorieGoal;

  @override
  void initState() {
    super.initState();
    habitBox = Hive.box<Habit>('habits');
    loadHabit();
    loadUserProfile();
  }

  void loadUserProfile() {
    final box = Hive.box<UserProfile>('userProfile');
    final profile = box.get('cached');
    setState(() {
      sleepGoal = profile?.sleepGoal;
      calorieGoal = profile?.calorieGoal;
    });
  }

  void saveHabit() {
    final key = DateFormat('yyyy-MM-dd').format(widget.date);
    final newHabit = Habit(
      sleepHours: sleepHours,
      moodEntries: moodEntries,
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
    saveHabitToFirestore(widget.date, newHabit, context);
  }

  void loadHabit() async {
    final key = DateFormat('yyyy-MM-dd').format(widget.date);
    Habit? storedHabit = habitBox.get(key);
    storedHabit ??= await loadHabitFromFirestore(widget.date, context);

    if (storedHabit != null) {
      final Habit nonNullHabit = storedHabit;
      setState(() {
        habit = nonNullHabit;
        sleepHours = nonNullHabit.sleepHours;
        moodEntries = nonNullHabit.moodEntries;
        dietNotes = nonNullHabit.dietNotes;
        exercises = nonNullHabit.exercises;
        workoutNotes = nonNullHabit.workoutNotes;
        dailyNotes = nonNullHabit.dailyNotes;
        sleepQuality = nonNullHabit.sleepQuality;
        sleepNotes = nonNullHabit.sleepNotes;
      });
    }
  }

  Future<T?> _slideToPage<T>(Widget page) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(
        builder: (_) => page,
      ),
    );
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

  Widget _buildDailySummaryCard() {
    final totalCalories = (habit?.foods.fold(0.0, (sum, food) => sum + food.calories) ?? 0).toStringAsFixed(0);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today\'s Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildSummaryRow(
              '🛌 Sleep',
              sleepHours > 0
                  ? '${sleepHours.toStringAsFixed(1)}h${sleepGoal != null ? ' / ${sleepGoal!.toStringAsFixed(1)}h' : ''} • Quality: ${_sleepQualityText(sleepQuality)}'
                  : 'Not logged',
            ),
            _buildSummaryRow('🙂 Mood', (habit?.moodEntries.isNotEmpty ?? false)
                ? '${habit!.moodEntries.length} log(s)'
                : 'Not logged'),
            _buildSummaryRow('🏋️ Workouts', (habit?.workouts.isNotEmpty ?? false)
                ? '${habit!.workouts.length} workout(s)'
                : 'Not logged'),
            _buildSummaryRow(
              '🥗 Nutrition',
              (habit?.foods.isNotEmpty ?? false)
                  ? '$totalCalories cal${calorieGoal != null ? ' / ${calorieGoal} cal' : ''}'
                  : 'Not logged',
            ),
            _buildSummaryRow('📝 Notes', dailyNotes.isNotEmpty ? 'Added' : 'Not logged'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(
            detail,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _sleepQualityText(int quality) {
    if (quality >= 4) return 'Excellent';
    if (quality == 3) return 'Good';
    if (quality == 2) return 'Okay';
    return 'Poor';
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
            _buildDailySummaryCard(),
            SizedBox(height: 16),
            _buildCategoryButton(
              icon: Icons.bedtime,
              label: 'Sleep',
              color: Colors.indigoAccent,
              onPressed: () async {
                final updatedSleepData = await _slideToPage<Map<String, dynamic>>(
                  SleepEntryScreen(
                    initialSleepHours: sleepHours,
                    initialSleepQuality: sleepQuality,
                    initialSleepNotes: sleepNotes,
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
                final updatedHabit = await _slideToPage<Habit>(
                  MoodEntryScreen(
                    habit: habit ?? Habit(
                      sleepHours: sleepHours,
                      moodEntries: moodEntries,
                      dietNotes: dietNotes,
                      exercises: exercises,
                      foods: [],
                      workouts: [],
                      workoutNotes: workoutNotes,
                      dailyNotes: dailyNotes,
                    ),
                  ),
                );
                if (updatedHabit != null) {
                  setState(() {
                    habit = updatedHabit;
                    moodEntries = updatedHabit.moodEntries;
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
                final updatedHabit = await _slideToPage<Habit>(
                  WorkoutsScreen(
                    habit: habit ?? Habit(
                      sleepHours: sleepHours,
                      moodEntries: moodEntries,
                      dietNotes: dietNotes,
                      exercises: exercises,
                      foods: [],
                      workoutNotes: workoutNotes,
                      dailyNotes: dailyNotes,
                    ),
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
                final updatedHabit = await _slideToPage<Habit>(
                  NutritionScreen(
                    habit: habit ?? Habit(
                      sleepHours: sleepHours,
                      moodEntries: moodEntries,
                      dietNotes: dietNotes,
                      exercises: exercises,
                      foods: [],
                      workoutNotes: workoutNotes,
                      dailyNotes: dailyNotes,
                    ),
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
                final updatedNotes = await _slideToPage<String>(
                  DailyNotesScreen(initialNotes: dailyNotes),
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

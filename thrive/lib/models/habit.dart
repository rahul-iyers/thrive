import 'package:hive/hive.dart';
import 'exercise.dart';
import 'food.dart';
import 'workout.dart';
import 'mood_entry.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  double sleepHours;

  @HiveField(1)
  List<MoodEntry> moodEntries;

  @HiveField(2)
  String dietNotes;

  @HiveField(3)
  List<Exercise> exercises;

  @HiveField(4)
  List<Food> foods;

  @HiveField(5)
  String workoutNotes;

  @HiveField(6)
  List<Workout> workouts;

  @HiveField(7)
  String dailyNotes;

  @HiveField(8)
  int sleepQuality;

  @HiveField(9)
  String sleepNotes;

  Habit({
    required this.sleepHours,
    required this.moodEntries,
    required this.dietNotes,
    required this.exercises,
    this.foods = const [],
    required this.workoutNotes,
    this.workouts = const[],
    required this.dailyNotes,
    this.sleepQuality = 3,   // default medium quality
    this.sleepNotes = '',
  });
}

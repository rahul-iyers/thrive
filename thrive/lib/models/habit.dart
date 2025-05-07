import 'package:hive/hive.dart';
import 'exercise.dart';
import 'food.dart';
import 'workout.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  double sleepHours;

  @HiveField(1)
  int moodRating;

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

  Habit({
    required this.sleepHours,
    required this.moodRating,
    required this.dietNotes,
    required this.exercises,
    this.foods = const [],
    required this.workoutNotes,
    this.workouts = const[],
    required this.dailyNotes
  });
}

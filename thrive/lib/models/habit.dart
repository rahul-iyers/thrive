import 'package:hive/hive.dart';
import 'exercise.dart';

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

  Habit({
    required this.sleepHours,
    required this.moodRating,
    required this.dietNotes,
    required this.exercises,
  });
}

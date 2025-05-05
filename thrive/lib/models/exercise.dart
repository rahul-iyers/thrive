import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int minutes; // minutes spent on exercise

  @HiveField(2)
  int sets; // gym only (can be 0 for sports)

  @HiveField(3)
  int reps; // gym only (can be 0 for sports)

  @HiveField(4)
  String weight; // gym only (can be 0 for sports)

  @HiveField(5)
  String notes; // optional notes (e.g., "Felt great" / "Hard tennis match")

  @HiveField(6)
  String type; // Gym, Sport, Cardio, etc.

  Exercise({
    required this.name,
    this.minutes = 0,
    this.sets = 0,
    this.reps = 0,
    this.weight = '',
    this.notes = '',
    this.type = 'Gym',
  });
}

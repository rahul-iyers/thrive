import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  String name; // name of exercise

  @HiveField(1)
  int minutes; // minutes spent on exercise

  @HiveField(2)
  int sets; // gym

  @HiveField(3)
  String reps; // gym

  @HiveField(4)
  String weight; // gym

  @HiveField(5)
  String notes; // optional notes

  @HiveField(6)
  String type; // gym, sport, cardio, etc.

  Exercise({
    required this.name,
    this.minutes = 0,
    this.sets = 0,
    this.reps = '',
    this.weight = '',
    this.notes = '',
    this.type = 'Gym',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'minutes': minutes,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'notes': notes,
      'type': type,
    };
  }
}

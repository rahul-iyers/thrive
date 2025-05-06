import 'package:hive/hive.dart';

part 'workout.g.dart'; // This is needed for Hive type adapter

@HiveType(typeId: 2)
class Workout extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type; // gym, sport, cardio, etc.

  @HiveField(2)
  double minutes;

  Workout({
    required this.name,
    required this.type,
    this.minutes = 0,
  });
}

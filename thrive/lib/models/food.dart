import 'package:hive/hive.dart';

part 'food.g.dart'; // This is needed for Hive type adapter

@HiveType(typeId: 3)
class Food extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double calories;

  @HiveField(2)
  double carbs;

  @HiveField(3)
  double protein;

  @HiveField(4)
  double fats;

  @HiveField(5)
  double addedSugar;

  Food({
    required this.name,
    required this.calories,
    this.carbs = 0,
    this.protein = 0,
    this.fats = 0,
    this.addedSugar = 0,
  });
}

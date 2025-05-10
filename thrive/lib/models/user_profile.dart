import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 5)
class UserProfile extends HiveObject {
  @HiveField(0)
  String displayName;

  @HiveField(1)
  String? photoUrl;

  @HiveField(2)
  int? weightGoal;

  @HiveField(3)
  int? calorieGoal;

  @HiveField(4)
  int? workoutGoal;

  @HiveField(5)
  int? proteinGoal;

  @HiveField(6)
  int? currentWeight;

  @HiveField(7)
  String? weightUnit; // 'lbs' or 'kg'

  @HiveField(8)
  String? gender;

  @HiveField(9)
  int? age;

  @HiveField(10)
  double? heightInches;

  @HiveField(11)
  DateTime? createdAt;

  UserProfile({
    required this.displayName,
    this.photoUrl,
    this.weightGoal,
    this.calorieGoal,
    this.workoutGoal,
    this.proteinGoal,
    this.currentWeight,
    this.weightUnit,
    this.gender,
    this.age,
    this.heightInches,
    this.createdAt,
  });

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    int? weightGoal,
    int? calorieGoal,
    int? workoutGoal,
    int? proteinGoal,
    int? age,
    double? heightInches,
    String? gender,
    String? weightUnit,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      weightGoal: weightGoal ?? this.weightGoal,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      workoutGoal: workoutGoal ?? this.workoutGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      age: age ?? this.age,
      heightInches: heightInches ?? this.heightInches,
      gender: gender ?? this.gender,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }

}

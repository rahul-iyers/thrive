// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 5;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      displayName: fields[0] as String,
      photoUrl: fields[1] as String?,
      weightGoal: fields[2] as int?,
      calorieGoal: fields[3] as int?,
      workoutGoal: fields[4] as int?,
      proteinGoal: fields[5] as int?,
      currentWeight: fields[6] as int?,
      weightUnit: fields[7] as String?,
      gender: fields[8] as String?,
      age: fields[9] as int?,
      heightInches: fields[10] as double?,
      createdAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.displayName)
      ..writeByte(1)
      ..write(obj.photoUrl)
      ..writeByte(2)
      ..write(obj.weightGoal)
      ..writeByte(3)
      ..write(obj.calorieGoal)
      ..writeByte(4)
      ..write(obj.workoutGoal)
      ..writeByte(5)
      ..write(obj.proteinGoal)
      ..writeByte(6)
      ..write(obj.currentWeight)
      ..writeByte(7)
      ..write(obj.weightUnit)
      ..writeByte(8)
      ..write(obj.gender)
      ..writeByte(9)
      ..write(obj.age)
      ..writeByte(10)
      ..write(obj.heightInches)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

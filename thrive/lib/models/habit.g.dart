// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      sleepHours: fields[0] as double,
      moodRating: fields[1] as int,
      dietNotes: fields[2] as String,
      exercises: (fields[3] as List).cast<Exercise>(),
      foods: (fields[4] as List).cast<Food>(),
      workoutNotes: fields[5] as String,
      workouts: (fields[6] as List).cast<Workout>(),
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.sleepHours)
      ..writeByte(1)
      ..write(obj.moodRating)
      ..writeByte(2)
      ..write(obj.dietNotes)
      ..writeByte(3)
      ..write(obj.exercises)
      ..writeByte(4)
      ..write(obj.foods)
      ..writeByte(5)
      ..write(obj.workoutNotes)
      ..writeByte(6)
      ..write(obj.workouts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

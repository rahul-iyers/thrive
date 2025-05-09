import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 5)
class MoodEntry extends HiveObject {
  @HiveField(0)
  DateTime timestamp;

  @HiveField(1)
  int rating;

  @HiveField(2)
  String notes;

  MoodEntry({
    required this.timestamp,
    required this.rating,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'rating': rating,
      'notes': notes,
    };
  }
}

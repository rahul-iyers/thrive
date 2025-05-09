import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 4)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final int rating;

  @HiveField(3)
  final String notes;

  MoodEntry({
    required this.id,
    required this.timestamp,
    required this.rating,
    required this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'rating': rating,
    'notes': notes,
  };

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      rating: map['rating'] ?? 5,
      notes: map['notes'] ?? '',
    );
  }
}

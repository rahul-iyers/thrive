import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../models/habit.dart';

class MoodEntryScreen extends StatefulWidget {
  final Habit habit; // <-- pass in Habit!

  MoodEntryScreen({required this.habit});

  @override
  _MoodEntryScreenState createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  int moodRating = 5;
  TextEditingController notesController = TextEditingController();

  void _saveMood() {
    final newEntry = MoodEntry(
      timestamp: DateTime.now(),
      rating: moodRating,
      notes: notesController.text,
    );

    final updatedMoodEntries = List<MoodEntry>.from(widget.habit.moodEntries)
      ..add(newEntry);

    final updatedHabit = Habit(
      sleepHours: widget.habit.sleepHours,
      moodEntries: updatedMoodEntries,
      dietNotes: widget.habit.dietNotes,
      exercises: widget.habit.exercises,
      foods: widget.habit.foods,
      workouts: widget.habit.workouts,
      workoutNotes: widget.habit.workoutNotes,
      dailyNotes: widget.habit.dailyNotes,
      sleepQuality: widget.habit.sleepQuality,
      sleepNotes: widget.habit.sleepNotes,
    );

    Navigator.pop(context, updatedHabit);
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.habit.moodEntries.reversed.toList(); // newest first

    return Scaffold(
      appBar: AppBar(title: Text('Mood Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Rate your mood (1–10)', style: TextStyle(fontSize: 18)),
            Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: moodRating.toDouble(),
              label: moodRating.toString(),
              onChanged: (value) {
                setState(() {
                  moodRating = value.toInt();
                });
              },
            ),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Add notes (optional)',
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMood,
              child: Text('Save Mood Entry'),
            ),
            SizedBox(height: 24),
            Divider(),
            Text('Today\'s Entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Expanded(
              child: entries.isEmpty
                  ? Center(child: Text('No mood entries yet.'))
                  : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.pinkAccent,
                      child: Text(entry.rating.toString(), style: TextStyle(color: Colors.white)),
                    ),
                    title: Text(entry.notes.isNotEmpty ? entry.notes : 'No notes'),
                    subtitle: Text(
                      '${TimeOfDay.fromDateTime(entry.timestamp).format(context)}',
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

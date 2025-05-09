import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../models/mood_entry.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../services/firestore_service.dart';

class MoodEntryScreen extends StatefulWidget {
  final Habit habit;

  MoodEntryScreen({required this.habit});

  @override
  _MoodEntryScreenState createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  late List<MoodEntry> moodEntries;

  @override
  void initState() {
    super.initState();
    moodEntries = List<MoodEntry>.from(widget.habit.moodEntries);
  }

  void _addEntry() {
    setState(() {
      moodEntries.add(MoodEntry(
        id: Uuid().v4(),
        timestamp: DateTime.now(),
        rating: 5,
        notes: '',
      ));
    });
    _save();
  }

  void _deleteEntry(String id) {
    setState(() {
      moodEntries.removeWhere((entry) => entry.id == id);
    });
    _save();
  }

  void _updateEntry(String id, int rating, String notes) {
    setState(() {
      final index = moodEntries.indexWhere((e) => e.id == id);
      if (index != -1) {
        moodEntries[index] = MoodEntry(
          id: id,
          timestamp: moodEntries[index].timestamp,
          rating: rating,
          notes: notes,
        );
      }
    });
    _save();
  }

  void _save() {
    final updatedHabit = widget.habit..moodEntries = moodEntries;
    final box = Hive.box<Habit>('habits');
    box.put(widget.habit.key, updatedHabit);
    saveHabitToFirestore(DateTime.parse(widget.habit.key), updatedHabit, context);
  }

  Widget _buildMoodCard(MoodEntry entry) {
    final controller = TextEditingController(text: entry.notes);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat.jm().format(entry.timestamp), style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteEntry(entry.id),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Mood Rating: ${entry.rating}', style: TextStyle(fontSize: 16)),
            Slider(
              value: entry.rating.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: entry.rating.toString(),
              onChanged: (value) {
                _updateEntry(entry.id, value.toInt(), controller.text);
              },
            ),
            TextField(
              controller: controller,
              onChanged: (val) => _updateEntry(entry.id, entry.rating, val),
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Logs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: moodEntries.isEmpty
            ? Center(child: Text('No mood entries yet.\nTap + to add one.', textAlign: TextAlign.center))
            : ListView.builder(
          itemCount: moodEntries.length,
          itemBuilder: (context, index) {
            return _buildMoodCard(moodEntries[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: Icon(Icons.add),
      ),
    );
  }
}

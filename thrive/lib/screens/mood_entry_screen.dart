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

  void _deleteEntry(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Entry?'),
        content: Text('Are you sure you want to delete this mood entry?'),
        actions: [
          TextButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: Text('Delete'), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        moodEntries.removeWhere((entry) => entry.id == id);
      });
      _save();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mood entry deleted')));
    }
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

  void _showAddMoodDialog() {
    int newRating = 5;
    TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('New Mood Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mood Rating: $newRating'),
              Slider(
                value: newRating.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: newRating.toString(),
                onChanged: (value) {
                  setState(() {
                    newRating = value.toInt(); // <-- now updates inside dialog
                  });
                },
              ),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final newEntry = MoodEntry(
                  id: Uuid().v4(),
                  timestamp: DateTime.now(),
                  rating: newRating,
                  notes: notesController.text,
                );
                setState(() {
                  moodEntries.add(newEntry);
                });
                _save();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mood entry saved')));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(MoodEntry entry) {
    final notesController = TextEditingController(text: entry.notes);
    int currentRating = entry.rating;
    bool hasChanges = false;

    return StatefulBuilder(
      builder: (context, setCardState) {
        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header row with time + delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat.jm().format(entry.timestamp),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.grey[700]),
                      onPressed: () => _deleteEntry(entry.id),
                    ),
                  ],
                ),

                SizedBox(height: 12),
                Text('Mood Rating', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Slider(
                  value: currentRating.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: currentRating.toString(),
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.blueGrey[100],
                  onChanged: (value) {
                    setCardState(() {
                      currentRating = value.toInt();
                      hasChanges = true;
                    });
                  },
                ),

                SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  onChanged: (val) {
                    setCardState(() {
                      hasChanges = true;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    labelStyle: TextStyle(fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.all(12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: null,
                ),

                if (hasChanges) ...[
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        _updateEntry(entry.id, currentRating, notesController.text);
                        setCardState(() => hasChanges = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Changes saved')));
                      },
                    ),
                  )
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Mood Logs', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
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
        onPressed: _showAddMoodDialog,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, size: 28),
      ),
    );
  }
}

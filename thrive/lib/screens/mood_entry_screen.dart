import 'package:flutter/material.dart';

class MoodEntryScreen extends StatefulWidget {
  final int initialMoodRating;

  MoodEntryScreen({required this.initialMoodRating});

  @override
  _MoodEntryScreenState createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  late int moodRating;

  @override
  void initState() {
    super.initState();
    moodRating = widget.initialMoodRating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Mood')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Mood Rating: $moodRating', style: TextStyle(fontSize: 24)),
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
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, moodRating);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

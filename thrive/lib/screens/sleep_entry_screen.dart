import 'package:flutter/material.dart';

class SleepEntryScreen extends StatefulWidget {
  final double initialSleepHours;

  SleepEntryScreen({required this.initialSleepHours});

  @override
  _SleepEntryScreenState createState() => _SleepEntryScreenState();
}

class _SleepEntryScreenState extends State<SleepEntryScreen> {
  late double sleepHours;

  @override
  void initState() {
    super.initState();
    sleepHours = widget.initialSleepHours;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Sleep')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Sleep Hours: ${sleepHours.toStringAsFixed(1)}', style: TextStyle(fontSize: 24)),
            Slider(
              min: 0,
              max: 12,
              divisions: 24,
              value: sleepHours,
              label: sleepHours.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  sleepHours = value;
                });
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, sleepHours);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

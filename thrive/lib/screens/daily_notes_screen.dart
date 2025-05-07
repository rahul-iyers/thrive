import 'package:flutter/material.dart';

class DailyNotesScreen extends StatefulWidget {
  final String initialNotes;

  DailyNotesScreen({required this.initialNotes});

  @override
  _DailyNotesScreenState createState() => _DailyNotesScreenState();
}

class _DailyNotesScreenState extends State<DailyNotesScreen> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Notes')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _notesController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Write anything about your day...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _notesController.text);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

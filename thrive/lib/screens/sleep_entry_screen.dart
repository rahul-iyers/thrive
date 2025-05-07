import 'package:flutter/material.dart';

class SleepEntryScreen extends StatefulWidget {
  final double initialSleepHours;
  final int initialSleepQuality;
  final String initialSleepNotes;

  SleepEntryScreen({
    required this.initialSleepHours,
    required this.initialSleepQuality,
    required this.initialSleepNotes,
  });

  @override
  _SleepEntryScreenState createState() => _SleepEntryScreenState();
}

class _SleepEntryScreenState extends State<SleepEntryScreen> {
  late double sleepHours;
  late int sleepQuality;
  late String sleepNotes;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    sleepHours = widget.initialSleepHours;
    sleepQuality = widget.initialSleepQuality;
    sleepNotes = widget.initialSleepNotes;
    notesController = TextEditingController(text: sleepNotes);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  void _saveAndExit() {
    Navigator.pop(context, {
      'sleepHours': sleepHours,
      'sleepQuality': sleepQuality,
      'sleepNotes': notesController.text,
    });
  }

  Widget _buildSleepDashboard() {
    String qualityText;
    Color qualityColor;

    switch (sleepQuality) {
      case 5:
        qualityText = 'Excellent';
        qualityColor = Colors.green;
        break;
      case 4:
        qualityText = 'Good';
        qualityColor = Colors.lightGreen;
        break;
      case 3:
        qualityText = 'Average';
        qualityColor = Colors.orange;
        break;
      case 2:
        qualityText = 'Poor';
        qualityColor = Colors.deepOrange;
        break;
      case 1:
      default:
        qualityText = 'Very Poor';
        qualityColor = Colors.red;
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sleep Summary',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.bedtime, size: 36, color: Colors.blueAccent),
                SizedBox(width: 12),
                Text('${sleepHours.toStringAsFixed(1)} hrs',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 20),
            Text('Sleep Quality', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: sleepQuality / 5,
              backgroundColor: Colors.grey[300],
              color: qualityColor,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                '$qualityText',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: qualityColor),
              ),
            ),
            SizedBox(height: 20),
            if (sleepNotes.isNotEmpty) ...[
              Divider(),
              SizedBox(height: 8),
              Text('Sleep Notes', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text(
                sleepNotes.length > 120 ? sleepNotes.substring(0, 120) + '...' : sleepNotes,
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveAndExit();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sleep Entry'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _saveAndExit,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildSleepDashboard(),
              SizedBox(height: 24),

              // Sleep Hours Input
              Text('Adjust Sleep Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Slider(
                min: 0,
                max: 12,
                divisions: 24,
                value: sleepHours,
                label: '${sleepHours.toStringAsFixed(1)} hrs',
                onChanged: (value) {
                  setState(() {
                    sleepHours = value;
                  });
                },
              ),
              Center(
                child: Text('${sleepHours.toStringAsFixed(1)} hours', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 24),

              // Sleep Quality Input
              Text('Rate Sleep Quality', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Slider(
                min: 1,
                max: 5,
                divisions: 4,
                value: sleepQuality.toDouble(),
                label: '$sleepQuality / 5',
                onChanged: (value) {
                  setState(() {
                    sleepQuality = value.toInt();
                  });
                },
              ),
              Center(
                child: Text('Quality: $sleepQuality / 5', style: TextStyle(fontSize: 16)),
              ),

              SizedBox(height: 24),

              // Sleep Notes
              Text('Sleep Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'e.g. Trouble falling asleep, woke up once, good dreams...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

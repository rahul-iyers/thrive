import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';
import 'add_exercise_screen.dart';

class ExerciseTemplatesScreen extends StatefulWidget {
  @override
  _ExerciseTemplatesScreenState createState() => _ExerciseTemplatesScreenState();
}

class _ExerciseTemplatesScreenState extends State<ExerciseTemplatesScreen> {
  late Box<Exercise> templatesBox;

  @override
  void initState() {
    super.initState();
    templatesBox = Hive.box<Exercise>('exercise_templates');
  }

  void addTemplate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(
          onAdd: (newExercise) {
            templatesBox.add(newExercise);
            setState(() {});
          },
          showPickTemplateButton: false,
        ),
      ),
    );
  }

  void editTemplate(int index, Exercise oldExercise) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(
          onAdd: (updatedExercise) {
            templatesBox.putAt(index, updatedExercise);
            setState(() {});
          },
          exercise: oldExercise,
          showPickTemplateButton: false,
        ),
      ),
    );
  }

  void deleteTemplate(int index) {
    templatesBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final templates = templatesBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Exercises Templates'),
        actions: [
          IconButton(
            onPressed: addTemplate,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: templates.isEmpty
          ? Center(
        child: Text(
          'No templates yet.\nTap + to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: templates.length,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        itemBuilder: (context, index) {
          final exercise = templates[index];

          return Dismissible(
            key: UniqueKey(),
            background: Container(color: Colors.red),
            onDismissed: (_) => deleteTemplate(index),
            child: GestureDetector(
              onTap: () => editTemplate(index, exercise),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          exercise.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    // Sets, Reps, Weight
                    Text(
                      'Sets: ${exercise.sets}  Reps: ${exercise.reps}  Weight: ${exercise.weight}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    // Type
                    Text(
                      'Type: ${exercise.type} | ${exercise.minutes} min',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Notes (optional)
                    if (exercise.notes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Notes: ${exercise.notes}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

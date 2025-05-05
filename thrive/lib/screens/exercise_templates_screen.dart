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
          showPickTemplateButton: false, // ✅ Hide Pick Template when creating template
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
          showPickTemplateButton: false, // ✅ Hide Pick Template when editing template
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
        itemBuilder: (context, index) {
          final exercise = templates[index];
          return Dismissible(
            key: UniqueKey(),
            background: Container(color: Colors.red),
            onDismissed: (_) => deleteTemplate(index),
            child: ListTile(
              title: Text(exercise.name),
              subtitle: Text('${exercise.type} | ${exercise.minutes} min'),
              onTap: () => editTemplate(index, exercise),
            ),
          );
        },
      ),
    );
  }
}

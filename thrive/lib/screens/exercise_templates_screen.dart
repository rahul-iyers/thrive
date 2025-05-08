import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';
import '../widgets/add_exercise_dialog.dart';
import '../services/firestore_service.dart';

class ExerciseTemplatesScreen extends StatefulWidget {
  @override
  _ExerciseTemplatesScreenState createState() => _ExerciseTemplatesScreenState();
}

class _ExerciseTemplatesScreenState extends State<ExerciseTemplatesScreen> {
  late Box<Exercise> templatesBox;
  int? tappedIndex;

  @override
  void initState() {
    super.initState();
    templatesBox = Hive.box<Exercise>('exercise_templates');
  }

  void addTemplate() async {
    final newExercise = await showDialog<Exercise>(
      context: context,
      builder: (context) => AddExerciseDialog(),
    );

    if (newExercise != null) {
      await templatesBox.add(newExercise);
      setState(() {});
      await saveTemplatesToFirestore(context);
    }
  }

  void editTemplate(int index, Exercise oldExercise) async {
    setState(() {
      tappedIndex = index;
    });

    await Future.delayed(Duration(milliseconds: 150));

    final updatedExercise = await showDialog<Exercise>(
      context: context,
      builder: (context) => AddExerciseDialog(existingExercise: oldExercise),
    );

    if (updatedExercise != null) {
      await templatesBox.putAt(index, updatedExercise);
      setState(() {});
      await saveTemplatesToFirestore(context);
    }

    setState(() {
      tappedIndex = null;
    });
  }

  void confirmDeleteTemplate(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Template?'),
        content: Text('Are you sure you want to delete this exercise template?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await templatesBox.deleteAt(index);
              setState(() {});
              Navigator.pop(context);
              await saveTemplatesToFirestore(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = templatesBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Exercise Templates'),
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

          return GestureDetector(
            onTap: () => editTemplate(index, exercise),
            child: AnimatedScale(
              scale: tappedIndex == index ? 0.95 : 1.0,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeInOut,
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
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => confirmDeleteTemplate(index),
                              icon: Icon(Icons.close, size: 20),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Sets: ${exercise.sets}  Reps: ${exercise.reps}  Weight: ${exercise.weight}',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Type: ${exercise.type} | ${exercise.minutes} min',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
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

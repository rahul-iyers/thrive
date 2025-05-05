import 'package:flutter/material.dart';
import '../models/exercise.dart';
import 'add_exercise_screen.dart';

class ViewExercisesScreen extends StatefulWidget {
  final List<Exercise> exercises;
  final Function(List<Exercise>) onUpdate;

  ViewExercisesScreen({required this.exercises, required this.onUpdate});

  @override
  _ViewExercisesScreenState createState() => _ViewExercisesScreenState();
}

class _ViewExercisesScreenState extends State<ViewExercisesScreen> {
  late List<Exercise> exercisesCopy;

  @override
  void initState() {
    super.initState();
    exercisesCopy = List.from(widget.exercises);
  }

  void editExercise(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(
          onAdd: (updatedExercise) {
            setState(() {
              exercisesCopy[index] = updatedExercise;
            });
          },
          exercise: exercisesCopy[index],
        ),
      ),
    );
  }

  void deleteExercise(int index) {
    setState(() {
      exercisesCopy.removeAt(index);
    });
  }

  void viewNotes(String notes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notes'),
        content: Text(notes),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.onUpdate(exercisesCopy);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercises'),
      ),
      body: ListView.builder(
        itemCount: exercisesCopy.length,
        itemBuilder: (context, index) {
          final exercise = exercisesCopy[index];
          return Dismissible(
            key: UniqueKey(),
            background: Container(color: Colors.red),
            onDismissed: (_) => deleteExercise(index),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: ListTile(
                title: Text(exercise.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${exercise.type} - ${exercise.minutes} min' +
                          (exercise.sets > 0 ? ' | ${exercise.sets}x${exercise.reps} @ ${exercise.weight} lbs' : ''),
                    ),
                    if (exercise.notes.isNotEmpty)
                      TextButton(
                        onPressed: () => viewNotes(exercise.notes),
                        child: Text('View Notes'),
                      ),
                  ],
                ),
                onTap: () => editExercise(index),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class ExercisesScreen extends StatefulWidget {
  final Workout workout;

  ExercisesScreen({required this.workout});

  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late Workout workout;

  @override
  void initState() {
    super.initState();
    workout = widget.workout;
  }

  void addExercise(Exercise exercise) {
    setState(() {
      workout.exercises.add(exercise);
    });
  }

  void deleteExercise(int index) {
    setState(() {
      workout.exercises.removeAt(index);
    });
  }

  void _editExercise(int index, Exercise exercise) {
    setState(() {
      workout.exercises[index] = exercise;
    });
  }

  void _showAddExerciseDialog() {
    String name = '';
    int minutes = 0;
    int sets = 0;
    String reps = '';
    String weight = '';
    String notes = '';
    String type = 'Gym';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Exercise Name'),
                  onChanged: (val) => name = val,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Minutes'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => minutes = int.tryParse(val) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Sets'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => sets = int.tryParse(val) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Reps'),
                  onChanged: (val) => reps = val,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Weight'),
                  onChanged: (val) => weight = val,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Notes'),
                  onChanged: (val) => notes = val,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Type (Gym, Sport, Cardio)'),
                  onChanged: (val) => type = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  addExercise(Exercise(
                    name: name,
                    minutes: minutes,
                    sets: sets,
                    reps: reps,
                    weight: weight,
                    notes: notes,
                    type: type,
                  ));
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditExerciseDialog(int index, Exercise exercise) {
    String name = exercise.name;
    int minutes = exercise.minutes;
    int sets = exercise.sets;
    String reps = exercise.reps;
    String weight = exercise.weight;
    String notes = exercise.notes;
    String type = exercise.type;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Exercise'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Exercise Name'),
                  controller: TextEditingController(text: name),
                  onChanged: (val) => name = val,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Minutes'),
                  controller: TextEditingController(text: minutes.toString()),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => minutes = int.tryParse(val) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Sets'),
                  controller: TextEditingController(text: sets.toString()),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => sets = int.tryParse(val) ?? 0,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Reps'),
                  controller: TextEditingController(text: reps),
                  onChanged: (val) => reps = val,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Weight'),
                  controller: TextEditingController(text: weight),
                  onChanged: (val) => weight = val,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Notes'),
                  controller: TextEditingController(text: notes),
                  onChanged: (val) => notes = val,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Type'),
                  controller: TextEditingController(text: type),
                  onChanged: (val) => type = val,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _editExercise(index, Exercise(
                  name: name,
                  minutes: minutes,
                  sets: sets,
                  reps: reps,
                  weight: weight,
                  notes: notes,
                  type: type,
                ));
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${workout.name} Exercises'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: workout.exercises.isEmpty
                  ? Center(child: Text('No exercises yet.'))
                  : ListView.builder(
                itemCount: workout.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = workout.exercises[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(exercise.name),
                      subtitle: Text('${exercise.sets} sets • ${exercise.reps} reps'),
                      onTap: () => _showEditExerciseDialog(index, exercise),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteExercise(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _showAddExerciseDialog,
              child: Text('Add Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}

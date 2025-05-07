import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.create),
              title: Text('Create New Exercise'),
              onTap: () {
                Navigator.pop(context);
                _showManualAddExerciseDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text('Pick from Templates'),
              onTap: () {
                Navigator.pop(context);
                _showPickTemplateDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showManualAddExerciseDialog() {
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
          title: Text('Add New Exercise'),
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

  Future<bool> _showTemplatePreviewDialog(Exercise exercise) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add This Exercise?'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${exercise.name}', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Minutes: ${exercise.minutes}'),
                Text('Sets: ${exercise.sets}'),
                Text('Reps: ${exercise.reps}'),
                Text('Weight: ${exercise.weight}'),
                Text('Type: ${exercise.type}'),
                if (exercise.notes.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(exercise.notes),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Add Exercise'),
            ),
          ],
        );
      },
    ) ?? false;
  }


  void _showPickTemplateDialog() async {
    final templatesBox = Hive.box<Exercise>('exercise_templates');
    final templates = templatesBox.values.toList();

    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No templates available')),
      );
      return;
    }

    final selectedExercise = await showDialog<Exercise>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick a Template'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final exercise = templates[index];
                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text('${exercise.sets} sets, ${exercise.reps} reps'),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirmed = await _showTemplatePreviewDialog(exercise);
                    if (confirmed) {
                      addExercise(Exercise(
                        name: exercise.name,
                        minutes: exercise.minutes,
                        sets: exercise.sets,
                        reps: exercise.reps,
                        weight: exercise.weight,
                        notes: exercise.notes,
                        type: exercise.type,
                      ));
                    }
                  },
                );
              },
            ),
          ),
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
                  controller: TextEditingController(text: name),
                  decoration: InputDecoration(labelText: 'Exercise Name'),
                  onChanged: (val) => name = val,
                ),
                TextField(
                  controller: TextEditingController(text: minutes.toString()),
                  decoration: InputDecoration(labelText: 'Minutes'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => minutes = int.tryParse(val) ?? 0,
                ),
                TextField(
                  controller: TextEditingController(text: sets.toString()),
                  decoration: InputDecoration(labelText: 'Sets'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => sets = int.tryParse(val) ?? 0,
                ),
                TextField(
                  controller: TextEditingController(text: reps),
                  decoration: InputDecoration(labelText: 'Reps'),
                  onChanged: (val) => reps = val,
                ),
                TextField(
                  controller: TextEditingController(text: weight),
                  decoration: InputDecoration(labelText: 'Weight'),
                  onChanged: (val) => weight = val,
                ),
                TextField(
                  controller: TextEditingController(text: notes),
                  decoration: InputDecoration(labelText: 'Notes'),
                  onChanged: (val) => notes = val,
                ),
                TextField(
                  controller: TextEditingController(text: type),
                  decoration: InputDecoration(labelText: 'Type'),
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
